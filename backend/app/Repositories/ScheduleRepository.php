<?php

namespace App\Repositories;

use App\Models\Schedule;
use Illuminate\Database\Eloquent\Collection;

class ScheduleRepository
{
    /**
     * Get unique schedules for a teacher with class and subject
     */
    public function getTeacherSchedules(string $teacherId): Collection
    {
        return Schedule::where('teacher_id', $teacherId)
            ->with(['class.major', 'subject'])
            ->get();
    }

    /**
     * Get schedules for a specific class with teacher profile and subject
     */
    public function getClassSchedules(string $classId): Collection
    {
        return Schedule::where('class_id', $classId)
            ->with(['teacher.guruProfile', 'subject'])
            ->get();
    }
}
