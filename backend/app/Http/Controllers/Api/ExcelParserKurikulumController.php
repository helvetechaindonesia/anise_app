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
use App\Models\AcademicCalendar;
use App\Models\SchoolHoliday;

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
                } elseif ($type === 'kalender_akademik') {
                    $errors = $this->parseKalenderAkademik($collection, $academicYear);
                } elseif ($type === 'hari_libur') {
                    $errors = $this->parseHariLibur($collection, $academicYear);
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

    private function parseKalenderAkademik($collection, $academicYear)
    {
        $errors = [];
        $headerFound = false;
        $rowNum = 1;

        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);

            $val0 = $values[0] ?? '';
            $firstCol = strtolower(trim(($val0 instanceof \DateTimeInterface) ? $val0->format('Y-m-d') : (string)$val0));
            $val1 = $values[1] ?? '';
            $secondCol = strtolower(trim(($val1 instanceof \DateTimeInterface) ? $val1->format('Y-m-d') : (string)$val1));

            // 1. Deteksi Baris Header Kolom
            if (!$headerFound) {
                if ($firstCol === 'nama' && str_contains($secondCol, 'jenis')) {
                    $headerFound = true;
                }
                continue;
            }

            $nama = trim(($val0 instanceof \DateTimeInterface) ? $val0->format('Y-m-d') : (string)$val0);
            $jenisRaw = strtolower(trim(($val1 instanceof \DateTimeInterface) ? $val1->format('Y-m-d') : (string)$val1));
            $mulaiRaw = $values[2] ?? null;
            $selesaiRaw = $values[3] ?? null;
            $val4 = $values[4] ?? '';
            $tingkatRaw = strtoupper(trim(($val4 instanceof \DateTimeInterface) ? $val4->format('Y-m-d') : (string)$val4));

            // Skip jika baris benar-benar kosong
            if (empty($nama) && empty($jenisRaw) && empty($mulaiRaw)) {
                continue;
            }

            // Validasi Ketat: Nama Agenda
            if (empty($nama) || strlen($nama) < 3) {
                $errors[] = "Baris $rowNum: Nama agenda wajib diisi (minimal 3 karakter).";
                continue;
            }

            // Validasi Ketat: Jenis Agenda
            $validTypes = [
                'asesmen' => 'ASESMEN',
                'kegiatan' => 'KEGIATAN',
                'seremonial' => 'SEREMONIAL',
                'administrasi' => 'ADMINISTRASI',
                'libur' => 'LIBUR',
            ];
            if (!isset($validTypes[$jenisRaw])) {
                $errors[] = "Baris $rowNum: Jenis '$jenisRaw' tidak valid. Pilihan: asesmen, kegiatan, seremonial, administrasi.";
                continue;
            }
            $type = $validTypes[$jenisRaw];

            // Validasi Ketat: Tanggal Mulai & Selesai
            $start = $this->formatDate($mulaiRaw);
            $end = $this->formatDate($selesaiRaw) ?? $start;

            if (!$start || !$this->isValidDate($start)) {
                $errors[] = "Baris $rowNum: Format tanggal mulai tidak valid. Gunakan format DD/MM/YYYY.";
                continue;
            }
            if (!$end || !$this->isValidDate($end)) {
                $errors[] = "Baris $rowNum: Format tanggal selesai tidak valid. Gunakan format DD/MM/YYYY.";
                continue;
            }
            if ($end < $start) {
                $errors[] = "Baris $rowNum: Tanggal selesai ($end) tidak boleh mendahului tanggal mulai ($start).";
                continue;
            }

            // Validasi Ketat: Tingkat
            if (in_array($tingkatRaw, ['#', '*', 'ALL', 'SEMUA', ''])) {
                $tingkat = 'SEMUA';
            } elseif (in_array($tingkatRaw, ['X', '10'])) {
                $tingkat = 'X';
            } elseif (in_array($tingkatRaw, ['XI', '11'])) {
                $tingkat = 'XI';
            } elseif (in_array($tingkatRaw, ['XII', '12'])) {
                $tingkat = 'XII';
            } else {
                $errors[] = "Baris $rowNum: Tingkat '$tingkatRaw' tidak valid. Gunakan # (semua), X, XI, atau XII.";
                continue;
            }

            $isHoliday = ($type === 'LIBUR');

            AcademicCalendar::updateOrCreate(
                [
                    'name' => $nama,
                    'start_date' => $start,
                    'academic_year_id' => $academicYear ? $academicYear->id : null,
                ],
                [
                    'type' => $type,
                    'end_date' => $end,
                    'target_grade' => $tingkat,
                    'is_holiday' => $isHoliday,
                ]
            );
        }

        if (!$headerFound) {
            $errors[] = "Format template tidak sesuai! Header kolom harus memuat: Nama, Jenis, Mulai (DD/MM/YYYY), Selesai (DD/MM/YYYY), dan Tingkat.";
        }

        return $errors;
    }

    private function parseHariLibur($collection, $academicYear)
    {
        $errors = [];
        $headerFound = false;
        $rowNum = 1;

        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);

            $val0 = $values[0] ?? '';
            $firstCol = strtolower(trim(($val0 instanceof \DateTimeInterface) ? $val0->format('Y-m-d') : (string)$val0));
            $val1 = $values[1] ?? '';
            $secondCol = strtolower(trim(($val1 instanceof \DateTimeInterface) ? $val1->format('Y-m-d') : (string)$val1));

            // 1. Deteksi Baris Header Kolom
            if (!$headerFound) {
                if (str_contains($firstCol, 'waktu') || str_contains($firstCol, 'tanggal') || str_contains($secondCol, 'keterangan')) {
                    $headerFound = true;
                }
                continue;
            }

            $waktuRaw = $values[0] ?? null;
            $keterangan = trim(($val1 instanceof \DateTimeInterface) ? $val1->format('Y-m-d') : (string)$val1);

            // Skip jika baris benar-benar kosong
            if (empty($waktuRaw) && empty($keterangan)) {
                continue;
            }

            // Validasi Ketat: Keterangan
            if (empty($keterangan) || strlen($keterangan) < 3) {
                $errors[] = "Baris $rowNum: Keterangan hari libur wajib diisi (minimal 3 karakter).";
                continue;
            }

            // Validasi Ketat: Tanggal Waktu
            $date = $this->formatDate($waktuRaw);
            if (!$date || !$this->isValidDate($date)) {
                $errors[] = "Baris $rowNum: Format tanggal waktu hari libur tidak valid. Gunakan format DD/MM/YYYY.";
                continue;
            }

            // Klasifikasi Tipe Hari Libur Otomatis
            $lower = strtolower($keterangan);
            $type = 'SEKOLAH';
            if (str_contains($lower, 'cuti bersama')) {
                $type = 'CUTI_BERSAMA';
            } elseif (
                str_contains($lower, 'natal') ||
                str_contains($lower, 'idul fitri') ||
                str_contains($lower, 'idul adha') ||
                str_contains($lower, 'tahun baru') ||
                str_contains($lower, 'kemerdekaan') ||
                str_contains($lower, 'nyepi') ||
                str_contains($lower, 'waisak') ||
                str_contains($lower, 'imlek') ||
                str_contains($lower, 'isra') ||
                str_contains($lower, 'maulid') ||
                str_contains($lower, 'paskah') ||
                str_contains($lower, 'kenaikan') ||
                str_contains($lower, 'pancasila') ||
                str_contains($lower, 'buruh')
            ) {
                $type = 'NASIONAL';
            }

            SchoolHoliday::updateOrCreate(
                [
                    'name' => $keterangan,
                    'start_date' => $date,
                ],
                [
                    'end_date' => $date,
                    'type' => $type,
                    'description' => $keterangan,
                    'academic_year_id' => $academicYear ? $academicYear->id : null,
                    'is_active' => true,
                ]
            );
        }

        if (!$headerFound) {
            $errors[] = "Format template tidak sesuai! Header kolom harus memuat: Waktu (DD/MM/YYYY) dan Keterangan.";
        }

        return $errors;
    }

    private function formatDate($val)
    {
        if (empty($val)) return null;
        if ($val instanceof \DateTimeInterface) {
            return $val->format('Y-m-d');
        }
        if (is_numeric($val) && (float)$val > 10000) {
            return gmdate('Y-m-d', (int)(((float)$val - 25569) * 86400));
        }
        $str = trim((string)$val);
        if (preg_match('/^\d{1,2}\/\d{1,2}\/\d{4}$/', $str)) {
            $dt = \DateTime::createFromFormat('d/m/Y', $str);
            if ($dt !== false) return $dt->format('Y-m-d');
        }
        if (preg_match('/^\d{1,2}-\d{1,2}-\d{4}$/', $str)) {
            $dt = \DateTime::createFromFormat('d-m-Y', $str);
            if ($dt !== false) return $dt->format('Y-m-d');
        }
        $timestamp = strtotime($str);
        if ($timestamp !== false) {
            return date('Y-m-d', $timestamp);
        }
        return $str;
    }

    private function isValidDate($dateStr)
    {
        if (!is_string($dateStr) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateStr)) {
            return false;
        }
        [$y, $m, $d] = explode('-', $dateStr);
        return checkdate((int)$m, (int)$d, (int)$y);
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
