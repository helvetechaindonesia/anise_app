<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\DisiplinReport;
use App\Models\GuruWaliStudent;
use App\Traits\ApiResponser;

class DisciplineController extends Controller
{
    use ApiResponser;

    public function submitDisiplinReport(Request $request)
    {
        $request->validate([
            'siswa_id' => 'required|exists:users,id',
            'category' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $reporter = $request->user();
        $isWaliKelas = GuruWaliStudent::where('guru_id', $reporter->id)->where('student_id', $request->siswa_id)->exists();
        $status = $isWaliKelas ? 'INPUT' : 'LAPORAN';

        $report = DisiplinReport::create([
            'siswa_id' => $request->siswa_id,
            'reporter_id' => $reporter->id,
            'category' => $request->category,
            'notes' => $request->notes,
            'status' => $status
        ]);

        return $this->success($report, 'Berhasil mencatat kedisiplinan');
    }

    public function getDisiplinReports(Request $request)
    {
        $reports = DisiplinReport::with(['siswa', 'reporter'])->orderBy('created_at', 'desc')->get();
        return $this->success($reports);
    }
}
