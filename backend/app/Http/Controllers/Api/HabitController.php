<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Habit;
use App\Models\StudentHabitLog;
use App\Traits\ApiResponser;

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

        $log = StudentHabitLog::create([
            'student_id' => $user->id,
            'habit_id' => $request->habit_id,
            'logged_date' => now(),
            'status' => 'LOGGED',
        ]);

        return $this->success($log, 'Habit log submitted successfully', 201);
    }

    // For Guru
    public function pendingLogs(Request $request)
    {
        $user = $request->user();
        if ($user->role_type !== 'GURU') {
            return $this->error('Unauthorized', 403);
        }

        // Ideally, filter by students in classes taught by this guru
        // For MVP, return all pending logs
        $logs = StudentHabitLog::with(['student', 'habit'])
            ->where('status', 'PENDING')
            ->get();

        return $this->success($logs);
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

        // 3. Get class IDs from GuruBkClass
        $guruBkClassIds = \App\Models\GuruBkClass::where('guru_id', $user->id)->pluck('class_id')->toArray();

        $allClassIds = array_unique(array_merge($waliKelasClassIds, $guruBkClassIds));

        // 4. Get student IDs from ClassStudent
        $classStudentIds = \App\Models\ClassStudent::whereIn('class_id', $allClassIds)->pluck('student_id')->toArray();

        // 5. Merge all student IDs
        $allStudentIds = array_unique(array_merge($guruWaliStudentIds, $classStudentIds));

        // 6. Fetch the students with their latest class
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

        // Hitung total log yang diajukan bulan ini
        $currentMonth = \Carbon\Carbon::now()->month;
        $currentYear = \Carbon\Carbon::now()->year;

        $logs = StudentHabitLog::where('student_id', $studentId)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->get();

        $totalApproved = $logs->where('status', 'APPROVED')->count();
        $totalPending = $logs->where('status', 'PENDING')->count();
        $totalRejected = $logs->where('status', 'REJECTED')->count();
        $totalSubmissions = $logs->count();

        // Hitung per habit (kategori)
        $habitStats = [];
        $habits = Habit::all();
        foreach ($habits as $habit) {
            $habitLogs = $logs->where('habit_id', $habit->id);
            $habitStats[] = [
                'habit_id' => $habit->id,
                'name' => $habit->title,
                'category' => $habit->category,
                'total_submissions' => $habitLogs->count(),
                'approved' => $habitLogs->where('status', 'APPROVED')->count(),
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

        // Get student IDs like monitoredStudents
        $guruWaliStudentIds = \App\Models\GuruWaliStudent::where('guru_id', $user->id)->pluck('student_id')->toArray();
        $waliKelasClassIds = \App\Models\SchoolClass::where('wali_kelas_id', $user->id)->pluck('id')->toArray();
        $guruBkClassIds = \App\Models\GuruBkClass::where('guru_id', $user->id)->pluck('class_id')->toArray();
        $allClassIds = array_unique(array_merge($waliKelasClassIds, $guruBkClassIds));
        $classStudentIds = \App\Models\ClassStudent::whereIn('class_id', $allClassIds)->pluck('student_id')->toArray();
        $allStudentIds = array_unique(array_merge($guruWaliStudentIds, $classStudentIds));

        $currentMonth = \Carbon\Carbon::now()->month;
        $currentYear = \Carbon\Carbon::now()->year;

        $logs = StudentHabitLog::whereIn('student_id', $allStudentIds)
            ->whereMonth('logged_date', $currentMonth)
            ->whereYear('logged_date', $currentYear)
            ->get();

        $totalApproved = $logs->where('status', 'APPROVED')->count();
        $totalPending = $logs->where('status', 'PENDING')->count();

        // category stats
        $habits = Habit::all();
        $categoryStats = [];
        foreach (['IBADAH', 'KEDISIPLINAN', 'KESEHATAN', 'AKADEMIK', 'SOSIAL'] as $cat) {
            $catHabitIds = $habits->where('category', $cat)->pluck('id');
            $catLogs = $logs->whereIn('habit_id', $catHabitIds);
            
            $categoryStats[$cat] = [
                'total' => $catLogs->count(),
                'approved' => $catLogs->where('status', 'APPROVED')->count(),
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


