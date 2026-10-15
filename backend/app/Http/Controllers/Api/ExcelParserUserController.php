<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Rap2hpoutre\FastExcel\FastExcel;
use App\Traits\ApiResponser;
use App\Models\User;
use App\Models\Role;
use App\Models\SiswaProfile;
use App\Models\GuruProfile;
use App\Models\AcademicYear;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ExcelParserUserController extends Controller
{
    use ApiResponser;

    /**
     * Memvalidasi apakah isi berkas Excel cocok dengan tipe role pengguna yang dipilih.
     */
    private function validateUserFileContent($collection, string $roleType): ?string
    {
        // Kumpulkan teks dari 3 baris pertama untuk identifikasi template
        $textBlob = '';
        $rowCount = 0;
        foreach ($collection as $row) {
            $rowArr = (array)$row;
            $textBlob .= ' ' . implode(' ', array_keys($rowArr)) . ' ' . implode(' ', array_values($rowArr));
            $rowCount++;
            if ($rowCount >= 3) break;
        }
        $textLower = strtolower($textBlob);

        // 1. Cek jika berkas ternyata milik modul manajemen sekolah
        if (str_contains($textLower, 'areatugas') || str_contains($textLower, 'area tugas') || (str_contains($textLower, 'jabatan') && !str_contains($textLower, 'kredensial') && !str_contains($textLower, 'nuptk'))) {
            return 'Berkas ditolak! Berkas ini terdeteksi sebagai Master Jabatan, bukan data pengguna.';
        }
        if ((str_contains($textLower, 'isguruwali') || str_contains($textLower, 'is_guru_wali') || str_contains($textLower, 'peran')) && !str_contains($textLower, 'kredensial') && !str_contains($textLower, 'nama lengkap')) {
            return 'Berkas ditolak! Berkas ini terdeteksi sebagai Master Role, bukan data pengguna.';
        }
        if ((str_contains($textLower, 'tingkat') || str_contains($textLower, 'rombel')) && !str_contains($textLower, 'kredensial') && !str_contains($textLower, 'nisn')) {
            return 'Berkas ditolak! Berkas ini terdeteksi sebagai Master Kelas, bukan data pengguna.';
        }

        // 2. Cek kecocokan antar jenis user (Siswa vs Guru/GTK)
        if ($roleType === 'SISWA') {
            $hasSiswaIndicator = str_contains($textLower, 'nisn') || str_contains($textLower, 'nis') || str_contains($textLower, 'data siswa');
            $hasGtkIndicator = str_contains($textLower, 'nuptk') || str_contains($textLower, 'guru pengajar') || str_contains($textLower, 'kepala sekolah') || str_contains($textLower, 'tata usaha');

            if ($hasGtkIndicator && !$hasSiswaIndicator) {
                return 'Berkas ditolak! Anda memilih impor Siswa, tetapi berkas yang diunggah terdeteksi sebagai data Guru / GTK.';
            }
            if (!$hasSiswaIndicator && !str_contains($textLower, 'nama lengkap') && !str_contains($textLower, 'nama')) {
                return 'Berkas ditolak! Struktur berkas tidak sesuai untuk data Siswa (kolom NIS/NISN tidak ditemukan).';
            }
        } else {
            // GTK (Guru, Guru BK, Staff TU, Kepsek)
            $hasSiswaIndicator = (str_contains($textLower, 'nisn') || str_contains($textLower, 'data siswa')) && !str_contains($textLower, 'nuptk');
            if ($hasSiswaIndicator) {
                return 'Berkas ditolak! Anda memilih impor data ' . str_replace('_', ' ', $roleType) . ', tetapi berkas yang diunggah terdeteksi sebagai data Siswa (memuat NIS/NISN).';
            }

            // Deteksi spesifik jika judul template tertulis peran lain
            if ($roleType === 'GURU' && str_contains($textLower, 'data staff tata usaha')) {
                return 'Berkas ditolak! Anda memilih impor Guru, tetapi berkas terdeteksi sebagai data Staf Tata Usaha.';
            }
            if ($roleType === 'TATA_USAHA' && str_contains($textLower, 'data guru pengajar')) {
                return 'Berkas ditolak! Anda memilih impor Staf Tata Usaha, tetapi berkas terdeteksi sebagai data Guru Pengajar.';
            }
            if ($roleType === 'KEPALA_SEKOLAH' && !str_contains($textLower, 'kepala sekolah') && (str_contains($textLower, 'data guru pengajar') || str_contains($textLower, 'data staff'))) {
                return 'Berkas ditolak! Anda memilih impor Kepala Sekolah, tetapi berkas terdeteksi sebagai data Guru/Staf.';
            }

            // Cek minimal indikator data GTK / Pegawai
            $hasGtkOrUser = str_contains($textLower, 'nuptk') || str_contains($textLower, 'nip') || str_contains($textLower, 'kredensial') || str_contains($textLower, 'username') || str_contains($textLower, 'nama lengkap') || str_contains($textLower, 'nama');
            if (!$hasGtkOrUser) {
                return 'Berkas ditolak! Format berkas tidak sesuai untuk data ' . str_replace('_', ' ', $roleType) . ' (kolom Nama / Kredensial / NUPTK tidak ditemukan).';
            }
        }

        return null; // Lolos verifikasi
    }

    public function parseUser(Request $request, $type)
    {
        set_time_limit(0);

        try {
            if (!$request->hasFile('file')) {
                return $this->error('Berkas wajib diunggah!', 422);
            }

            $file = $request->file('file');
            $ext = strtolower($file->getClientOriginalExtension());
            $mime = strtolower($file->getClientMimeType());

            // Tolak jika PDF atau non-excel
            if ($ext === 'pdf' || str_contains($mime, 'pdf')) {
                return $this->error('Berkas PDF ditolak! Fitur ini hanya menerima berkas spreadsheet Excel (.xlsx / .xls).', 422);
            }

            if (!in_array($ext, ['xlsx', 'xls'])) {
                return $this->error('Format berkas ditolak! Harap unggah file spreadsheet Excel dengan format .xlsx atau .xls.', 422);
            }

            $roleMap = [
                'siswa' => 'SISWA',
                'guru' => 'GURU',
                'guru-bk' => 'GURU_BK',
                'staff-tu' => 'TATA_USAHA',
                'kepsek' => 'KEPALA_SEKOLAH',
            ];

            if (!isset($roleMap[$type])) {
                return $this->error('Tipe user tidak valid', 400);
            }

            $roleType = $roleMap[$type];
            $role = Role::where('name', $roleType)->first() 
                ?? Role::where('name', str_replace('_', ' ', $roleType))->first();

            if (!$role) {
                $role = Role::create(['name' => $roleType]);
            }
            $roleId = $role->id;

            $collection = (new FastExcel)->import($file->path());
            if ($collection->isEmpty()) {
                return $this->error('Berkas Excel kosong atau tidak memuat data yang valid!', 422);
            }

            // Validasi kecocokan isi template berkas dengan role yang dipilih
            $contentError = $this->validateUserFileContent($collection, $roleType);
            if ($contentError !== null) {
                return $this->error($contentError, 422);
            }

            $academicYear = AcademicYear::where('is_active', true)->first();
            $currentUserId = $request->user()?->id;

            $syncedUserIds = [];

            DB::transaction(function () use ($collection, $roleType, $roleId, $academicYear, $currentUserId, &$syncedUserIds) {
                $isFirst = true;
                foreach ($collection as $row) {
                    if ($isFirst) {
                        $isFirst = false;
                        continue;
                    }

                    $values = array_values((array)$row);
                    
                    $fullName = $values[0] ?? null;
                    $kredensial = $values[1] ?? null;
                    
                    if (empty($fullName) || empty($kredensial)) continue;

                    if ($roleType === 'SISWA') {
                        $nis = $values[2] ?? null;
                        $nisn = $values[3] ?? null;
                        $email = $values[4] ?? ($kredensial . '@siswa.com');
                        $genderRaw = $values[7] ?? 'L';
                    } else {
                        $nuptk = $values[2] ?? null;
                        $email = $values[3] ?? ($kredensial . '@sekolah.com');
                        $genderRaw = $values[5] ?? 'L';
                    }

                    $gender = (strtoupper(trim((string)$genderRaw)) == 'PEREMPUAN' || strtoupper(trim((string)$genderRaw)) == 'P') ? 'P' : 'L';

                    // One-Door System: Cari user jika ada, atau buat instansi baru jika belum ada
                    $user = User::firstOrNew(['username' => $kredensial]);
                    
                    if (!$user->exists) {
                        $user->password_hash = Hash::make((string)$kredensial, ['rounds' => 4]);
                    }
                    
                    $user->full_name = trim((string)$fullName);
                    $user->email = trim((string)$email);
                    $user->role_id = $roleId;
                    $user->gender = $gender;
                    $user->is_active = true;
                    $user->save();
                    
                    $syncedUserIds[] = $user->id;

                    if ($roleType === 'SISWA') {
                        SiswaProfile::updateOrCreate(
                            ['user_id' => $user->id],
                            [
                                'nis' => $nis ? trim((string)$nis) : null,
                                'nisn' => $nisn ? trim((string)$nisn) : null,
                                'academic_year_id' => $academicYear ? $academicYear->id : null,
                            ]
                        );
                    } else {
                        GuruProfile::updateOrCreate(
                            ['user_id' => $user->id],
                            [
                                'nip_nuptk' => $nuptk ? trim((string)$nuptk) : null,
                            ]
                        );
                    }
                }

                // Perlindungan: Jangan hapus akun user jika data kosong, atau akun user yang sedang login saat ini, atau akun admin/tu_dev
                if (count($syncedUserIds) > 0) {
                    $deleteQuery = User::where('role_id', $roleId)->whereNotIn('id', $syncedUserIds);
                    if ($currentUserId) {
                        $deleteQuery->where('id', '!=', $currentUserId);
                    }
                    $deleteQuery->whereNotIn('username', ['tu_dev', 'admin', 'administrator'])->delete();
                }
            });

            if (count($syncedUserIds) === 0) {
                return $this->error('Berkas ditolak! Tidak ditemukan data pengguna yang cocok untuk role ini.', 422);
            }

            return $this->success(null, 'Data ' . strtoupper($type) . ' berhasil disinkronisasi!');
        } catch (\Throwable $e) {
            \Log::error('Excel Parse Error: ' . $e->getMessage() . ' at line ' . $e->getLine());
            return response()->json([
                'status' => 'error',
                'message' => 'Exception: ' . $e->getMessage(),
                'line' => $e->getLine()
            ], 500);
        }
    }
}
