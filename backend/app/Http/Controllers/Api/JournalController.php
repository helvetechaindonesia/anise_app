<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Subject;
use App\Models\Schedule;
use App\Models\Journal;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class JournalController extends Controller
{
    public function getTerbitOptions(Request $request)
    {
        try {
            $user = Auth::user();
            
            $schedules = Schedule::where('teacher_id', $user->id)
                ->with(['subject', 'class'])
                ->get();
                
            $subjects = $schedules->pluck('subject')->filter()->unique('id')->values();
            
            $formattedSchedules = [];
            $startDate = Carbon::today();
            $endDate = Carbon::today()->addDays(30); // 1 bulan ke depan

            foreach ($schedules as $sched) {
                if (!$sched->class) continue;

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
                        
                        $formattedSchedules[] = [
                            'id' => $uniqueId,
                            'subject_id' => $sched->subject_id,
                            'schedule_id' => $sched->id,
                            'teaching_date' => $currentDate->format('Y-m-d'),
                            'label' => "{$hariIndo}, {$tanggalString}\nJam {$sched->start_time} - {$sched->end_time}, Tingkat {$grade} {$className}"
                        ];
                        
                        $currentDate->addWeek();
                    }
                }
            }

            // Urutkan berdasarkan tanggal terdekat
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
            'schedule_id' => 'required', // Bisa berupa "uuid|YYYY-MM-DD"
            'subject_id' => 'required|exists:subjects,id',
            'topic_material' => 'required|string',
            'description' => 'nullable|string',
            'has_task' => 'boolean',
            'attachment' => 'nullable|file|max:20480'
        ]);

        // Parsing schedule_id yang sekarang berupa "uuid|YYYY-MM-DD"
        $parts = explode('|', $request->schedule_id);
        if (count($parts) !== 2) {
            return response()->json(['status' => 'error', 'message' => 'Format Jadwal tidak valid'], 400);
        }

        $realScheduleId = $parts[0];
        $teachingDate = $parts[1];

        $schedule = Schedule::findOrFail($realScheduleId);

        $journal = new Journal();
        $journal->teacher_id = Auth::id();
        $journal->schedule_id = $schedule->id;
        $journal->class_id = $schedule->class_id;
        $journal->subject_id = $request->subject_id;
        $journal->teaching_date = $teachingDate; // Ambil dari dropdown
        $journal->topic_material = $request->topic_material;
        $journal->description = $request->description;
        $journal->has_task = $request->has_task ?? false;
        $journal->status = 'Aktif';
        $journal->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Jurnal berhasil diterbitkan',
            'data' => $journal
        ]);
    }

        public function mySchedules()
    {
        try {
            $user = Auth::user();
            
            // Get unique class & subject combinations for this teacher
            $schedules = Schedule::where('teacher_id', $user->id)
                ->with(['class.major', 'subject'])
                ->get();
                
            $uniqueClasses = [];
            foreach ($schedules as $sched) {
                if (!$sched->class || !$sched->subject) continue;
                
                $key = $sched->class_id . '_' . $sched->subject_id;
                
                if (!isset($uniqueClasses[$key])) {
                    // Hitung jumlah siswa di kelas ini
                    $studentCount = \App\Models\ClassStudent::where('class_id', $sched->class_id)->count();
                    
                    $uniqueClasses[$key] = [
                        'class_id' => $sched->class_id,
                        'subject_id' => $sched->subject_id,
                        'class_name' => $sched->class->grade_level . ' ' . $sched->class->name,
                        'subject_name' => $sched->subject->name,
                        'student_count' => $studentCount
                    ];
                }
            }

            return response()->json([
                'status' => 'success',
                'data' => array_values($uniqueClasses)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    public function submitJournal() { return response()->json(['status' => 'success']); }

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
            
            $journals = \App\Models\Journal::whereHas('schedule', function ($q) use ($user) {
                $q->where('teacher_id', $user->id);
            })
            ->with(['schedule.subject', 'schedule.class.major', 'tasks'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($journal) {
                $sched = $journal->schedule;
                $classObj = $sched->class;
                $className = $classObj->grade_level . ' ' . $classObj->name;
                
                return [
                    'id' => $journal->id,
                    'topic' => $journal->topic_material,
                    'description' => $journal->description,
                    'created_at' => $journal->created_at,
                    'subject' => $sched->subject->name,
                    'class' => $className,
                    'has_task' => $journal->tasks->count() > 0
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $journals
            ]);
        } catch (\Exception $e) {
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
                    ->with(['subject', 'teacher.guruProfile'])
                    ->get();
            } catch (\Throwable $e) {}

            // 2. Ambil seluruh jurnal mengajar untuk kelas siswa secara aman
            $journals = collect();
            try {
                $withRelations = ['schedule.subject', 'schedule.teacher.guruProfile'];
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
                // Fallback query tanpa relasi tambahan jika terjadi mismatch
                try {
                    $journals = \App\Models\Journal::where('class_id', $classId)
                        ->orWhereHas('schedule', function ($q) use ($classId) {
                            $q->where('class_id', $classId);
                        })
                        ->get();
                } catch (\Throwable $ex) {}
            }

            $result = [];

            // A. Petakan data Jurnal yang sudah terbit
            foreach ($journals as $journal) {
                $sched = $journal->schedule ?? null;
                $teacher = $sched ? $sched->teacher : ($journal->teacher ?? null);
                $teacherName = $teacher?->guruProfile ? $teacher->guruProfile->full_name : ($teacher?->full_name ?: ($teacher?->username ?? 'Guru Pengajar'));
                
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
                $taskTitle = null;
                try {
                    if ($journal->relationLoaded('tasks') && $journal->tasks && $journal->tasks->isNotEmpty()) {
                        $hasTask = true;
                        $taskTitle = $journal->tasks->first()->title;
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

                $userRating = null;
                $hasRated = false;
                $isLikedByMe = false;
                $isSavedByMe = false;

                try {
                    if (\Illuminate\Support\Facades\Schema::hasTable('journal_reviews')) {
                        $myReview = \Illuminate\Support\Facades\DB::table('journal_reviews')
                            ->where('journal_id', $journal->id)
                            ->where('student_id', $user->id)
                            ->first();
                        if ($myReview) {
                            $hasRated = true;
                            $userRating = (int)$myReview->rating;
                        }
                    }
                    if (\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                        $isLikedByMe = \Illuminate\Support\Facades\DB::table('journal_interactions')
                            ->where('journal_id', $journal->id)
                            ->where('student_id', $user->id)
                            ->where('interaction_type', 'LIKE')
                            ->exists();
                        $isSavedByMe = \Illuminate\Support\Facades\DB::table('journal_interactions')
                            ->where('journal_id', $journal->id)
                            ->where('student_id', $user->id)
                            ->where('interaction_type', 'SAVE')
                            ->exists();
                    }
                } catch (\Throwable $e) {}

                $result[] = [
                    'id' => $journal->id,
                    'schedule_id' => $journal->schedule_id,
                    'type' => 'journal',
                    'topic' => $journal->topic_material,
                    'description' => $journal->description ?: $journal->topic_material,
                    'created_at' => $journal->created_at ? $journal->created_at->toIso8601String() : null,
                    'teaching_date' => $journal->teaching_date ? Carbon::parse($journal->teaching_date)->format('Y-m-d') : null,
                    'subject' => $subjectName,
                    'teacher' => $teacherName,
                    'teacher_id' => $teacher?->id,
                    'teacher_image' => $teacher?->profile_picture ?? null,
                    'start_time' => $startTime,
                    'end_time' => $endTime,
                    'day_of_week' => $dayOfWeek,
                    'has_task' => $hasTask,
                    'task_title' => $taskTitle,
                    'attachment_url' => $journal->attachment_url ?? null,
                    'likes' => $likesCount,
                    'is_liked' => $isLikedByMe,
                    'is_saved' => $isSavedByMe,
                    'comments' => $commentsCount,
                    'rating' => (float)$avgRating,
                    'has_rated' => $hasRated,
                    'my_rating' => $userRating
                ];
            }

            // B. Petakan Jadwal Reguler mingguan (Template mata pelajaran)
            foreach ($schedules as $sched) {
                $teacher = $sched->teacher ?? null;
                $teacherName = $teacher?->guruProfile ? $teacher->guruProfile->full_name : ($teacher?->full_name ?: ($teacher?->username ?? 'Guru Pengajar'));
                $subjectName = $sched->subject?->name ?? 'Mata Pelajaran';

                $result[] = [
                    'id' => 'sched_' . $sched->id,
                    'schedule_id' => $sched->id,
                    'type' => 'schedule',
                    'topic' => 'Jadwal Rutin: ' . $subjectName,
                    'description' => 'Materi pembelajaran belum dipublikasikan oleh guru mata pelajaran.',
                    'created_at' => $sched->created_at ? $sched->created_at->toIso8601String() : null,
                    'teaching_date' => null,
                    'subject' => $subjectName,
                    'teacher' => $teacherName,
                    'teacher_id' => $teacher?->id,
                    'teacher_image' => $teacher?->profile_picture ?? null,
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

    public function toggleLike(Request $request, $journalId)
    {
        try {
            $user = Auth::user();

            if (!\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                \Illuminate\Support\Facades\Schema::create('journal_interactions', function (\Illuminate\Database\Schema\Blueprint $table) {
                    $table->uuid('id')->primary();
                    $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
                    $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
                    $table->string('interaction_type'); // LIKE, SAVE, SHARE
                    $table->timestamps();
                });
            }

            $existing = \Illuminate\Support\Facades\DB::table('journal_interactions')
                ->where('journal_id', $journalId)
                ->where('student_id', $user->id)
                ->where('interaction_type', 'LIKE')
                ->first();

            if ($existing) {
                \Illuminate\Support\Facades\DB::table('journal_interactions')->where('id', $existing->id)->delete();
                $liked = false;
            } else {
                \Illuminate\Support\Facades\DB::table('journal_interactions')->insert([
                    'id' => (string) \Illuminate\Support\Str::uuid(),
                    'journal_id' => $journalId,
                    'student_id' => $user->id,
                    'interaction_type' => 'LIKE',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                $liked = true;
            }

            $count = \Illuminate\Support\Facades\DB::table('journal_interactions')
                ->where('journal_id', $journalId)
                ->where('interaction_type', 'LIKE')
                ->count();

            return response()->json(['status' => 'success', 'data' => ['liked' => $liked, 'likes_count' => $count]]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getComments($journalId)
    {
        try {
            $user = Auth::user();
            $userRole = $user->role_type ?? ($user->role ?? '');
            $journal = \App\Models\Journal::with('schedule')->find($journalId);
            $teacherId = $journal?->teacher_id ?? $journal?->schedule?->teacher_id;
            $isTeacherOwner = ($user->id === $teacherId) || in_array($userRole, ['GURU', 'ADMIN', 'TATA_USAHA']);

            if (!\Illuminate\Support\Facades\Schema::hasTable('journal_comments')) {
                return response()->json(['status' => 'success', 'data' => []]);
            }

            $comments = \App\Models\JournalComment::where('journal_id', $journalId)
                ->with(['user.siswaProfile', 'user.guruProfile'])
                ->orderBy('created_at', 'asc')
                ->get()
                ->map(function ($c) use ($user, $isTeacherOwner) {
                    $u = $c->user;
                    $name = $u?->guruProfile ? $u->guruProfile->full_name : ($u?->siswaProfile ? $u->siswaProfile->full_name : ($u?->full_name ?: ($u?->username ?? 'Pengguna')));
                    $uRole = $u?->role_type ?? ($u?->role ?? 'SISWA');
                    return [
                        'id' => $c->id,
                        'journal_id' => $c->journal_id,
                        'user_id' => $c->user_id,
                        'author_name' => $name,
                        'author_role' => $uRole,
                        'author_avatar' => $u?->profile_picture,
                        'comment_text' => $c->comment_text,
                        'created_at' => $c->created_at ? $c->created_at->toIso8601String() : null,
                        'can_delete' => ($user->id === $c->user_id) || $isTeacherOwner
                    ];
                });

            return response()->json(['status' => 'success', 'data' => $comments]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function toggleSave(Request $request, $journalId)
    {
        try {
            $user = Auth::user();
            if (!\Illuminate\Support\Facades\Schema::hasTable('journal_interactions')) {
                \Illuminate\Support\Facades\Schema::create('journal_interactions', function (\Illuminate\Database\Schema\Blueprint $table) {
                    $table->uuid('id')->primary();
                    $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
                    $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
                    $table->string('interaction_type'); // LIKE, SAVE, SHARE
                    $table->timestamps();
                });
            }

            $existing = \Illuminate\Support\Facades\DB::table('journal_interactions')
                ->where('journal_id', $journalId)
                ->where('student_id', $user->id)
                ->where('interaction_type', 'SAVE')
                ->first();

            if ($existing) {
                \Illuminate\Support\Facades\DB::table('journal_interactions')->where('id', $existing->id)->delete();
                $saved = false;
            } else {
                \Illuminate\Support\Facades\DB::table('journal_interactions')->insert([
                    'id' => (string) \Illuminate\Support\Str::uuid(),
                    'journal_id' => $journalId,
                    'student_id' => $user->id,
                    'interaction_type' => 'SAVE',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                $saved = true;
            }

            return response()->json(['status' => 'success', 'data' => ['saved' => $saved]]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function submitComment(Request $request, $journalId)
    {
        try {
            $request->validate(['comment_text' => 'required|string|max:500']);
            $user = Auth::user();
            $userRole = $user->role_type ?? ($user->role ?? '');

            if (!\Illuminate\Support\Facades\Schema::hasTable('journal_comments')) {
                \Illuminate\Support\Facades\Schema::create('journal_comments', function (\Illuminate\Database\Schema\Blueprint $table) {
                    $table->uuid('id')->primary();
                    $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
                    $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
                    $table->text('comment_text');
                    $table->timestamps();
                });
            }

            // Batasi 1 siswa hanya boleh memberikan 1 komentar per jurnal item
            $existingComment = \App\Models\JournalComment::where('journal_id', $journalId)
                ->where('user_id', $user->id)
                ->first();

            if ($existingComment && $userRole === 'SISWA') {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Anda sudah memberikan komentar untuk jurnal ini (maksimal 1 komentar per siswa).'
                ], 422);
            }

            $comment = \App\Models\JournalComment::create([
                'journal_id' => $journalId,
                'user_id' => $user->id,
                'comment_text' => $request->comment_text
            ]);

            $name = $user->guruProfile ? $user->guruProfile->full_name : ($user->siswaProfile ? $user->siswaProfile->full_name : ($user->full_name ?: ($user->username ?? 'Saya')));

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $comment->id,
                    'journal_id' => $comment->journal_id,
                    'user_id' => $comment->user_id,
                    'author_name' => $name,
                    'author_role' => $userRole,
                    'author_avatar' => $user->profile_picture,
                    'comment_text' => $comment->comment_text,
                    'created_at' => $comment->created_at ? $comment->created_at->toIso8601String() : null,
                    'can_delete' => true
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function deleteComment($journalId, $commentId)
    {
        try {
            $user = Auth::user();
            $userRole = $user->role_type ?? ($user->role ?? '');
            $comment = \App\Models\JournalComment::find($commentId);
            if (!$comment) {
                return response()->json(['status' => 'error', 'message' => 'Komentar tidak ditemukan'], 404);
            }

            $journal = \App\Models\Journal::with('schedule')->find($journalId);
            $teacherId = $journal?->teacher_id ?? $journal?->schedule?->teacher_id;
            $isTeacherOwner = ($user->id === $teacherId) || in_array($userRole, ['GURU', 'ADMIN', 'TATA_USAHA']);
            $isCommentAuthor = ($user->id === $comment->user_id);

            // Guru penerbit jurnal atau pembuat komentar boleh menghapus
            if (!$isTeacherOwner && !$isCommentAuthor) {
                return response()->json(['status' => 'error', 'message' => 'Anda tidak memiliki hak untuk menghapus komentar ini'], 403);
            }

            $comment->delete();
            return response()->json(['status' => 'success', 'message' => 'Komentar berhasil dihapus']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function submitRating(Request $request, $journalId)
    {
        try {
            $request->validate([
                'rating' => 'required|integer|min:1|max:5',
                'review_text' => 'nullable|string|max:500'
            ]);

            $user = Auth::user();
            $userRole = $user->role_type ?? ($user->role ?? '');
            if ($userRole !== 'SISWA') {
                return response()->json(['status' => 'error', 'message' => 'Hanya siswa yang dapat memberikan penilaian'], 403);
            }

            // Buat tabel jika belum ada
            if (!\Illuminate\Support\Facades\Schema::hasTable('journal_reviews')) {
                \Illuminate\Support\Facades\Schema::create('journal_reviews', function (\Illuminate\Database\Schema\Blueprint $table) {
                    $table->uuid('id')->primary();
                    $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
                    $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
                    $table->integer('rating');
                    $table->text('review_text')->nullable();
                    $table->timestamps();
                    $table->unique(['journal_id', 'student_id']);
                });
            }

            // Cek apakah siswa sudah pernah memberikan rating (1 user siswa hanya boleh ngisi 1 kali, tidak boleh diganti)
            $existing = \Illuminate\Support\Facades\DB::table('journal_reviews')
                ->where('journal_id', $journalId)
                ->where('student_id', $user->id)
                ->first();

            if ($existing) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Anda sudah memberikan penilaian untuk jurnal ini dan tidak dapat mengubahnya.'
                ], 422);
            }

            \Illuminate\Support\Facades\DB::table('journal_reviews')->insert([
                'id' => (string) \Illuminate\Support\Str::uuid(),
                'journal_id' => $journalId,
                'student_id' => $user->id,
                'rating' => $request->rating,
                'review_text' => $request->review_text ?? null,
                'created_at' => now(),
                'updated_at' => now()
            ]);

            // Hitung rata-rata rating terbaru
            $newAvg = (float)\Illuminate\Support\Facades\DB::table('journal_reviews')
                ->where('journal_id', $journalId)
                ->avg('rating');

            return response()->json([
                'status' => 'success',
                'message' => 'Penilaian berhasil disimpan',
                'data' => [
                    'rating' => $request->rating,
                    'average_rating' => round($newAvg, 1)
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }


    public function getSiswaTeachers()
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

            $schedules = \App\Models\Schedule::where('class_id', $classId)
                ->with(['teacher.guruProfile', 'subject'])
                ->get();
                
            $teachers = collect();
            foreach ($schedules as $sched) {
                if (!$sched->teacher || !$sched->subject) continue;

                $teacherId = $sched->teacher_id;
                if (!$teachers->has($teacherId)) {
                    $name = $sched->teacher->full_name ?: $sched->teacher->username;
                    $teachers->put($teacherId, [
                        'id' => $teacherId,
                        'name' => $name,
                        'subject' => $sched->subject->name
                    ]);
                } else {
                    $existing = $teachers->get($teacherId);
                    if (!str_contains($existing['subject'], $sched->subject->name)) {
                        $existing['subject'] .= ', ' . $sched->subject->name;
                        $teachers->put($teacherId, $existing);
                    }
                }
            }

            return response()->json([
                'status' => 'success',
                'data' => $teachers->values()->all()
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}
