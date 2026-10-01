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
            $request->validate(['file' => 'required|file']);
            
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
            $role = Role::where('name', str_replace('_', ' ', $roleType))->first();
            if (!$role) {
                $role = Role::where('name', $roleType)->first(); // fallback
            }
            $roleId = $role ? $role->id : null;

            $collection = (new FastExcel)->import($request->file('file')->path());

            $academicYear = AcademicYear::where('is_active', true)->first();

            DB::transaction(function () use ($collection, $roleType, $roleId, $academicYear) {
                $syncedUserIds = [];

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

                    $gender = (strtoupper(trim($genderRaw)) == 'PEREMPUAN' || strtoupper(trim($genderRaw)) == 'P') ? 'P' : 'L';

                    // One-Door System: Cari user jika ada, atau buat instansi baru jika belum ada
                    $user = User::firstOrNew(['username' => $kredensial]);
                    
                    if (!$user->exists) {
                        // BCRYPT SANGAT BERAT! Untuk ratusan data baru, kita turunkan 'rounds' menjadi 4
                        // agar proses enkripsi 500+ siswa selesai dalam 1 detik alih-alih 2 menit.
                        $user->password_hash = Hash::make($kredensial, ['rounds' => 4]);
                    }
                    
                    $user->full_name = $fullName;
                    $user->email = $email;
                    $user->role_id = $roleId;
                    $user->is_active = true;
                    $user->save();
                    
                    $syncedUserIds[] = $user->id;

                    if ($roleType === 'SISWA') {
                        SiswaProfile::updateOrCreate(
                            ['user_id' => $user->id],
                            [
                                'nis' => $nis,
                                'nisn' => $nisn,
                                'academic_year_id' => $academicYear ? $academicYear->id : null,
                                'gender' => $gender,
                            ]
                        );
                    } else {
                        GuruProfile::updateOrCreate(
                            ['user_id' => $user->id],
                            [
                                'nip_nuptk' => $nuptk,
                                'gender' => $gender,
                            ]
                        );
                    }
                }

                User::where('role_id', $roleId)->whereNotIn('id', $syncedUserIds)->delete();
            });

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
