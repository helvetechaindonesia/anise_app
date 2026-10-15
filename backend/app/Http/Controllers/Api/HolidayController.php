<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\HolidayService;
use App\Traits\ApiResponser;

class HolidayController extends Controller
{
    use ApiResponser;

    protected HolidayService $holidayService;

    public function __construct(HolidayService $holidayService)
    {
        $this->holidayService = $holidayService;
    }

    public function index(Request $request)
    {
        $filters = $request->only(['year', 'type', 'is_active']);
        $holidays = $this->holidayService->listHolidays($filters);
        return $this->success($holidays, 'Daftar hari libur berhasil dimuat');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date_format:Y-m-d',
            'end_date' => 'nullable|date_format:Y-m-d',
            'type' => 'nullable|string|in:LIBUR,NASIONAL,SEKOLAH,CUTI_BERSAMA,KHUSUS',
            'description' => 'nullable|string',
            'academic_year_id' => 'nullable|exists:academic_years,id',
            'is_active' => 'nullable|boolean',
        ]);

        $holiday = $this->holidayService->createHoliday($validated);
        return $this->success($holiday, 'Hari libur berhasil ditambahkan', 201);
    }

    public function show($id)
    {
        $holiday = $this->holidayService->getHoliday($id);
        if (!$holiday) {
            return $this->error('Hari libur tidak ditemukan', 404);
        }

        return $this->success($holiday, 'Detail hari libur');
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'start_date' => 'sometimes|required|date_format:Y-m-d',
            'end_date' => 'nullable|date_format:Y-m-d',
            'type' => 'nullable|string|in:LIBUR,NASIONAL,SEKOLAH,CUTI_BERSAMA,KHUSUS',
            'description' => 'nullable|string',
            'academic_year_id' => 'nullable|exists:academic_years,id',
            'is_active' => 'nullable|boolean',
        ]);

        $holiday = $this->holidayService->updateHoliday($id, $validated);
        if (!$holiday) {
            return $this->error('Hari libur tidak ditemukan', 404);
        }

        return $this->success($holiday, 'Hari libur berhasil diperbarui');
    }

    public function destroy($id)
    {
        $deleted = $this->holidayService->deleteHoliday($id);
        if (!$deleted) {
            return $this->error('Hari libur tidak ditemukan atau gagal dihapus', 404);
        }

        return $this->success(null, 'Hari libur berhasil dihapus');
    }

    public function checkDate(Request $request)
    {
        $request->validate([
            'date' => 'required|date_format:Y-m-d',
        ]);

        $result = $this->holidayService->checkDate($request->date);
        return $this->success($result);
    }
}
