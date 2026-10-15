<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\Schedule;
use App\Models\StructuralAssignment;
use App\Models\GuruWaliStudent;
use App\Models\AcademicCalendar;
use App\Models\AcademicYear;
use App\Traits\ApiResponser;

class CurriculumController extends Controller
{
    use ApiResponser;

    // ==========================================
    // 1. KELAS & WALI KELAS
    // ==========================================
    public function getClasses()
    {
        $kelas = SchoolClass::with(['major', 'academicYear', 'waliKelas'])
            ->orderBy('grade_level', 'asc')
            ->orderBy('name', 'asc')
            ->get();
        return $this->success($kelas, 'Data kelas berhasil dimuat');
    }

    public function storeClass(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'grade_level' => 'required|in:10,11,12',
            'major_id' => 'nullable|exists:majors,id',
            'academic_year_id' => 'nullable|exists:academic_years,id',
            'wali_kelas_id' => 'nullable|exists:users,id',
        ]);

        $academicYearId = $request->academic_year_id;
        if (!$academicYearId) {
            $activeYear = AcademicYear::where('is_active', true)->first()
                ?? AcademicYear::latest()->first();
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
            'wali_kelas_id' => $request->wali_kelas_id,
        ]);

        $kelas->load(['major', 'academicYear', 'waliKelas']);

        return $this->success($kelas, 'Kelas berhasil dibuat', 201);
    }

    public function updateClass(Request $request, $id)
    {
        $kelas = SchoolClass::findOrFail($id);
        $request->validate([
            'name' => 'required|string|max:255',
            'grade_level' => 'nullable|in:10,11,12',
            'major_id' => 'nullable|exists:majors,id',
            'wali_kelas_id' => 'nullable|exists:users,id',
        ]);

        $updateData = ['name' => $request->name];
        if ($request->filled('grade_level')) {
            $updateData['grade_level'] = (int) $request->grade_level;
            $updateData['code'] = "{$request->grade_level}-" . str_replace(' ', '-', strtoupper(trim($request->name)));
        }
        if ($request->filled('major_id')) {
            $updateData['major_id'] = $request->major_id;
        }
        if ($request->has('wali_kelas_id')) {
            $updateData['wali_kelas_id'] = $request->wali_kelas_id;
        }

        $kelas->update($updateData);
        $kelas->load(['major', 'academicYear', 'waliKelas']);

        return $this->success($kelas, 'Kelas berhasil diperbarui');
    }

    public function assignWaliKelas(Request $request, $id)
    {
        $kelas = SchoolClass::findOrFail($id);
        $request->validate([
            'wali_kelas_id' => 'nullable|exists:users,id',
        ]);

        $kelas->update(['wali_kelas_id' => $request->wali_kelas_id]);
        $kelas->load(['major', 'academicYear', 'waliKelas']);

        return $this->success($kelas, 'Wali kelas berhasil diperbarui');
    }

    public function deleteClass($id)
    {
        SchoolClass::findOrFail($id)->delete();
        return $this->success(null, 'Kelas berhasil dihapus');
    }

    // ==========================================
    // 2. GURU WALI (SISWA ASUH / BK)
    // ==========================================
    public function getGuruWali()
    {
        $data = GuruWaliStudent::with(['guru', 'student', 'academicYear'])->get();
        return $this->success($data, 'Data Guru Wali & Siswa Asuh berhasil dimuat');
    }

    public function storeGuruWali(Request $request)
    {
        $request->validate([
            'guru_id' => 'required|exists:users,id',
            'student_id' => 'required|exists:users,id',
            'academic_year_id' => 'nullable|exists:academic_years,id',
        ]);

        $academicYearId = $request->academic_year_id;
        if (!$academicYearId) {
            $activeYear = AcademicYear::where('is_active', true)->first()
                ?? AcademicYear::latest()->first();
            $academicYearId = $activeYear?->id;
        }

        $record = GuruWaliStudent::updateOrCreate(
            [
                'guru_id' => $request->guru_id,
                'student_id' => $request->student_id,
                'academic_year_id' => $academicYearId,
            ]
        );

        $record->load(['guru', 'student', 'academicYear']);
        return $this->success($record, 'Penetapan Guru Wali berhasil disimpan', 201);
    }

    public function deleteGuruWali($id)
    {
        GuruWaliStudent::findOrFail($id)->delete();
        return $this->success(null, 'Data Guru Wali berhasil dihapus');
    }

    // ==========================================
    // 3. MATA PELAJARAN (MAPEL)
    // ==========================================
    public function getSubjects()
    {
        return $this->success(Subject::orderBy('name', 'asc')->get(), 'Data Mapel berhasil dimuat');
    }

    public function storeSubject(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:subjects,code',
        ]);

        $subject = Subject::create([
            'name' => $request->name,
            'code' => strtoupper(trim($request->code)),
        ]);

        return $this->success($subject, 'Mapel berhasil ditambahkan', 201);
    }

    public function updateSubject(Request $request, $id)
    {
        $subject = Subject::findOrFail($id);
        $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:subjects,code,' . $id,
        ]);

        $subject->update([
            'name' => $request->name,
            'code' => strtoupper(trim($request->code)),
        ]);

        return $this->success($subject, 'Mapel berhasil diperbarui');
    }

    public function deleteSubject($id)
    {
        Subject::findOrFail($id)->delete();
        return $this->success(null, 'Mapel berhasil dihapus');
    }

    // ==========================================
    // 4. JADWAL KBM
    // ==========================================
    public function getSchedules()
    {
        $schedules = Schedule::with(['class', 'subject', 'teacher', 'academicYear'])
            ->orderBy('day_of_week', 'asc')
            ->orderBy('start_time', 'asc')
            ->get();
        return $this->success($schedules, 'Jadwal KBM berhasil dimuat');
    }

    public function storeSchedule(Request $request)
    {
        $request->validate([
            'class_id' => 'required|exists:classes,id',
            'subject_id' => 'nullable|exists:subjects,id',
            'teacher_id' => 'nullable|exists:users,id',
            'day_of_week' => 'required|string',
            'start_time' => 'required',
            'end_time' => 'required',
            'activity_name' => 'nullable|string',
            'academic_year_id' => 'nullable|exists:academic_years,id',
        ]);

        $academicYearId = $request->academic_year_id;
        if (!$academicYearId) {
            $activeYear = AcademicYear::where('is_active', true)->first()
                ?? AcademicYear::latest()->first();
            $academicYearId = $activeYear?->id;
        }

        $schedule = Schedule::create([
            'class_id' => $request->class_id,
            'subject_id' => $request->subject_id,
            'teacher_id' => $request->teacher_id,
            'day_of_week' => $request->day_of_week,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'activity_name' => $request->activity_name,
            'academic_year_id' => $academicYearId,
        ]);

        $schedule->load(['class', 'subject', 'teacher', 'academicYear']);

        return $this->success($schedule, 'Jadwal KBM berhasil dibuat', 201);
    }

    public function updateSchedule(Request $request, $id)
    {
        $schedule = Schedule::findOrFail($id);
        $request->validate([
            'class_id' => 'sometimes|required|exists:classes,id',
            'subject_id' => 'nullable|exists:subjects,id',
            'teacher_id' => 'nullable|exists:users,id',
            'day_of_week' => 'sometimes|required|string',
            'start_time' => 'sometimes|required',
            'end_time' => 'sometimes|required',
            'activity_name' => 'nullable|string',
        ]);

        $schedule->update($request->only([
            'class_id', 'subject_id', 'teacher_id', 'day_of_week', 'start_time', 'end_time', 'activity_name'
        ]));

        $schedule->load(['class', 'subject', 'teacher', 'academicYear']);

        return $this->success($schedule, 'Jadwal KBM berhasil diperbarui');
    }

    public function deleteSchedule($id)
    {
        Schedule::findOrFail($id)->delete();
        return $this->success(null, 'Jadwal berhasil dihapus');
    }

    // ==========================================
    // 5. PENUGASAN STRUKTURAL (TUGAS TAMBAHAN)
    // ==========================================
    public function getStructuralAssignments()
    {
        $assignments = StructuralAssignment::with(['guru', 'jabatan', 'academicYear'])->get();
        return $this->success($assignments, 'Data penugasan struktural berhasil dimuat');
    }

    public function storeStructuralAssignment(Request $request)
    {
        $request->validate([
            'guru_id' => 'required|exists:users,id',
            'jabatan_id' => 'required|exists:jabatans,id',
            'academic_year_id' => 'nullable|exists:academic_years,id',
        ]);

        $academicYearId = $request->academic_year_id;
        if (!$academicYearId) {
            $activeYear = AcademicYear::where('is_active', true)->first()
                ?? AcademicYear::latest()->first();
            $academicYearId = $activeYear?->id;
        }

        $assignment = StructuralAssignment::updateOrCreate(
            [
                'guru_id' => $request->guru_id,
                'academic_year_id' => $academicYearId,
            ],
            [
                'jabatan_id' => $request->jabatan_id,
            ]
        );

        $assignment->load(['guru', 'jabatan', 'academicYear']);

        return $this->success($assignment, 'Penugasan berhasil disimpan', 201);
    }

    public function deleteStructuralAssignment($id)
    {
        StructuralAssignment::findOrFail($id)->delete();
        return $this->success(null, 'Penugasan berhasil dihapus');
    }

    // ==========================================
    // 6. KALENDER AKADEMIK (AGENDA KEGIATAN & SUMATIF)
    // ==========================================
    public function getAcademicCalendars(Request $request)
    {
        $query = AcademicCalendar::with('academicYear')->orderBy('start_date', 'asc');

        if ($request->filled('year')) {
            $query->whereYear('start_date', $request->year);
        }

        return $this->success($query->get(), 'Kalender akademik berhasil dimuat');
    }

    public function storeAcademicCalendar(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date_format:Y-m-d',
            'end_date' => 'required|date_format:Y-m-d|after_or_equal:start_date',
            'is_holiday' => 'nullable|boolean',
            'academic_year_id' => 'nullable|exists:academic_years,id',
        ]);

        $academicYearId = $request->academic_year_id;
        if (!$academicYearId) {
            $activeYear = AcademicYear::where('is_active', true)->first()
                ?? AcademicYear::latest()->first();
            $academicYearId = $activeYear?->id;
        }

        $calendar = AcademicCalendar::create([
            'name' => $request->name,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'is_holiday' => $request->boolean('is_holiday', false),
            'academic_year_id' => $academicYearId,
        ]);

        $calendar->load('academicYear');

        return $this->success($calendar, 'Agenda kalender akademik berhasil ditambahkan', 201);
    }

    public function updateAcademicCalendar(Request $request, $id)
    {
        $calendar = AcademicCalendar::findOrFail($id);
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'start_date' => 'sometimes|required|date_format:Y-m-d',
            'end_date' => 'sometimes|required|date_format:Y-m-d|after_or_equal:start_date',
            'is_holiday' => 'nullable|boolean',
            'academic_year_id' => 'nullable|exists:academic_years,id',
        ]);

        $calendar->update($request->only(['name', 'start_date', 'end_date', 'is_holiday', 'academic_year_id']));
        $calendar->load('academicYear');

        return $this->success($calendar, 'Agenda kalender akademik berhasil diperbarui');
    }

    public function deleteAcademicCalendar($id)
    {
        AcademicCalendar::findOrFail($id)->delete();
        return $this->success(null, 'Agenda kalender akademik berhasil dihapus');
    }
}
