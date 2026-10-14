<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\Schedule;
use App\Models\StructuralAssignment;
use App\Traits\ApiResponser;

class CurriculumController extends Controller
{
    use ApiResponser;

    public function getClasses()
    {
        $kelas = SchoolClass::with(['major', 'academicYear'])->orderBy('grade_level', 'asc')->orderBy('name', 'asc')->get();
        return $this->success($kelas);
    }

    public function storeClass(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'grade_level' => 'required|in:10,11,12',
            'major_id' => 'nullable|exists:majors,id',
            'academic_year_id' => 'nullable|exists:academic_years,id',
        ]);

        $academicYearId = $request->academic_year_id;
        if (!$academicYearId) {
            $activeYear = \App\Models\AcademicYear::where('is_active', true)->first()
                ?? \App\Models\AcademicYear::latest()->first();
            $academicYearId = $activeYear?->id;
        }

        $majorId = $request->major_id;
        if (!$majorId) {
            $defaultMajor = \App\Models\Major::first();
            $majorId = $defaultMajor?->id;
        }

        $cleanName = strtoupper(trim($request->name));
        $code = "{$request->grade_level}-" . str_replace(' ', '-', $cleanName);

        $kelas = SchoolClass::create([
            'academic_year_id' => $academicYearId,
            'name' => $request->name,
            'code' => $code,
            'grade_level' => (int) $request->grade_level,
            'major_id' => $majorId,
        ]);

        $kelas->load(['major', 'academicYear']);

        return $this->success($kelas, 'Kelas berhasil dibuat', 201);
    }

    public function updateClass(Request $request, $id)
    {
        $kelas = SchoolClass::findOrFail($id);
        $request->validate([
            'name' => 'required|string|max:255',
            'grade_level' => 'nullable|in:10,11,12',
            'major_id' => 'nullable|exists:majors,id',
        ]);

        $updateData = ['name' => $request->name];
        if ($request->filled('grade_level')) {
            $updateData['grade_level'] = (int) $request->grade_level;
            $updateData['code'] = "{$request->grade_level}-" . str_replace(' ', '-', strtoupper(trim($request->name)));
        }
        if ($request->filled('major_id')) {
            $updateData['major_id'] = $request->major_id;
        }

        $kelas->update($updateData);
        $kelas->load(['major', 'academicYear']);

        return $this->success($kelas, 'Kelas berhasil diperbarui');
    }

    public function deleteClass($id)
    {
        SchoolClass::findOrFail($id)->delete();
        return $this->success(null, 'Kelas berhasil dihapus');
    }

    public function getSubjects()
    {
        return $this->success(Subject::orderBy('name', 'asc')->get());
    }

    public function deleteSubject($id)
    {
        Subject::findOrFail($id)->delete();
        return $this->success(null, 'Mapel berhasil dihapus');
    }

    public function getSchedules()
    {
        return $this->success(Schedule::with(['class', 'subject', 'teacher'])->orderBy('day_of_week', 'asc')->orderBy('start_time', 'asc')->get());
    }

    public function deleteSchedule($id)
    {
        Schedule::findOrFail($id)->delete();
        return $this->success(null, 'Jadwal berhasil dihapus');
    }

    public function getStructuralAssignments()
    {
        return $this->success(StructuralAssignment::with(['guru', 'jabatan', 'academicYear'])->get());
    }

    public function deleteStructuralAssignment($id)
    {
        StructuralAssignment::findOrFail($id)->delete();
        return $this->success(null, 'Penugasan berhasil dihapus');
    }
}
