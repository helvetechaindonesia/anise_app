<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Subject;
use App\Models\Schedule;
use App\Models\Journal;
use App\Models\JournalReview;
use App\Models\JournalComment;
use App\Models\JournalTask;
use App\Models\JournalTaskAttachment;
use App\Services\FileStorageService;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;
use App\Services\JournalService;

class JournalController extends Controller
{
    protected JournalService $journalService;

    public function __construct(JournalService $journalService)
    {
        $this->journalService = $journalService;
    }

    public function getTerbitOptions(Request $request)
    {
        try {
            $user = Auth::user();
            
            $schedules = Schedule::where('teacher_id', $user->id)
                ->whereNotNull('subject_id')
                ->whereNull('activity_name')
                ->with(['subject', 'class'])
                ->get()
                ->filter(function ($sched) {
                    return $sched->subject && $sched->subject->code !== 'KEG' && empty($sched->activity_name);
                });
                
            $subjects = $schedules->pluck('subject')->filter()->unique('id')->values();
            
            $formattedSchedules = [];
            $startDate = Carbon::today();
            $endDate = Carbon::today()->addDays(30); // 1 bulan ke depan

            foreach ($schedules as $sched) {
                if (!$sched->class || !$sched->subject || $sched->subject->code === 'KEG' || !empty($sched->activity_name)) continue;

                $className = $sched->class->name;
                $grade = $sched->class->grade_level ?? '';
                
                // Konversi day_of_week dari database ke format nama hari Carbon bahasa Inggris
                // Asumsi database nyimpen 'Monday', 'Tuesday', dst.
                $dayNameMap = [
                    'Monday' => Carbon::MONDAY, 'Senin' => Carbon::MONDAY,
                    'Tuesday' => Carbon::TUESDAY, 'Selasa' => Carbon::TUESDAY,
                    'Wednesday' => Carbon::WEDNESDAY, 'Rabu' => Carbon::WEDNESDAY,
                    'Thursday' => Carbon::THURSDAY, 'Kamis' => Carbon::THURSDAY,
                    'Friday' => Carbon::FRIDAY, 'Jumat' => Carbon::FRIDAY,
                    'Saturday' => Carbon::SATURDAY, 'Sabtu' => Carbon::SATURDAY,
                    'Sunday' => Carbon::SUNDAY, 'Minggu' => Carbon::SUNDAY,
                ];

                $dayMapIndo = [
                    'Monday' => 'Senin',
                    'Tuesday' => 'Selasa',
                    'Wednesday' => 'Rabu',
                    'Thursday' => 'Kamis',
                    'Friday' => 'Jumat',
                    'Saturday' => 'Sabtu',
                    'Sunday' => 'Minggu',
                ];

                $targetDay = $dayNameMap[$sched->day_of_week] ?? null;
                $hariIndo = $dayMapIndo[$sched->day_of_week] ?? $sched->day_of_week;

                if ($targetDay !== null) {
                    // Cari tanggal pertama dari hari tersebut mulai dari hari ini
                    $currentDate = $startDate->copy()->next($targetDay);
                    // Jika hari ini adalah hari tersebut, kita masukkan juga
                    if ($startDate->dayOfWeekIso === $targetDay) {
                        $currentDate = $startDate->copy();
                    }

                    // Loop untuk mendapatkan semua tanggal dalam 1 bulan
                    while ($currentDate->lte($endDate)) {
                        $tanggalString = $currentDate->format('d/m/Y');
                        
                        // ID Dropdown harus unik per kombinasi jadwal dan tanggal
                        // Kita gabungkan schedule_id dan tanggal sebagai ID
                        $uniqueId = $sched->id . '|' . $currentDate->format('Y-m-d');
                        
                        $startTimeClean = substr($sched->start_time, 0, 5);
                        $endTimeClean = substr($sched->end_time, 0, 5);
                        $timeRange = "Jam {$startTimeClean} - {$endTimeClean}";
                        $gradeClass = "Tingkat {$grade} {$className}";

                        $formattedSchedules[] = [
                            'id' => $uniqueId,
                            'subject_id' => $sched->subject_id,
                            'schedule_id' => $sched->id,
                            'teaching_date' => $currentDate->format('Y-m-d'),
                            'day_name' => $hariIndo,
                            'date_formatted' => $tanggalString,
                            'time_range' => $timeRange,
                            'class_name' => $gradeClass,
                            'label' => "{$hariIndo}, {$tanggalString}\n{$timeRange} • {$gradeClass}"
                        ];
                        
                        $currentDate->addWeek();
                    }
                }
            }

            // Deduping per unique ID dan urutkan berdasarkan tanggal terdekat
            $formattedSchedules = collect($formattedSchedules)->unique('id')->values()->all();
            usort($formattedSchedules, function($a, $b) {
                return strcmp($a['teaching_date'], $b['teaching_date']);
            });

            return response()->json([
                'status' => 'success',
                'data' => [
                    'subjects' => $subjects,
                    'schedules' => $formattedSchedules
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'line' => $e->getLine()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $request->validate([
            'schedule_id' => 'required', // Format: "uuid|YYYY-MM-DD"
            'subject_id' => 'required|exists:subjects,id',
            'topic_material' => 'required|string',
            'description' => 'nullable|string',
            'has_task' => 'nullable',
            'attachment' => 'nullable|file|max:20480'
        ]);

        // Parsing schedule_id yang sekarang berupa "uuid|YYYY-MM-DD"
        $parts = explode('|', $request->schedule_id);
        if (count($parts) !== 2) {
            return response()->json(['status' => 'error', 'message' => 'Format Jadwal tidak valid'], 400);
        }

        $realScheduleId = $parts[0];
        $teachingDate = $parts[1];

        $schedule = Schedule::with('subject')->findOrFail($realScheduleId);

        if (!empty($schedule->activity_name) || empty($schedule->subject_id) || ($schedule->subject && $schedule->subject->code === 'KEG')) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kegiatan luar mapel (KEG) tidak memerlukan penerbitan jurnal mengajar.'
            ], 422);
        }

        $hasTaskInput = $request->input('has_task');
        $hasTask = filter_var($hasTaskInput, FILTER_VALIDATE_BOOLEAN) || $hasTaskInput == 1 || $hasTaskInput === '1' || $hasTaskInput === 'true';

        $journal = new Journal();
        $journal->teacher_id = Auth::id();
        $journal->schedule_id = $schedule->id;
        $journal->class_id = $schedule->class_id;
        $journal->subject_id = $request->subject_id;
        $journal->teaching_date = $teachingDate; // Ambil dari dropdown
        $journal->topic_material = $request->topic_material;
        $journal->description = $request->description;
        $journal->has_task = $hasTask;
        $journal->status = 'Aktif';
        $journal->published_at = now();
        $journal->save();

        // 1. Simpan berkas lampiran materi / modul jika diunggah
        if ($request->hasFile('attachment')) {
            $journal->load(['class.academicYear', 'subject']);
            $path = FileStorageService::storeJournalAttachment($request->file('attachment'), $journal);
            $journal->attachment_url = '/storage/' . $path;
            $journal->save();
        }

        // 2. Jika toggle has_task aktif, jurnal akan bertindak sebagai cangkang penugasan
        // Guru kemudian membuat rincian penugasan melalui tombol 'Buat Tugas' di Jurnal atau Halaman Penugasan.

        // 3. Notifikasi ke seluruh siswa aktif di kelas bersangkutan
        try {
            $teacher = Auth::user();
            $teacherName = $teacher->full_name ?: ($teacher->username ?? 'Guru Pengampu');
            $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
            $className = $schedule->class ? ($schedule->class->grade_level . ' ' . $schedule->class->name) : 'Kelas';
            $dateStr = Carbon::parse($teachingDate)->locale('id')->isoFormat('dddd, D MMMM Y');

            $notifTitle = "Materi Baru: {$subjectName}";
            $notifMessage = "Bapak/Ibu {$teacherName} telah menerbitkan jurnal pembelajaran untuk {$subjectName} di {$className} ({$dateStr}). Silakan periksa materi & modul pembelajaran Anda.";

            $studentIds = \App\Models\ClassStudent::where('class_id', $schedule->class_id)
                ->where('status', 'ACTIVE')
                ->pluck('student_id');

            foreach ($studentIds as $sId) {
                \App\Services\NotificationService::sendInAppNotification($sId, $notifTitle, $notifMessage);
            }
        } catch (\Throwable $err) {
            \Log::warning("Gagal mengirim notifikasi terbit jurnal ke siswa: " . $err->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Jurnal berhasil diterbitkan',
            'data' => $journal
        ]);
    }

    public function updateJournal(Request $request, $journalId)
    {
        $request->validate([
            'topic_material' => 'required|string',
            'description' => 'nullable|string',
            'has_task' => 'nullable',
            'attachment' => 'nullable|file|max:20480'
        ]);

        try {
            $user = Auth::user();
            $journal = Journal::with(['class.academicYear', 'subject', 'tasks'])->findOrFail($journalId);

            if ($journal->teacher_id !== $user->id) {
                return response()->json(['status' => 'error', 'message' => 'Anda bukan guru penerbit jurnal ini.'], 403);
            }

            $hasTaskInput = $request->input('has_task');
            $hasTask = filter_var($hasTaskInput, FILTER_VALIDATE_BOOLEAN) || $hasTaskInput == 1 || $hasTaskInput === '1' || $hasTaskInput === 'true';

            $journal->topic_material = $request->topic_material;
            $journal->description = $request->description;
            $journal->has_task = $hasTask;

            // Simpan lampiran baru jika diunggah
            if ($request->hasFile('attachment')) {
                $path = FileStorageService::storeJournalAttachment($request->file('attachment'), $journal);
                $journal->attachment_url = '/storage/' . $path;
            }

            $journal->save();

            // Jika toggle has_task dimatikan dan belum ada siswa yang mengerjakan, bisa diatur
            if (!$hasTask) {
                // Jurnal tidak lagi membutuhkan penugasan
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Jurnal berhasil diperbarui.',
                'data' => $journal
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal memperbarui jurnal: ' . $e->getMessage()], 500);
        }
    }

    public function deleteJournal($journalId)
    {
        try {
            $user = Auth::user();
            $journal = Journal::findOrFail($journalId);

            if ($journal->teacher_id !== $user->id) {
                return response()->json(['status' => 'error', 'message' => 'Anda bukan guru penerbit jurnal ini.'], 403);
            }

            if ($journal->tasks) {
                foreach ($journal->tasks as $task) {
                    $task->attachments()->delete();
                    $task->delete();
                }
            }

            $journal->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Jurnal berhasil dihapus.'
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal menghapus jurnal: ' . $e->getMessage()], 500);
        }
    }

    public function mySchedules()
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
            }

            $uniqueClasses = $this->journalService->getTeacherClassesAndSchedules($user->id);

            return response()->json([
                'status' => 'success',
                'data' => $uniqueClasses
            ]);
        } catch (\Throwable $e) {
            \Log::error('Error mySchedules: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memuat jadwal dan kelas: ' . $e->getMessage()
            ], 500);
        }
    }

    public function checkInCam(Request $request, $journalId)
    {
        try {
            $user = Auth::user();
            $journal = $this->resolveJournal($journalId);

            // Validasi kepemilikan guru
            if ($journal->teacher_id && $journal->teacher_id !== $user->id) {
                return response()->json(['status' => 'error', 'message' => 'Anda bukan guru pengampu untuk jurnal ini.'], 403);
            }

            $schedule = $journal->schedule;
            $now = Carbon::now();

            // Cek batas toleransi 15 menit dari start_time
            $isLate = false;
            $minutesLate = 0;
            if ($schedule && $schedule->start_time && $journal->teaching_date) {
                $teachingDateStr = Carbon::parse($journal->teaching_date)->format('Y-m-d');
                $startDateTime = Carbon::createFromFormat('Y-m-d H:i:s', "{$teachingDateStr} {$schedule->start_time}");
                $minutesDiff = (int)$startDateTime->diffInMinutes($now, false);
                if ($minutesDiff > 15) {
                    $isLate = true;
                    $minutesLate = $minutesDiff;
                }
            }

            // Simpan data presensi cam
            $journal->check_in_time = $now;
            $journal->latitude = $request->input('lat', $request->input('latitude'));
            $journal->longitude = $request->input('lng', $request->input('longitude'));

            if ($request->hasFile('face_image')) {
                $path = $request->file('face_image')->store('presensi_cam', 'public');
                $journal->face_snapshot_url = '/storage/' . $path;
            } elseif ($request->filled('face_snapshot_url')) {
                $journal->face_snapshot_url = $request->face_snapshot_url;
            }

            $journal->status = 'Aktif';
            $journal->save();

            $msg = 'Presensi Cam Jurnal berhasil diverifikasi.';
            if ($isLate) {
                $msg .= " Peringatan: Presensi tercatat terlambat {$minutesLate} menit dari jam mulai KBM.";
            }

            return response()->json([
                'status' => 'success',
                'message' => $msg,
                'data' => [
                    'journal_id' => $journal->id,
                    'check_in_time' => $journal->check_in_time ? $journal->check_in_time->format('H:i:s') : $now->format('H:i:s'),
                    'is_late' => $isLate,
                    'minutes_late' => $minutesLate,
                    'can_fill' => true
                ]
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getClassStudents(Request $request, $journalId)
    {
        try {
            $journal = $this->resolveJournal($journalId);
            $classId = $journal->class_id ?? ($journal->schedule?->class_id);

            if (!$classId) {
                return response()->json(['status' => 'success', 'data' => []]);
            }

            $students = \App\Models\ClassStudent::where('class_id', $classId)
                ->where('status', 'ACTIVE')
                ->with(['student.siswaProfile'])
                ->get()
                ->map(function ($cs) {
                    $student = $cs->student;
                    $profile = $student?->siswaProfile;
                    $name = $profile?->full_name ?: ($student?->full_name ?: ($student?->username ?? 'Siswa'));
                    $nis = $profile?->nisn ?: ($profile?->nis ?? '-');

                    return [
                        'id' => $student?->id,
                        'name' => $name,
                        'nis' => $nis,
                        'gender' => $profile?->gender ?? 'L',
                        'avatar' => $student?->profile_picture ?? null,
                    ];
                });

            return response()->json([
                'status' => 'success',
                'data' => $students
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function fillJournal(Request $request, $journalId)
    {
        $request->validate([
            'class_notes' => 'required|string',
            'student_records' => 'nullable|array',
            'student_records.*.student_id' => 'required|string',
            'student_records.*.record_type' => 'required|in:ABSENCE,VIOLATION,ACHIEVEMENT',
            'student_records.*.keterangan' => 'required|string',
        ]);

        try {
            $user = Auth::user();
            $journal = $this->resolveJournal($journalId);

            // Validasi kepemilikan guru
            if ($journal->teacher_id && $journal->teacher_id !== $user->id) {
                return response()->json(['status' => 'error', 'message' => 'Anda bukan guru pengampu untuk jurnal ini.'], 403);
            }

            // Validasi Wajib Presensi Cam terlebih dahulu
            if (empty($journal->check_in_time)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Guru belum melakukan Presensi Cam! Anda wajib melakukan presensi cam terlebih dahulu sebelum mengisi laporan jurnal.'
                ], 422);
            }

            $now = Carbon::now();
            $journal->filled_at = $now;
            $journal->class_notes = $request->class_notes;
            $journal->status = 'Selesai';
            $journal->save();

            // Simpan anomali siswa jika ada
            if ($request->has('student_records') && is_array($request->student_records)) {
                foreach ($request->student_records as $rec) {
                    $studentId = $rec['student_id'] ?? null;
                    if (!$studentId) continue;

                    $recordType = strtoupper($rec['record_type']);
                    $keterangan = $rec['keterangan'] ?? '';

                    $sr = new \App\Models\JournalStudentRecord();
                    $sr->journal_id = $journal->id;
                    $sr->student_id = $studentId;
                    $sr->record_type = $recordType;
                    $sr->keterangan = $keterangan;
                    $sr->save();

                    // Jika VIOLATION, otomatis buat salinan ke discipline_reports (Modul 9)
                    if ($recordType === 'VIOLATION' && \Illuminate\Support\Facades\Schema::hasTable('discipline_reports')) {
                        try {
                            \Illuminate\Support\Facades\DB::table('discipline_reports')->insert([
                                'id' => \Illuminate\Support\Str::uuid()->toString(),
                                'student_id' => $studentId,
                                'reporter_id' => $user->id,
                                'description' => "Pelanggaran di kelas saat KBM {$journal->subject?->name}: {$keterangan}",
                                'status' => 'PENDING',
                                'created_at' => $now,
                                'updated_at' => $now,
                            ]);
                        } catch (\Throwable $err) {
                            \Illuminate\Support\Facades\Log::error("Gagal sinkron pelanggaran disiplin: " . $err->getMessage());
                        }
                    }
                }
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Laporan Jurnal Mengajar berhasil disimpan dan KBM dinyatakan Selesai.',
                'data' => [
                    'journal_id' => $journal->id,
                    'filled_at' => $now->toIso8601String(),
                    'status' => 'Selesai',
                    'class_notes' => $journal->class_notes
                ]
            ]);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            return response()->json(['status' => 'error', 'message' => $ve->getMessage()], 422);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function submitJournal(Request $request)
    {
        $journalId = $request->input('journal_id');
        if ($journalId) {
            return $this->fillJournal($request, $journalId);
        }
        return response()->json(['status' => 'success']);
    }

    public function triggerKbmReminders(Request $request)
    {
        try {
            \Illuminate\Support\Facades\Artisan::call('kbm:check-reminders');
            $output = \Illuminate\Support\Facades\Artisan::output();

            return response()->json([
                'status' => 'success',
                'message' => 'Pemindaian KBM dan pengiriman notifikasi berhasil dijalankan.',
                'output' => $output
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getJournalsBySubject($subjectId)
    {
        try {
            $user = Auth::user();
            
            // Get journals created by this teacher for this subject
            $journals = \App\Models\Journal::whereHas('schedule', function ($q) use ($user, $subjectId) {
                $q->where('teacher_id', $user->id)
                  ->where('subject_id', $subjectId);
            })->get(['id', 'topic_material', 'created_at']);
            
            return response()->json([
                'status' => 'success',
                'data' => $journals
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getGuruJournals()
    {
        try {
            $user = Auth::user();
            
            // 1. Ambil seluruh jadwal mengajar yang diampu guru ini
            $schedules = Schedule::where('teacher_id', $user->id)
                ->with(['subject', 'class.major'])
                ->get();

            // 2. Ambil seluruh jurnal mengajar yang diterbitkan oleh guru ini secara aman
            $withRelations = ['schedule.subject', 'schedule.class', 'subject'];
            if (\Illuminate\Support\Facades\Schema::hasTable('journal_tasks')) {
                $withRelations[] = 'tasks';
            }
            if (\Illuminate\Support\Facades\Schema::hasTable('journal_comments')) {
                $withRelations[] = 'comments';
            }
            if (\Illuminate\Support\Facades\Schema::hasTable('journal_reviews')) {
                $withRelations[] = 'reviews';
            }

            $journals = Journal::where('teacher_id', $user->id)
                ->with($withRelations)
                ->orderBy('teaching_date', 'desc')
                ->get();

            // Ambil ID interaksi guru untuk like & save
            $myLikedIds = collect();
            $mySavedIds = collect();
            if (\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                $myLikedIds = \Illuminate\Support\Facades\DB::table('journal_interactions')
                    ->where('student_id', $user->id)
                    ->where('interaction_type', 'LIKE')
                    ->pluck('journal_id');

                $mySavedIds = \Illuminate\Support\Facades\DB::table('journal_interactions')
                    ->where('student_id', $user->id)
                    ->where('interaction_type', 'SAVE')
                    ->pluck('journal_id');
            }

            $teacherName = $user->full_name ?: ($user->username ?? 'Guru Pengajar');
            $teacherImage = $user->profile_picture ?? null;
            $result = [];

            // A. Petakan data Jurnal yang sudah diterbitkan
            foreach ($journals as $journal) {
                $sched = $journal->schedule ?? null;
                $subjectName = $sched?->subject?->name ?? ($journal->subject?->name ?? 'Mata Pelajaran');
                $startTime = $sched ? $sched->start_time : '07:30:00';
                $endTime = $sched ? $sched->end_time : '09:30:00';
                
                $dayOfWeek = $sched ? $sched->day_of_week : null;
                if ($dayOfWeek === null && $journal->teaching_date) {
                    try {
                        $dayOfWeek = Carbon::parse($journal->teaching_date)->dayOfWeekIso;
                    } catch (\Throwable $e) {}
                }

                $hasTask = (bool)($journal->has_task ?? false);
                $taskId = null;
                $taskTitle = null;
                $taskDueDate = null;
                if ($journal->relationLoaded('tasks') && $journal->tasks && $journal->tasks->isNotEmpty()) {
                    $hasTask = true;
                    $firstTask = $journal->tasks->first();
                    $taskId = $firstTask->id;
                    $taskTitle = $firstTask->title;
                    $taskDueDate = $firstTask->due_date ? Carbon::parse($firstTask->due_date)->locale('id')->isoFormat('D MMM Y, HH:mm') : null;
                }

                $likesCount = 0;
                if (\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                    $likesCount = \Illuminate\Support\Facades\DB::table('journal_interactions')
                        ->where('journal_id', $journal->id)
                        ->where('interaction_type', 'LIKE')
                        ->count();
                }

                $commentsCount = 0;
                if ($journal->relationLoaded('comments') && $journal->comments) {
                    $commentsCount = $journal->comments->count();
                } elseif (\Illuminate\Support\Facades\Schema::hasTable('journal_comments')) {
                    $commentsCount = \Illuminate\Support\Facades\DB::table('journal_comments')->where('journal_id', $journal->id)->count();
                }

                $avgRating = 5.0;
                if ($journal->relationLoaded('reviews') && $journal->reviews && $journal->reviews->isNotEmpty()) {
                    $avgRating = (float)($journal->reviews->avg('rating') ?: 5.0);
                } elseif (\Illuminate\Support\Facades\Schema::hasTable('journal_reviews')) {
                    $avgRating = (float)(\Illuminate\Support\Facades\DB::table('journal_reviews')->where('journal_id', $journal->id)->avg('rating') ?: 5.0);
                }

                $className = $sched?->class ? ($sched->class->grade_level . ' ' . $sched->class->name) : 'Kelas';
                $classId = $sched?->class_id ?? $journal->class_id;

                $journalStatus = 'Belum';
                if (!empty($journal->filled_at) || $journal->status === 'Selesai' || $journal->status === 'COMPLETED') {
                    $journalStatus = 'Selesai';
                } elseif (!empty($journal->check_in_time) || $journal->status === 'Aktif' || $journal->status === 'ONGOING') {
                    $journalStatus = 'Aktif';
                }

                $isFilled = !empty($journal->filled_at) || $journalStatus === 'Selesai';
                $isCheckedIn = !empty($journal->check_in_time);

                $result[] = [
                    'id' => $journal->id,
                    'schedule_id' => $journal->schedule_id,
                    'type' => 'journal',
                    'status' => $journalStatus,
                    'topic' => $journal->topic_material,
                    'description' => $journal->description ?: $journal->topic_material,
                    'created_at' => $journal->created_at ? $journal->created_at->toIso8601String() : null,
                    'teaching_date' => $journal->teaching_date ? Carbon::parse($journal->teaching_date)->format('Y-m-d') : null,
                    'subject' => $subjectName,
                    'class_name' => $className,
                    'class_id' => $classId,
                    'subject_id' => $sched?->subject_id ?? $journal->subject_id,
                    'teacher' => $teacherName,
                    'teacher_image' => $teacherImage,
                    'start_time' => $startTime,
                    'end_time' => $endTime,
                    'day_of_week' => $dayOfWeek,
                    'has_task' => $hasTask,
                    'task_id' => $taskId,
                    'task_title' => $taskTitle,
                    'task_due_date' => $taskDueDate,
                    'attachment_url' => $journal->attachment_url ?? null,
                    'check_in_time' => $journal->check_in_time ? Carbon::parse($journal->check_in_time)->format('H:i') : null,
                    'filled_at' => $journal->filled_at ? Carbon::parse($journal->filled_at)->format('H:i') : null,
                    'class_notes' => $journal->class_notes,
                    'is_checked_in' => $isCheckedIn,
                    'is_filled' => $isFilled,
                    'can_fill' => $isCheckedIn && !$isFilled,
                    'likes' => $likesCount,
                    'is_liked' => $myLikedIds->contains($journal->id),
                    'is_saved' => $mySavedIds->contains($journal->id),
                    'comments' => $commentsCount,
                    'rating' => (float)round($avgRating, 1),
                    'has_rated' => false,
                    'my_rating' => null
                ];
            }

            // B. Petakan Jadwal Mengajar Reguler mingguan guru (Jurnal Cangkang)
            foreach ($schedules as $sched) {
                // Abaikan kegiatan non-mapel (KEG) karena tidak memerlukan penerbitan jurnal
                if (!empty($sched->activity_name) || empty($sched->subject_id) || ($sched->subject && $sched->subject->code === 'KEG')) {
                    continue;
                }

                $subjectName = $sched->subject?->name ?? 'Mata Pelajaran';
                $className = $sched->class ? ($sched->class->grade_level . ' ' . $sched->class->name) : 'Kelas';

                $result[] = [
                    'id' => 'sched_' . $sched->id,
                    'schedule_id' => $sched->id,
                    'subject_id' => $sched->subject_id,
                    'subject_code' => $sched->subject?->code ?? '',
                    'activity_name' => $sched->activity_name ?? null,
                    'class_id' => $sched->class_id,
                    'class_name' => $className,
                    'type' => 'schedule',
                    'topic' => 'Jadwal Mengajar: ' . $subjectName . ' (' . $className . ')',
                    'description' => 'Materi pembelajaran belum dipublikasikan oleh Anda untuk sesi ini.',
                    'created_at' => $sched->created_at ? $sched->created_at->toIso8601String() : null,
                    'teaching_date' => null,
                    'subject' => $subjectName,
                    'teacher' => $teacherName,
                    'teacher_image' => $teacherImage,
                    'start_time' => $sched->start_time,
                    'end_time' => $sched->end_time,
                    'day_of_week' => $sched->day_of_week,
                    'has_task' => false,
                    'task_title' => null,
                    'attachment_url' => null,
                    'likes' => 0,
                    'is_liked' => false,
                    'is_saved' => false,
                    'comments' => 0,
                    'rating' => 5.0,
                    'has_rated' => false,
                    'my_rating' => null
                ];
            }

            return response()->json([
                'status' => 'success',
                'data' => $result
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getOffDays(Request $request)
    {
        try {
            // 1. Ambil setting hari nonaktif mingguan sekolah dari database school_settings
            $offDaysSetting = \Illuminate\Support\Facades\DB::table('school_settings')
                ->where('setting_key', 'school_off_days')
                ->value('setting_value');

            $offDays = [];
            if ($offDaysSetting) {
                $decoded = json_decode($offDaysSetting, true);
                if (is_array($decoded)) {
                    $offDays = $decoded;
                }
            }

            // Jika belum ada di school_settings, ambil hari yang tidak ada jadwal KBM sama sekali di database schedules
            if (empty($offDays)) {
                $activeDays = Schedule::pluck('day_of_week')
                    ->filter()
                    ->map(fn($d) => ucfirst(strtolower(trim($d))))
                    ->unique()
                    ->toArray();

                $allDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                $offDays = array_values(array_diff($allDays, $activeDays));
                if (empty($offDays)) {
                    $offDays = ['Minggu'];
                }
            }

            // 2. Ambil tanggal rilis resmi aplikasi dari school_settings (default 26 Oktober 2026)
            $releaseDateSetting = \Illuminate\Support\Facades\DB::table('school_settings')
                ->where('setting_key', 'app_release_date')
                ->value('setting_value') ?: '2026-10-26';

            $releaseDate = \Carbon\Carbon::parse($releaseDateSetting)->startOfDay();
            $releaseMonday = $releaseDate->copy()->startOfWeek();

            // 3. Tentukan hari nonaktif pertama dan kalkulasi reset mingguan (jam 01.00)
            $dayToIso = [
                'senin' => 1, 'monday' => 1,
                'selasa' => 2, 'tuesday' => 2,
                'rabu' => 3, 'wednesday' => 3,
                'kamis' => 4, 'thursday' => 4,
                'jumat' => 5, 'friday' => 5,
                'sabtu' => 6, 'saturday' => 6,
                'minggu' => 7, 'sunday' => 7,
            ];
            $isoToDay = [
                1 => 'Senin',
                2 => 'Selasa',
                3 => 'Rabu',
                4 => 'Kamis',
                5 => 'Jumat',
                6 => 'Sabtu',
                7 => 'Minggu',
            ];

            $offDayIsos = [];
            $normalizedOffDays = [];
            foreach ($offDays as $d) {
                $clean = strtolower(trim($d));
                if (isset($dayToIso[$clean])) {
                    $iso = $dayToIso[$clean];
                    $offDayIsos[] = $iso;
                    $normalizedOffDays[] = $isoToDay[$iso];
                } else {
                    $normalizedOffDays[] = ucfirst($clean);
                }
            }
            sort($offDayIsos);
            $normalizedOffDays = array_values(array_unique($normalizedOffDays));
            if (empty($offDayIsos)) {
                $offDayIsos = [7];
                $normalizedOffDays = ['Minggu'];
            }

            // Hari nonaktif pertama (misal: Sabtu jika Sabtu-Minggu libur, atau Minggu jika hanya Minggu)
            $firstOffDayIso = !empty($offDayIsos) ? $offDayIsos[0] : 7;
            $firstOffDayName = $isoToDay[$firstOffDayIso] ?? 'Minggu';

            $now = \Carbon\Carbon::now();
            $todayIso = $now->dayOfWeekIso;

            // Logika Reset Mingguan pada pukul 01.00 di hari nonaktif pertama:
            // Jika hari ini setelah hari nonaktif pertama ATAU tepat hari nonaktif pertama dan sudah jam 01.00+:
            // Siklus filter tanggal per item berganti/reset ke pekan berikutnya (Senin depan).
            $hasRolledOver = false;
            if ($todayIso > $firstOffDayIso) {
                $hasRolledOver = true;
            } elseif ($todayIso === $firstOffDayIso && $now->hour >= 1) {
                $hasRolledOver = true;
            }

            if ($hasRolledOver) {
                $activeWeekStart = $now->copy()->addWeek()->startOfWeek();
            } else {
                $activeWeekStart = $now->copy()->startOfWeek();
            }

            // Kunci: Tidak boleh lebih mundur dari tanggal rilis resmi (26 Oktober 2026)
            if ($activeWeekStart->lt($releaseMonday)) {
                $activeWeekStart = $releaseMonday;
            }

            $activeWeekStartStr = $activeWeekStart->format('Y-m-d');

            // 4. Ambil daftar tanggal hari libur aktif dari tabel holidays
            $holidays = collect();
            if (\Illuminate\Support\Facades\Schema::hasTable('holidays')) {
                $holidays = \App\Models\SchoolHoliday::where('is_active', true)
                    ->get(['id', 'name', 'start_date', 'end_date', 'type', 'description']);
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'off_weekdays' => $normalizedOffDays,
                    'first_off_day' => $firstOffDayName,
                    'reset_time' => '01:00',
                    'current_week_start' => $activeWeekStartStr,
                    'app_release_date' => $releaseDateSetting,
                    'holidays' => $holidays,
                ]
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getSiswaJournals()
    {
        try {
            $user = Auth::user();
            $classStudent = \App\Models\ClassStudent::where('student_id', $user->id)
                ->where('status', 'ACTIVE')
                ->first();
                
            if (!$classStudent) {
                return response()->json(['status' => 'success', 'data' => []]);
            }
            
            $classId = $classStudent->class_id;

            // 1. Ambil seluruh jadwal reguler untuk kelas siswa
            $schedules = collect();
            try {
                $schedules = \App\Models\Schedule::where('class_id', $classId)
                    ->with(['subject', 'teacher'])
                    ->get();
            } catch (\Throwable $e) {}

            // 2. Ambil seluruh jurnal mengajar untuk kelas siswa secara aman
            $journals = collect();
            try {
                $withRelations = ['schedule.subject', 'schedule.teacher', 'schedule.class', 'teacher', 'subject'];
                if (\Illuminate\Support\Facades\Schema::hasTable('journal_tasks')) {
                    $withRelations[] = 'tasks';
                }
                if (\Illuminate\Support\Facades\Schema::hasTable('journal_comments')) {
                    $withRelations[] = 'comments';
                }
                if (\Illuminate\Support\Facades\Schema::hasTable('journal_reviews')) {
                    $withRelations[] = 'reviews';
                }

                $journals = \App\Models\Journal::where(function ($query) use ($classId) {
                    $query->where('class_id', $classId)
                          ->orWhereHas('schedule', function ($q) use ($classId) {
                              $q->where('class_id', $classId);
                          });
                })
                ->with($withRelations)
                ->orderBy('teaching_date', 'desc')
                ->get();
            } catch (\Throwable $e) {
                try {
                    $journals = \App\Models\Journal::where('class_id', $classId)
                        ->orWhereHas('schedule', function ($q) use ($classId) {
                            $q->where('class_id', $classId);
                        })
                        ->with(['schedule.subject', 'schedule.teacher', 'teacher', 'subject'])
                        ->get();
                } catch (\Throwable $ex) {}
            }

            // Ambil ID interaksi siswa untuk like, save, dan review
            $myLikedIds = collect();
            $mySavedIds = collect();
            if (\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                $myLikedIds = \Illuminate\Support\Facades\DB::table('journal_interactions')
                    ->where('student_id', $user->id)
                    ->where('interaction_type', 'LIKE')
                    ->pluck('journal_id');

                $mySavedIds = \Illuminate\Support\Facades\DB::table('journal_interactions')
                    ->where('student_id', $user->id)
                    ->where('interaction_type', 'SAVE')
                    ->pluck('journal_id');
            }

            $myReviews = collect();
            if (\Illuminate\Support\Facades\Schema::hasTable('journal_reviews')) {
                $myReviews = \Illuminate\Support\Facades\DB::table('journal_reviews')
                    ->where('student_id', $user->id)
                    ->pluck('rating', 'journal_id');
            }

            $result = [];

            // A. Petakan data Jurnal yang sudah terbit
            foreach ($journals as $journal) {
                $sched = $journal->schedule ?? null;
                $teacher = $journal->teacher ?: ($sched ? $sched->teacher : null);
                $teacherName = $teacher?->full_name ?: ($teacher?->username ?? 'Guru Pengajar');
                
                $subjectName = $sched?->subject?->name ?? ($journal->subject?->name ?? 'Mata Pelajaran');
                $startTime = $sched ? $sched->start_time : '07:30:00';
                $endTime = $sched ? $sched->end_time : '09:30:00';
                
                $dayOfWeek = $sched ? $sched->day_of_week : null;
                if ($dayOfWeek === null && $journal->teaching_date) {
                    try {
                        $dayOfWeek = Carbon::parse($journal->teaching_date)->dayOfWeekIso;
                    } catch (\Throwable $e) {}
                }

                $hasTask = (bool)($journal->has_task ?? false);
                $taskId = null;
                $taskTitle = null;
                $taskDueDate = null;
                try {
                    if ($journal->relationLoaded('tasks') && $journal->tasks && $journal->tasks->isNotEmpty()) {
                        $hasTask = true;
                        $firstTask = $journal->tasks->first();
                        $taskId = $firstTask->id;
                        $taskTitle = $firstTask->title;
                        $taskDueDate = $firstTask->due_date ? Carbon::parse($firstTask->due_date)->locale('id')->isoFormat('D MMM Y, HH:mm') : null;
                    }
                } catch (\Throwable $e) {}

                $likesCount = 0;
                try {
                    if (\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                        $likesCount = \Illuminate\Support\Facades\DB::table('journal_interactions')
                            ->where('journal_id', $journal->id)
                            ->where('interaction_type', 'LIKE')
                            ->count();
                    }
                } catch (\Throwable $e) {}

                $commentsCount = 0;
                try {
                    if ($journal->relationLoaded('comments') && $journal->comments) {
                        $commentsCount = $journal->comments->count();
                    } elseif (\Illuminate\Support\Facades\Schema::hasTable('journal_comments')) {
                        $commentsCount = \Illuminate\Support\Facades\DB::table('journal_comments')->where('journal_id', $journal->id)->count();
                    }
                } catch (\Throwable $e) {}

                $avgRating = 5.0;
                try {
                    if ($journal->relationLoaded('reviews') && $journal->reviews && $journal->reviews->isNotEmpty()) {
                        $avgRating = (float)($journal->reviews->avg('rating') ?: 5.0);
                    } elseif (\Illuminate\Support\Facades\Schema::hasTable('journal_reviews')) {
                        $avgRating = (float)(\Illuminate\Support\Facades\DB::table('journal_reviews')->where('journal_id', $journal->id)->avg('rating') ?: 5.0);
                    }
                } catch (\Throwable $e) {}

                $hasRated = $myReviews->has($journal->id);
                $myRating = $hasRated ? (int)$myReviews->get($journal->id) : null;

                $result[] = [
                    'id' => $journal->id,
                    'schedule_id' => $journal->schedule_id,
                    'type' => 'journal',
                    'status' => $journal->status ?: 'Aktif',
                    'topic' => $journal->topic_material,
                    'description' => $journal->description ?: $journal->topic_material,
                    'created_at' => $journal->created_at ? $journal->created_at->toIso8601String() : null,
                    'teaching_date' => $journal->teaching_date ? Carbon::parse($journal->teaching_date)->format('Y-m-d') : null,
                    'subject' => $subjectName,
                    'class_name' => $sched?->class ? ($sched->class->grade_level . ' ' . $sched->class->name) : 'Kelas',
                    'class_id' => $sched?->class_id ?? $journal->class_id,
                    'teacher' => $teacherName,
                    'teacher_image' => $teacher?->profile_picture ?? null,
                    'start_time' => $startTime,
                    'end_time' => $endTime,
                    'day_of_week' => $dayOfWeek,
                    'has_task' => $hasTask,
                    'task_id' => $taskId,
                    'task_title' => $taskTitle,
                    'task_due_date' => $taskDueDate,
                    'attachment_url' => $journal->attachment_url ?? null,
                    'likes' => $likesCount,
                    'is_liked' => $myLikedIds->contains($journal->id),
                    'is_saved' => $mySavedIds->contains($journal->id),
                    'comments' => $commentsCount,
                    'rating' => (float)round($avgRating, 1),
                    'has_rated' => $hasRated,
                    'my_rating' => $myRating
                ];
            }

            // B. Siswa HANYA melihat jurnal yang SUDAH DITERBITKAN oleh guru pengampu
            // Cangkang jadwal yang belum diterbitkan dihilangkan dari feed siswa agar tidak rancu

            return response()->json([
                'status' => 'success',
                'data' => $result
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    protected function resolveJournal($journalId, $targetDate = null)
    {
        if (str_starts_with($journalId, 'sched_')) {
            $scheduleId = substr($journalId, 6);
            $schedule = Schedule::with(['subject'])->findOrFail($scheduleId);
            $date = $targetDate ?: Carbon::today()->format('Y-m-d');

            $journal = Journal::where('schedule_id', $scheduleId)
                ->whereDate('teaching_date', $date)
                ->first();

            if (!$journal) {
                $journal = new Journal();
                $journal->schedule_id = $schedule->id;
                $journal->class_id = $schedule->class_id;
                $journal->subject_id = $schedule->subject_id;
                $journal->teacher_id = $schedule->teacher_id;
                $journal->teaching_date = $date;
                $journal->topic_material = 'Pembelajaran ' . ($schedule->subject?->name ?? 'Mata Pelajaran');
                $journal->description = 'Sesi pembelajaran ' . ($schedule->subject?->name ?? '');
                $journal->status = 'Aktif';
                $journal->save();
            }
            return $journal;
        }

        return Journal::findOrFail($journalId);
    }

    public function toggleLike(Request $request, $journalId)
    {
        try {
            $user = Auth::user();
            $journal = $this->resolveJournal($journalId);
            $journalId = $journal->id;

            if (\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                $existing = \App\Models\JournalInteraction::where('journal_id', $journalId)
                    ->where('student_id', $user->id)
                    ->where('interaction_type', 'LIKE')
                    ->first();

                if ($existing) {
                    $existing->delete();
                    $liked = false;
                } else {
                    \App\Models\JournalInteraction::create([
                        'journal_id' => $journalId,
                        'student_id' => $user->id,
                        'interaction_type' => 'LIKE'
                    ]);
                    $liked = true;
                }

                $count = \App\Models\JournalInteraction::where('journal_id', $journalId)
                    ->where('interaction_type', 'LIKE')
                    ->count();

                return response()->json([
                    'status' => 'success',
                    'data' => [
                        'liked' => (bool)$liked,
                        'likes_count' => (int)$count
                    ]
                ]);
            }

            return response()->json(['status' => 'success', 'data' => ['liked' => true, 'likes_count' => 1]]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function toggleSave(Request $request, $journalId)
    {
        try {
            $user = Auth::user();
            $journal = $this->resolveJournal($journalId);
            $journalId = $journal->id;

            if (\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                $existing = \App\Models\JournalInteraction::where('journal_id', $journalId)
                    ->where('student_id', $user->id)
                    ->where('interaction_type', 'SAVE')
                    ->first();

                if ($existing) {
                    $existing->delete();
                    $saved = false;
                } else {
                    \App\Models\JournalInteraction::create([
                        'journal_id' => $journalId,
                        'student_id' => $user->id,
                        'interaction_type' => 'SAVE'
                    ]);
                    $saved = true;
                }

                return response()->json([
                    'status' => 'success',
                    'data' => [
                        'saved' => (bool)$saved
                    ]
                ]);
            }

            return response()->json(['status' => 'success', 'data' => ['saved' => true]]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function submitComment(Request $request, $journalId)
    {
        try {
            $request->validate(['comment_text' => 'required|string|max:500']);
            $user = Auth::user();
            $journal = $this->resolveJournal($journalId);
            $journalId = $journal->id;
            $role = $user->role?->name ?? ($user->role_type ?? 'SISWA');

            // Batasi siswa maksimal 1 komentar per sesi materi pembelajaran untuk menjaga ketertiban
            if ($role === 'SISWA') {
                $existing = JournalComment::where('journal_id', $journalId)
                    ->where('user_id', $user->id)
                    ->first();

                if ($existing) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Anda sudah memberikan komentar untuk jurnal ini (maksimal 1 komentar per siswa).'
                    ], 422);
                }
            }

            $comment = JournalComment::create([
                'journal_id' => $journalId,
                'user_id' => $user->id,
                'comment_text' => $request->comment_text
            ]);

            $rawName = $user->siswaProfile?->full_name 
                ?: ($user->guruProfile?->full_name 
                    ?: ($user->full_name ?: ($user->username ?? 'Pengguna')));

            return response()->json([
                'status' => 'success',
                'message' => 'Komentar berhasil dikirim.',
                'data' => [
                    'id' => $comment->id,
                    'journal_id' => $comment->journal_id,
                    'user_id' => $comment->user_id,
                    'author_name' => 'Saya',
                    'raw_author_name' => $rawName,
                    'author_role' => $role,
                    'author_avatar' => $user->profile_picture ?? null,
                    'comment_text' => $comment->comment_text,
                    'created_at' => $comment->created_at ? $comment->created_at->toIso8601String() : now()->toIso8601String(),
                    'is_me' => true,
                    'can_delete' => true
                ]
            ]);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            return response()->json(['status' => 'error', 'message' => $ve->getMessage()], 422);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getComments(Request $request, $journalId)
    {
        try {
            $user = Auth::user();
            if (str_starts_with($journalId, 'sched_')) {
                $scheduleId = substr($journalId, 6);
                $journal = Journal::where('schedule_id', $scheduleId)->whereDate('teaching_date', Carbon::today()->format('Y-m-d'))->first();
                if (!$journal) {
                    return response()->json(['status' => 'success', 'data' => []]);
                }
                $journalId = $journal->id;
            } else {
                $journal = Journal::findOrFail($journalId);
            }

            $isPublisher = $user && ($journal->teacher_id === $user->id);

            $comments = JournalComment::where('journal_id', $journalId)
                ->with(['user.siswaProfile', 'user.guruProfile', 'user.role'])
                ->orderBy('created_at', 'asc')
                ->get()
                ->map(function ($c) use ($user, $isPublisher) {
                    $isMe = $user && $c->user_id === $user->id;
                    $role = $c->user?->role?->name ?? ($c->user?->role_type ?? 'SISWA');
                    $rawName = $c->user?->siswaProfile?->full_name 
                        ?: ($c->user?->guruProfile?->full_name 
                            ?: ($c->user?->full_name ?: ($c->user?->username ?? 'Pengguna')));

                    return [
                        'id' => $c->id,
                        'journal_id' => $c->journal_id,
                        'user_id' => $c->user_id,
                        'author_name' => $rawName,
                        'raw_author_name' => $rawName,
                        'author_role' => $role,
                        'author_avatar' => $c->user?->profile_picture ?? null,
                        'comment_text' => $c->comment_text,
                        'created_at' => $c->created_at ? $c->created_at->toIso8601String() : null,
                        'is_me' => $isMe,
                        'can_delete' => $isMe || $isPublisher,
                    ];
                });

            return response()->json([
                'status' => 'success',
                'data' => $comments
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function deleteComment(Request $request, $journalId, $commentId)
    {
        try {
            $user = Auth::user();
            if (str_starts_with($journalId, 'sched_')) {
                $scheduleId = substr($journalId, 6);
                $journal = Journal::where('schedule_id', $scheduleId)->whereDate('teaching_date', Carbon::today()->format('Y-m-d'))->first();
                if (!$journal) {
                    return response()->json(['status' => 'error', 'message' => 'Not found'], 404);
                }
                $journalId = $journal->id;
            } else {
                $journal = Journal::findOrFail($journalId);
            }

            $comment = JournalComment::where('journal_id', $journalId)
                ->where('id', $commentId)
                ->firstOrFail();

            $isOwner = $comment->user_id === $user->id;
            $isPublisher = $journal->teacher_id === $user->id;

            // Hanya pemilik komentar atau guru penerbit jurnal yang diizinkan menghapus
            if (!$isOwner && !$isPublisher) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki hak untuk menghapus komentar ini.'], 403);
            }

            $comment->delete();
            return response()->json([
                'status' => 'success',
                'message' => 'Komentar berhasil dihapus.'
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function submitRating(Request $request, $journalId)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'review_text' => 'nullable|string'
        ]);

        try {
            $user = Auth::user();
            $journal = $this->resolveJournal($journalId);
            $journalId = $journal->id;

            // Validasi: ulasan ulasan siswa bersifat permanen
            $existing = JournalReview::where('journal_id', $journalId)
                ->where('student_id', $user->id)
                ->first();

            if ($existing) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Anda sudah memberikan penilaian untuk jurnal ini dan tidak dapat mengubahnya.'
                ], 422);
            }

            $review = JournalReview::create([
                'journal_id' => $journalId,
                'student_id' => $user->id,
                'rating' => (int)$request->rating,
                'review_text' => $request->review_text,
            ]);

            $avgRating = JournalReview::where('journal_id', $journalId)->avg('rating') ?: $request->rating;

            return response()->json([
                'status' => 'success',
                'message' => 'Penilaian berhasil disimpan.',
                'data' => [
                    'rating' => (int)$review->rating,
                    'average_rating' => (float)round($avgRating, 1)
                ]
            ]);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            return response()->json(['status' => 'error', 'message' => $ve->getMessage()], 422);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getSiswaTeachers()
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
            }

            $teachers = $this->journalService->getStudentTeachers($user->id);

            return response()->json([
                'status' => 'success',
                'data' => $teachers
            ]);
        } catch (\Throwable $e) {
            \Log::error('Error getSiswaTeachers: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memuat data pengajar: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Endpoint unduh berkas lampiran jurnal secara langsung dan aman
     * Menjamin berkas tetap dapat diunduh baik via storage symlink maupun direct response
     */
    public function downloadAttachment($journalId)
    {
        try {
            $journal = Journal::findOrFail($journalId);

            if (empty($journal->attachment_url)) {
                return response()->json(['status' => 'error', 'message' => 'Jurnal ini tidak memiliki berkas lampiran.'], 404);
            }

            // Path relatif di storage disk public: buang prefix '/storage/'
            $relativePath = ltrim(str_replace('/storage/', '', $journal->attachment_url), '/');

            if (!\Illuminate\Support\Facades\Storage::disk('public')->exists($relativePath)) {
                return response()->json(['status' => 'error', 'message' => 'Berkas fisik tidak ditemukan di server.'], 404);
            }

            $fullPath = \Illuminate\Support\Facades\Storage::disk('public')->path($relativePath);
            $fileName = basename($fullPath);

            return response()->download($fullPath, $fileName, [
                'Access-Control-Expose-Headers' => 'Content-Disposition',
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal mengunduh berkas: ' . $e->getMessage()], 500);
        }
    }
}
