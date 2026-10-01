<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Rap2hpoutre\FastExcel\FastExcel;
use Illuminate\Support\Facades\DB;
use App\Traits\ApiResponser;

use App\Models\Subject;
use App\Models\Schedule;
use App\Models\StructuralAssignment;
use App\Models\SchoolClass;
use App\Models\Jabatan;
use App\Models\AcademicYear;
use App\Models\User;

class ExcelParserKurikulumController extends Controller
{
    use ApiResponser;

    public function parseKurikulum(Request $request, $type)
    {
        set_time_limit(0);

        try {
            $request->validate(['file' => 'required|file']);
            
            $collection = (new FastExcel)->import($request->file('file')->path());
            $academicYear = AcademicYear::where('is_active', true)->first();

            $errors = [];

            DB::transaction(function () use ($collection, $type, $academicYear, &$errors) {
                if ($type === 'mapel') {
                    $errors = $this->parseMapel($collection);
                } elseif ($type === 'jurnal_mengajar') {
                    $errors = $this->parseJurnalMengajar($collection, $academicYear);
                } elseif ($type === 'penugasan') {
                    $errors = $this->parsePenugasan($collection, $academicYear);
                } elseif ($type === 'wali_kelas') {
                    $errors = $this->parseWaliKelas($collection);
                } elseif ($type === 'guru_wali') {
                    $errors = $this->parseGuruWali($collection, $academicYear);
                } else {
                    throw new \Exception("Tipe kurikulum tidak valid: $type");
                }
                
                if (!empty($errors)) {
                    throw new \Exception(json_encode($errors));
                }
            });

            return $this->success(null, 'Data ' . strtoupper(str_replace('_', ' ', $type)) . ' berhasil disinkronisasi!');
        } catch (\Throwable $e) {
            $msg = $e->getMessage();
            $decoded = json_decode($msg, true);
            if (is_array($decoded)) {
                $errorMsg = "Validasi gagal:\n" . implode("\n", array_slice($decoded, 0, 5));
                if (count($decoded) > 5) {
                    $errorMsg .= "\n...dan " . (count($decoded) - 5) . " error lainnya.";
                }
                return response()->json([
                    'status' => 'error',
                    'message' => $errorMsg,
                    'errors' => $decoded
                ], 400);
            }

            \Log::error('Excel Parse Error Kurikulum: ' . $msg . ' at line ' . $e->getLine());
            return response()->json([
                'status' => 'error',
                'message' => 'Exception: ' . $msg,
                'line' => $e->getLine()
            ], 500);
        }
    }

    private function parseMapel($collection)
    {
        $errors = [];
        $rowNum = 1;
        // Headers di Row 1
        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);
            
            $namaMapel = $values[0] ?? null;
            $kodeMapel = $values[1] ?? null;

            if (empty($namaMapel) || empty($kodeMapel)) {
                $errors[] = "Baris $rowNum: Nama/Kode Mapel kosong.";
                continue;
            }

            Subject::updateOrCreate(
                ['code' => $kodeMapel],
                ['name' => $namaMapel]
            );
        }
        return $errors;
    }

    private function parseJurnalMengajar($collection, $academicYear)
    {
        $errors = [];
        $rowNum = 1;
        // Headers di Row 1, kita baca dari row 2
        // Hari(0), Jam ke-(1), Jam Mulai(2), Jam Selesai(3), Tingkat(4), Nama Kelas(5), Kode Mapel(6), Nama Mata Pelajaran(7), Nama Tendik(8), NUPTK(9)
        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);
            
            $hari = $values[0] ?? null;
            if (empty($hari)) continue;

            $jamMulai = $this->formatTime($values[2] ?? null);
            $jamSelesai = $this->formatTime($values[3] ?? null);
            $namaKelas = $values[5] ?? null;
            $kodeMapel = $values[6] ?? null;
            $nuptk = $values[9] ?? null;

            if (empty($jamMulai) || empty($jamSelesai) || empty($namaKelas) || empty($kodeMapel)) {
                $errors[] = "Baris $rowNum: Data jam/kelas/mapel tidak lengkap.";
                continue;
            }

            $class = SchoolClass::whereRaw("CONCAT(grade_level, ' ', name) = ?", [$namaKelas])
                                ->orWhere('name', $namaKelas)
                                ->first();

            if (!$class) {
                $errors[] = "Baris $rowNum: Kelas '$namaKelas' tidak ditemukan.";
                continue;
            }

            $subjectId = null;
            $teacherId = null;
            $activityName = null;

            if ($kodeMapel === 'KEG') {
                $activityName = $values[7] ?? 'Kegiatan Sekolah'; // Nama Mata Pelajaran as activity name
            } else {
                if (empty($nuptk) || $nuptk === '-') {
                    $errors[] = "Baris $rowNum: NUPTK wajib diisi untuk mapel reguler.";
                    continue;
                }
                
                $subject = Subject::where('code', $kodeMapel)->first();
                $teacher = User::where('username', $nuptk)->first();

                if (!$subject) $errors[] = "Baris $rowNum: Mapel '$kodeMapel' tidak ditemukan.";
                if (!$teacher) $errors[] = "Baris $rowNum: NUPTK '$nuptk' tidak ditemukan di master user.";

                if (!$subject || !$teacher) continue;

                $subjectId = $subject->id;
                $teacherId = $teacher->id;
            }

            Schedule::updateOrCreate(
                [
                    'academic_year_id' => $academicYear ? $academicYear->id : null,
                    'class_id' => $class->id,
                    'day_of_week' => $hari,
                    'start_time' => $jamMulai,
                ],
                [
                    'end_time' => $jamSelesai,
                    'subject_id' => $subjectId,
                    'teacher_id' => $teacherId,
                    'activity_name' => $activityName,
                ]
            );
        }
        return $errors;
    }

    private function parsePenugasan($collection, $academicYear)
    {
        $errors = [];
        $rowNum = 1;
        // Judul di Row 1, Headers di Row 2. Kita skip row 1.
        // Nama Tendik(0), Tugas Tambahan(1), Area Penugasan(2)
        $isFirst = true;
        foreach ($collection as $row) {
            $rowNum++;
            if ($isFirst) {
                $isFirst = false;
                continue;
            }

            $values = array_values((array)$row);
            $namaTendik = $values[0] ?? null;
            $tugasTambahan = $values[1] ?? null;
            
            if (empty($namaTendik) || empty($tugasTambahan) || $namaTendik === 'Nama Tendik') {
                continue; // Kosong atau header kedua
            }

            $user = User::where('full_name', $namaTendik)->first();
            $jabatan = Jabatan::where('name', $tugasTambahan)->first();

            if (!$user) $errors[] = "Baris $rowNum: Nama '$namaTendik' tidak ditemukan di master user.";
            if (!$jabatan) $errors[] = "Baris $rowNum: Jabatan '$tugasTambahan' tidak ada di master jabatan.";

            if ($user && $jabatan) {
                StructuralAssignment::updateOrCreate(
                    [
                        'guru_id' => $user->id,
                        'academic_year_id' => $academicYear ? $academicYear->id : null,
                    ],
                    [
                        'jabatan_id' => $jabatan->id,
                    ]
                );
            }
        }
        return $errors;
    }

    private function parseWaliKelas($collection)
    {
        $errors = [];
        $rowNum = 1;
        // Judul di Row 1, Headers di Row 2. Skip row 1.
        // Tingkat(0), Nama Kelas(1), Nama Wali Kelas(2), NUPTK/NIP Wali Kelas(3)
        $isFirst = true;
        foreach ($collection as $row) {
            $rowNum++;
            if ($isFirst) {
                $isFirst = false;
                continue;
            }

            $values = array_values((array)$row);
            $tingkat = $values[0] ?? null;
            $namaKelas = $values[1] ?? null;
            $nuptk = $values[3] ?? null;
            
            if (empty($tingkat) || empty($namaKelas) || empty($nuptk) || $tingkat === 'Tingkat') continue;

            $fullClassName = $tingkat . ' ' . $namaKelas;

            $class = SchoolClass::whereRaw("CONCAT(grade_level, ' ', name) = ?", [$fullClassName])
                                ->orWhere('name', $namaKelas)
                                ->first();
            $user = User::where('username', $nuptk)->first();

            if (!$class) $errors[] = "Baris $rowNum: Kelas '$fullClassName' tidak ditemukan.";
            if (!$user) $errors[] = "Baris $rowNum: NUPTK '$nuptk' tidak ditemukan di master user.";

            if ($class && $user) {
                $class->wali_kelas_id = $user->id;
                $class->save();
            }
        }
        return $errors;
    }

    private function parseGuruWali($collection, $academicYear)
    {
        $errors = [];
        $rowNum = 1;
        // Judul di Row 1, Headers di Row 2. Skip row 1.
        // Nama Siswa(0), NISN(1), Tingkat(2), Nama Kelas(3), Nama Guru BK(4)
        $isFirst = true;
        foreach ($collection as $row) {
            $rowNum++;
            if ($isFirst) {
                $isFirst = false;
                continue;
            }

            $values = array_values((array)$row);
            $namaSiswa = $values[0] ?? null;
            $nisn = $values[1] ?? null;
            $tingkat = $values[2] ?? null;
            $namaKelas = $values[3] ?? null;
            $namaGuruWali = $values[4] ?? null;
            
            if (empty($namaSiswa) || empty($nisn) || empty($tingkat) || empty($namaKelas) || $namaSiswa === 'Nama Siswa') continue;

            $fullClassName = $tingkat . ' ' . $namaKelas;

            $class = SchoolClass::whereRaw("CONCAT(grade_level, ' ', name) = ?", [$fullClassName])
                                ->orWhere('name', $namaKelas)
                                ->first();
            $student = User::where('username', $nisn)->first();

            if (!$class) $errors[] = "Baris $rowNum: Kelas '$fullClassName' tidak ditemukan.";
            if (!$student) $errors[] = "Baris $rowNum: NISN '$nisn' tidak ditemukan di master user.";

            if ($class && $student) {
                // Update class_id of student
                \App\Models\ClassStudent::updateOrCreate(
                    [
                        'student_id' => $student->id,
                    ],
                    [
                        'class_id' => $class->id,
                        'status' => 'ACTIVE'
                    ]
                );
            }

            if (!empty($namaGuruWali) && $student) {
                $guruWali = User::where('full_name', $namaGuruWali)->first();
                if (!$guruWali) {
                    $errors[] = "Baris $rowNum: Guru Wali '$namaGuruWali' tidak ditemukan di master user.";
                } else {
                    \App\Models\GuruWaliStudent::updateOrCreate(
                        [
                            'student_id' => $student->id,
                            'academic_year_id' => $academicYear ? $academicYear->id : null,
                        ],
                        [
                            'guru_id' => $guruWali->id,
                        ]
                    );
                }
            }
        }
        return $errors;
    }

    private function formatTime($val)
    {
        if (empty($val)) return null;
        if ($val instanceof \DateTimeInterface) {
            return $val->format('H:i:s');
        }
        return (string)$val;
    }
}
