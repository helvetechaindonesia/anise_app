<?php

namespace App\Repositories;

use App\Models\SchoolHoliday;

class HolidayRepository
{
    public function getAll(array $filters = [])
    {
        $query = SchoolHoliday::with('academicYear')->orderBy('start_date', 'asc');

        if (!empty($filters['year'])) {
            $query->whereYear('start_date', $filters['year']);
        }

        if (!empty($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['is_active'])) {
            $query->where('is_active', filter_var($filters['is_active'], FILTER_VALIDATE_BOOLEAN));
        }

        return $query->get();
    }

    public function findById(string $id): ?SchoolHoliday
    {
        return SchoolHoliday::with('academicYear')->find($id);
    }

    public function create(array $data): SchoolHoliday
    {
        return SchoolHoliday::create($data);
    }

    public function update(string $id, array $data): ?SchoolHoliday
    {
        $holiday = SchoolHoliday::find($id);
        if (!$holiday) {
            return null;
        }

        $holiday->update($data);
        return $holiday->fresh(['academicYear']);
    }

    public function delete(string $id): bool
    {
        $holiday = SchoolHoliday::find($id);
        if (!$holiday) {
            return false;
        }

        return (bool) $holiday->delete();
    }

    public function isHoliday(string $date): bool
    {
        return SchoolHoliday::active()->forDate($date)->exists();
    }

    public function getHolidayForDate(string $date): ?SchoolHoliday
    {
        return SchoolHoliday::active()->forDate($date)->first();
    }
}
