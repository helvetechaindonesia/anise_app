<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Rap2hpoutre\FastExcel\FastExcel;
use App\Traits\ApiResponser;
use App\Models\Role;
use App\Models\Jabatan;
use App\Models\SchoolClass;
use App\Models\AcademicYear;
use App\Models\Major;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Support\Facades\DB;

class ExcelParserController extends Controller
{
    use ApiResponser;

    /**
     * Validasi umum berkas: Wajib format spreadsheet Excel (.xlsx / .xls).
     */
    private function validateExcelFile(Request $request, string $moduleName, ?string $userId): ?\Illuminate\Http\JsonResponse
    {
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

        return null;
    }

    /**
     * Memeriksa apakah salah satu header dalam berkas cocok dengan daftar kata kunci.
     */
    private function hasHeaderMatching(array $headers, array $keywords): bool
    {
        foreach ($headers as $header) {
            $cleanHeader = strtolower(trim(preg_replace('/[^a-zA-Z0-9]/', '', (string)$header)));
            foreach ($keywords as $kw) {
                $cleanKw = strtolower(trim(preg_replace('/[^a-zA-Z0-9]/', '', $kw)));
                if ($cleanHeader === $cleanKw || str_contains($cleanHeader, $cleanKw) || str_contains($cleanKw, $cleanHeader)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Mengambil nilai baris berdasarkan kesamaan makna header.
     */
    private function getValueBySemantics(array $row, array $keywords): ?string
    {
        foreach ($row as $header => $val) {
            $cleanHeader = strtolower(trim(preg_replace('/[^a-zA-Z0-9]/', '', (string)$header)));
            foreach ($keywords as $kw) {
                $cleanKw = strtolower(trim(preg_replace('/[^a-zA-Z0-9]/', '', $kw)));
                if ($cleanHeader === $cleanKw || str_contains($cleanHeader, $cleanKw) || str_contains($cleanKw, $cleanHeader)) {
                    if ($val !== null && trim((string)$val) !== '') {
                        return trim((string)$val);
                    }
                }
            }
        }
        return null;
    }

    /**
     * 1. PARSE MASTER ROLE (STRICT VALIDATION)
     * Kolom wajib: Nama Role / Peran. Kolom lainnya (isGuruWali) opsional.
     */
    public function parseMasterRole(Request $request)
    {
        $moduleName = 'Role & Hak Akses';
        $userId = $request->user()?->id ?? User::where('username', 'tu_dev')->first()?->id ?? User::first()?->id;

        try {
            if ($err = $this->validateExcelFile($request, $moduleName, $userId)) return $err;

            $collection = (new FastExcel)->import($request->file('file')->path());
            if ($collection->isEmpty()) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Berkas Excel kosong atau tidak memuat baris data!',
                    'Berkas spreadsheet yang Anda unggah tidak memiliki baris data apapun.'
                );
                return $this->error('Berkas Excel kosong atau tidak memuat baris data!', 422);
            }

            $headers = array_keys((array)$collection->first());

            // Kata kunci spesifik Role
            $roleKeywords = ['peran', 'role', 'hakakses', 'namarole', 'peranpengguna'];
            $waliKeywords = ['isguruwali', 'guruwali', 'wali', 'iswali', 'statuswali'];

            // Cek apakah berkas memuat kolom Peran/Role
            if (!$this->hasHeaderMatching($headers, $roleKeywords)) {
                $errDetail = 'Berkas yang Anda unggah bukan berkas Master Role. Kolom "Peran" atau "Role" tidak ditemukan.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }

            // Cek jika berkas terdeteksi milik modul lain
            if ($this->hasHeaderMatching($headers, ['tingkat', 'rombel', 'grade', 'koderombel'])) {
                $errDetail = 'Berkas ini terdeteksi sebagai data Master Kelas/Rombel, bukan Master Role.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }
            if ($this->hasHeaderMatching($headers, ['areatugas', 'lingkuptugas'])) {
                $errDetail = 'Berkas ini terdeteksi sebagai data Master Jabatan, bukan Master Role.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }

            $rowErrors = [];
            $rowNum = 1;

            // Validasi Ketat: Nama Role wajib diisi untuk tiap baris
            foreach ($collection as $row) {
                $rowNum++;
                $rowArr = (array)$row;

                $hasAnyData = false;
                foreach ($rowArr as $v) {
                    if ($v !== null && trim((string)$v) !== '') {
                        $hasAnyData = true;
                        break;
                    }
                }
                if (!$hasAnyData) continue;

                $peranRaw = $this->getValueBySemantics($rowArr, $roleKeywords);
                if (empty($peranRaw)) {
                    $rowErrors[] = "Baris $rowNum: Nama Role/Peran wajib diisi.";
                }
            }

            if (!empty($rowErrors)) {
                $totalErr = count($rowErrors);
                $errorSlice = array_slice($rowErrors, 0, 5);
                $msg = "Validasi gagal:\n" . implode("\n", $errorSlice);
                if ($totalErr > 5) {
                    $msg .= "\n... dan " . ($totalErr - 5) . " error lainnya.";
                }

                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    "Terdapat {$totalErr} baris data yang kolom Nama Role/Perannya belum diisi.",
                    $rowErrors,
                    'Lengkapi kolom Nama Role pada seluruh baris berkas Excel Anda lalu unggah kembali.'
                );

                return response()->json([
                    'status' => 'error',
                    'message' => $msg,
                    'errors' => $rowErrors
                ], 422);
            }

            $syncedIds = [];
            DB::transaction(function () use ($collection, $roleKeywords, $waliKeywords, &$syncedIds) {
                foreach ($collection as $row) {
                    $rowArr = (array)$row;
                    $peranRaw = $this->getValueBySemantics($rowArr, $roleKeywords);
                    if (empty($peranRaw)) continue;

                    $rawWali = $this->getValueBySemantics($rowArr, $waliKeywords) ?? '';
                    $isGuruWali = false;
                    if (!empty($rawWali) && strtoupper($rawWali) !== 'NULL' && $rawWali !== '0' && strtolower($rawWali) !== 'false') {
                        $isGuruWali = true;
                    }

                    $cleanPeran = strtoupper(trim(str_replace(' ', '_', $peranRaw)));
                    $role = Role::updateOrCreate(
                        ['name' => $cleanPeran],
                        ['is_guru_wali' => $isGuruWali]
                    );
                    $syncedIds[] = $role->id;
                }

                // Perlindungan: 5 Role inti sistem tidak boleh terhapus
                $protectedRoles = ['TATA_USAHA', 'KEPALA_SEKOLAH', 'GURU', 'GURU_BK', 'SISWA'];
                foreach ($protectedRoles as $protRole) {
                    $exist = Role::firstOrCreate(['name' => $protRole]);
                    $syncedIds[] = $exist->id;
                }

                Role::whereNotIn('id', $syncedIds)->whereNotIn('name', $protectedRoles)->delete();
            });

            if (count($syncedIds) <= 5 && $collection->count() > 0) {
                $nonProtectedCount = Role::whereIn('id', $syncedIds)->whereNotIn('name', ['TATA_USAHA', 'KEPALA_SEKOLAH', 'GURU', 'GURU_BK', 'SISWA'])->count();
                if ($nonProtectedCount === 0) {
                    NotificationService::recordUploadFailure(
                        $userId,
                        $moduleName,
                        'Tidak ada data Peran/Role yang valid di dalam file ini.',
                        'Pastikan baris data memuat nama peran/role yang valid.'
                    );
                    return $this->error('Berkas ditolak! Tidak ada data Peran/Role yang valid di dalam file ini.', 422);
                }
            }

            return $this->success(null, 'Master Role berhasil disinkronisasi!');
        } catch (\Throwable $e) {
            NotificationService::recordUploadFailure(
                $userId,
                $moduleName,
                'Terjadi kesalahan sistem saat memproses berkas.',
                'Error teknis: ' . $e->getMessage()
            );
            return response()->json([
                'status' => 'error',
                'message' => 'Exception: ' . $e->getMessage(),
                'line' => $e->getLine()
            ], 500);
        }
    }

    /**
     * 2. PARSE MASTER KELAS (STRICT VALIDATION)
     * Semua kolom wajib diisi tanpa terkecuali (Tingkat, Nama Kelas, Kode Kelas).
     */
    public function parseMasterKelas(Request $request)
    {
        $moduleName = 'Kelas & Rombel';
        $userId = $request->user()?->id ?? User::where('username', 'tu_dev')->first()?->id ?? User::first()?->id;

        try {
            if ($err = $this->validateExcelFile($request, $moduleName, $userId)) return $err;

            $collection = (new FastExcel)->import($request->file('file')->path());
            if ($collection->isEmpty()) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Berkas Excel kosong atau tidak memuat baris data!',
                    'Berkas spreadsheet yang Anda unggah tidak memiliki baris data apapun.'
                );
                return $this->error('Berkas Excel kosong atau tidak memuat baris data!', 422);
            }

            $headers = array_keys((array)$collection->first());

            // Validasi: Berkas Kelas HARUS memiliki indikator kelas/rombel/tingkat
            $hasGrade = $this->hasHeaderMatching($headers, ['tingkat', 'tingkatkelas', 'grade', 'level', 'jenjang']);
            $hasRombel = $this->hasHeaderMatching($headers, ['rombel', 'namarombel', 'kelas', 'namakelas', 'kodekelas', 'koderombel']);

            if (!$hasGrade && !$hasRombel) {
                $errDetail = 'Berkas yang Anda unggah bukan berkas Master Kelas. Kolom "Tingkat" atau "Rombel/Kelas" tidak ditemukan.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }

            // Cek jika berkas ternyata milik modul lain
            if ($this->hasHeaderMatching($headers, ['peran', 'isguruwali']) && !$hasGrade) {
                $errDetail = 'Berkas ini terdeteksi sebagai data Master Role, bukan Master Kelas.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }
            if ($this->hasHeaderMatching($headers, ['jabatan', 'areatugas']) && !$hasGrade && !$hasRombel) {
                $errDetail = 'Berkas ini terdeteksi sebagai data Master Jabatan, bukan Master Kelas.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }

            $academicYear = AcademicYear::where('is_active', true)->first();
            $major = Major::first();

            if (!$academicYear || !$major) {
                $errDetail = 'Tahun Akademik aktif atau Jurusan belum tersedia di database.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Pengaturan dasar belum lengkap.', $errDetail, 'Pastikan Tahun Akademik dan Jurusan sudah disetel di sistem.');
                return $this->error($errDetail, 400);
            }

            $nameKeywords = ['namakelas', 'namarombel', 'rombel', 'kelas', 'nama'];
            $gradeKeywords = ['tingkat', 'tingkatkelas', 'grade', 'level', 'jenjang'];
            $codeKeywords = ['kodekelas', 'koderombel', 'kode', 'code', 'classcode'];

            $rowErrors = [];
            $rowNum = 1;

            // Validasi Ketat: Semua kolom wajib diisi tanpa terkecuali
            foreach ($collection as $row) {
                $rowNum++;
                $rowArr = (array)$row;

                $hasAnyData = false;
                foreach ($rowArr as $v) {
                    if ($v !== null && trim((string)$v) !== '') {
                        $hasAnyData = true;
                        break;
                    }
                }
                if (!$hasAnyData) continue;

                $nameRaw = $this->getValueBySemantics($rowArr, $nameKeywords);
                $codeRaw = $this->getValueBySemantics($rowArr, $codeKeywords);
                $gradeRaw = $this->getValueBySemantics($rowArr, $gradeKeywords);

                $missing = [];
                if (empty($gradeRaw)) $missing[] = 'Tingkat';
                if (empty($nameRaw)) $missing[] = 'Nama Kelas';
                if (empty($codeRaw)) $missing[] = 'Kode Kelas';

                if (!empty($missing)) {
                    $rowErrors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Kolom " . implode(', ', $missing) . " belum diisi).";
                }
            }

            if (!empty($rowErrors)) {
                $totalErr = count($rowErrors);
                $errorSlice = array_slice($rowErrors, 0, 5);
                $msg = "Validasi gagal:\n" . implode("\n", $errorSlice);
                if ($totalErr > 5) {
                    $msg .= "\n... dan " . ($totalErr - 5) . " error lainnya.";
                }

                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    "Terdapat {$totalErr} baris data kelas yang belum lengkap.",
                    $rowErrors,
                    'Lengkapi seluruh kolom (Tingkat, Nama Kelas, Kode Kelas) pada berkas Excel Anda lalu unggah kembali.'
                );

                return response()->json([
                    'status' => 'error',
                    'message' => $msg,
                    'errors' => $rowErrors
                ], 422);
            }

            $syncedIds = [];
            DB::transaction(function () use ($collection, $academicYear, $major, $nameKeywords, $gradeKeywords, $codeKeywords, &$syncedIds) {
                foreach ($collection as $row) {
                    $rowArr = (array)$row;
                    $nameRaw = $this->getValueBySemantics($rowArr, $nameKeywords);
                    $codeRaw = $this->getValueBySemantics($rowArr, $codeKeywords);
                    $gradeRaw = $this->getValueBySemantics($rowArr, $gradeKeywords);

                    if (empty($nameRaw) && empty($codeRaw)) continue;

                    $gradeLevel = 10;
                    if ($gradeRaw !== null) {
                        $cleanGrade = strtoupper(trim($gradeRaw));
                        if (in_array($cleanGrade, ['10', 'X'])) $gradeLevel = 10;
                        else if (in_array($cleanGrade, ['11', 'XI'])) $gradeLevel = 11;
                        else if (in_array($cleanGrade, ['12', 'XII'])) $gradeLevel = 12;
                    }

                    $finalName = $nameRaw ?? $codeRaw;
                    $finalCode = !empty($codeRaw) ? $codeRaw : "{$gradeLevel}-" . str_replace(' ', '-', strtoupper(trim($finalName)));

                    $class = SchoolClass::updateOrCreate(
                        ['code' => $finalCode],
                        [
                            'name' => $finalName,
                            'grade_level' => $gradeLevel,
                            'academic_year_id' => $academicYear->id,
                            'major_id' => $major->id,
                        ]
                    );
                    $syncedIds[] = $class->id;
                }

                if (count($syncedIds) > 0) {
                    SchoolClass::whereNotIn('id', $syncedIds)->delete();
                }
            });

            if (count($syncedIds) === 0) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Tidak ditemukan data rombel kelas yang valid di dalam berkas ini.',
                    'Pastikan berkas memuat baris data kelas dengan Tingkat, Nama Kelas, dan Kode Kelas.'
                );
                return $this->error('Berkas ditolak! Tidak ditemukan data rombel kelas yang valid di dalam file ini.', 422);
            }

            return $this->success(null, 'Master Kelas berhasil disinkronisasi!');
        } catch (\Throwable $e) {
            NotificationService::recordUploadFailure(
                $userId,
                $moduleName,
                'Terjadi kesalahan sistem saat memproses berkas.',
                'Error teknis: ' . $e->getMessage()
            );
            return response()->json([
                'status' => 'error',
                'message' => 'Exception: ' . $e->getMessage(),
                'line' => $e->getLine()
            ], 500);
        }
    }

    /**
     * 3. PARSE MASTER JABATAN (STRICT VALIDATION)
     * Semua kolom wajib diisi tanpa terkecuali (Jabatan dan Area Tugas).
     */
    public function parseMasterJabatan(Request $request)
    {
        $moduleName = 'Jabatan & Area Tugas';
        $userId = $request->user()?->id ?? User::where('username', 'tu_dev')->first()?->id ?? User::first()?->id;

        try {
            if ($err = $this->validateExcelFile($request, $moduleName, $userId)) return $err;

            $collection = (new FastExcel)->import($request->file('file')->path());
            if ($collection->isEmpty()) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Berkas Excel kosong atau tidak memuat baris data!',
                    'Berkas spreadsheet yang Anda unggah tidak memiliki baris data apapun.'
                );
                return $this->error('Berkas Excel kosong atau tidak memuat baris data!', 422);
            }

            $headers = array_keys((array)$collection->first());

            // Validasi: Wajib memuat kolom Jabatan / Posisi
            $jabatanKeywords = ['jabatan', 'namajabatan', 'posisi', 'title', 'struktural', 'jabatanorganisasi'];
            if (!$this->hasHeaderMatching($headers, $jabatanKeywords)) {
                $errDetail = 'Berkas yang Anda unggah bukan berkas Master Jabatan. Kolom "Jabatan" tidak ditemukan.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }

            // Cek jika berkas ternyata milik modul lain
            if ($this->hasHeaderMatching($headers, ['peran', 'isguruwali'])) {
                $errDetail = 'Berkas ini terdeteksi sebagai data Master Role, bukan Master Jabatan.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }
            if ($this->hasHeaderMatching($headers, ['tingkat', 'rombel', 'grade', 'koderombel'])) {
                $errDetail = 'Berkas ini terdeteksi sebagai data Master Kelas, bukan Master Jabatan.';
                NotificationService::recordUploadFailure($userId, $moduleName, 'Template berkas tidak sesuai.', $errDetail);
                return $this->error('Berkas ditolak! ' . $errDetail, 422);
            }

            $areaKeywords = ['areatugas', 'area', 'tugas', 'deskripsi', 'taskarea', 'lingkuptugas', 'bidang'];

            $rowErrors = [];
            $rowNum = 1;

            // Validasi Ketat: Semua kolom wajib diisi tanpa terkecuali (Jabatan & Area Tugas)
            foreach ($collection as $row) {
                $rowNum++;
                $rowArr = (array)$row;

                $hasAnyData = false;
                foreach ($rowArr as $v) {
                    if ($v !== null && trim((string)$v) !== '') {
                        $hasAnyData = true;
                        break;
                    }
                }
                if (!$hasAnyData) continue;

                $jabatanRaw = $this->getValueBySemantics($rowArr, $jabatanKeywords);
                $areaRaw = $this->getValueBySemantics($rowArr, $areaKeywords);

                $missing = [];
                if (empty($jabatanRaw)) $missing[] = 'Jabatan';
                if (empty($areaRaw)) $missing[] = 'Area Tugas';

                if (!empty($missing)) {
                    $rowErrors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Kolom " . implode(' & ', $missing) . " belum diisi).";
                }
            }

            if (!empty($rowErrors)) {
                $totalErr = count($rowErrors);
                $errorSlice = array_slice($rowErrors, 0, 5);
                $msg = "Validasi gagal:\n" . implode("\n", $errorSlice);
                if ($totalErr > 5) {
                    $msg .= "\n... dan " . ($totalErr - 5) . " error lainnya.";
                }

                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    "Terdapat {$totalErr} baris data jabatan yang belum lengkap.",
                    $rowErrors,
                    'Lengkapi seluruh kolom (Jabatan dan Area Tugas) pada berkas Excel Anda lalu unggah kembali.'
                );

                return response()->json([
                    'status' => 'error',
                    'message' => $msg,
                    'errors' => $rowErrors
                ], 422);
            }

            $syncedIds = [];
            DB::transaction(function () use ($collection, $jabatanKeywords, $areaKeywords, &$syncedIds) {
                foreach ($collection as $row) {
                    $rowArr = (array)$row;
                    $jabatanRaw = $this->getValueBySemantics($rowArr, $jabatanKeywords);
                    if (empty($jabatanRaw)) continue;

                    $areaRaw = $this->getValueBySemantics($rowArr, $areaKeywords);

                    $jabatan = Jabatan::updateOrCreate(
                        ['name' => strtoupper(str_replace(' ', '_', trim($jabatanRaw)))],
                        ['task_area' => $areaRaw]
                    );
                    $syncedIds[] = $jabatan->id;
                }

                if (count($syncedIds) > 0) {
                    Jabatan::whereNotIn('id', $syncedIds)->delete();
                }
            });

            if (count($syncedIds) === 0) {
                NotificationService::recordUploadFailure(
                    $userId,
                    $moduleName,
                    'Tidak ditemukan data jabatan yang valid di dalam file ini.',
                    'Pastikan baris data memuat kolom Jabatan dan Area Tugas.'
                );
                return $this->error('Berkas ditolak! Tidak ditemukan data jabatan yang valid di dalam file ini.', 422);
            }

            return $this->success(null, 'Master Jabatan berhasil disinkronisasi!');
        } catch (\Throwable $e) {
            NotificationService::recordUploadFailure(
                $userId,
                $moduleName,
                'Terjadi kesalahan sistem saat memproses berkas.',
                'Error teknis: ' . $e->getMessage()
            );
            return response()->json([
                'status' => 'error',
                'message' => 'Exception: ' . $e->getMessage(),
                'line' => $e->getLine()
            ], 500);
        }
    }
}
