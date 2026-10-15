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
use App\Services\NotificationService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ExcelParserUserController extends Controller
{
    use ApiResponser;

    /**
     * Membaca nama-nama sheet dari berkas Excel .xlsx langsung dari archive zip.
     */
    private function getExcelSheetNames(?string $filePath): array
    {
        if (!$filePath || !class_exists('\ZipArchive')) {
            return [];
        }
        $sheetNames = [];
        try {
            $zip = new \ZipArchive();
            if ($zip->open($filePath) === true) {
                $xml = $zip->getFromName('xl/workbook.xml');
                if ($xml && preg_match_all('/<sheet[^>]*name="([^"]+)"/i', $xml, $matches)) {
                    $sheetNames = $matches[1];
                }
                $zip->close();
            }
        } catch (\Throwable $e) {
            // Abaikan jika bukan format zip standar
        }
        return $sheetNames;
    }

    /**
     * Memvalidasi apakah isi berkas Excel cocok dengan tipe role pengguna yang dipilih.
     */
    private function validateUserFileContent($collection, string $roleType, ?string $filePath = null): ?string
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

        // Sertakan nama sheet Excel jika tersedia
        $sheetNames = $this->getExcelSheetNames($filePath);
        $textLower = strtolower($textBlob . ' ' . implode(' ', $sheetNames));

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
            $hasGtkIndicator = str_contains($textLower, 'nuptk') || str_contains($textLower, 'guru pengajar') || str_contains($textLower, 'guru bk') || str_contains($textLower, 'kepala sekolah') || str_contains($textLower, 'tata usaha');

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

            // Indikator khusus masing-masing tipe GTK
            $isBkFile = str_contains($textLower, 'guru bk') 
                || str_contains($textLower, 'guru_bk') 
                || str_contains($textLower, 'bimbingan konseling') 
                || str_contains($textLower, 'bimbingan dan konseling')
                || preg_match('/\b(bk|guru\s*bk)\b/i', $textLower);

            $isGuruPengajarFile = str_contains($textLower, 'guru pengajar') 
                || str_contains($textLower, 'guru_pengajar') 
                || str_contains($textLower, 'guru mata pelajaran')
                || str_contains($textLower, 'guru mapel');

            if ($roleType === 'GURU') {
                if ($isBkFile) {
                    return 'Berkas ditolak! Anda memilih impor Guru Pengajar, tetapi berkas terdeteksi sebagai data Guru BK (Bimbingan Konseling).';
                }
                if (str_contains($textLower, 'staff tata usaha') || str_contains($textLower, 'staf tata usaha')) {
                    return 'Berkas ditolak! Anda memilih impor Guru Pengajar, tetapi berkas terdeteksi sebagai data Staf Tata Usaha.';
                }
                if (str_contains($textLower, 'kepala sekolah')) {
                    return 'Berkas ditolak! Anda memilih impor Guru Pengajar, tetapi berkas terdeteksi sebagai data Kepala Sekolah.';
                }
            } elseif ($roleType === 'GURU_BK') {
                if ($isGuruPengajarFile && !$isBkFile) {
                    return 'Berkas ditolak! Anda memilih impor Guru BK, tetapi berkas terdeteksi sebagai data Guru Pengajar (tidak memuat tanda Guru BK).';
                }
                if (str_contains($textLower, 'staff tata usaha') || str_contains($textLower, 'staf tata usaha')) {
                    return 'Berkas ditolak! Anda memilih impor Guru BK, tetapi berkas terdeteksi sebagai data Staf Tata Usaha.';
                }
                if (str_contains($textLower, 'kepala sekolah')) {
                    return 'Berkas ditolak! Anda memilih impor Guru BK, tetapi berkas terdeteksi sebagai data Kepala Sekolah.';
                }
                if (!$isBkFile) {
                    return 'Berkas ditolak! Berkas ini tidak terdeteksi sebagai data Guru BK (kata kunci "Guru BK" atau "Bimbingan Konseling" tidak ditemukan pada judul baris 1 atau sheet).';
                }
            } elseif ($roleType === 'TATA_USAHA') {
                if ($isGuruPengajarFile || $isBkFile) {
                    return 'Berkas ditolak! Anda memilih impor Staf Tata Usaha, tetapi berkas terdeteksi sebagai data Guru.';
                }
                if (str_contains($textLower, 'kepala sekolah') && !str_contains($textLower, 'tata usaha')) {
                    return 'Berkas ditolak! Anda memilih impor Staf Tata Usaha, tetapi berkas terdeteksi sebagai data Kepala Sekolah.';
                }
            } elseif ($roleType === 'KEPALA_SEKOLAH') {
                if (!str_contains($textLower, 'kepala sekolah') && !str_contains($textLower, 'kepsek')) {
                    return 'Berkas ditolak! Anda memilih impor Kepala Sekolah, tetapi berkas terdeteksi sebagai data Guru/Staf.';
                }
            }

            // Cek minimal indikator data GTK / Pegawai
            $hasGtkOrUser = str_contains($textLower, 'nuptk') || str_contains($textLower, 'nip') || str_contains($textLower, 'kredensial') || str_contains($textLower, 'username') || str_contains($textLower, 'nama lengkap') || str_contains($textLower, 'nama');
            if (!$hasGtkOrUser) {
                return 'Berkas ditolak! Format berkas tidak sesuai untuk data ' . str_replace('_', ' ', $roleType) . ' (kolom Nama / Kredensial / NUPTK tidak ditemukan).';
            }
        }

        return null; // Lolos verifikasi
    }

    /**
     * Memvalidasi kelengkapan kolom wajib (Nama, Kredensial, Email) per baris data.
     */
    private function validateRequiredColumns($collection, string $roleType): array
    {
        if ($collection->isEmpty()) {
            return [
                'errors' => [],
                'colMap' => [],
                'hasHeadersInFirstValues' => false,
            ];
        }

        $firstRowArray = (array)$collection->first();
        $keys = array_keys($firstRowArray);
        $headerRowValues = array_values($firstRowArray);

        $valuesLower = strtolower(implode(' ', $headerRowValues));
        $hasHeadersInFirstValues = str_contains($valuesLower, 'nama') && str_contains($valuesLower, 'kredensial');

        // Default fallback mapping
        $colMap = [
            'name' => 0,
            'kredensial' => 1,
            'nuptk' => 2,
            'nis' => 2,
            'nisn' => 3,
            'email' => ($roleType === 'SISWA') ? 4 : 3,
            'gender' => ($roleType === 'SISWA') ? 7 : 5,
        ];

        $headerList = $hasHeadersInFirstValues ? $headerRowValues : $keys;
        foreach ($headerList as $idx => $hdr) {
            $cleanHdr = strtolower(trim(preg_replace('/[^a-zA-Z0-9]/', '', (string)$hdr)));
            if (in_array($cleanHdr, ['namalengkap', 'nama', 'fullname', 'name', 'namapesertadidik', 'namaguru'])) {
                $colMap['name'] = $idx;
            } elseif (in_array($cleanHdr, ['kredensial', 'username', 'kredensialpengguna', 'user', 'idpengguna'])) {
                $colMap['kredensial'] = $idx;
            } elseif (in_array($cleanHdr, ['email', 'surel', 'alamatemail', 'mail'])) {
                $colMap['email'] = $idx;
            } elseif (in_array($cleanHdr, ['nis'])) {
                $colMap['nis'] = $idx;
            } elseif (in_array($cleanHdr, ['nisn'])) {
                $colMap['nisn'] = $idx;
            } elseif (in_array($cleanHdr, ['nuptk', 'nuptknik', 'nik', 'nipnuptk', 'nip'])) {
                $colMap['nuptk'] = $idx;
            } elseif (in_array($cleanHdr, ['gender', 'jeniskelamin', 'jk', 'sex'])) {
                $colMap['gender'] = $idx;
            }
        }

        $rowErrors = [];
        $isFirst = true;

        foreach ($collection as $index => $row) {
            // Lewati baris header jika baris 1 di file adalah banner judul
            if ($hasHeadersInFirstValues && $isFirst) {
                $isFirst = false;
                continue;
            }

            $rowValues = array_values((array)$row);

            // Cek apakah seluruh baris ini kosong
            $hasAnyData = false;
            foreach ($rowValues as $v) {
                if ($v !== null && trim((string)$v) !== '') {
                    $hasAnyData = true;
                    break;
                }
            }
            if (!$hasAnyData) {
                continue; // Lewati baris kosong di akhir sheet
            }

            // Nomor baris riil di file Excel (Baris 1 judul, Baris 2 header, dst)
            $excelRowNum = $hasHeadersInFirstValues ? ($index + 2) : ($index + 2);

            $rawName = isset($rowValues[$colMap['name']]) ? trim((string)$rowValues[$colMap['name']]) : '';
            $rawKredensial = isset($rowValues[$colMap['kredensial']]) ? trim((string)$rowValues[$colMap['kredensial']]) : '';
            $rawEmail = isset($rowValues[$colMap['email']]) ? trim((string)$rowValues[$colMap['email']]) : '';

            $missingFields = [];
            if ($rawName === '') {
                $missingFields[] = 'Nama Lengkap';
            }
            if ($rawKredensial === '') {
                $missingFields[] = 'Kredensial';
            }
            if ($rawEmail === '') {
                $missingFields[] = 'Email';
            }

            if (!empty($missingFields)) {
                $identifier = '';
                if ($rawName !== '') {
                    $identifier = " ({$rawName})";
                } elseif ($rawKredensial !== '') {
                    $identifier = " (Kredensial: {$rawKredensial})";
                }

                $rowErrors[] = "Baris {$excelRowNum}{$identifier}: Kolom " . implode(' & ', $missingFields) . " belum diisi.";
            }
        }

        return [
            'errors' => $rowErrors,
            'colMap' => $colMap,
            'hasHeadersInFirstValues' => $hasHeadersInFirstValues,
        ];
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
            $contentError = $this->validateUserFileContent($collection, $roleType, $file->path());
            if ($contentError !== null) {
                return $this->error($contentError, 422);
            }

            // Validasi keketatan kolom wajib (Nama, Kredensial, Email)
            $validation = $this->validateRequiredColumns($collection, $roleType);
            $columnErrors = $validation['errors'] ?? [];

            if (!empty($columnErrors)) {
                $currentUser = $request->user();
                $userId = $currentUser?->id ?? User::where('username', 'tu_dev')->first()?->id ?? User::first()?->id;

                if ($userId) {
                    $notifTitle = '⚠️ Impor Data ' . str_replace('_', ' ', $roleType) . ' Ditolak';
                    $totalErr = count($columnErrors);
                    $errorSlice = array_slice($columnErrors, 0, 15);
                    $detailList = implode("\n• ", $errorSlice);
                    if ($totalErr > 15) {
                        $detailList .= "\n... dan " . ($totalErr - 15) . " baris lainnya.";
                    }

                    $notifMessage = "Berkas impor data " . str_replace('_', ' ', $roleType) . " ditolak karena terdapat kolom wajib (Nama Lengkap, Kredensial, atau Email) yang belum terisi pada {$totalErr} baris data:\n\n• " . $detailList . "\n\nSilakan perbaiki baris data di atas pada berkas Excel Anda lalu unggah kembali.";

                    NotificationService::sendInAppNotification($userId, $notifTitle, $notifMessage);
                }

                $countErr = count($columnErrors);
                return $this->error(
                    "Berkas ditolak! Ditemukan {$countErr} baris data yang belum lengkap (Nama, Email, atau Kredensial kosong). Silakan cek detail baris yang perlu diperbaiki di Halaman Notifikasi.",
                    422
                );
            }

            $academicYear = AcademicYear::where('is_active', true)->first();
            $currentUserId = $request->user()?->id;

            $syncedUserIds = [];
            $colMap = $validation['colMap'];
            $hasHeadersInFirstValues = $validation['hasHeadersInFirstValues'];

            DB::transaction(function () use ($collection, $roleType, $roleId, $academicYear, $currentUserId, $colMap, $hasHeadersInFirstValues, &$syncedUserIds) {
                $isFirst = true;
                foreach ($collection as $row) {
                    if ($hasHeadersInFirstValues && $isFirst) {
                        $isFirst = false;
                        continue;
                    }

                    $values = array_values((array)$row);
                    
                    $fullName = isset($values[$colMap['name']]) ? trim((string)$values[$colMap['name']]) : null;
                    $kredensial = isset($values[$colMap['kredensial']]) ? trim((string)$values[$colMap['kredensial']]) : null;
                    $email = isset($values[$colMap['email']]) ? trim((string)$values[$colMap['email']]) : null;
                    
                    if (empty($fullName) || empty($kredensial) || empty($email)) continue;

                    if ($roleType === 'SISWA') {
                        $nis = isset($values[$colMap['nis']]) ? trim((string)$values[$colMap['nis']]) : null;
                        $nisn = isset($values[$colMap['nisn']]) ? trim((string)$values[$colMap['nisn']]) : null;
                        $genderRaw = $values[$colMap['gender']] ?? 'L';
                    } else {
                        $nuptk = isset($values[$colMap['nuptk']]) ? trim((string)$values[$colMap['nuptk']]) : null;
                        $genderRaw = $values[$colMap['gender']] ?? 'L';
                    }

                    $gender = (strtoupper(trim((string)$genderRaw)) == 'PEREMPUAN' || strtoupper(trim((string)$genderRaw)) == 'P') ? 'P' : 'L';

                    // One-Door System: Cari user jika ada, atau buat instansi baru jika belum ada
                    $user = User::firstOrNew(['username' => $kredensial]);
                    
                    if (!$user->exists) {
                        $user->password_hash = Hash::make((string)$kredensial, ['rounds' => 4]);
                    }
                    
                    $user->full_name = $fullName;
                    $user->email = $email;
                    $user->role_id = $roleId;
                    $user->gender = $gender;
                    $user->is_active = true;
                    $user->save();
                    
                    $syncedUserIds[] = $user->id;

                    if ($roleType === 'SISWA') {
                        SiswaProfile::updateOrCreate(
                            ['user_id' => $user->id],
                            [
                                'nis' => $nis ? (string)$nis : null,
                                'nisn' => $nisn ? (string)$nisn : null,
                                'academic_year_id' => $academicYear ? $academicYear->id : null,
                            ]
                        );
                    } else {
                        GuruProfile::updateOrCreate(
                            ['user_id' => $user->id],
                            [
                                'nip_nuptk' => $nuptk ? (string)$nuptk : null,
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
