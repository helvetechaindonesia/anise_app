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
use Illuminate\Support\Facades\DB;

class ExcelParserController extends Controller
{
    use ApiResponser;

    /**
     * Validasi umum berkas: Wajib format spreadsheet Excel (.xlsx / .xls).
     */
    private function validateExcelFile(Request $request): ?\Illuminate\Http\JsonResponse
    {
        if (!$request->hasFile('file')) {
            return $this->error('Berkas wajib diunggah!', 422);
        }

        $file = $request->file('file');
        $ext = strtolower($file->getClientOriginalExtension());
        $mime = strtolower($file->getClientMimeType());

        if ($ext === 'pdf' || str_contains($mime, 'pdf')) {
            return $this->error('Berkas PDF ditolak! Fitur ini hanya menerima berkas spreadsheet Excel (.xlsx / .xls).', 422);
        }

        if (!in_array($ext, ['xlsx', 'xls'])) {
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
     * 1. PARSE MASTER ROLE
     */
    public function parseMasterRole(Request $request)
    {
        if ($err = $this->validateExcelFile($request)) return $err;

        $collection = (new FastExcel)->import($request->file('file')->path());
        if ($collection->isEmpty()) {
            return $this->error('Berkas Excel kosong atau tidak memuat baris data!', 422);
        }

        $headers = array_keys((array)$collection->first());

        // Kata kunci spesifik Role
        $roleKeywords = ['peran', 'role', 'hakakses', 'namarole', 'peranpengguna'];
        $waliKeywords = ['isguruwali', 'guruwali', 'wali', 'iswali', 'statuswali'];

        // Cek apakah berkas memuat kolom Peran/Role
        if (!$this->hasHeaderMatching($headers, $roleKeywords)) {
            return $this->error('Berkas ditolak! Berkas yang Anda unggah bukan berkas Master Role. Kolom "Peran" atau "Role" tidak ditemukan.', 422);
        }

        // Cek jika berkas terdeteksi milik modul lain (contoh: berkas Kelas atau Jabatan)
        if ($this->hasHeaderMatching($headers, ['tingkat', 'rombel', 'grade', 'koderombel'])) {
            return $this->error('Berkas ditolak! Berkas ini terdeteksi sebagai data Master Kelas/Rombel, bukan Master Role.', 422);
        }
        if ($this->hasHeaderMatching($headers, ['areatugas', 'lingkuptugas'])) {
            return $this->error('Berkas ditolak! Berkas ini terdeteksi sebagai data Master Jabatan, bukan Master Role.', 422);
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
            // Jika yang tersimpan hanya protected roles saja dan 0 data dari file berhasil dibaca
            $nonProtectedCount = Role::whereIn('id', $syncedIds)->whereNotIn('name', ['TATA_USAHA', 'KEPALA_SEKOLAH', 'GURU', 'GURU_BK', 'SISWA'])->count();
            if ($nonProtectedCount === 0) {
                // Periksa apakah peran di file memang ada yang cocok
                $hasValidPeranInFile = false;
                foreach ($collection as $r) {
                    if (!empty($this->getValueBySemantics((array)$r, $roleKeywords))) {
                        $hasValidPeranInFile = true;
                        break;
                    }
                }
                if (!$hasValidPeranInFile) {
                    return $this->error('Berkas ditolak! Tidak ada data Peran/Role yang valid di dalam file ini.', 422);
                }
            }
        }

        return $this->success(null, 'Master Role berhasil disinkronisasi!');
    }

    /**
     * 2. PARSE MASTER KELAS
     */
    public function parseMasterKelas(Request $request)
    {
        if ($err = $this->validateExcelFile($request)) return $err;

        $collection = (new FastExcel)->import($request->file('file')->path());
        if ($collection->isEmpty()) {
            return $this->error('Berkas Excel kosong atau tidak memuat baris data!', 422);
        }

        $headers = array_keys((array)$collection->first());

        // Validasi: Berkas Kelas HARUS memiliki indikator kelas/rombel/tingkat
        $hasGrade = $this->hasHeaderMatching($headers, ['tingkat', 'tingkatkelas', 'grade', 'level', 'jenjang']);
        $hasRombel = $this->hasHeaderMatching($headers, ['rombel', 'namarombel', 'kelas', 'namakelas', 'kodekelas', 'koderombel']);

        if (!$hasGrade && !$hasRombel) {
            return $this->error('Berkas ditolak! Berkas yang Anda unggah bukan berkas Master Kelas. Kolom "Tingkat" atau "Rombel/Kelas" tidak ditemukan.', 422);
        }

        // Cek jika berkas ternyata milik modul lain
        if ($this->hasHeaderMatching($headers, ['peran', 'isguruwali']) && !$hasGrade) {
            return $this->error('Berkas ditolak! Berkas ini terdeteksi sebagai data Master Role, bukan Master Kelas.', 422);
        }
        if ($this->hasHeaderMatching($headers, ['jabatan', 'areatugas']) && !$hasGrade && !$hasRombel) {
            return $this->error('Berkas ditolak! Berkas ini terdeteksi sebagai data Master Jabatan, bukan Master Kelas.', 422);
        }

        $academicYear = AcademicYear::where('is_active', true)->first();
        $major = Major::first();

        if (!$academicYear || !$major) {
            return $this->error('Tahun Akademik aktif atau Jurusan belum tersedia di database.', 400);
        }

        $nameKeywords = ['namakelas', 'namarombel', 'rombel', 'kelas', 'nama'];
        $gradeKeywords = ['tingkat', 'tingkatkelas', 'grade', 'level', 'jenjang'];
        $codeKeywords = ['kodekelas', 'koderombel', 'kode', 'code', 'classcode'];

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
            return $this->error('Berkas ditolak! Tidak ditemukan data rombel kelas yang valid di dalam file ini.', 422);
        }

        return $this->success(null, 'Master Kelas berhasil disinkronisasi!');
    }

    /**
     * 3. PARSE MASTER JABATAN
     */
    public function parseMasterJabatan(Request $request)
    {
        if ($err = $this->validateExcelFile($request)) return $err;

        $collection = (new FastExcel)->import($request->file('file')->path());
        if ($collection->isEmpty()) {
            return $this->error('Berkas Excel kosong atau tidak memuat baris data!', 422);
        }

        $headers = array_keys((array)$collection->first());

        // Validasi: Wajib memuat kolom Jabatan / Posisi
        $jabatanKeywords = ['jabatan', 'namajabatan', 'posisi', 'title', 'struktural', 'jabatanorganisasi'];
        if (!$this->hasHeaderMatching($headers, $jabatanKeywords)) {
            return $this->error('Berkas ditolak! Berkas yang Anda unggah bukan berkas Master Jabatan. Kolom "Jabatan" tidak ditemukan.', 422);
        }

        // Cek jika berkas ternyata milik modul lain
        if ($this->hasHeaderMatching($headers, ['peran', 'isguruwali'])) {
            return $this->error('Berkas ditolak! Berkas ini terdeteksi sebagai data Master Role, bukan Master Jabatan.', 422);
        }
        if ($this->hasHeaderMatching($headers, ['tingkat', 'rombel', 'grade', 'koderombel'])) {
            return $this->error('Berkas ditolak! Berkas ini terdeteksi sebagai data Master Kelas, bukan Master Jabatan.', 422);
        }

        $areaKeywords = ['areatugas', 'area', 'tugas', 'deskripsi', 'taskarea', 'lingkuptugas', 'bidang'];

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
            return $this->error('Berkas ditolak! Tidak ditemukan data jabatan yang valid di dalam file ini.', 422);
        }

        return $this->success(null, 'Master Jabatan berhasil disinkronisasi!');
    }
}
