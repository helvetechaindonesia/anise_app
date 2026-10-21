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
use App\Models\TaskLateSubmissionRequest;
use App\Models\Notification;
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
                $task->load(['journal.class.academicYear', 'journal.schedule.class.academicYear', 'journal.subject', 'journal.schedule.subject']);
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
                    $notifData = [
                        'type' => 'task',
                        'task_id' => $task->id,
                        'task_title' => $request->title,
                        'subject_name' => $subjectName,
                        'teacher_name' => $teacherName,
                        'due_date_formatted' => $dueDateFormatted,
                    ];
                    $notifMessage = "Bpk/Ibu {$teacherName} telah menerbitkan tugas baru: \"{$request->title}\". Tenggat waktu pengumpulan: {$dueDateFormatted} WIB.\n<!--DATA:" . json_encode($notifData) . "-->";

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

            // Ambil permohonan keterlambatan tugas untuk tugas ini
            $lateRequests = TaskLateSubmissionRequest::where('journal_task_id', $taskId)
                ->orderBy('created_at', 'desc')
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

                // Cek status permohonan terlambat
                $lateReq = $lateRequests->get($student->id);
                $lateReqData = null;
                if ($lateReq) {
                    $lateReqData = [
                        'id' => $lateReq->id,
                        'reason' => $lateReq->reason,
                        'status' => $lateReq->status,
                        'teacher_note' => $lateReq->teacher_note,
                        'extended_until' => $lateReq->extended_until?->toIso8601String(),
                        'extended_until_formatted' => $lateReq->extended_until ? Carbon::parse($lateReq->extended_until)->locale('id')->isoFormat('D MMM Y, HH:mm') : null,
                        'created_at_formatted' => $lateReq->created_at ? Carbon::parse($lateReq->created_at)->locale('id')->isoFormat('D MMM Y, HH:mm') : null,
                    ];
                }

                $statusText = 'Belum Mengumpulkan';
                if ($hasGrade) {
                    $statusText = 'Sudah Dinilai';
                } elseif ($isSubmitted) {
                    $statusText = $isLate ? 'Mengumpulkan (Terlambat)' : 'Sudah Mengumpulkan';
                } elseif ($lateReq && $lateReq->status === 'PENDING') {
                    $statusText = 'Menunggu Konfirmasi Keterlambatan';
                } elseif ($lateReq && $lateReq->status === 'APPROVED') {
                    $statusText = 'Izin Keterlambatan Diberikan';
                } elseif ($lateReq && $lateReq->status === 'REJECTED') {
                    $statusText = 'Permohonan Ditolak';
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
                    'submitted_at' => $submittedAt ? $submittedAt->format('d/m/Y, H:i') : null,
                    'answer_text' => $submission?->answer_text,
                    'attachment_url' => $submission?->attachment_url,
                    'score' => $submission?->grade ? (float) $submission->grade->score : null,
                    'feedback' => $submission?->grade?->feedback ?? null,
                    'graded_at' => $submission?->grade?->updated_at ? Carbon::parse($submission->grade->updated_at)->format('d/m/Y, H:i') : null,
                    'late_request' => $lateReqData,
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

            $existingGrade = StudentTaskGrade::where('submission_id', $submission->id)->first();
            $isEditingScore = $existingGrade !== null;

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
                $task = $submission->journalTask;
                $taskTitle = $task->title;
                $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
                $teacherName = $user->full_name ?: ($user->username ?? 'Guru');
                $scoreFormatted = number_format($request->score, 0);

                $notifData = [
                    'type' => 'task',
                    'task_id' => $task->id,
                    'task_title' => $taskTitle,
                    'subject_name' => $subjectName,
                    'teacher_name' => $teacherName,
                    'due_date_formatted' => Carbon::parse($task->due_date)->locale('id')->isoFormat('D MMM Y, HH:mm'),
                ];

                if ($isEditingScore) {
                    $notifTitle = "Nilai Tugas Diperbarui: {$subjectName}";
                    $notifMessage = "Guru {$teacherName} telah memperbarui nilai tugas \"{$taskTitle}\" menjadi skor {$scoreFormatted}/100." . 
                        ($request->feedback ? " Catatan Guru: \"{$request->feedback}\"" : "") .
                        "\n<!--DATA:" . json_encode($notifData) . "-->";
                } else {
                    $notifTitle = "Nilai Tugas: {$subjectName}";
                    $notifMessage = "Tugas \"{$taskTitle}\" telah dinilai dengan skor {$scoreFormatted}/100." . 
                        ($request->feedback ? " Catatan Guru: \"{$request->feedback}\"" : "") .
                        "\n<!--DATA:" . json_encode($notifData) . "-->";
                }

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
            'due_date' => 'required|date',
            'attachment' => 'nullable|file|max:20480'
        ]);

        try {
            $user = Auth::user();
            $task = JournalTask::with(['journal.schedule.class.academicYear', 'journal.subject', 'attachments'])->findOrFail($id);

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

            // Jika ada lampiran baru yang diunggah saat edit tugas
            if ($request->hasFile('attachment')) {
                // Hapus lampiran lama
                foreach ($task->attachments as $oldAtt) {
                    $oldPath = ltrim(str_replace('/storage/', '', $oldAtt->attachment_url ?? $oldAtt->file_url ?? ''), '/');
                    if (!empty($oldPath) && \Illuminate\Support\Facades\Storage::disk('public')->exists($oldPath)) {
                        \Illuminate\Support\Facades\Storage::disk('public')->delete($oldPath);
                    }
                    $oldAtt->delete();
                }

                $path = FileStorageService::storeTaskAttachment($request->file('attachment'), $task);
                JournalTaskAttachment::create([
                    'journal_task_id' => $task->id,
                    'attachment_name' => $request->file('attachment')->getClientOriginalName(),
                    'attachment_url' => '/storage/' . $path
                ]);
            }

            $task->load('attachments');

            // Kirim notifikasi ke seluruh siswa di kelas bahwa tugas telah diperbarui
            $classId = $task->journal?->schedule?->class_id ?? $task->journal?->class_id;
            if ($classId) {
                try {
                    $teacherName = $user->full_name ?: ($user->username ?? 'Guru');
                    $subjectName = $task->journal?->schedule?->subject?->name ?? ($task->journal?->subject?->name ?? 'Mata Pelajaran');
                    $dueDateFormatted = Carbon::parse($task->due_date)->locale('id')->isoFormat('D MMMM Y, HH:mm');

                    $notifTitle = "Pembaruan Tugas: {$subjectName}";
                    $notifData = [
                        'type' => 'task',
                        'task_id' => $task->id,
                        'task_title' => $task->title,
                        'subject_name' => $subjectName,
                        'teacher_name' => $teacherName,
                        'due_date_formatted' => $dueDateFormatted,
                    ];
                    $notifMessage = "Guru {$teacherName} telah memperbarui rincian/tenggat tugas \"{$task->title}\" ({$subjectName}). Tenggat saat ini: {$dueDateFormatted} WIB. Silakan periksa kembali detail tugas Anda.\n<!--DATA:" . json_encode($notifData) . "-->";

                    $studentIds = ClassStudent::where('class_id', $classId)
                        ->where('status', 'ACTIVE')
                        ->pluck('student_id');

                    foreach ($studentIds as $sId) {
                        NotificationService::sendInAppNotification($sId, $notifTitle, $notifMessage);
                    }
                } catch (\Throwable $notifErr) {
                    \Log::warning("Gagal mengirim notif pembaruan tugas: " . $notifErr->getMessage());
                }
            }

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
     * Endpoint unduh berkas lampiran penugasan secara langsung dan aman
     * Format nama berkas: namaTugas_namaUserPenerbit_tanggal_bulan_tahun.{ext}
     */
    public function downloadTaskAttachment($attachmentId)
    {
        try {
            $attachment = JournalTaskAttachment::with([
                'journalTask.journal.teacher',
                'journalTask.journal.schedule.teacher'
            ])->findOrFail($attachmentId);
            $url = $attachment->attachment_url ?? $attachment->file_url;

            if (empty($url)) {
                return response()->json(['status' => 'error', 'message' => 'Berkas lampiran tidak ditemukan.'], 404);
            }

            $relativePath = ltrim(str_replace('/storage/', '', $url), '/');

            if (!\Illuminate\Support\Facades\Storage::disk('public')->exists($relativePath)) {
                return response()->json(['status' => 'error', 'message' => 'Berkas fisik tidak ditemukan di server.'], 404);
            }

            $fullPath = \Illuminate\Support\Facades\Storage::disk('public')->path($relativePath);
            $ext = pathinfo($fullPath, PATHINFO_EXTENSION) ?: 'pdf';

            // Parameter nama: namaTugas_namaUserPenerbit_tanggal_bulan_tahun
            $task = $attachment->journalTask;
            $taskTitle = $task?->title ?? 'Tugas';
            $teacher = $task?->journal?->teacher ?? $task?->journal?->schedule?->teacher;
            $teacherName = $teacher ? ($teacher->full_name ?: $teacher->username) : 'Guru';
            $dateFormatted = Carbon::parse($attachment->created_at ?? $task?->created_at ?? now())->format('d_m_Y');

            $slugTask = \Illuminate\Support\Str::slug($taskTitle, '_');
            $slugTeacher = \Illuminate\Support\Str::slug($teacherName, '_');
            $fileName = "{$slugTask}_{$slugTeacher}_{$dateFormatted}.{$ext}";

            return response()->download($fullPath, $fileName, [
                'Access-Control-Expose-Headers' => 'Content-Disposition',
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal mengunduh berkas: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Endpoint unduh berkas jawaban tugas siswa secara langsung dan aman
     * Format nama berkas: namaUserYangMengumpulkan_namaTugas_tanggal_bulan_tahun.{ext}
     */
    public function downloadSubmissionAttachment($submissionId)
    {
        try {
            $submission = StudentTaskSubmission::with(['student', 'journalTask'])->findOrFail($submissionId);
            $url = $submission->attachment_url;

            if (empty($url)) {
                return response()->json(['status' => 'error', 'message' => 'Berkas jawaban siswa tidak ditemukan.'], 404);
            }

            $relativePath = ltrim(str_replace('/storage/', '', $url), '/');

            if (!\Illuminate\Support\Facades\Storage::disk('public')->exists($relativePath)) {
                return response()->json(['status' => 'error', 'message' => 'Berkas fisik jawaban tidak ditemukan di server.'], 404);
            }

            $fullPath = \Illuminate\Support\Facades\Storage::disk('public')->path($relativePath);
            $ext = pathinfo($fullPath, PATHINFO_EXTENSION) ?: 'pdf';

            // Parameter nama: namaUserYangMengumpulkan_namaTugas_tanggal_bulan_tahun
            $studentName = $submission->student?->full_name ?: ($submission->student?->username ?? 'Siswa');
            $taskTitle = $submission->journalTask?->title ?? 'Tugas';
            $dateFormatted = Carbon::parse($submission->submitted_at ?? $submission->updated_at ?? now())->format('d_m_Y');

            $slugStudent = \Illuminate\Support\Str::slug($studentName, '_');
            $slugTask = \Illuminate\Support\Str::slug($taskTitle, '_');
            $fileName = "{$slugStudent}_{$slugTask}_{$dateFormatted}.{$ext}";

            return response()->download($fullPath, $fileName, [
                'Access-Control-Expose-Headers' => 'Content-Disposition',
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal mengunduh berkas jawaban: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Guru menghapus tugas (mengembalikan tugas ke card cangkang / belum terbit)
     */
    public function deleteTask($id)
    {
        try {
            $user = Auth::user();
            $task = JournalTask::with(['journal.schedule', 'attachments', 'submissions.grade'])->findOrFail($id);

            $journalTeacherId = $task->journal?->teacher_id;
            $scheduleTeacherId = $task->journal?->schedule?->teacher_id;
            $isOwner = ($journalTeacherId && $journalTeacherId === $user->id) || ($scheduleTeacherId && $scheduleTeacherId === $user->id);

            if (!$isOwner) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki hak akses untuk menghapus tugas ini karena bukan penerbit tugas.'], 403);
            }

            $journalId = $task->journal_id;
            $classId = $task->journal?->schedule?->class_id ?? $task->journal?->class_id;
            $taskTitle = $task->title;
            $subjectName = $task->journal?->schedule?->subject?->name ?? ($task->journal?->subject?->name ?? 'Mata Pelajaran');
            $teacherName = $user->full_name ?: ($user->username ?? 'Guru');
            
            // 1. Hapus berkas fisik lampiran materi tugas
            foreach ($task->attachments as $att) {
                $attPath = ltrim(str_replace('/storage/', '', $att->attachment_url ?? $att->file_url ?? ''), '/');
                if (!empty($attPath) && \Illuminate\Support\Facades\Storage::disk('public')->exists($attPath)) {
                    \Illuminate\Support\Facades\Storage::disk('public')->delete($attPath);
                }
            }
            $task->attachments()->delete();

            // 2. Hapus pengumpulan tugas siswa (submissions), nilai & berkas fisiknya di storage cloud
            foreach ($task->submissions as $sub) {
                if (!empty($sub->attachment_url)) {
                    $subPath = ltrim(str_replace('/storage/', '', $sub->attachment_url), '/');
                    if (\Illuminate\Support\Facades\Storage::disk('public')->exists($subPath)) {
                        \Illuminate\Support\Facades\Storage::disk('public')->delete($subPath);
                    }
                }
                if ($sub->grade) {
                    $sub->grade()->delete();
                }
                $sub->delete();
            }

            $task->delete();

            // Poin 2: Kembalikan status jurnal ke cangkang (has_task = true)
            // Sehingga tugas kembali muncul di tab "Belum" sebagai cangkang, bukan terhapus total
            if ($journalId) {
                Journal::where('id', $journalId)->update(['has_task' => true]);
            }

            // Kirim notifikasi ke siswa bahwa tugas telah ditarik / dihapus
            if ($classId) {
                try {
                    $notifTitle = "Tugas Dihapus: {$subjectName}";
                    $notifMessage = "Tugas \"{$taskTitle}\" ({$subjectName}) telah dihapus atau ditarik oleh guru pengampu ({$teacherName}).";

                    $studentIds = ClassStudent::where('class_id', $classId)
                        ->where('status', 'ACTIVE')
                        ->pluck('student_id');

                    foreach ($studentIds as $sId) {
                        NotificationService::sendInAppNotification($sId, $notifTitle, $notifMessage);
                    }
                } catch (\Throwable $notifErr) {
                    \Log::warning("Gagal mengirim notif hapus tugas: " . $notifErr->getMessage());
                }
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
                },
                'lateRequests' => function ($q) use ($user) {
                    $q->where('student_id', $user->id)->latest();
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
                
                // Cek Permohonan Pengumpulan Terlewat Siswa
                $latestLateRequest = $task->lateRequests->first();
                $isLateRequestApproved = $latestLateRequest && $latestLateRequest->status === 'APPROVED' && $latestLateRequest->extended_until && $now->lt($latestLateRequest->extended_until);
                $isLateRequestPending = $latestLateRequest && $latestLateRequest->status === 'PENDING';

                if ($dueDate->between($startOfWeek, $endOfWeek)) {
                    $mingguIniCount++;
                }

                if ($isSubmitted) {
                    $status = 'Selesai Dikerjakan';
                    $selesaiCount++;
                } elseif ($isLateRequestApproved) {
                    // Tombol aktif kembali 2x24 jam dengan status khusus agar siswa aware
                    $status = 'Terlewat ; Belum Dikerjakan';
                    $belumCount++;
                } elseif ($now->gt($dueDate)) {
                    $status = 'Terlewat';
                    $terlewatCount++;

                    // Pastikan notifikasi tugas terlewat terbit ke notifikasi siswa jika belum ada
                    try {
                        $notifTitle = "⚠️ Tugas Terlewat: " . ($sched?->subject?->name ?? 'Mata Pelajaran');
                        $alreadyNotified = Notification::where('user_id', $user->id)
                            ->where('title', $notifTitle)
                            ->where('message', 'like', "%{$task->id}%")
                            ->exists();

                        if (!$alreadyNotified) {
                            $dueDateFormatted = $dueDate->locale('id')->isoFormat('D MMM Y, HH:mm');
                            $subjectName = $sched?->subject?->name ?? 'Mata Pelajaran';
                            $notifData = [
                                'type' => 'task',
                                'task_id' => $task->id,
                                'task_title' => $task->title,
                                'subject_name' => $subjectName,
                                'due_date_formatted' => $dueDateFormatted,
                            ];
                            $notifMessage = "Batas waktu pengumpulan tugas \"{$task->title}\" ({$subjectName}) telah terlewat pada {$dueDateFormatted} WIB. Silakan ajukan permohonan mengumpulkan kepada guru pengampu jika masih ingin mengumpulkan.\n<!--DATA:" . json_encode($notifData) . "-->";
                            
                            // Pasang created_at sesuai waktu saat tugas tersebut terlewat (tenggat waktu)
                            // agar notifikasi terlewat tidak mendahului notifikasi aksi terbaru (seperti permohonan disetujui / nilai)
                            Notification::create([
                                'user_id' => $user->id,
                                'title' => $notifTitle,
                                'message' => $notifMessage,
                                'is_read' => false,
                                'created_at' => $dueDate,
                                'updated_at' => $dueDate,
                            ]);
                        }
                    } catch (\Throwable $notifErr) {
                        \Log::warning("Gagal auto-sync notif terlewat: " . $notifErr->getMessage());
                    }
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

                // Jika permohonan disetujui, gunakan batas perpanjangan (extended_until / 2x24 jam) sebagai tenggat efektif
                $effectiveDueDate = ($isLateRequestApproved && $latestLateRequest->extended_until) 
                    ? Carbon::parse($latestLateRequest->extended_until) 
                    : $dueDate;

                return [
                    'id' => $task->id,
                    'title' => $task->title,
                    'description' => $task->description ?? '',
                    'due_date' => $effectiveDueDate->toIso8601String(),
                    'due_date_formatted' => $effectiveDueDate->locale('id')->isoFormat('D MMM Y, HH:mm'),
                    'original_due_date' => $task->due_date,
                    'original_due_date_formatted' => $dueDate->locale('id')->isoFormat('D MMM Y, HH:mm'),
                    'subject' => $sched?->subject?->name ?? 'Mata Pelajaran',
                    'teacher' => $teacherName,
                    'teacher_avatar' => $teacherAvatar,
                    'status' => $status,
                    'is_submitted' => $isSubmitted,
                    'late_request' => $latestLateRequest ? [
                        'id' => $latestLateRequest->id,
                        'status' => $latestLateRequest->status,
                        'reason' => $latestLateRequest->reason,
                        'teacher_note' => $latestLateRequest->teacher_note,
                        'extended_until' => $latestLateRequest->extended_until?->toIso8601String(),
                        'extended_until_formatted' => $latestLateRequest->extended_until ? Carbon::parse($latestLateRequest->extended_until)->locale('id')->isoFormat('D MMM Y, HH:mm') : null,
                        'can_submit_again' => $isLateRequestApproved,
                    ] : null,
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
            $task = JournalTask::with([
                'journal.class.academicYear', 
                'journal.schedule.class.academicYear', 
                'journal.subject', 
                'journal.schedule.subject'
            ])->findOrFail($request->journal_task_id);

            // Cek apakah sudah dinilai
            $existingSubmission = StudentTaskSubmission::where('journal_task_id', $task->id)
                ->where('student_id', $user->id)
                ->with('grade')
                ->first();

            if ($existingSubmission && ($existingSubmission->grade !== null || $existingSubmission->status === 'GRADED')) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Tugas ini sudah dinilai oleh guru dan tidak dapat diperbarui lagi.'
                ], 422);
            }

            // Cek Batas Waktu / Tenggat & Permohonan Terlewat
            $now = now();
            $dueDate = Carbon::parse($task->due_date);
            if ($now->gt($dueDate)) {
                $latestLateRequest = TaskLateSubmissionRequest::where('journal_task_id', $task->id)
                    ->where('student_id', $user->id)
                    ->latest()
                    ->first();

                $isApproved = $latestLateRequest 
                    && $latestLateRequest->status === 'APPROVED' 
                    && $latestLateRequest->extended_until 
                    && $now->lt($latestLateRequest->extended_until);

                if (!$isApproved) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Batas waktu pengumpulan tugas ini telah berakhir. Silakan ajukan permohonan mengumpulkan kepada guru pengampu.'
                    ], 422);
                }
            }

            $attachmentUrl = null;
            if ($request->hasFile('attachment')) {
                // Hapus berkas jawaban lama jika ada
                if ($existingSubmission && !empty($existingSubmission->attachment_url)) {
                    $oldPath = ltrim(str_replace('/storage/', '', $existingSubmission->attachment_url), '/');
                    if (\Illuminate\Support\Facades\Storage::disk('public')->exists($oldPath)) {
                        \Illuminate\Support\Facades\Storage::disk('public')->delete($oldPath);
                    }
                }

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

            $isResubmission = $existingSubmission !== null;

            $submission = StudentTaskSubmission::updateOrCreate(
                [
                    'journal_task_id' => $task->id,
                    'student_id' => $user->id,
                ],
                $submissionData
            );

            // Kirim notifikasi ke Guru Pengampu
            try {
                $teacher = $task->journal?->teacher ?? $task->journal?->schedule?->teacher;
                if ($teacher) {
                    $studentName = $user->full_name ?: ($user->username ?? 'Siswa');
                    $taskTitle = $task->title;
                    $subjectName = $task->journal?->schedule?->subject?->name ?? ($task->journal?->subject?->name ?? 'Mata Pelajaran');
                    $className = $task->journal?->schedule?->class ? ($task->journal->schedule->class->grade_level . ' ' . $task->journal->schedule->class->name) : '';

                    $notifData = [
                        'type' => 'task',
                        'task_id' => $task->id,
                        'task_title' => $taskTitle,
                        'student_id' => $user->id,
                        'student_name' => $studentName,
                        'subject_name' => $subjectName,
                        'class_name' => $className,
                    ];

                    if ($isResubmission) {
                        $teacherNotifTitle = "Pembaruan Tugas: {$studentName}";
                        $teacherNotifMsg = "Siswa {$studentName} telah memperbarui pengumpulan tugas \"{$taskTitle}\" ({$subjectName})." . 
                            "\n<!--DATA:" . json_encode($notifData) . "-->";
                    } else {
                        $teacherNotifTitle = "Tugas Dikumpulkan: {$studentName}";
                        $teacherNotifMsg = "Siswa {$studentName} telah mengumpulkan tugas \"{$taskTitle}\" ({$subjectName})." . 
                            "\n<!--DATA:" . json_encode($notifData) . "-->";
                    }

                    NotificationService::sendInAppNotification($teacher->id, $teacherNotifTitle, $teacherNotifMsg);
                }
            } catch (\Throwable $notifErr) {
                \Log::warning("Gagal mengirim notif pengumpulan tugas ke guru: " . $notifErr->getMessage());
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Tugas berhasil dikumpulkan!',
                'data' => $submission
            ]);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            return response()->json([
                'status' => 'error',
                'message' => $ve->getMessage(),
                'errors' => $ve->errors()
            ], 422);
        } catch (\Throwable $e) {
            \Log::error('Gagal submitTask: ' . $e->getMessage() . ' at ' . $e->getFile() . ':' . $e->getLine());
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Mengambil detail 1 tugas untuk Siswa secara realtime
     */
    public function getTaskDetailForSiswa($id)
    {
        try {
            $user = Auth::user();
            $task = JournalTask::with([
                'journal.schedule.class',
                'journal.schedule.subject',
                'journal.schedule.teacher',
                'attachments',
                'submissions' => function ($q) use ($user) {
                    $q->where('student_id', $user->id)->with('grade');
                },
                'lateRequests' => function ($q) use ($user) {
                    $q->where('student_id', $user->id)->latest();
                }
            ])->findOrFail($id);

            $sched = $task->journal->schedule ?? null;
            $teacher = $sched?->teacher;
            $teacherName = $teacher ? ($teacher->full_name ?: $teacher->username) : 'Guru Pengampu';
            $submission = $task->submissions->first();
            $isSubmitted = $submission !== null;
            $dueDate = Carbon::parse($task->due_date);
            $now = now();

            $latestLateRequest = $task->lateRequests->first();
            $isLateRequestApproved = $latestLateRequest && $latestLateRequest->status === 'APPROVED' && $latestLateRequest->extended_until && $now->lt($latestLateRequest->extended_until);

            if ($isSubmitted) {
                $status = 'Selesai Dikerjakan';
            } elseif ($isLateRequestApproved) {
                $status = 'Terlewat ; Belum Dikerjakan';
            } elseif ($now->gt($dueDate)) {
                $status = 'Terlewat';
            } else {
                $status = 'Belum Dikerjakan';
            }

            // Jika permohonan disetujui, gunakan batas perpanjangan (extended_until / 2x24 jam) sebagai tenggat efektif
            $effectiveDueDate = ($isLateRequestApproved && $latestLateRequest->extended_until) 
                ? Carbon::parse($latestLateRequest->extended_until) 
                : $dueDate;

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $task->id,
                    'title' => $task->title,
                    'description' => $task->description ?? '',
                    'due_date' => $effectiveDueDate->toIso8601String(),
                    'due_date_formatted' => $effectiveDueDate->locale('id')->isoFormat('D MMM Y, HH:mm'),
                    'original_due_date' => $task->due_date,
                    'original_due_date_formatted' => $dueDate->locale('id')->isoFormat('D MMM Y, HH:mm'),
                    'subject' => $sched?->subject?->name ?? 'Mata Pelajaran',
                    'teacher' => $teacherName,
                    'status' => $status,
                    'is_submitted' => $isSubmitted,
                    'late_request' => $latestLateRequest ? [
                        'id' => $latestLateRequest->id,
                        'status' => $latestLateRequest->status,
                        'reason' => $latestLateRequest->reason,
                        'teacher_note' => $latestLateRequest->teacher_note,
                        'extended_until' => $latestLateRequest->extended_until?->toIso8601String(),
                        'extended_until_formatted' => $latestLateRequest->extended_until ? Carbon::parse($latestLateRequest->extended_until)->locale('id')->isoFormat('D MMM Y, HH:mm') : null,
                        'can_submit_again' => $isLateRequestApproved,
                        'is_expired_after_approved' => ($latestLateRequest->status === 'APPROVED' && $latestLateRequest->extended_until && $now->gte($latestLateRequest->extended_until)),
                    ] : null,
                    'submission' => $submission ? [
                        'id' => $submission->id,
                        'status' => $submission->status,
                        'answer_text' => $submission->answer_text,
                        'attachment_url' => $submission->attachment_url,
                        'submitted_at' => $submission->submitted_at ? Carbon::parse($submission->submitted_at)->locale('id')->isoFormat('D MMM Y, HH:mm') : null,
                        'score' => $submission->grade ? (float) $submission->grade->score : null,
                        'feedback' => $submission->grade?->feedback ?? null,
                    ] : null,
                    'attachments' => $task->attachments->map(fn($a) => [
                        'id' => $a->id,
                        'name' => $a->attachment_name ?? $a->file_name ?? 'Lampiran_Materi.pdf',
                        'url' => $a->attachment_url ?? $a->file_url ?? '',
                    ]),
                    'created_at' => $task->created_at,
                ]
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['status' => 'error', 'message' => 'Tugas tidak ditemukan atau telah dihapus.'], 404);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Siswa mengajukan permohonan untuk mengumpulkan tugas yang sudah terlewat
     */
    public function requestLateSubmission(Request $request, $id)
    {
        $request->validate([
            'reason' => 'required|string|min:5'
        ]);

        try {
            $user = Auth::user();
            $task = JournalTask::with([
                'journal.teacher',
                'journal.schedule.teacher'
            ])->findOrFail($id);

            $teacher = $task->journal?->teacher ?? $task->journal?->schedule?->teacher;
            if (!$teacher) {
                return response()->json(['status' => 'error', 'message' => 'Guru penerbit tugas tidak ditemukan.'], 404);
            }

            // Batas permohonan hanya 1 kali per siswa per tugas
            $existing = TaskLateSubmissionRequest::where('journal_task_id', $task->id)
                ->where('student_id', $user->id)
                ->first();

            if ($existing) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Anda sudah pernah mengajukan permohonan keterlambatan untuk tugas ini. Kesempatan permohonan hanya 1 kali.'
                ], 422);
            }

            // Simpan permohonan
            $lateRequest = TaskLateSubmissionRequest::create([
                'journal_task_id' => $task->id,
                'student_id' => $user->id,
                'teacher_id' => $teacher->id,
                'reason' => $request->reason,
                'status' => 'PENDING',
            ]);

            // Kirim notifikasi ke Guru (sertakan metadata tugas & siswa di pesan/payload)
            $studentName = $user->full_name ?: $user->username;
            $taskTitle = $task->title;

            $notifData = [
                'type' => 'late_request',
                'task_id' => $task->id,
                'task_title' => $task->title,
                'student_id' => $user->id,
                'student_name' => $studentName,
                'subject_name' => $task->journal?->schedule?->subject?->name ?? 'Mata Pelajaran',
                'class_name' => ($task->journal?->schedule?->class?->grade_level . ' ' . $task->journal?->schedule?->class?->name),
            ];

            Notification::create([
                'user_id' => $teacher->id,
                'title' => 'Permohonan Tugas Terlewat',
                'message' => "Siswa {$studentName} mengajukan permohonan untuk mengumpulkan tugas \"{$taskTitle}\". Alasan: \"{$request->reason}\"\n<!--DATA:" . json_encode($notifData) . "-->",
                'is_read' => false,
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Permohonan berhasil dikirim ke guru pengampu.',
                'data' => $lateRequest
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Guru mengambil daftar permohonan tugas terlewat yang masuk
     */
    public function getLateSubmissionRequests(Request $request)
    {
        try {
            $user = Auth::user();
            $requests = TaskLateSubmissionRequest::where('teacher_id', $user->id)
                ->with(['student.siswaProfile', 'journalTask'])
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($req) {
                    return [
                        'id' => $req->id,
                        'task_id' => $req->journal_task_id,
                        'task_title' => $req->journalTask?->title ?? 'Tugas',
                        'student_id' => $req->student_id,
                        'student_name' => $req->student?->full_name ?: ($req->student?->username ?? 'Siswa'),
                        'student_nis' => $req->student?->siswaProfile?->nis ?? '-',
                        'reason' => $req->reason,
                        'status' => $req->status,
                        'teacher_note' => $req->teacher_note,
                        'extended_until' => $req->extended_until?->toIso8601String(),
                        'created_at' => $req->created_at?->toIso8601String(),
                        'created_at_formatted' => $req->created_at ? Carbon::parse($req->created_at)->locale('id')->isoFormat('D MMM Y, HH:mm') : '-',
                    ];
                });

            return response()->json([
                'status' => 'success',
                'data' => $requests
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Guru merespons permohonan tugas terlewat (SETUJUI / TOLAK + Nasihat)
     * Jika disetujui: tombol pengumpulan siswa aktif kembali selama 2x24 jam (48 jam)
     */
    public function respondLateSubmissionRequest(Request $request, $requestId)
    {
        $request->validate([
            'action' => 'required|in:APPROVE,REJECT',
            'note' => 'required|string|min:3'
        ]);

        try {
            $user = Auth::user();
            $lateRequest = TaskLateSubmissionRequest::with(['journalTask', 'student'])->findOrFail($requestId);

            if ($lateRequest->teacher_id !== $user->id) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak berwenang merespons permohonan ini.'], 403);
            }

            $now = now();
            if ($request->action === 'APPROVE') {
                $lateRequest->status = 'APPROVED';
                $lateRequest->extended_until = $now->copy()->addHours(48); // Aktif kembali 2 x 24 jam!
                $statusMsg = 'disetujui';
                $notifTitle = 'Permohonan Tugas Disetujui';
                $deadlineStr = $lateRequest->extended_until->locale('id')->isoFormat('dddd, D MMMM Y HH:mm');
                $notifMsg = "Guru telah menyetujui permohonan tugas \"{$lateRequest->journalTask?->title}\". Tombol pengumpulan aktif kembali hingga {$deadlineStr}. Pesan Guru: \"{$request->note}\"";
            } else {
                $lateRequest->status = 'REJECTED';
                $statusMsg = 'ditolak';
                $notifTitle = 'Permohonan Tugas Ditolak';
                $notifMsg = "Permohonan tugas \"{$lateRequest->journalTask?->title}\" ditolak oleh guru. Pesan Guru: \"{$request->note}\"";
            }

            $lateRequest->teacher_note = $request->note;
            $lateRequest->responded_at = $now;
            $lateRequest->save();

            $task = $lateRequest->journalTask;
            $teacherName = $user->full_name ?: ($user->username ?? 'Guru');
            $subjectName = $task?->journal?->schedule?->subject?->name ?? 'Mata Pelajaran';

            $notifData = [
                'type' => 'task',
                'task_id' => $task?->id,
                'task_title' => $task?->title ?? 'Tugas',
                'subject_name' => $subjectName,
                'teacher_name' => $teacherName,
                'due_date_formatted' => $task ? Carbon::parse($task->due_date)->locale('id')->isoFormat('D MMM Y, HH:mm') : '',
            ];

            $notifMsg .= "\n<!--DATA:" . json_encode($notifData) . "-->";

            // Kirim notifikasi ke siswa
            Notification::create([
                'user_id' => $lateRequest->student_id,
                'title' => $notifTitle,
                'message' => $notifMsg,
                'is_read' => false,
            ]);

            return response()->json([
                'status' => 'success',
                'message' => "Permohonan berhasil {$statusMsg}.",
                'data' => $lateRequest
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}

