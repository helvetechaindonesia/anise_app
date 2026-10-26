<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use App\Models\DisiplinReport;
use App\Helpers\AppTime;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PointController extends Controller
{
    use ApiResponser;

    /**
     * Mengambil saldo poin kedisiplinan user pada bulan berjalan.
     * Aturan:
     * - Default: 100 poin per bulan (reset setiap awal bulan).
     * - Batas pelanggaran harian: 3 kali per hari.
     * - Pengurangan per pelanggaran sah (status != 'REJECTED'):
     *   bobot = 100 / (jumlah hari dalam bulan tersebut) / 3.
     */
    public function getBalance(Request $request)
    {
        $user = $request->user();
        $targetUserId = $request->query('user_id', $user->id);

        $now = AppTime::now();
        $year = $now->year;
        $month = $now->month;
        $daysInMonth = $now->daysInMonth;

        // Hitung pengurangan per 1 kali pelanggaran
        $deductionPerViolation = 100.0 / $daysInMonth / 3.0;

        // Ambil semua pelanggaran sah user di bulan berjalan
        $reports = DisiplinReport::where('siswa_id', $targetUserId)
            ->whereYear('created_at', $year)
            ->whereMonth('created_at', $month)
            ->whereIn('status', ['INPUT', 'APPROVED', 'LAPORAN'])
            ->get();

        // Kelompokkan per tanggal pelanggaran
        $groupedByDate = $reports->groupBy(function ($item) {
            return Carbon::parse($item->created_at)->format('Y-m-d');
        });

        $totalViolationsCounted = 0;
        foreach ($groupedByDate as $date => $dayReports) {
            // Setiap hari maksimal dihitung 3 pelanggaran yang mengurangi poin
            $count = min($dayReports->count(), 3);
            $totalViolationsCounted += $count;
        }

        $totalDeducted = round($totalViolationsCounted * $deductionPerViolation, 1);
        $currentBalance = max(0, round(100.0 - $totalDeducted, 1));

        // Cek pelanggaran hari ini
        $todayStr = $now->format('Y-m-d');
        $todayViolationsCount = $groupedByDate->get($todayStr, collect())->count();
        $remainingViolationsToday = max(0, 3 - $todayViolationsCount);

        return $this->success([
            'balance' => $currentBalance,
            'initial_balance' => 100,
            'total_deducted' => $totalDeducted,
            'days_in_month' => $daysInMonth,
            'deduction_per_violation' => round($deductionPerViolation, 2),
            'total_violations_month' => $reports->count(),
            'violations_counted' => $totalViolationsCounted,
            'today_violations' => $todayViolationsCount,
            'remaining_violations_today' => $remainingViolationsToday,
            'month_label' => $now->translatedFormat('F Y'),
        ]);
    }

    /**
     * Aturan kalkulasi poin
     */
    public function getRules(Request $request)
    {
        $now = AppTime::now();
        $daysInMonth = $now->daysInMonth;
        $deduction = round(100.0 / $daysInMonth / 3.0, 2);

        return $this->success([
            'base_points' => 100,
            'reset_cycle' => 'Bulanan (Awal Bulan)',
            'max_daily_violations' => 3,
            'days_in_current_month' => $daysInMonth,
            'deduction_formula' => "100 / $daysInMonth / 3 = $deduction poin per pelanggaran",
        ]);
    }

    /**
     * Riwayat pelanggaran yang tercatat di sistem (History Poin).
     */
    public function getHistory(Request $request)
    {
        $user = $request->user();
        $targetUserId = $request->query('user_id', $user->id);

        $now = AppTime::now();
        $daysInMonth = $now->daysInMonth;
        $deductionPerViolation = round(100.0 / $daysInMonth / 3.0, 1);

        $reports = DisiplinReport::with(['reporter'])
            ->where('siswa_id', $targetUserId)
            ->orderBy('created_at', 'desc')
            ->get();

        $history = $reports->map(function ($item) use ($deductionPerViolation) {
            $created = Carbon::parse($item->created_at);
            return [
                'id' => $item->id,
                'category' => $item->category,
                'title' => 'Pelanggaran: ' . $item->category,
                'description' => $item->notes ?? 'Pelanggaran kedisiplinan tercatat dalam sistem.',
                'date' => $created->translatedFormat('d M Y, H:i') . ' WIB',
                'created_at' => $item->created_at,
                'points_deducted' => -$deductionPerViolation,
                'status' => $item->status,
                'reporter_name' => $item->reporter ? $item->reporter->full_name : 'Petugas / Guru',
            ];
        });

        return $this->success($history);
    }
}
