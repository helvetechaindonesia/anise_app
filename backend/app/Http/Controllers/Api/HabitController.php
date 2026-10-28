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

    /**
     * Daftar Master Habit G7-KAIH
     */
    public function masterHabits(Request $request)
    {
        $user = $request->user();
        $habits = Habit::all();
        
        // Cek log habit user hari ini
        $today = Carbon::today()->format('Y-m-d');
        $loggedHabitIds = DB::table('user_habit_logs')
            ->where('user_id', $user->id)
            ->whereDate('logged_date', $today)
            ->pluck('habit_id')
            ->toArray();

        // Cek prayer log hari ini jika ada
        $prayerLog = DB::table('user_prayer_logs')
            ->where('user_id', $user->id)
            ->whereDate('logged_date', $today)
            ->first();

        return $this->success([
            'habits' => $habits,
            'today_logged_habit_ids' => $loggedHabitIds,
            'today_prayer_log' => $prayerLog ? [
                'is_subuh' => (bool) $prayerLog->is_subuh,
                'is_dhuhur' => (bool) $prayerLog->is_dhuhur,
                'is_asar' => (bool) $prayerLog->is_asar,
                'is_maghrib' => (bool) $prayerLog->is_maghrib,
                'is_isya' => (bool) $prayerLog->is_isya,
                'is_quran' => (bool) $prayerLog->is_quran,
            ] : [
                'is_subuh' => false,
                'is_dhuhur' => false,
                'is_asar' => false,
                'is_maghrib' => false,
                'is_isya' => false,
                'is_quran' => false,
            ]
        ]);
    }

    /**
     * Submit Log Pembiasaan Generic (Siswa, Guru, Tendik, Kepala Sekolah)
     */
    public function submitLog(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'habit_id' => 'required|exists:habits,id',
            'notes' => 'nullable|string',
            'photo' => 'nullable|image|max:2048',
        ]);

        $photoPath = null;
        if ($request->hasFile('photo')) {
            $photoPath = $request->file('photo')->store('habits', 'public');
        }

        $today = Carbon::today()->format('Y-m-d');

        // Simpan / update log harian user
        $existing = DB::table('user_habit_logs')
            ->where('user_id', $user->id)
            ->where('habit_id', $request->habit_id)
            ->whereDate('logged_date', $today)
            ->first();

        if ($existing) {
            DB::table('user_habit_logs')
                ->where('id', $existing->id)
                ->update([
                    'notes' => $request->notes ?? $existing->notes,
                    'attachment_url' => $photoPath ?? $existing->attachment_url,
                    'updated_at' => now(),
                ]);
        } else {
            DB::table('user_habit_logs')->insert([
                'id' => (string) Str::uuid(),
                'user_id' => $user->id,
                'habit_id' => $request->habit_id,
                'logged_date' => $today,
                'notes' => $request->notes,
                'attachment_url' => $photoPath,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return $this->success(null, 'G7-KAIH berhasil dicatat', 201);
    }

    /**
     * Ambil data Prayer Log (Ibadah Khusus Muslim) hari ini
     */
    public function getPrayerLog(Request $request)
    {
        $user = $request->user();
        $targetUserId = $request->query('user_id', $user->id);
        $date = $request->query('date', Carbon::today()->format('Y-m-d'));

        $prayerLog = DB::table('user_prayer_logs')
            ->where('user_id', $targetUserId)
            ->whereDate('logged_date', $date)
            ->first();

        return $this->success([
            'date' => $date,
            'is_subuh' => $prayerLog ? (bool) $prayerLog->is_subuh : false,
            'is_dhuhur' => $prayerLog ? (bool) $prayerLog->is_dhuhur : false,
            'is_asar' => $prayerLog ? (bool) $prayerLog->is_asar : false,
            'is_maghrib' => $prayerLog ? (bool) $prayerLog->is_maghrib : false,
            'is_isya' => $prayerLog ? (bool) $prayerLog->is_isya : false,
            'is_quran' => $prayerLog ? (bool) $prayerLog->is_quran : false,
        ]);
    }

    /**
     * Submit / Toggle Prayer Log (Ibadah Khusus Muslim)
     */
    public function submitPrayerLog(Request $request)
    {
        $user = $request->user();
        $today = Carbon::today()->format('Y-m-d');

        $request->validate([
            'is_subuh' => 'nullable|boolean',
            'is_dhuhur' => 'nullable|boolean',
            'is_asar' => 'nullable|boolean',
            'is_maghrib' => 'nullable|boolean',
            'is_isya' => 'nullable|boolean',
            'is_quran' => 'nullable|boolean',
        ]);

        $existing = DB::table('user_prayer_logs')
            ->where('user_id', $user->id)
            ->whereDate('logged_date', $today)
            ->first();

        $updateData = [];
        foreach (['is_subuh', 'is_dhuhur', 'is_asar', 'is_maghrib', 'is_isya', 'is_quran'] as $field) {
            if ($request->has($field)) {
                $updateData[$field] = $request->boolean($field);
            }
        }
        $updateData['updated_at'] = now();

        if ($existing) {
            DB::table('user_prayer_logs')
                ->where('id', $existing->id)
                ->update($updateData);
        } else {
            $insertData = array_merge([
                'id' => (string) Str::uuid(),
                'user_id' => $user->id,
                'logged_date' => $today,
                'is_subuh' => false,
                'is_dhuhur' => false,
                'is_asar' => false,
                'is_maghrib' => false,
                'is_isya' => false,
                'is_quran' => false,
                'created_at' => now(),
            ], $updateData);

            DB::table('user_prayer_logs')->insert($insertData);
        }

        // Cari master habit Beribadah jika ada, pastikan juga log ter-record jika minimal 1 shalat terisi
        $beribadahHabit = Habit::where('category', 'IBADAH')->first();
        if ($beribadahHabit) {
            $anyChecked = false;
            $checkRecord = DB::table('user_prayer_logs')
                ->where('user_id', $user->id)
                ->whereDate('logged_date', $today)
                ->first();
            if ($checkRecord) {
                $anyChecked = ($checkRecord->is_subuh || $checkRecord->is_dhuhur || $checkRecord->is_asar || 
                               $checkRecord->is_maghrib || $checkRecord->is_isya || $checkRecord->is_quran);
            }

            if ($anyChecked) {
                $hasHabitLog = DB::table('user_habit_logs')
                    ->where('user_id', $user->id)
                    ->where('habit_id', $beribadahHabit->id)
                    ->whereDate('logged_date', $today)
                    ->exists();

                if (!$hasHabitLog) {
                    DB::table('user_habit_logs')->insert([
                        'id' => (string) Str::uuid(),
                        'user_id' => $user->id,
                        'habit_id' => $beribadahHabit->id,
                        'logged_date' => $today,
                        'notes' => 'Ibadah harian tercatat',
                        'attachment_url' => null,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
        }

        return $this->success(null, 'Catatan Ibadah berhasil diperbarui');
    }

    /**
     * Pending Logs (Compatibility stub)
     */
    public function pendingLogs(Request $request)
    {
        return $this->success([]);
    }

    /**
     * Daftar Anggota yang Dipantau:
     * - Guru Wali -> Memantau SISWA asuhan perwaliannya murni (tabel guru_wali_students).
     * - Guru BK -> Memantau siswa binaan BK (guru_bk_students).
     * - Kepala Sekolah -> Memantau seluruh Tenaga Pendidik / Guru & Staff.
     * - Guru biasa tanpa perwalian -> Memantau diri sendiri.
     */
    public function monitoredStudents(Request $request)
    {
        $user = $request->user();

        // 1. Kepala Sekolah -> Memantau seluruh user sekolah (Siswa, Guru, Guru BK, Tata Usaha)
        if ($user->role_type === 'KEPALA_SEKOLAH') {
            $allUsers = \App\Models\User::where('id', '!=', $user->id)
                ->where('is_active', true)
                ->with(['role', 'siswaProfile', 'guruProfile', 'studentClass'])
                ->get()
                ->map(function ($u) {
                    $roleType = $u->role?->name ?? $u->role_type;
                    $roleLabel = 'User';
                    $type = 'UMUM';

                    if ($roleType === 'SISWA') {
                        $roleLabel = 'Siswa (' . ($u->class_name ?? 'Umum') . ')';
                        $type = 'SISWA';
                    } elseif ($roleType === 'GURU') {
                        $roleLabel = 'Guru Pengajar';
                        $type = 'TENAGA_PENDIDIK';
                    } elseif ($roleType === 'GURU_BK') {
                        $roleLabel = 'Guru BK';
                        $type = 'TENAGA_PENDIDIK';
                    } elseif ($roleType === 'TATA_USAHA') {
                        $roleLabel = 'Tata Usaha';
                        $type = 'TENAGA_PENDIDIK';
                    }

                    return [
                        'id' => $u->id,
                        'name' => $u->full_name ?? $u->username,
                        'username' => $u->username,
                        'type' => $type,
                        'role_label' => $roleLabel,
                    ];
                });

            return $this->success($allUsers);
        }

        // 2. Guru / Guru BK
        if (in_array($user->role_type, ['GURU', 'GURU_BK'])) {
            // MURNI DARI GURU WALI (bukan wali kelas)
            $guruWaliStudentIds = \App\Models\GuruWaliStudent::where('guru_id', $user->id)->pluck('student_id')->toArray();

            // Jika Guru BK, tambahkan siswa binaan BK
            $guruBkStudentIds = [];
            if ($user->role_type === 'GURU_BK') {
                $guruBkStudentIds = DB::table('guru_bk_students')->where('guru_bk_id', $user->id)->pluck('student_id')->toArray();
            }

            $allStudentIds = array_unique(array_merge($guruWaliStudentIds, $guruBkStudentIds));

            $siswaRoleId = \App\Models\Role::where('name', 'SISWA')->value('id');
            $students = \App\Models\User::whereIn('id', $allStudentIds)
                ->where('role_id', $siswaRoleId)
                ->select('id', 'full_name as name', 'username')
                ->get()
                ->map(function ($s) {
                    return [
                        'id' => $s->id,
                        'name' => $s->name,
                        'username' => $s->username,
                        'type' => 'SISWA',
                        'role_label' => 'Siswa Perwalian',
                    ];
                });

            return $this->success($students);
        }

        return $this->success([]);
    }

    /**
     * Statistik Capaian Personal G7-KAIH (Siswa, Guru, Tendik, Kepsek)
     */
    public function getHabitStats(Request $request)
    {
        $user = $request->user();
        
        // Target ID yang ingin dilihat statistiknya
        $targetUserId = $request->query('student_id') ?: $request->query('user_id');

        // Jika tidak ditentukan, default ke user sendiri (pemantauan diri sendiri)
        if (!$targetUserId) {
            $targetUserId = $user->id;
        }

        $currentMonth = Carbon::now()->month;
        $currentYear = Carbon::now()->year;

        // Ambil data log
        $logs = DB::table('user_habit_logs')
            ->where('user_id', $targetUserId)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->get();

        $targetUser = \App\Models\User::find($targetUserId);
        $isMuslim = $targetUser && strtolower(trim($targetUser->religion ?? '')) === 'islam';

        // Hitung rincian per jenis ibadah jika Muslim
        $prayerBreakdown = null;
        if ($isMuslim) {
            $prayerStats = DB::table('user_prayer_logs')
                ->where('user_id', $targetUserId)
                ->whereMonth('logged_date', $currentMonth)
                ->whereYear('logged_date', $currentYear)
                ->select(
                    DB::raw('SUM(is_subuh) as subuh'),
                    DB::raw('SUM(is_dhuhur) as dhuhur'),
                    DB::raw('SUM(is_asar) as asar'),
                    DB::raw('SUM(is_maghrib) as maghrib'),
                    DB::raw('SUM(is_isya) as isya'),
                    DB::raw('SUM(is_quran) as quran')
                )
                ->first();

            $prayerBreakdown = [
                ['name' => 'Shalat Subuh', 'key' => 'subuh', 'total' => (int) ($prayerStats->subuh ?? 0)],
                ['name' => 'Shalat Dzuhur', 'key' => 'dhuhur', 'total' => (int) ($prayerStats->dhuhur ?? 0)],
                ['name' => 'Shalat Asar', 'key' => 'asar', 'total' => (int) ($prayerStats->asar ?? 0)],
                ['name' => 'Shalat Maghrib', 'key' => 'maghrib', 'total' => (int) ($prayerStats->maghrib ?? 0)],
                ['name' => 'Shalat Isya', 'key' => 'isya', 'total' => (int) ($prayerStats->isya ?? 0)],
                ['name' => 'Membaca Al-Qur\'an', 'key' => 'quran', 'total' => (int) ($prayerStats->quran ?? 0)],
            ];
        }

        $prayerLogsSum = DB::table('user_prayer_logs')
            ->where('user_id', $targetUserId)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->select(DB::raw('SUM(is_subuh + is_dhuhur + is_asar + is_maghrib + is_isya + is_quran) as total'))
            ->first();

        $prayerCount = $prayerLogsSum && $prayerLogsSum->total ? (int) $prayerLogsSum->total : 0;

        $totalSubmissions = $logs->count() + $prayerCount;
        $totalApproved = $totalSubmissions;
        $totalPending = 0;
        $totalRejected = 0;

        $habitStats = [];
        $habits = Habit::all();
        foreach ($habits as $habit) {
            $habitLogsCount = $logs->where('habit_id', $habit->id)->count();
            
            // Jika kategori ibadah, tambahkan prayer logs
            if (strtoupper($habit->category) === 'IBADAH') {
                $habitLogsCount += $prayerCount;
            }

            $habitStats[] = [
                'habit_id' => $habit->id,
                'name' => $habit->title,
                'category' => $habit->category,
                'total_submissions' => $habitLogsCount,
                'approved' => $habitLogsCount,
            ];
        }

        return $this->success([
            'is_muslim' => $isMuslim,
            'target_user' => $targetUser ? [
                'id' => $targetUser->id,
                'name' => $targetUser->name,
                'religion' => $targetUser->religion,
            ] : null,
            'summary' => [
                'total_submissions' => $totalSubmissions,
                'approved' => $totalApproved,
                'pending' => $totalPending,
                'rejected' => $totalRejected,
            ],
            'habits' => $habitStats,
            'prayer_breakdown' => $prayerBreakdown,
        ]);
    }

    /**
     * Statistik Pemantauan Kolektif Guru / Kepala Sekolah
     */
    public function guruHabitStats(Request $request)
    {
        $user = $request->user();

        // 1. KEPALA SEKOLAH -> Memantau statistik seluruh User (Siswa, Guru & Staff)
        if ($user->role_type === 'KEPALA_SEKOLAH') {
            $targetUserIds = \App\Models\User::where('id', '!=', $user->id)
                ->where('is_active', true)
                ->pluck('id')
                ->toArray();
        } else {
            // 2. GURU WALI -> Murni siswa perwaliannya
            $guruWaliStudentIds = \App\Models\GuruWaliStudent::where('guru_id', $user->id)->pluck('student_id')->toArray();
            $guruBkStudentIds = [];
            if ($user->role_type === 'GURU_BK') {
                $guruBkStudentIds = DB::table('guru_bk_students')->where('guru_bk_id', $user->id)->pluck('student_id')->toArray();
            }
            $targetUserIds = array_unique(array_merge($guruWaliStudentIds, $guruBkStudentIds));
        }

        $currentMonth = Carbon::now()->month;
        $currentYear = Carbon::now()->year;

        $logs = DB::table('user_habit_logs')
            ->whereIn('user_id', $targetUserIds)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->get();

        $prayerLogsSum = DB::table('user_prayer_logs')
            ->whereIn('user_id', $targetUserIds)
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

        // Rincian agregat ibadah (Shalat & Al-Quran) seluruh anggota yang dipantau
        $prayerAggregates = DB::table('user_prayer_logs')
            ->whereIn('user_id', $targetUserIds)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->select(
                DB::raw('SUM(is_subuh) as subuh'),
                DB::raw('SUM(is_dhuhur) as dhuhur'),
                DB::raw('SUM(is_asar) as asar'),
                DB::raw('SUM(is_maghrib) as maghrib'),
                DB::raw('SUM(is_isya) as isya'),
                DB::raw('SUM(is_quran) as quran')
            )
            ->first();

        $prayerBreakdown = [
            ['name' => 'Shalat Subuh', 'key' => 'subuh', 'total' => (int) ($prayerAggregates->subuh ?? 0)],
            ['name' => 'Shalat Dzuhur', 'key' => 'dhuhur', 'total' => (int) ($prayerAggregates->dhuhur ?? 0)],
            ['name' => 'Shalat Asar', 'key' => 'asar', 'total' => (int) ($prayerAggregates->asar ?? 0)],
            ['name' => 'Shalat Maghrib', 'key' => 'maghrib', 'total' => (int) ($prayerAggregates->maghrib ?? 0)],
            ['name' => 'Shalat Isya', 'key' => 'isya', 'total' => (int) ($prayerAggregates->isya ?? 0)],
            ['name' => 'Membaca Al-Qur\'an', 'key' => 'quran', 'total' => (int) ($prayerAggregates->quran ?? 0)],
        ];

        return $this->success([
            'total_students' => count($targetUserIds),
            'total_approved' => $totalApproved,
            'total_pending' => $totalPending,
            'categories' => $categoryStats,
            'prayer_breakdown' => $prayerBreakdown,
        ]);
    }
}
