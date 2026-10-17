<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Journal;
use App\Models\JournalTask;
use App\Models\JournalTaskAttachment;
use App\Models\StudentTaskSubmission;
use App\Models\StudentTaskGrade;
use App\Models\ClassStudent;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use App\Services\FileStorageService;
use App\Services\NotificationService;
use Carbon\Carbon;

class AssignmentController extends Controller
{
    /**
     * Guru membuat tugas baru
     */
    public function storeTask(Request $request)
    {
        $request->validate([
            'journal_id' => 'required|exists:journals,id',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'due_date' => 'required|date',
            'attachment' => 'nullable|file|max:20480'
        ]);

        try {
            $task = JournalTask::create([
                'journal_id' => $request->journal_id,
                'title' => $request->title,
                'description' => $request->description,
                'due_date' => $request->due_date
            ]);

            // Sinkronisasi status penugasan di tabel journals
            $journal = Journal::with(['schedule.class', 'schedule.subject'])->find($request->journal_id);
            if ($journal) {
                $journal->update(['has_task' => true]);
            }

            if ($request->hasFile('attachment')) {
                $task->load(['journal.class.academicYear', 'journal.subject']);
                $path = FileStorageService::storeTaskAttachment($request->file('attachment'), $task);
                JournalTaskAttachment::create([
                    'journal_task_id' => $task->id,
                    'attachment_name' => $request->file('attachment')->getClientOriginalName(),
                    'attachment_url' => '/storage/' . $path
                ]);
            }

            // Kirim notifikasi in-app ke seluruh siswa aktif di kelas
            if ($journal && $journal->schedule && $journal->schedule->class_id) {
                try {
                    $teacher = Auth::user();
                    $teacherName = $teacher->full_name ?: ($teacher->username ?? 'Guru');
                    $subjectName = $journal->schedule->subject?->name ?? 'Mata Pelajaran';
                    $dueDateFormatted = Carbon::parse($request->due_date)->locale('id')->isoFormat('D MMMM Y, HH:mm');

                    $notifTitle = "Tugas Baru: {$subjectName}";
                    $notifMessage = "Bpk/Ibu {$teacherName} telah menerbitkan tugas baru: \"{$request->title}\". Tenggat waktu pengumpulan: {$dueDateFormatted} WIB.";

                    $studentIds = ClassStudent::where('class_id', $journal->schedule->class_id)
                        ->where('status', 'ACTIVE')
                        ->pluck('student_id');

                    foreach ($studentIds as $sId) {
                        NotificationService::sendInAppNotification($sId, $notifTitle, $notifMessage);
                    }
                } catch (\Throwable $notifErr) {
                    \Log::warning("Gagal mengirim notif tugas baru: " . $notifErr->getMessage());
                }
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Tugas berhasil dibuat dan dibagikan ke siswa.',
                'data' => $task
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Mengambil daftar tugas untuk guru yang login
     */
    public function getTasks(Request $request)
    {
        try {
            $user = Auth::user();
            $now = Carbon::now();
            
            // 1. Ambil Tugas yang sudah diterbitkan (JournalTask)
            $query = JournalTask::whereHas('journal', function ($q) use ($user) {
                $q->where('teacher_id', $user->id)
                  ->orWhereHas('schedule', function ($sq) use ($user) {
                      $sq->where('teacher_id', $user->id);
                  });
            })
            ->with(['journal.schedule.class.major', 'journal.schedule.subject', 'attachments'])
            ->orderBy('created_at', 'desc');

            if ($request->filled('year')) {
                $query->whereYear('due_date', $request->year);
            }
            if ($request->filled('month')) {
                $monthNum = is_numeric($request->month) 
                    ? (int) $request->month 
                    : (int) date('m', strtotime($request->month . ' 1 2026'));
                if ($monthNum > 0) {
                    $query->whereMonth('due_date', $monthNum);
                }
            }

            $publishedTasks = $query->get()->map(function ($task) use ($now, $user) {
                $schedule = $task->journal->schedule ?? null;
                $classObj = $schedule?->class;
                $className = $classObj ? ($classObj->grade_level . ' ' . $classObj->name) : 'Kelas';
                
                $submittedCount = StudentTaskSubmission::where('journal_task_id', $task->id)->count();
                $gradedCount = StudentTaskSubmission::where('journal_task_id', $task->id)
                    ->whereHas('grade')
                    ->count();
                $totalStudents = $classObj ? ClassStudent::where('class_id', $classObj->id)->where('status', 'ACTIVE')->count() : 0;

                $dueDate = Carbon::parse($task->due_date);
                $isOverdue = $now->gt($dueDate);

                return [
                    'id' => $task->id,
                    'journal_id' => $task->journal_id,
                    'is_cangkang' => false,
                    'status_category' => $isOverdue ? 'COMPLETED' : 'ACTIVE',
                    'title' => $task->title,
                    'description' => $task->description,
                    'due_date' => $task->due_date,
                    'due_date_formatted' => $dueDate->locale('id')->isoFormat('D MMMM Y, HH:mm'),
                    'is_overdue' => $isOverdue,
                    'created_at' => $task->created_at,
                    'subject_name' => $schedule?->subject?->name ?? 'Mata Pelajaran',
                    'subject_id' => $schedule?->subject_id,
                    'class_name' => $className,
                    'class_id' => $classObj?->id,
                    'submitted_count' => $submittedCount,
                    'graded_count' => $gradedCount,
                    'total_students' => $totalStudents,
                    'teacher_id' => $task->journal?->teacher_id ?? $schedule?->teacher_id,
                    'is_publisher' => (($task->journal?->teacher_id && $task->journal->teacher_id === $user->id) || ($schedule?->teacher_id && $schedule->teacher_id === $user->id)),
                    'attachments' => $task->attachments->map(fn($a) => [
                        'id' => $a->id,
                        'name' => $a->attachment_name,
                        'url' => $a->attachment_url
                    ])
                ];
            });

            // 2. Ambil Jurnal Mengajar yang toggle has_task = true tapi BELUM ada tugasnya (Cangkang Tugas / Belum Terbit)
            $pendingJournalsQuery = Journal::where(function ($q) use ($user) {
                $q->where('teacher_id', $user->id)
                  ->orWhereHas('schedule', function ($sq) use ($user) {
                      $sq->where('teacher_id', $user->id);
                  });
            })
            ->where('has_task', true)
            ->whereDoesntHave('tasks')
            ->with(['schedule.class.major', 'schedule.subject'])
            ->orderBy('created_at', 'desc');

            if ($request->filled('year')) {
                $pendingJournalsQuery->whereYear('teaching_date', $request->year);
            }
            if ($request->filled('month')) {
                $monthNum = is_numeric($request->month) 
                    ? (int) $request->month 
                    : (int) date('m', strtotime($request->month . ' 1 2026'));
                if ($monthNum > 0) {
                    $pendingJournalsQuery->whereMonth('teaching_date', $monthNum);
                }
            }

            $cangkangTasks = $pendingJournalsQuery->get()->map(function ($j) use ($user) {
                $schedule = $j->schedule ?? null;
                $classObj = $schedule?->class;
                $className = $classObj ? ($classObj->grade_level . ' ' . $classObj->name) : 'Kelas';
                $totalStudents = $classObj ? ClassStudent::where('class_id', $classObj->id)->where('status', 'ACTIVE')->count() : 0;
                $dateFormatted = $j->teaching_date ? Carbon::parse($j->teaching_date)->locale('id')->isoFormat('D MMMM Y') : '-';

                return [
                    'id' => $j->id, // ID Jurnal sebagai acuan buat tugas
                    'journal_id' => $j->id,
                    'is_cangkang' => true,
                    'status_category' => 'PENDING',
                    'title' => $j->topic_material ?: 'Jurnal Mengajar',
                    'description' => $j->description ?: '',
                    'due_date' => null,
                    'due_date_formatted' => "KBM: {$dateFormatted}",
                    'is_overdue' => false,
                    'created_at' => $j->created_at,
                    'subject_name' => $schedule?->subject?->name ?? 'Mata Pelajaran',
                    'subject_id' => $schedule?->subject_id ?? $j->subject_id,
                    'class_name' => $className,
                    'class_id' => $classObj?->id,
                    'submitted_count' => 0,
                    'graded_count' => 0,
                    'total_students' => $totalStudents,
                    'teacher_id' => $j->teacher_id ?? $schedule?->teacher_id,
                    'is_publisher' => (($j->teacher_id && $j->teacher_id === $user->id) || ($schedule?->teacher_id && $schedule->teacher_id === $user->id)),
                    'attachments' => []
                ];
            });

            // Pisahkan ke dalam 3 kelompok
            $activeList = $publishedTasks->where('status_category', 'ACTIVE')->values();
            $completedList = $publishedTasks->where('status_category', 'COMPLETED')->values();
            $pendingList = $cangkangTasks->values();

            // Gabungan semua untuk kemudahan
            $allTasks = $pendingList->concat($activeList)->concat($completedList)->values();

            return response()->json([
                'status' => 'success',
                'data' => $allTasks,
                'categories' => [
                    'pending' => $pendingList,
                    'active' => $activeList,
                    'completed' => $completedList,
                ],
                'insight' => [
                    'pending_count' => $pendingList->count(),
                    'active_count' => $activeList->count(),
                    'completed_count' => $completedList->count(),
                    'total_count' => $allTasks->count(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Mengambil daftar siswa dan status submission untuk 1 tugas (Untuk Halaman Penilaian Guru)
     */
    public function getTaskSubmissions($taskId)
    {
        try {
            $user = Auth::user();
            $task = JournalTask::with([
                'journal.schedule.class',
                'journal.schedule.subject',
                'attachments'
            ])->findOrFail($taskId);

            $schedule = $task->journal->schedule ?? null;
            if (!$schedule || $schedule->teacher_id !== $user->id) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki hak akses pada tugas ini.'], 403);
            }

            $classId = $schedule->class_id;
            $dueDate = Carbon::parse($task->due_date);

            // Ambil semua siswa di kelas ini
            $classStudents = ClassStudent::where('class_id', $classId)
                ->where('status', 'ACTIVE')
                ->with(['student.siswaProfile'])
                ->get();

            // Ambil seluruh submission untuk tugas ini
            $submissions = StudentTaskSubmission::where('journal_task_id', $taskId)
                ->with('grade')
                ->get()
                ->keyBy('student_id');

            $studentsList = [];
            $submittedCount = 0;
            $gradedCount = 0;

            foreach ($classStudents as $cs) {
                $student = $cs->student;
                if (!$student) continue;

                $submission = $submissions->get($student->id);
                $isSubmitted = $submission !== null;
                $hasGrade = $isSubmitted && $submission->grade !== null;

                if ($isSubmitted) $submittedCount++;
                if ($hasGrade) $gradedCount++;

                $submittedAt = $isSubmitted && $submission->submitted_at ? Carbon::parse($submission->submitted_at) : null;
                $isLate = $submittedAt ? $submittedAt->gt($dueDate) : false;

                $statusText = 'Belum Mengumpulkan';
                if ($hasGrade) {
                    $statusText = 'Sudah Dinilai';
                } elseif ($isSubmitted) {
                    $statusText = $isLate ? 'Mengumpulkan (Terlambat)' : 'Sudah Mengumpulkan';
                }

                $studentsList[] = [
                    'student_id' => $student->id,
                    'nisn' => $student->siswaProfile?->nisn ?? $student->username ?? '-',
                    'name' => $student->full_name ?: ($student->username ?? 'Siswa'),
                    'avatar_url' => $student->profile_picture_url ?? null,
                    'status' => $statusText,
                    'is_submitted' => $isSubmitted,
                    'is_late' => $isLate,
                    'submission_id' => $submission?->id,
                    'submitted_at' => $submittedAt ? $submittedAt->locale('id')->isoFormat('D MMM Y, HH:mm') : null,
                    'answer_text' => $submission?->answer_text,
                    'attachment_url' => $submission?->attachment_url,
                    'score' => $submission?->grade ? (float) $submission->grade->score : null,
                    'feedback' => $submission?->grade?->feedback ?? null,
                    'graded_at' => $submission?->grade?->updated_at ? Carbon::parse($submission->grade->updated_at)->locale('id')->isoFormat('D MMM Y, HH:mm') : null
                ];
            }

            // Urutkan: Yang sudah mengumpulkan dan belum dinilai di atas, lalu dinilai, lalu belum mengumpulkan
            usort($studentsList, function ($a, $b) {
                if ($a['is_submitted'] && !$b['is_submitted']) return -1;
                if (!$a['is_submitted'] && $b['is_submitted']) return 1;
                return strcmp($a['name'], $b['name']);
            });

            return response()->json([
                'status' => 'success',
                'data' => [
                    'task' => [
                        'id' => $task->id,
                        'title' => $task->title,
                        'description' => $task->description,
                        'due_date' => $task->due_date,
                        'due_date_formatted' => $dueDate->locale('id')->isoFormat('dddd, D MMMM Y, HH:mm'),
                        'subject_name' => $schedule->subject?->name ?? 'Mata Pelajaran',
                        'class_name' => ($schedule->class?->grade_level . ' ' . $schedule->class?->name),
                        'total_students' => count($studentsList),
                        'submitted_count' => $submittedCount,
                        'graded_count' => $gradedCount,
                        'attachments' => $task->attachments->map(fn($a) => [
                            'id' => $a->id,
                            'name' => $a->attachment_name,
                            'url' => $a->attachment_url
                        ])
                    ],
                    'students' => $studentsList
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Guru memberikan nilai & feedback untuk submission tugas siswa
     */
    public function gradeSubmission(Request $request, $submissionId)
    {
        $request->validate([
            'score' => 'required|numeric|min:0|max:100',
            'feedback' => 'nullable|string|max:1000'
        ]);

        try {
            $user = Auth::user();
            $submission = StudentTaskSubmission::with(['journalTask.journal.schedule', 'student'])->findOrFail($submissionId);

            $schedule = $submission->journalTask->journal->schedule ?? null;
            if (!$schedule || $schedule->teacher_id !== $user->id) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki hak akses untuk menilai tugas ini.'], 403);
            }

            $grade = StudentTaskGrade::updateOrCreate(
                ['submission_id' => $submission->id],
                [
                    'teacher_id' => $user->id,
                    'score' => $request->score,
                    'feedback' => $request->feedback
                ]
            );

            // Update status submission
            $submission->update(['status' => 'GRADED']);

            // Kirim notifikasi in-app ke siswa
            try {
                $taskTitle = $submission->journalTask->title;
                $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
                $scoreFormatted = number_format($request->score, 0);

                $notifTitle = "Nilai Tugas: {$subjectName}";
                $notifMessage = "Tugas \"{$taskTitle}\" telah dinilai dengan skor {$scoreFormatted}/100." . 
                    ($request->feedback ? " Catatan Guru: \"{$request->feedback}\"" : "");

                NotificationService::sendInAppNotification($submission->student_id, $notifTitle, $notifMessage);
            } catch (\Throwable $notifErr) {
                \Log::warning("Gagal kirim notif nilai tugas: " . $notifErr->getMessage());
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Nilai berhasil disimpan.',
                'data' => [
                    'submission_id' => $submission->id,
                    'score' => (float) $grade->score,
                    'feedback' => $grade->feedback,
                    'graded_at' => Carbon::parse($grade->updated_at)->locale('id')->isoFormat('D MMM Y, HH:mm')
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Guru update data tugas (Judul, Deskripsi, Deadline)
     */
    public function updateTask(Request $request, $id)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'due_date' => 'required|date'
        ]);

        try {
            $user = Auth::user();
            $task = JournalTask::with('journal.schedule')->findOrFail($id);

            $journalTeacherId = $task->journal?->teacher_id;
            $scheduleTeacherId = $task->journal?->schedule?->teacher_id;
            $isOwner = ($journalTeacherId && $journalTeacherId === $user->id) || ($scheduleTeacherId && $scheduleTeacherId === $user->id);

            if (!$isOwner) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki hak akses untuk mengubah tugas ini karena bukan penerbit tugas.'], 403);
            }

            $task->update([
                'title' => $request->title,
                'description' => $request->description,
                'due_date' => $request->due_date
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Tugas berhasil diperbarui.',
                'data' => $task
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Guru menghapus tugas (mengembalikan tugas ke card cangkang / belum terbit)
     */
    public function deleteTask($id)
    {
        try {
            $user = Auth::user();
            $task = JournalTask::with(['journal.schedule', 'attachments'])->findOrFail($id);

            $journalTeacherId = $task->journal?->teacher_id;
            $scheduleTeacherId = $task->journal?->schedule?->teacher_id;
            $isOwner = ($journalTeacherId && $journalTeacherId === $user->id) || ($scheduleTeacherId && $scheduleTeacherId === $user->id);

            if (!$isOwner) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki hak akses untuk menghapus tugas ini karena bukan penerbit tugas.'], 403);
            }

            $journalId = $task->journal_id;
            
            // Hapus lampiran tugas terlebih dahulu
            $task->attachments()->delete();
            $task->delete();

            // Poin 2: Kembalikan status jurnal ke cangkang (has_task = true)
            // Sehingga tugas kembali muncul di tab "Belum" sebagai cangkang, bukan terhapus total
            if ($journalId) {
                Journal::where('id', $journalId)->update(['has_task' => true]);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Tugas berhasil dihapus dan dikembalikan ke status belum terbit (cangkang tugas).'
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Mengambil daftar tugas untuk Siswa
     */
    public function getSiswaTasks(Request $request)
    {
        try {
            $user = Auth::user();
            $classStudent = ClassStudent::where('student_id', $user->id)
                ->where('status', 'ACTIVE')
                ->first();
                
            if (!$classStudent) {
                return response()->json([
                    'status' => 'success',
                    'data' => [],
                    'meta' => [
                        'total' => 0,
                        'belum' => 0,
                        'selesai' => 0,
                        'terlewat' => 0,
                        'minggu_ini' => 0,
                    ]
                ]);
            }
            
            $classId = $classStudent->class_id;

            $query = JournalTask::whereHas('journal.schedule', function ($q) use ($classId) {
                $q->where('class_id', $classId);
            })
            ->with([
                'journal.schedule.subject',
                'journal.schedule.teacher.guruProfile',
                'attachments',
                'submissions' => function ($q) use ($user) {
                    $q->where('student_id', $user->id)->with('grade');
                }
            ]);

            if ($request->filled('year')) {
                $query->whereYear('due_date', $request->year);
            }
            if ($request->filled('month')) {
                $monthNum = is_numeric($request->month) 
                    ? (int) $request->month 
                    : (int) date('m', strtotime($request->month . ' 1 2026'));
                if ($monthNum > 0) {
                    $query->whereMonth('due_date', $monthNum);
                }
            }

            $tasks = $query->orderBy('due_date', 'asc')->get();

            $now = now();
            $startOfWeek = now()->startOfWeek();
            $endOfWeek = now()->endOfWeek();

            $belumCount = 0;
            $selesaiCount = 0;
            $terlewatCount = 0;
            $mingguIniCount = 0;

            $mappedTasks = $tasks->map(function ($task) use ($user, $now, $startOfWeek, $endOfWeek, &$belumCount, &$selesaiCount, &$terlewatCount, &$mingguIniCount) {
                $sched = $task->journal->schedule ?? null;
                $teacher = $sched?->teacher;
                $teacherName = $teacher ? ($teacher->full_name ?: $teacher->username) : 'Guru Pengampu';
                $teacherAvatar = $teacher?->profile_picture_url ?? null;
                
                $submission = $task->submissions->first();
                $isSubmitted = $submission !== null;
                $dueDate = Carbon::parse($task->due_date);
                
                if ($dueDate->between($startOfWeek, $endOfWeek)) {
                    $mingguIniCount++;
                }

                if ($isSubmitted) {
                    $status = 'Selesai Dikerjakan';
                    $selesaiCount++;
                } elseif ($now->gt($dueDate)) {
                    $status = 'Terlewat';
                    $terlewatCount++;
                } else {
                    $status = 'Belum Dikerjakan';
                    $belumCount++;
                }

                $attachments = $task->attachments->map(function ($att) {
                    return [
                        'id' => $att->id,
                        'name' => $att->attachment_name ?? $att->file_name ?? 'Lampiran_Materi.pdf',
                        'url' => $att->attachment_url ?? $att->file_url ?? '',
                    ];
                });

                return [
                    'id' => $task->id,
                    'title' => $task->title,
                    'description' => $task->description ?? '',
                    'due_date' => $task->due_date,
                    'due_date_formatted' => $dueDate->locale('id')->isoFormat('D MMM Y, HH:mm'),
                    'subject' => $sched?->subject?->name ?? 'Mata Pelajaran',
                    'teacher' => $teacherName,
                    'teacher_avatar' => $teacherAvatar,
                    'status' => $status,
                    'is_submitted' => $isSubmitted,
                    'submission' => $submission ? [
                        'id' => $submission->id,
                        'status' => $submission->status,
                        'answer_text' => $submission->answer_text,
                        'attachment_url' => $submission->attachment_url,
                        'submitted_at' => $submission->submitted_at ? Carbon::parse($submission->submitted_at)->locale('id')->isoFormat('D MMM Y, HH:mm') : null,
                        'score' => $submission->grade ? (float) $submission->grade->score : null,
                        'feedback' => $submission->grade?->feedback ?? null,
                    ] : null,
                    'attachments' => $attachments,
                    'created_at' => $task->created_at,
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $mappedTasks,
                'meta' => [
                    'total' => $mappedTasks->count(),
                    'belum' => $belumCount,
                    'selesai' => $selesaiCount,
                    'terlewat' => $terlewatCount,
                    'minggu_ini' => $mingguIniCount,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Siswa mengumpulkan tugas
     */
    public function submitTask(Request $request)
    {
        $request->validate([
            'journal_task_id' => 'required|exists:journal_tasks,id',
            'answer_text' => 'nullable|string',
            'attachment' => 'nullable|file|max:20480'
        ]);

        try {
            $user = Auth::user();
            $task = JournalTask::with(['journal.class.academicYear', 'journal.subject'])->findOrFail($request->journal_task_id);

            $attachmentUrl = null;
            if ($request->hasFile('attachment')) {
                $user->loadMissing('siswaProfile');
                $path = FileStorageService::storeTaskSubmission($request->file('attachment'), $task, $user);
                $attachmentUrl = '/storage/' . $path;
            }

            $submissionData = [
                'status' => 'SUBMITTED',
                'answer_text' => $request->answer_text,
                'submitted_at' => now(),
            ];

            if ($attachmentUrl) {
                $submissionData['attachment_url'] = $attachmentUrl;
            }

            $submission = StudentTaskSubmission::updateOrCreate(
                [
                    'journal_task_id' => $task->id,
                    'student_id' => $user->id,
                ],
                $submissionData
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Tugas berhasil dikumpulkan!',
                'data' => $submission
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}

