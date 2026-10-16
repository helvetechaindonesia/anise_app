<?php

namespace App\Repositories;

use App\Models\ClassStudent;

class JournalRepository
{
    /**
     * Get active class student record for a student
     */
    public function getActiveClassStudent(string $studentId): ?ClassStudent
    {
        return ClassStudent::where('student_id', $studentId)
            ->where('status', 'ACTIVE')
            ->first();
    }

    /**
     * Count active students in a class
     */
    public function countActiveStudentsByClass(string $classId): int
    {
        return ClassStudent::where('class_id', $classId)
            ->where('status', 'ACTIVE')
            ->count();
    }
}
