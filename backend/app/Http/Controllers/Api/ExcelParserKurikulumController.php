<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Rap2hpoutre\FastExcel\FastExcel;
use Illuminate\Support\Facades\DB;
use App\Traits\ApiResponser;

use App\Models\Subject;
use App\Models\SubjectTeacher;
use App\Models\Schedule;
use App\Models\StructuralAssignment;
use App\Models\SchoolClass;
use App\Models\Jabatan;
use App\Models\AcademicYear;
use App\Models\User;
use App\Models\AcademicCalendar;
use App\Models\SchoolHoliday;
use App\Services\NotificationService;

class ExcelParserKurikulumController extends Controller
{
    use ApiResponser;

    /**
     * Memvalidasi apakah template berkas cocok dengan tipe modul kurikulum yang dipilih.
     */
    private function validateCurriculumFileContent($collection, string $type): ?string
    {
        $textBlob = '';
        $rowCount = 0;
        foreach ($collection as $row) {
            $rowArr = (array)$row;
            $stringValues = array_map(function($v) {
                if ($v instanceof \DateTimeInterface) {
                    return $v->format('Y-m-d');
                }
                return is_scalar($v) ? (string)$v : '';
            }, array_values($rowArr));
            $textBlob .= ' ' . implode(' ', array_keys($rowArr)) . ' ' . implode(' ', $stringValues);
            $rowCount++;
            if ($rowCount >= 3) break;
        }

        $textLower = strtolower($textBlob);

        // 1. Deteksi template modul lain (User, Role, Jabatan, Kelas)
        if (str_contains($textLower, 'areatugas') && $type !== 'penugasan') {
            return 'Berkas ditolak! Berkas ini terdeteksi sebagai data Master Jabatan Sekolah, bukan Master Kurikulum.';
        }
        if ((str_contains($textLower, 'isguruwali') || str_contains($textLower, 'peran')) && !str_contains($textLower, 'mata pelajaran') && !str_contains($textLower, 'jurnal') && !str_contains($textLower, 'kbm')) {
            return 'Berkas ditolak! Berkas ini terdeteksi sebagai data Master Role, bukan Master Kurikulum.';
        }
        if (str_contains($textLower, 'kredensial') && str_contains($textLower, 'nama lengkap') && !in_array($type, ['guru_wali', 'penugasan'])) {
            return 'Berkas ditolak! Berkas ini terdeteksi sebagai data Master Pengguna/User, bukan Master Kurikulum.';
        }

        // 2. Deteksi silang antar modul kurikulum
        if ($type === 'mapel') {
            if (str_contains($textLower, 'hari') && (str_contains($textLower, 'jam mulai') || str_contains($textLower, 'jam ke'))) {
                return 'Berkas ditolak! Anda memilih impor Master Mata Pelajaran, tetapi berkas terdeteksi sebagai Master Jurnal Mengajar / Jadwal KBM.';
            }
            if (str_contains($textLower, 'tugas tambahan')) {
                return 'Berkas ditolak! Anda memilih impor Master Mata Pelajaran, tetapi berkas terdeteksi sebagai Master Penugasan Tendik.';
            }
        } elseif ($type === 'jurnal_mengajar') {
            if (str_contains($textLower, 'tugas tambahan')) {
                return 'Berkas ditolak! Anda memilih impor Master Jurnal Mengajar, tetapi berkas terdeteksi sebagai Master Penugasan Tendik.';
            }
            if (!str_contains($textLower, 'hari') && !str_contains($textLower, 'jam') && str_contains($textLower, 'mata pelajaran')) {
                return 'Berkas ditolak! Anda memilih impor Master Jurnal Mengajar, tetapi berkas terdeteksi sebagai Master Mapel (kolom Hari/Jam tidak ditemukan).';
            }
        } elseif ($type === 'penugasan') {
            if (str_contains($textLower, 'mata pelajaran') || str_contains($textLower, 'kode mapel')) {
                return 'Berkas ditolak! Anda memilih impor Master Penugasan Tendik, tetapi berkas terdeteksi sebagai Master Mapel.';
            }
            if (str_contains($textLower, 'hari') && str_contains($textLower, 'jam')) {
                return 'Berkas ditolak! Anda memilih impor Master Penugasan Tendik, tetapi berkas terdeteksi sebagai Master Jurnal Mengajar.';
            }
        } elseif ($type === 'wali_kelas') {
            if (str_contains($textLower, 'mata pelajaran') || str_contains($textLower, 'kode mapel')) {
                return 'Berkas ditolak! Anda memilih impor Master Wali Kelas, tetapi berkas terdeteksi sebagai Master Mapel.';
            }
        } elseif ($type === 'guru_wali') {
            if (str_contains($textLower, 'mata pelajaran') || str_contains($textLower, 'kode mapel')) {
                return 'Berkas ditolak! Anda memilih impor Master Guru Wali, tetapi berkas terdeteksi sebagai Master Mapel.';
            }
        } elseif ($type === 'kalender_akademik') {
            if (str_contains($textLower, 'keterangan') && !str_contains($textLower, 'kegiatan') && !str_contains($textLower, 'akademik')) {
                return 'Berkas ditolak! Anda memilih impor Master Kalender Akademik, tetapi berkas terdeteksi sebagai Master Hari Libur (memuat kolom Keterangan).';
            }
        } elseif ($type === 'hari_libur') {
            if (str_contains($textLower, 'kegiatan') && !str_contains($textLower, 'keterangan') && !str_contains($textLower, 'libur')) {
                return 'Berkas ditolak! Anda memilih impor Master Hari Libur, tetapi berkas terdeteksi sebagai Master Kalender Akademik (memuat kolom Kegiatan).';
            }
        }

        return null;
    }

    public function parseKurikulum(Request $request, $type)
    {
        set_time_limit(0);

        $typeNames = [
            'mapel' => 'Mata Pelajaran',
            'jurnal_mengajar' => 'Jurnal Mengajar / Jadwal KBM',
            'penugasan' => 'Penugasan Tendik',
            'wali_kelas' => 'Wali Kelas',
            'guru_wali' => 'Guru Wali',
            'kalender_akademik' => 'Kalender Akademik',
            'hari_libur' => 'Hari Libur',
        ];

        $moduleName = $typeNames[$type] ?? strtoupper(str_replace('_', ' ', $type));
        $userId = $request->user()?->id ?? User::where('username', 'tu_dev')->first()?->id ?? User::first()?->id;

        try {
            if (!$request->hasFile('file')) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Berkas belum dipilih atau gagal diunggah.',
                    'Tidak ada berkas yang dilampirkan pada permintaan unggah.'
                );
                return $this->error('Berkas wajib diunggah!', 422);
            }

            $file = $request->file('file');
            $ext = strtolower($file->getClientOriginalExtension());
            $mime = strtolower($file->getClientMimeType());

            // Tolak jika PDF atau non-excel
            if ($ext === 'pdf' || str_contains($mime, 'pdf')) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Berkas berformat PDF tidak didukung.',
                    'Sistem hanya menerima berkas spreadsheet Excel (.xlsx / .xls). Silakan ekspor spreadsheet Anda ke format .xlsx atau .xls.'
                );
                return $this->error('Berkas PDF ditolak! Fitur ini hanya menerima berkas spreadsheet Excel (.xlsx / .xls).', 422);
            }

            if (!in_array($ext, ['xlsx', 'xls'])) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    "Format berkas (.{$ext}) tidak didukung.",
                    'Harap unggah berkas spreadsheet Excel dengan format .xlsx atau .xls.'
                );
                return $this->error('Format berkas ditolak! Harap unggah file spreadsheet Excel dengan format .xlsx atau .xls.', 422);
            }

            if (!isset($typeNames[$type])) {
                NotificationService::recordUploadFailure(
                    $userId,
                    'Kurikulum',
                    'Tipe modul kurikulum tidak valid.',
                    "Tipe kurikulum '{$type}' tidak dikenali oleh sistem."
                );
                return $this->error("Tipe kurikulum tidak valid: $type", 400);
            }

            $collection = (new FastExcel)->import($file->path());
            if ($collection->isEmpty()) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Berkas Excel kosong atau tidak memuat data yang valid.',
                    'Berkas spreadsheet yang Anda unggah tidak memiliki baris data apapun.'
                );
                return $this->error('Berkas Excel kosong atau tidak memuat baris data!', 422);
            }

            // Validasi kecocokan isi template berkas
            $contentError = $this->validateCurriculumFileContent($collection, $type);
            if ($contentError !== null) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Template berkas tidak sesuai dengan modul kurikulum yang dipilih.',
                    $contentError
                );
                return $this->error($contentError, 422);
            }

            $academicYear = AcademicYear::where('is_active', true)->first();
            $errors = [];

            DB::transaction(function () use ($collection, $type, $academicYear, &$errors) {
                if ($type === 'mapel') {
                    $errors = $this->parseMapel($collection, $academicYear);
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
                $totalErr = count($decoded);
                $errorMsg = "Validasi gagal:\n" . implode("\n", array_slice($decoded, 0, 5));
                if ($totalErr > 5) {
                    $errorMsg .= "\n...dan " . ($totalErr - 5) . " error lainnya.";
                }

                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    "Terdapat {$totalErr} baris data yang belum memenuhi syarat validasi atau tidak cocok dengan data master terkait.",
                    $decoded
                );

                return response()->json([
                    'status' => 'error',
                    'message' => $errorMsg,
                    'errors' => $decoded
                ], 422);
            }

            \Log::error('Excel Parse Error Kurikulum: ' . $msg . ' at line ' . $e->getLine());
            NotificationService::recordUploadFailure(
                $userId,
                $moduleName,
                'Terjadi kesalahan sistem saat memproses berkas kurikulum.',
                'Error teknis: ' . $msg
            );

            return response()->json([
                'status' => 'error',
                'message' => 'Exception: ' . $msg,
                'line' => $e->getLine()
            ], 500);
        }
    }

    // =========================================================================
    // 1. MASTER MAPEL (STRICT VALIDATION)
    // =========================================================================
    private function parseMapel($collection, $academicYear)
    {
        $errors = [];
        $rowNum = 1;

        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);

            $val0 = strtolower($this->cleanString($values[0] ?? ''));
            $val1 = strtolower($this->cleanString($values[1] ?? ''));

            // Abaikan baris header / banner
            if (str_contains($val0, 'mata pelajaran') || str_contains($val0, 'nama mapel') || str_contains($val1, 'kode') || str_contains($val0, 'master mapel')) {
                continue;
            }

            $namaMapel = $this->cleanString($values[0] ?? '');
            $kodeMapel = strtoupper($this->cleanString($values[1] ?? ''));
            $tingkat = strtoupper($this->cleanString($values[2] ?? ''));
            $namaKelas = $this->cleanString($values[3] ?? '');
            $namaTendik = $this->cleanString($values[4] ?? '');
            $nuptk = $this->cleanString($values[5] ?? '');

            // Abaikan jika baris kosong total
            if (empty($namaMapel) && empty($kodeMapel) && empty($namaKelas) && empty($nuptk)) {
                continue;
            }

            // Validasi Ketat: Semua 6 kolom wajib diisi
            if (empty($namaMapel) || empty($kodeMapel) || empty($tingkat) || empty($namaKelas) || empty($namaTendik) || empty($nuptk)) {
                $errors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Nama Mata Pelajaran, Kode Mapel, Tingkat, Nama Kelas, Nama Tendik(pengampu), NUPTK/NIP).";
                continue;
            }

            // Validasi Relasi: User Guru/Tendik berdasarkan NUPTK/NIP
            $teacher = $this->findTeacherByNuptk($nuptk, $namaTendik);
            if (!$teacher) {
                $errors[] = "Baris $rowNum: Guru dengan NUPTK/NIP '$nuptk' tidak ditemukan di Master User.";
                continue;
            }

            // Validasi Relasi: Nama Tendik harus identik cocok
            if (!$this->isSameName($teacher->full_name, $namaTendik)) {
                $errors[] = "Baris $rowNum: Nama pengampu '$namaTendik' tidak cocok dengan nama terdaftar ('{$teacher->full_name}') untuk NUPTK/NIP '$nuptk'.";
                continue;
            }

            // Validasi Relasi: Kelas
            $class = $this->findClass($tingkat, $namaKelas);
            if (!$class) {
                $errors[] = "Baris $rowNum: Kelas '$tingkat $namaKelas' tidak ditemukan di Master Kelas.";
                continue;
            }

            // Simpan / Update Master Subject
            $subject = Subject::updateOrCreate(
                ['code' => $kodeMapel],
                ['name' => $namaMapel]
            );

            // Simpan / Update Relasi Pengampu Mapel Kelas
            SubjectTeacher::updateOrCreate(
                [
                    'subject_id' => $subject->id,
                    'class_id' => $class->id,
                    'teacher_id' => $teacher->id,
                    'academic_year_id' => $academicYear ? $academicYear->id : null,
                ]
            );
        }

        return $errors;
    }

    // =========================================================================
    // 2. MASTER JURNAL MENGAJAR / JADWAL KBM (STRICT VALIDATION)
    // =========================================================================
    private function parseJurnalMengajar($collection, $academicYear)
    {
        $errors = [];
        $rowNum = 1;

        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);

            $val0 = strtolower($this->cleanString($values[0] ?? ''));
            if ($val0 === 'hari' || str_contains($val0, 'master jurnal')) {
                continue; // Skip header / banner
            }

            $hari = $this->cleanString($values[0] ?? '');
            $jamKe = $this->cleanString($values[1] ?? '');
            $jamMulai = $this->formatTime($values[2] ?? null);
            $jamSelesai = $this->formatTime($values[3] ?? null);
            $tingkat = strtoupper($this->cleanString($values[4] ?? ''));
            $namaKelas = $this->cleanString($values[5] ?? '');
            $kodeMapel = strtoupper($this->cleanString($values[6] ?? ''));
            $namaMapel = $this->cleanString($values[7] ?? '');
            $namaTendik = $this->cleanString($values[8] ?? '');
            $nuptk = $this->cleanString($values[9] ?? '');

            // Abaikan jika baris kosong total
            if (empty($hari) && empty($kodeMapel) && empty($namaKelas) && empty($jamMulai)) {
                continue;
            }

            // Validasi Kolom Wajib Dasar (semua baris termasuk KEG)
            if (empty($hari) || empty($jamKe) || empty($jamMulai) || empty($jamSelesai) || empty($tingkat) || empty($namaKelas) || empty($kodeMapel) || empty($namaMapel)) {
                $errors[] = "Baris $rowNum: Kolom Hari, Jam ke-, Jam Mulai, Jam Selesai, Tingkat, Nama Kelas, Kode Mapel, dan Nama Mapel wajib diisi.";
                continue;
            }

            // Validasi Relasi Kelas
            $class = $this->findClass($tingkat, $namaKelas);
            if (!$class) {
                $errors[] = "Baris $rowNum: Kelas '$tingkat $namaKelas' tidak ditemukan di Master Kelas.";
                continue;
            }

            $subjectId = null;
            $teacherId = null;
            $activityName = null;

            if ($kodeMapel === 'KEG') {
                // Kode KEG tidak wajib mengisi nama tendik dan NUPTK/NIP
                $activityName = $namaMapel;
            } else {
                // Mapel reguler: Nama Tendik dan NUPTK/NIP WAJIB DIISI!
                if (empty($namaTendik) || empty($nuptk) || $nuptk === '-') {
                    $errors[] = "Baris $rowNum: Nama Tendik dan NUPTK/NIP wajib diisi untuk mapel reguler (selain KEG).";
                    continue;
                }

                // Cek Master Mapel
                $subject = Subject::where('code', $kodeMapel)->first();
                if (!$subject) {
                    $errors[] = "Baris $rowNum: Kode Mapel '$kodeMapel' tidak ditemukan di Master Mapel. Silakan upload Master Mapel terlebih dahulu.";
                    continue;
                }

                // Cek Master User Guru
                $teacher = $this->findTeacherByNuptk($nuptk, $namaTendik);
                if (!$teacher) {
                    $errors[] = "Baris $rowNum: Guru dengan NUPTK/NIP '$nuptk' tidak ditemukan di Master User.";
                    continue;
                }

                // Cek Nama Guru identik
                if (!$this->isSameName($teacher->full_name, $namaTendik)) {
                    $errors[] = "Baris $rowNum: Nama Tendik '$namaTendik' tidak cocok dengan data terdaftar ('{$teacher->full_name}') untuk NUPTK/NIP '$nuptk'.";
                    continue;
                }

                // Cek Relasi Pengampu Mapel dari Master Mapel (Cross-check)
                $isAssigned = SubjectTeacher::where('subject_id', $subject->id)
                    ->where('class_id', $class->id)
                    ->where('teacher_id', $teacher->id)
                    ->exists();

                if (!$isAssigned) {
                    $errors[] = "Baris $rowNum: Guru '$namaTendik' ($nuptk) tidak terdaftar sebagai pengampu mapel '$kodeMapel' di kelas '{$class->grade_level} {$class->name}' pada Master Mapel.";
                    continue;
                }

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

    // =========================================================================
    // 3. MASTER PENUGASAN STRUKTURAL (STRICT VALIDATION)
    // =========================================================================
    private function parsePenugasan($collection, $academicYear)
    {
        $errors = [];
        $rowNum = 1;

        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);

            $val0 = strtolower($this->cleanString($values[0] ?? ''));
            $val1 = strtolower($this->cleanString($values[1] ?? ''));

            // Deteksi header/banner
            if (str_contains($val0, 'nama tendik') || str_contains($val1, 'tugas tambahan') || str_contains($val0, 'master penugasan')) {
                continue;
            }

            $namaTendik = $this->cleanString($values[0] ?? '');
            $tugasTambahan = $this->cleanString($values[1] ?? '');
            $area = $this->cleanString($values[2] ?? '');

            // Abaikan baris kosong
            if (empty($namaTendik) && empty($tugasTambahan)) {
                continue;
            }

            // Validasi Ketat: Nama Tendik dan Tugas Tambahan wajib diisi, area opsional
            if (empty($namaTendik) || empty($tugasTambahan)) {
                $errors[] = "Baris $rowNum: Nama Tendik dan Tugas Tambahan wajib diisi.";
                continue;
            }

            // Validasi Relasi: User Tendik
            $user = User::whereRaw('LOWER(TRIM(full_name)) = ?', [mb_strtolower($namaTendik)])->first();
            if (!$user) {
                $user = User::all()->first(fn($u) => $this->isSameName($u->full_name, $namaTendik));
            }
            if (!$user) {
                $errors[] = "Baris $rowNum: Nama Tendik '$namaTendik' tidak ditemukan di Master User.";
                continue;
            }

            // Validasi Relasi: Jabatan
            $jabatan = Jabatan::whereRaw('LOWER(TRIM(name)) = ?', [mb_strtolower($tugasTambahan)])->first();
            if (!$jabatan) {
                $errors[] = "Baris $rowNum: Tugas Tambahan / Jabatan '$tugasTambahan' tidak ditemukan di Master Jabatan.";
                continue;
            }

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
        return $errors;
    }

    // =========================================================================
    // 4. MASTER WALI KELAS (STRICT VALIDATION)
    // =========================================================================
    private function parseWaliKelas($collection)
    {
        $errors = [];
        $rowNum = 1;

        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);

            $val0 = strtolower($this->cleanString($values[0] ?? ''));
            $val1 = strtolower($this->cleanString($values[1] ?? ''));

            // Deteksi header / banner
            if (str_contains($val0, 'tingkat') || str_contains($val1, 'kelas') || str_contains($val0, 'master wali kelas') || str_contains($val1, 'master wali kelas')) {
                continue;
            }

            $tingkat = strtoupper($this->cleanString($values[0] ?? ''));
            $namaKelas = $this->cleanString($values[1] ?? '');
            $namaWali = $this->cleanString($values[2] ?? '');
            $nuptk = $this->cleanString($values[3] ?? '');

            // Abaikan baris kosong
            if (empty($tingkat) && empty($namaKelas) && empty($nuptk)) {
                continue;
            }

            // Validasi Ketat: Semua 4 kolom wajib diisi
            if (empty($tingkat) || empty($namaKelas) || empty($namaWali) || empty($nuptk)) {
                $errors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Tingkat, Nama Kelas, Nama Wali Kelas, NUPTK/NIP Wali Kelas).";
                continue;
            }

            // Validasi Relasi: Kelas
            $class = $this->findClass($tingkat, $namaKelas);
            if (!$class) {
                $errors[] = "Baris $rowNum: Kelas '$tingkat $namaKelas' tidak ditemukan di Master Kelas.";
                continue;
            }

            // Validasi Relasi: User Guru
            $user = $this->findTeacherByNuptk($nuptk, $namaWali);
            if (!$user) {
                $errors[] = "Baris $rowNum: Guru dengan NUPTK/NIP '$nuptk' tidak ditemukan di Master User.";
                continue;
            }

            // Validasi Relasi: Nama Wali Kelas harus cocok
            if (!$this->isSameName($user->full_name, $namaWali)) {
                $errors[] = "Baris $rowNum: Nama wali '$namaWali' tidak cocok dengan data terdaftar ('{$user->full_name}') untuk NUPTK/NIP '$nuptk'.";
                continue;
            }

            $class->wali_kelas_id = $user->id;
            $class->save();
        }
        return $errors;
    }

    // =========================================================================
    // 5. MASTER GURU WALI (PENEMPATAN KELAS & GURU WALI - STRICT VALIDATION)
    // =========================================================================
    private function parseGuruWali($collection, $academicYear)
    {
        $errors = [];
        $rowNum = 1;

        foreach ($collection as $row) {
            $rowNum++;
            $values = array_values((array)$row);

            $val0 = strtolower($this->cleanString($values[0] ?? ''));
            $val1 = strtolower($this->cleanString($values[1] ?? ''));

            // Deteksi header / banner
            if (str_contains($val0, 'nama lengkap') || (str_contains($val0, 'nama') && str_contains($val1, 'nisn')) || str_contains($val0, 'master penempatan kelas')) {
                continue;
            }

            $namaSiswa = $this->cleanString($values[0] ?? '');
            $nisn = $this->cleanString($values[1] ?? '');
            $tingkat = strtoupper($this->cleanString($values[2] ?? ''));
            $namaKelas = $this->cleanString($values[3] ?? '');
            $namaGuruWali = $this->cleanString($values[4] ?? '');

            // Abaikan baris kosong
            if (empty($namaSiswa) && empty($nisn) && empty($namaKelas) && empty($namaGuruWali)) {
                continue;
            }

            // Validasi Ketat: Semua 5 kolom wajib diisi
            if (empty($namaSiswa) || empty($nisn) || empty($tingkat) || empty($namaKelas) || empty($namaGuruWali)) {
                $errors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Nama Lengkap, NISN, Tingkat Kelas, Nama Kelas, Guru Wali).";
                continue;
            }

            // Validasi Relasi: Siswa di Master User
            $student = $this->findStudentByNisn($nisn, $namaSiswa);
            if (!$student) {
                $errors[] = "Baris $rowNum: Siswa dengan NISN '$nisn' tidak ditemukan di Master User.";
                continue;
            }

            // Validasi Relasi: Nama Siswa harus cocok
            if (!$this->isSameName($student->full_name, $namaSiswa)) {
                $errors[] = "Baris $rowNum: Nama siswa '$namaSiswa' tidak cocok dengan data terdaftar ('{$student->full_name}') untuk NISN '$nisn'.";
                continue;
            }

            // Validasi Relasi: Kelas
            $class = $this->findClass($tingkat, $namaKelas);
            if (!$class) {
                $errors[] = "Baris $rowNum: Kelas '$tingkat $namaKelas' tidak ditemukan di Master Kelas.";
                continue;
            }

            // Validasi Relasi: Guru Wali di Master User Guru
            $guruWali = User::whereRaw('LOWER(TRIM(full_name)) = ?', [mb_strtolower($namaGuruWali)])->first();
            if (!$guruWali) {
                $guruWali = User::all()->first(fn($u) => $this->isSameName($u->full_name, $namaGuruWali));
            }
            if (!$guruWali) {
                $errors[] = "Baris $rowNum: Guru Wali '$namaGuruWali' tidak ditemukan di Master User.";
                continue;
            }

            // Update Penempatan Kelas Siswa
            \App\Models\ClassStudent::updateOrCreate(
                [
                    'student_id' => $student->id,
                ],
                [
                    'class_id' => $class->id,
                    'status' => 'ACTIVE'
                ]
            );

            // Update Guru Wali Siswa
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
        return $errors;
    }

    // =========================================================================
    // 6. MASTER KALENDER AKADEMIK (STRICT VALIDATION)
    // =========================================================================
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

            // Deteksi Baris Header Kolom
            if (!$headerFound) {
                if ($firstCol === 'nama' && str_contains($secondCol, 'jenis')) {
                    $headerFound = true;
                }
                continue;
            }

            $nama = $this->cleanString(($val0 instanceof \DateTimeInterface) ? $val0->format('Y-m-d') : (string)$val0);
            $jenisRaw = strtolower($this->cleanString(($val1 instanceof \DateTimeInterface) ? $val1->format('Y-m-d') : (string)$val1));
            $mulaiRaw = $values[2] ?? null;
            $selesaiRaw = $values[3] ?? null;
            $val4 = $values[4] ?? '';
            $tingkatRaw = strtoupper($this->cleanString(($val4 instanceof \DateTimeInterface) ? $val4->format('Y-m-d') : (string)$val4));

            // Skip jika baris benar-benar kosong
            if (empty($nama) && empty($jenisRaw) && empty($mulaiRaw)) {
                continue;
            }

            // Validasi Ketat: Semua kolom wajib diisi tanpa terkecuali
            if (empty($nama) || empty($jenisRaw) || empty($mulaiRaw) || empty($selesaiRaw) || empty($tingkatRaw)) {
                $errors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Nama, Jenis, Mulai, Selesai, Tingkat).";
                continue;
            }

            if (strlen($nama) < 3) {
                $errors[] = "Baris $rowNum: Nama agenda minimal 3 karakter.";
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
                $errors[] = "Baris $rowNum: Jenis '$jenisRaw' tidak valid. Pilihan: asesmen, kegiatan, seremonial, administrasi, libur.";
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

            // Validasi Ketat: Tingkat (Single / Multi dengan penghubung '+')
            if (in_array($tingkatRaw, ['#', '*', 'ALL', 'SEMUA'])) {
                $tingkat = 'SEMUA';
            } else {
                $parts = array_map('trim', explode('+', $tingkatRaw));
                $normalizedParts = [];
                $gradeMap = [
                    'X' => 'X',
                    '10' => 'X',
                    'XI' => 'XI',
                    '11' => 'XI',
                    'XII' => 'XII',
                    '12' => 'XII',
                ];

                $hasInvalidGrade = false;
                foreach ($parts as $part) {
                    $pUpper = strtoupper($part);
                    if (!isset($gradeMap[$pUpper])) {
                        $errors[] = "Baris $rowNum: Tingkat '$part' pada '$tingkatRaw' tidak valid. Gunakan X, XI, XII, tanda '+' (contoh: X + XI), atau '#' untuk semua.";
                        $hasInvalidGrade = true;
                        break;
                    }
                    $norm = $gradeMap[$pUpper];
                    if (!in_array($norm, $normalizedParts)) {
                        $normalizedParts[] = $norm;
                    }
                }

                if ($hasInvalidGrade) {
                    continue;
                }

                if (count($normalizedParts) === 3 || empty($normalizedParts)) {
                    $tingkat = 'SEMUA';
                } else {
                    $order = ['X' => 1, 'XI' => 2, 'XII' => 3];
                    usort($normalizedParts, fn($a, $b) => $order[$a] <=> $order[$b]);
                    $tingkat = implode(' + ', $normalizedParts);
                }
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

    // =========================================================================
    // 7. MASTER HARI LIBUR (STRICT VALIDATION)
    // =========================================================================
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

            // Deteksi Baris Header Kolom
            if (!$headerFound) {
                if (str_contains($firstCol, 'waktu') || str_contains($firstCol, 'tanggal') || str_contains($secondCol, 'keterangan')) {
                    $headerFound = true;
                }
                continue;
            }

            $waktuRaw = $values[0] ?? null;
            $keterangan = $this->cleanString(($val1 instanceof \DateTimeInterface) ? $val1->format('Y-m-d') : (string)$val1);

            // Skip jika baris benar-benar kosong
            if (empty($waktuRaw) && empty($keterangan)) {
                continue;
            }

            // Validasi Ketat: Semua kolom wajib diisi tanpa terkecuali
            if (empty($waktuRaw) || empty($keterangan)) {
                $errors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Waktu dan Keterangan).";
                continue;
            }

            if (strlen($keterangan) < 3) {
                $errors[] = "Baris $rowNum: Keterangan hari libur minimal 3 karakter.";
                continue;
            }

            // Validasi Ketat: Tanggal Waktu
            $date = $this->formatDate($waktuRaw);
            if (!$date || !$this->isValidDate($date)) {
                $errors[] = "Baris $rowNum: Format tanggal waktu '$waktuRaw' tidak valid. Gunakan format DD/MM/YYYY.";
                continue;
            }

            SchoolHoliday::updateOrCreate(
                [
                    'name' => $keterangan,
                    'start_date' => $date,
                ],
                [
                    'end_date' => $date,
                    'type' => 'LIBUR',
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

    // =========================================================================
    // HELPER METHODS
    // =========================================================================
    private function cleanString($val)
    {
        if ($val === null) return '';
        $str = str_replace(["\xc2\xa0", "\u{00A0}"], ' ', (string)$val);
        $str = preg_replace('/\s+/', ' ', $str);
        return trim($str);
    }

    private function isSameName($name1, $name2)
    {
        $n1 = mb_strtolower($this->cleanString($name1));
        $n2 = mb_strtolower($this->cleanString($name2));
        return $n1 === $n2;
    }

    private function findClass($tingkat, $namaKelas)
    {
        $tingkat = strtoupper($this->cleanString($tingkat));
        $namaKelas = $this->cleanString($namaKelas);
        if (empty($namaKelas)) return null;

        $numericGrade = match($tingkat) { 'X' => '10', 'XI' => '11', 'XII' => '12', default => $tingkat };

        // 1. Coba cocokkan grade_level dan name
        $class = SchoolClass::where(function($q) use ($tingkat, $numericGrade) {
            $q->where('grade_level', $tingkat)->orWhere('grade_level', $numericGrade);
        })->where('name', $namaKelas)->first();

        if ($class) return $class;

        // 2. Coba CONCAT grade_level dan name (e.g. "X Cut Nyak Dhien" atau "10 Cut Nyak Dhien")
        $full1 = $tingkat . ' ' . $namaKelas;
        $full2 = $numericGrade . ' ' . $namaKelas;
        $class = SchoolClass::whereRaw("CONCAT(grade_level, ' ', name) = ?", [$full1])
            ->orWhereRaw("CONCAT(grade_level, ' ', name) = ?", [$full2])
            ->first();

        if ($class) return $class;

        // 3. Coba cari berdasarkan nama kelas saja
        return SchoolClass::where('name', $namaKelas)->first();
    }

    private function findTeacherByNuptk($nuptk, $nama = null)
    {
        $cleanNuptk = trim((string)$nuptk);
        $ltrimNuptk = ltrim($cleanNuptk, '0');

        $teacher = User::where('username', $cleanNuptk)->first();
        if (!$teacher && $ltrimNuptk !== '') {
            $teacher = User::where('username', $ltrimNuptk)->first();
        }
        if (!$teacher) {
            $teacher = GuruProfile::where('nip_nuptk', $cleanNuptk)
                ->orWhere('nip_nuptk', $ltrimNuptk)
                ->first()?->user;
        }
        if (!$teacher && !empty($nama)) {
            $teacher = User::whereRaw('LOWER(TRIM(full_name)) = ?', [mb_strtolower(trim($nama))])->first();
        }
        return $teacher;
    }

    private function findStudentByNisn($nisn, $nama = null)
    {
        $cleanNisn = trim((string)$nisn);
        $ltrimNisn = ltrim($cleanNisn, '0');

        $student = User::where('username', $cleanNisn)->first();
        if (!$student && $ltrimNisn !== '') {
            $student = User::where('username', $ltrimNisn)->first();
        }
        if (!$student) {
            $student = SiswaProfile::where('nisn', $cleanNisn)
                ->orWhere('nisn', $ltrimNisn)
                ->first()?->user;
        }
        if (!$student && !empty($nama)) {
            $student = User::whereRaw('LOWER(TRIM(full_name)) = ?', [mb_strtolower(trim($nama))])->first();
        }
        return $student;
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
        $str = trim((string)$val);
        if (preg_match('/^\d{1,2}:\d{2}(:\d{2})?$/', $str)) {
            return strlen($str) === 5 ? $str . ':00' : $str;
        }
        return $str;
    }
}
