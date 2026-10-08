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
        $kelas = SchoolClass::orderBy('grade_level', 'asc')->orderBy('name', 'asc')->get();
        return $this->success($kelas);
    }

    public function updateClass(Request $request, $id)
    {
        $kelas = SchoolClass::findOrFail($id);
        $request->validate(['name' => 'required|string|max:255']);
        $kelas->update(['name' => $request->name]);
        return $this->success($kelas);
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
