<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\DisiplinReport;
use App\Models\GuruWaliStudent;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;
use App\Helpers\AppTime;

class DisciplineController extends Controller
{
    use ApiResponser;

    /**
     * Submit Laporan / Input Kedisiplinan Siswa.
     * Aturan:
     * 1. Jika guru pelapor adalah GURU WALI dari siswa terlapor -> Status = 'INPUT'.
     *    Otomatis meng-akumulasi seluruh 'LAPORAN' terkait siswa tersebut pada hari itu (kategori yang sama).
     * 2. Jika guru pelapor bukan Guru Wali -> Status = 'LAPORAN'.
     */
    public function submitDisiplinReport(Request $request)
    {
        $request->validate([
            'siswa_id' => 'required|exists:users,id',
            'category' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $reporter = $request->user();
        
        // Pengecekan apakah pelapor adalah GURU WALI siswa terlapor (tabel guru_wali_students)
        $isGuruWali = GuruWaliStudent::where('guru_id', $reporter->id)
            ->where('student_id', $request->siswa_id)
            ->exists();

        $status = $isGuruWali ? 'INPUT' : 'LAPORAN';

        $report = DisiplinReport::create([
            'siswa_id' => $request->siswa_id,
            'reporter_id' => $reporter->id,
            'category' => $request->category,
            'notes' => $request->notes,
            'status' => $status,
        ]);

        // JIKA GURU WALI membuat INPUT baru untuk siswa asuhnya:
        // Seluruh tiket LAPORAN yang berkaitan dengan nama siswa tersebut pada hari itu
        // (dengan kategori laporan yang sama) otomatis terakumulasi bersama input baru tersebut.
        $accumulatedCount = 0;
        if ($isGuruWali) {
            $today = AppTime::now()->format('Y-m-d');
            $accumulatedCount = DisiplinReport::where('siswa_id', $request->siswa_id)
                ->where('id', '!=', $report->id)
                ->whereDate('created_at', $today)
                ->where('category', $request->category)
                ->where('status', 'LAPORAN')
                ->update([
                    'status' => 'APPROVED',
                    'notes' => DB::raw("CONCAT(COALESCE(notes, ''), ' [Terakumulasi dengan Input Guru Wali #{$report->id}]')"),
                    'updated_at' => now(),
                ]);
        }

        $msg = $isGuruWali 
            ? "Input kedisiplinan berhasil dicatat oleh Guru Wali" . ($accumulatedCount > 0 ? " ({$accumulatedCount} laporan sebelumnya otomatis terakumulasi)" : "")
            : "Laporan kedisiplinan berhasil dikirim, menunggu verifikasi Guru Wali";

        return $this->success([
            'report' => $report,
            'is_guru_wali' => $isGuruWali,
            'accumulated_reports_count' => $accumulatedCount,
        ], $msg);
    }

    /**
     * Persetujuan (Approval) Laporan Kedisiplinan oleh GURU WALI.
     */
    public function approveDisiplinReport(Request $request, $id)
    {
        $guru = $request->user();
        $report = DisiplinReport::with('siswa')->findOrFail($id);

        // Validasi: hanya GURU WALI dari siswa bersangkutan yang berhak menyetujui
        $isGuruWali = GuruWaliStudent::where('guru_id', $guru->id)
            ->where('student_id', $report->siswa_id)
            ->exists();

        if (!$isGuruWali) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak! Anda bukan Guru Wali dari siswa bersangkutan.'
            ], 403);
        }

        $report->status = 'APPROVED';
        if ($request->filled('notes')) {
            $report->notes = ($report->notes ? $report->notes . ' | ' : '') . 'Catatan Guru Wali: ' . $request->notes;
        }
        $report->save();

        return $this->success($report, 'Laporan kedisiplinan berhasil disetujui oleh Guru Wali');
    }

    /**
     * Mengambil daftar laporan kedisiplinan dengan info Guru Wali
     */
    public function getDisiplinReports(Request $request)
    {
        $user = $request->user();
        $query = DisiplinReport::with(['siswa', 'reporter'])->orderBy('created_at', 'desc');

        // Auto Accept: Laporan kedisiplinan yang berstatus 'LAPORAN' lebih dari 3x24 jam (72 jam) otomatis disetujui (APPROVED)
        $cutoff72Hours = Carbon::now()->subHours(72);
        DisiplinReport::where('status', 'LAPORAN')
            ->where('created_at', '<=', $cutoff72Hours)
            ->update([
                'status' => 'APPROVED',
                'notes' => DB::raw("CONCAT(COALESCE(notes, ''), ' (Auto-Disetujui: Melewati batas 3x24 jam verifikasi Guru Wali)')"),
                'updated_at' => Carbon::now(),
            ]);

        // Filter opsional berdasarkan status (INPUT, LAPORAN, APPROVED) atau kategori
        if ($request->filled('status')) {
            $query->where('status', strtoupper($request->status));
        }
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }
        if ($request->filled('date')) {
            $query->whereDate('created_at', $request->date);
        }

        // Tandai apakah user login adalah Guru Wali dari masing-masing siswa terlapor
        $reports = $query->get()->map(function ($r) use ($user) {
            $isMyStudent = GuruWaliStudent::where('guru_id', $user->id)
                ->where('student_id', $r->siswa_id)
                ->exists();

            $r->can_approve = ($r->status === 'LAPORAN' && $isMyStudent);
            $r->is_guru_wali = $isMyStudent;
            return $r;
        });

        return $this->success($reports);
    }

    /**
     * Mengambil daftar siswa aktif untuk dropdown pelaporan disiplin
     */
    public function getStudentsList(Request $request)
    {
        $user = $request->user();
        $students = DB::table('users')
            ->join('student_profiles', 'users.id', '=', 'student_profiles.user_id')
            ->leftJoin('class_students', 'users.id', '=', 'class_students.student_id')
            ->leftJoin('classes', 'class_students.class_id', '=', 'classes.id')
            ->where('users.is_active', true)
            ->select(
                'users.id',
                'users.full_name',
                'users.username as nisn',
                'student_profiles.nis',
                'classes.name as class_name'
            )
            ->orderBy('users.full_name', 'asc')
            ->get();

        // Cari tahu siswa mana saja yang merupakan anak asuh Guru Wali ini
        $myStudentIds = GuruWaliStudent::where('guru_id', $user->id)->pluck('student_id')->toArray();

        $result = $students->map(function ($s) use ($myStudentIds) {
            $s->is_my_student = in_array($s->id, $myStudentIds);
            return $s;
        });

        return $this->success($result);
    }
}
