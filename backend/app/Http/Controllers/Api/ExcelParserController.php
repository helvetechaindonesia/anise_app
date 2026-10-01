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

    public function parseMasterRole(Request $request)
    {
        $request->validate(['file' => 'required|file']);
        $collection = (new FastExcel)->import($request->file('file')->path());
        
        DB::transaction(function () use ($collection) {
            $syncedIds = [];
            foreach ($collection as $row) {
                if (empty($row['Peran'])) continue;
                $isGuruWali = false;
                $rawWali = $row['isGuruWali'] ?? '';
                if (!empty($rawWali) && strtoupper($rawWali) !== 'NULL' && $rawWali !== '0') {
                    $isGuruWali = true;
                }
                $cleanPeran = strtoupper(trim(str_replace(' ', '_', $row['Peran'])));
                $role = Role::updateOrCreate(
                    ['name' => $cleanPeran],
                    ['is_guru_wali' => $isGuruWali]
                );
                $syncedIds[] = $role->id;
            }
            Role::whereNotIn('id', $syncedIds)->delete();
        });

        return $this->success(null, 'Master Role berhasil disinkronisasi!');
    }

    public function parseMasterKelas(Request $request)
    {
        $request->validate(['file' => 'required|file']);
        $collection = (new FastExcel)->import($request->file('file')->path());

        $academicYear = AcademicYear::where('is_active', true)->first();
        $major = Major::first();

        if (!$academicYear || !$major) {
            return $this->error('Tahun Akademik aktif atau Jurusan belum tersedia di database.', 400);
        }

        DB::transaction(function () use ($collection, $academicYear, $major) {
            $syncedIds = [];
            foreach ($collection as $row) {
                if (empty($row['Kode']) && empty($row['Nama'])) continue;
                
                $gradeRaw = $row['Tingkat'] ?? '';
                $gradeLevel = 10;
                if (strtoupper($gradeRaw) === 'X' || $gradeRaw == '10') $gradeLevel = 10;
                else if (strtoupper($gradeRaw) === 'XI' || $gradeRaw == '11') $gradeLevel = 11;
                else if (strtoupper($gradeRaw) === 'XII' || $gradeRaw == '12') $gradeLevel = 12;

                $class = SchoolClass::updateOrCreate(
                    ['code' => $row['Kode'] ?? ''],
                    [
                        'name' => $row['Nama'] ?? '',
                        'grade_level' => $gradeLevel,
                        'academic_year_id' => $academicYear->id,
                        'major_id' => $major->id,
                    ]
                );
                $syncedIds[] = $class->id;
            }
            SchoolClass::whereNotIn('id', $syncedIds)->delete();
        });

        return $this->success(null, 'Master Kelas berhasil disinkronisasi!');
    }

    public function parseMasterJabatan(Request $request)
    {
        $request->validate(['file' => 'required|file']);
        $collection = (new FastExcel)->import($request->file('file')->path());

        DB::transaction(function () use ($collection) {
            $syncedIds = [];
            foreach ($collection as $row) {
                if (empty($row['Jabatan'])) continue;
                
                $jabatan = Jabatan::updateOrCreate(
                    ['name' => $row['Jabatan']],
                    ['task_area' => $row['Area Tugas'] ?? null]
                );
                $syncedIds[] = $jabatan->id;
            }
            Jabatan::whereNotIn('id', $syncedIds)->delete();
        });

        return $this->success(null, 'Master Jabatan berhasil disinkronisasi!');
    }
}
