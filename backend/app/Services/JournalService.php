<?php

namespace App\Services;

use App\Repositories\JournalRepository;
use App\Repositories\ScheduleRepository;

class JournalService
{
    protected JournalRepository $journalRepo;
    protected ScheduleRepository $scheduleRepo;

    public function __construct(JournalRepository $journalRepo, ScheduleRepository $scheduleRepo)
    {
        $this->journalRepo = $journalRepo;
        $this->scheduleRepo = $scheduleRepo;
    }

    /**
     * Fitur "Kelas & Jadwal" di tampilan pengajar:
     * Mengambil daftar unik kelas & mata pelajaran yang diampu oleh guru beserta jumlah siswa aktifnya.
     */
    public function getTeacherClassesAndSchedules(string $teacherId): array
    {
        $schedules = $this->scheduleRepo->getTeacherSchedules($teacherId);

        $uniqueClasses = [];
        foreach ($schedules as $sched) {
            if (!$sched->class || !$sched->subject) {
                continue;
            }

            $key = $sched->class_id . '_' . $sched->subject_id;

            if (!isset($uniqueClasses[$key])) {
                $studentCount = $this->journalRepo->countActiveStudentsByClass($sched->class_id);

                $uniqueClasses[$key] = [
                    'class_id' => $sched->class_id,
                    'subject_id' => $sched->subject_id,
                    'class_name' => trim(($sched->class->grade_level ?? '') . ' ' . $sched->class->name),
                    'subject_name' => $sched->subject->name,
                    'student_count' => $studentCount,
                ];
            }
        }

        return array_values($uniqueClasses);
    }

    /**
     * Fitur "Jadwal & Pengajar" di tampilan siswa:
     * Mengambil daftar pengajar yang mengajar di kelas aktif siswa beserta mapel yang diampunya.
     */
    public function getStudentTeachers(string $studentId): array
    {
        $classStudent = $this->journalRepo->getActiveClassStudent($studentId);

        if (!$classStudent) {
            return [];
        }

        $classId = $classStudent->class_id;
        $schedules = $this->scheduleRepo->getClassSchedules($classId);

        $teachers = collect();
        foreach ($schedules as $sched) {
            if (!$sched->teacher || !$sched->subject) {
                continue;
            }

            $teacherId = $sched->teacher_id;
            $teacher = $sched->teacher;
            $teacherName = $teacher->guruProfile?->full_name ?: ($teacher->full_name ?: ($teacher->username ?? 'Guru Pengajar'));
            $subjectName = $sched->subject->name;

            if (!$teachers->has($teacherId)) {
                $teachers->put($teacherId, [
                    'id' => $teacherId,
                    'name' => $teacherName,
                    'subject' => $subjectName,
                    'avatar' => $teacher->profile_picture ?? null,
                ]);
            } else {
                $existing = $teachers->get($teacherId);
                if (!str_contains($existing['subject'], $subjectName)) {
                    $existing['subject'] .= ', ' . $subjectName;
                    $teachers->put($teacherId, $existing);
                }
            }
        }

        return $teachers->values()->all();
    }
}
