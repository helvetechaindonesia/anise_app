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

    public function parseUser(Request $request, $type)
    {
        // Hilangkan batasan waktu eksekusi
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

                // Perlindungan: Jangan hapus akun user yang sedang login saat ini atau akun admin/tu_dev
                $deleteQuery = User::where('role_id', $roleId)->whereNotIn('id', $syncedUserIds);
                if ($currentUserId) {
                    $deleteQuery->where('id', '!=', $currentUserId);
                }
                $deleteQuery->whereNotIn('username', ['tu_dev', 'admin', 'administrator'])->delete();
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
