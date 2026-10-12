<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Habit;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class HabitController extends Controller
{
    use ApiResponser;

    public function masterHabits()
    {
        $habits = Habit::all();
        return $this->success($habits);
    }

    public function submitLog(Request $request)
    {
        $user = $request->user();
        if ($user->role_type !== 'SISWA') {
            return $this->error('Unauthorized', 403);
        }

        $request->validate([
            'habit_id' => 'required|exists:habits,id',
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:2048',
        ]);

        $photoPath = null;
        if ($request->hasFile('photo')) {
            $photoPath = $request->file('photo')->store('habits', 'public');
        }

        // Simpan ke user_habit_logs karena tabel lama sudah dihapus
        DB::table('user_habit_logs')->insert([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'habit_id' => $request->habit_id,
            'logged_date' => now(),
            'notes' => $request->notes,
            'attachment_url' => $photoPath,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $this->success(null, 'Habit log submitted successfully', 201);
    }

    // For Guru
    public function pendingLogs(Request $request)
    {
        $user = $request->user();
        if ($user->role_type !== 'GURU') {
            return $this->error('Unauthorized', 403);
        }

        // Di arsitektur baru, semua habit otomatis masuk tanpa butuh approval "PENDING".
        // Karena UI masih mengharapkan array, kita return empty array aja supaya gak bentrok.
        return $this->success([]);
    }

    public function monitoredStudents(Request $request)
    {
        $user = $request->user();
        if (!in_array($user->role_type, ['GURU', 'GURU_BK'])) {
            return $this->error('Unauthorized', 403);
        }

        // 1. Get student IDs from GuruWaliStudent
        $guruWaliStudentIds = \App\Models\GuruWaliStudent::where('guru_id', $user->id)->pluck('student_id')->toArray();

        // 2. Get class IDs where Guru is Wali Kelas
        $waliKelasClassIds = \App\Models\SchoolClass::where('wali_kelas_id', $user->id)->pluck('id')->toArray();

        // 3. Get student IDs from guru_bk_students
        $guruBkStudentIds = DB::table('guru_bk_students')->where('guru_bk_id', $user->id)->pluck('student_id')->toArray();

        $allClassIds = $waliKelasClassIds;

        // 4. Get student IDs from ClassStudent
        $classStudentIds = \App\Models\ClassStudent::whereIn('class_id', $allClassIds)->pluck('student_id')->toArray();

        // 5. Merge all student IDs
        $allStudentIds = array_unique(array_merge($guruWaliStudentIds, $classStudentIds, $guruBkStudentIds));

        // 6. Fetch the students
        $siswaRoleId = \App\Models\Role::where('name', 'SISWA')->value('id');
        $students = \App\Models\User::whereIn('id', $allStudentIds)
            ->where('role_id', $siswaRoleId)
            ->select('id', 'full_name as name', 'username')
            ->get();

        return $this->success($students);
    }

    public function getHabitStats(Request $request)
    {
        $user = $request->user();
        
        $studentId = $request->query('student_id');
        
        if ($user->role_type === 'SISWA') {
            $studentId = $user->id;
        } else if (!in_array($user->role_type, ['GURU', 'GURU_BK'])) {
            return $this->error('Unauthorized', 403);
        } else if (!$studentId) {
            return $this->error('student_id query parameter is required for Guru/BK', 400);
        }

        $currentMonth = Carbon::now()->month;
        $currentYear = Carbon::now()->year;

        // Ambil data dari tabel baru
        $logs = DB::table('user_habit_logs')
            ->where('user_id', $studentId)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->get();

        $prayerLogsSum = DB::table('user_prayer_logs')
            ->where('user_id', $studentId)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->select(DB::raw('SUM(is_subuh + is_dhuhur + is_asar + is_maghrib + is_isya + is_quran) as total'))
            ->first();

        $prayerCount = $prayerLogsSum && $prayerLogsSum->total ? (int) $prayerLogsSum->total : 0;

        $totalSubmissions = $logs->count() + $prayerCount;
        
        // Karena sistem baru tidak butuh approval, semuanya dihitung approved
        $totalApproved = $totalSubmissions;
        $totalPending = 0;
        $totalRejected = 0;

        $habitStats = [];
        $habits = Habit::all();
        foreach ($habits as $habit) {
            $habitLogsCount = $logs->where('habit_id', $habit->id)->count();
            $habitStats[] = [
                'habit_id' => $habit->id,
                'name' => $habit->title,
                'category' => $habit->category,
                'total_submissions' => $habitLogsCount,
                'approved' => $habitLogsCount, // Auto-approved di sistem baru
            ];
        }

        // Tambahkan statistik prayer log agar frontend tidak error
        if ($prayerCount > 0) {
            $habitStats[] = [
                'habit_id' => 'prayer-logs',
                'name' => 'Shalat Wajib & Al-Quran',
                'category' => 'IBADAH',
                'total_submissions' => $prayerCount,
                'approved' => $prayerCount,
            ];
        }

        return $this->success([
            'summary' => [
                'total_submissions' => $totalSubmissions,
                'approved' => $totalApproved,
                'pending' => $totalPending,
                'rejected' => $totalRejected,
            ],
            'habits' => $habitStats
        ]);
    }

    public function guruHabitStats(Request $request)
    {
        $user = $request->user();
        if (!in_array($user->role_type, ['GURU', 'GURU_BK'])) {
            return $this->error('Unauthorized', 403);
        }

        $guruWaliStudentIds = \App\Models\GuruWaliStudent::where('guru_id', $user->id)->pluck('student_id')->toArray();
        $waliKelasClassIds = \App\Models\SchoolClass::where('wali_kelas_id', $user->id)->pluck('id')->toArray();
        $guruBkStudentIds = DB::table('guru_bk_students')->where('guru_bk_id', $user->id)->pluck('student_id')->toArray();
        
        $allClassIds = $waliKelasClassIds;
        $classStudentIds = \App\Models\ClassStudent::whereIn('class_id', $allClassIds)->pluck('student_id')->toArray();
        $allStudentIds = array_unique(array_merge($guruWaliStudentIds, $classStudentIds, $guruBkStudentIds));

        $currentMonth = Carbon::now()->month;
        $currentYear = Carbon::now()->year;

        $logs = DB::table('user_habit_logs')
            ->whereIn('user_id', $allStudentIds)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->get();

        $prayerLogsSum = DB::table('user_prayer_logs')
            ->whereIn('user_id', $allStudentIds)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->select(DB::raw('SUM(is_subuh + is_dhuhur + is_asar + is_maghrib + is_isya + is_quran) as total'))
            ->first();

        $prayerCount = $prayerLogsSum && $prayerLogsSum->total ? (int) $prayerLogsSum->total : 0;

        $totalSubmissions = $logs->count() + $prayerCount;
        $totalApproved = $totalSubmissions;
        $totalPending = 0;

        // category stats
        $habits = Habit::all();
        $categoryStats = [];
        foreach (['IBADAH', 'KEDISIPLINAN', 'KESEHATAN', 'AKADEMIK', 'SOSIAL'] as $cat) {
            $catHabitIds = $habits->where('category', $cat)->pluck('id')->toArray();
            $catLogsCount = $logs->whereIn('habit_id', $catHabitIds)->count();
            
            if ($cat === 'IBADAH') {
                $catLogsCount += $prayerCount;
            }

            $categoryStats[$cat] = [
                'total' => $catLogsCount,
                'approved' => $catLogsCount,
            ];
        }

        return $this->success([
            'total_students' => count($allStudentIds),
            'total_approved' => $totalApproved,
            'total_pending' => $totalPending,
            'categories' => $categoryStats,
        ]);
    }
}
