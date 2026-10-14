<?php

namespace App\Services;

use App\Repositories\HolidayRepository;
use App\Models\AcademicYear;
use Illuminate\Validation\ValidationException;

class HolidayService
{
    protected HolidayRepository $holidayRepo;

    public function __construct(HolidayRepository $holidayRepo)
    {
        $this->holidayRepo = $holidayRepo;
    }

    public function listHolidays(array $filters = [])
    {
        return $this->holidayRepo->getAll($filters);
    }

    public function createHoliday(array $data)
    {
        if (empty($data['end_date'])) {
            $data['end_date'] = $data['start_date'];
        }

        if ($data['start_date'] > $data['end_date']) {
            throw ValidationException::withMessages([
                'end_date' => ['Tanggal selesai tidak boleh lebih awal dari tanggal mulai.'],
            ]);
        }

        if (empty($data['academic_year_id'])) {
            $activeYear = AcademicYear::where('is_active', true)->first()
                ?? AcademicYear::latest()->first();
            $data['academic_year_id'] = $activeYear?->id;
        }

        return $this->holidayRepo->create($data);
    }

    public function getHoliday(string $id)
    {
        return $this->holidayRepo->findById($id);
    }

    public function updateHoliday(string $id, array $data)
    {
        if (!empty($data['start_date']) && !empty($data['end_date'])) {
            if ($data['start_date'] > $data['end_date']) {
                throw ValidationException::withMessages([
                    'end_date' => ['Tanggal selesai tidak boleh lebih awal dari tanggal mulai.'],
                ]);
            }
        }

        return $this->holidayRepo->update($id, $data);
    }

    public function deleteHoliday(string $id): bool
    {
        return $this->holidayRepo->delete($id);
    }

    public function checkDate(string $date): array
    {
        // 1. Cek Hari Libur Rutin Mingguan Sekolah (School Off Days) dari school_settings
        $setting = \Illuminate\Support\Facades\DB::table('school_settings')
            ->where('setting_key', 'school_off_days')
            ->value('setting_value');
        $offDays = $setting ? json_decode($setting, true) : ['SATURDAY', 'SUNDAY'];
        if (!is_array($offDays)) {
            $offDays = ['SATURDAY', 'SUNDAY'];
        }

        $dayUpper = strtoupper(date('l', strtotime($date)));
        $indoDays = [
            'SUNDAY' => 'Minggu',
            'MONDAY' => 'Senin',
            'TUESDAY' => 'Selasa',
            'WEDNESDAY' => 'Rabu',
            'THURSDAY' => 'Kamis',
            'FRIDAY' => 'Jumat',
            'SATURDAY' => 'Sabtu',
        ];
        $dayIndo = $indoDays[$dayUpper] ?? $dayUpper;

        if (in_array($dayUpper, $offDays) || in_array($dayIndo, $offDays)) {
            return [
                'date' => $date,
                'is_holiday' => true,
                'holiday' => [
                    'id' => null,
                    'name' => 'Hari Libur Mingguan (' . $dayIndo . ')',
                    'type' => 'RUTIN_SEKOLAH',
                    'start_date' => $date,
                    'end_date' => $date,
                    'description' => 'Libur operasional mingguan sekolah',
                ],
            ];
        }

        // 2. Cek Hari Libur Kalender / Khusus dari tabel holidays
        $holiday = $this->holidayRepo->getHolidayForDate($date);

        return [
            'date' => $date,
            'is_holiday' => !is_null($holiday),
            'holiday' => $holiday,
        ];
    }
}
