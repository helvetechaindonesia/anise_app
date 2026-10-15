<?php

namespace App\Repositories;

use App\Models\AcademicCalendar;

class AcademicCalendarRepository
{
    public function getAll(array $filters = [])
    {
        $query = AcademicCalendar::with('academicYear')->orderBy('start_date', 'asc');

        if (!empty($filters['year'])) {
            $query->whereYear('start_date', $filters['year']);
        }

        if (!empty($filters['type'])) {
            $query->where('type', strtoupper($filters['type']));
        }

        if (!empty($filters['target_grade'])) {
            $query->where(function ($q) use ($filters) {
                $q->where('target_grade', 'SEMUA')
                  ->orWhere('target_grade', 'like', '%' . $filters['target_grade'] . '%');
            });
        }

        return $query->get();
    }

    public function findById(string $id): ?AcademicCalendar
    {
        return AcademicCalendar::with('academicYear')->find($id);
    }

    public function create(array $data): AcademicCalendar
    {
        return AcademicCalendar::create($data);
    }

    public function update(string $id, array $data): ?AcademicCalendar
    {
        $calendar = AcademicCalendar::find($id);
        if (!$calendar) {
            return null;
        }

        $calendar->update($data);
        return $calendar->fresh(['academicYear']);
    }

    public function delete(string $id): bool
    {
        $calendar = AcademicCalendar::find($id);
        if (!$calendar) {
            return false;
        }

        return (bool) $calendar->delete();
    }
}
