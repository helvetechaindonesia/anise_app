<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;
use App\Models\CounselingRequest;
use App\Models\SchoolClass;
use App\Models\Schedule;
use App\Models\Journal;
use App\Models\User;
use App\Models\Role;
use App\Models\ClassStudent;
use App\Helpers\AppTime;

class CounselingController extends Controller
{
    /**
     * GET /counseling/guru-bk — Mengambil daftar seluruh Guru BK yang aktif untuk dropdown siswa.
     */
    public function getGuruBk()
    {
        try {
            // 1. Cari user dengan Role GURU_BK atau nama/username mengandung BK / Wartono
            $guruBkUsers = User::where(function ($q) {
                    $q->whereHas('role', function ($r) {
                        $r->where('name', 'GURU_BK')
                          ->orWhere('name', 'LIKE', '%BK%')
                          ->orWhere('name', 'LIKE', '%bimbingan%');
                    })
                    ->orWhere('username', 'LIKE', '%199209092023211014%')
                    ->orWhere('username', 'LIKE', '%bk%')
                    ->orWhere('username', 'LIKE', '%wartono%')
                    ->orWhere('full_name', 'LIKE', '%Wartono%')
                    ->orWhere('full_name', 'LIKE', '%wartono%')
                    ->orWhere('full_name', 'LIKE', '%BK%')
                    ->orWhere('full_name', 'LIKE', '%Bimbingan%');
                })
                ->where(function ($q) {
                    $q->where('is_active', true)
                      ->orWhereNull('is_active');
                })
                ->select('id', 'full_name', 'username', 'email')
                ->orderBy('full_name', 'asc')
                ->get();

            // 2. Fallback: jika tidak ada role BK khusus, ambil user pendidik (non-siswa)
            if ($guruBkUsers->isEmpty()) {
                $guruBkUsers = User::where('is_active', true)
                    ->where(function ($q) {
                        $q->whereHas('role', function ($r) {
                            $r->whereNotIn('name', ['SISWA']);
                        })
                        ->orWhereNull('role_id')
                        ->orWhere('role_id', '!=', '');
                    })
                    ->select('id', 'full_name', 'username', 'email')
                    ->orderBy('full_name', 'asc')
                    ->get();
            }

            // 3. Fallback absolut: ambil seluruh user aktif
            if ($guruBkUsers->isEmpty()) {
                $guruBkUsers = User::where('is_active', true)
                    ->select('id', 'full_name', 'username', 'email')
                    ->orderBy('full_name', 'asc')
                    ->get();
            }

            $guruList = $guruBkUsers->map(function ($g) {
                return [
                    'id' => $g->id,
                    'name' => $g->full_name ?: $g->username,
                    'email' => $g->email ?? '',
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $guruList,
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * GET /counseling/klasikal/options — Mengambil data kelas untuk bimbingan klasikal.
     */
    public function getKlasikalOptions(Request $request)
    {
        try {
            $classes = SchoolClass::orderBy('grade_level', 'asc')
                ->orderBy('name', 'asc')
                ->get()
                ->map(function ($c) {
                    return [
                        'id' => $c->id,
                        'name' => ($c->grade_level ? "{$c->grade_level} " : "") . $c->name,
                    ];
                });

            return response()->json([
                'status' => 'success',
                'data' => [
                    'classes' => $classes,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * GET /counseling/klasikal/schedules — Mengambil daftar jadwal pelajaran asli di suatu kelas.
     */
    public function getKlasikalSchedules(Request $request)
    {
        $request->validate([
            'class_id' => 'required|exists:classes,id',
        ]);

        try {
            $schedules = Schedule::where('class_id', $request->class_id)
                ->with(['teacher', 'subject', 'class'])
                ->get()
                ->filter(function ($s) {
                    return $s->teacher && $s->subject && $s->subject->code !== 'KEG';
                })
                ->map(function ($s) {
                    $teacherName = $s->teacher ? ($s->teacher->full_name ?: $s->teacher->username) : 'Guru Pengajar';
                    $subjectName = $s->subject ? $s->subject->name : 'Mata Pelajaran';
                    $time = substr($s->start_time, 0, 5) . ' - ' . substr($s->end_time, 0, 5);
                    return [
                        'id' => $s->id,
                        'teacher_id' => $s->teacher_id,
                        'teacher_name' => $teacherName,
                        'subject_id' => $s->subject_id,
                        'subject_name' => $subjectName,
                        'day_of_week' => $s->day_of_week,
                        'start_time' => $s->start_time,
                        'end_time' => $s->end_time,
                        'time_label' => "{$s->day_of_week}, {$time} WIB",
                        'display_label' => "{$teacherName} • {$subjectName} ({$time})",
                    ];
                })
                ->values();

            return response()->json([
                'status' => 'success',
                'data' => $schedules,
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * POST /counseling/guru-bk/create — Guru BK membuat jadwal bimbingan (Klasikal, Individu, atau Kelompok).
     */
    public function storeByGuruBk(Request $request)
    {
        $request->validate([
            'type'          => 'required|in:KLASIKAL,INDIVIDU,KELOMPOK',
            'topic'         => 'required|string',
            'schedule_date' => 'nullable|date',
            'schedule_time' => 'nullable|string',
            'description'   => 'nullable|string',
            // Untuk Klasikal:
            'class_id'      => 'required_if:type,KLASIKAL|nullable|exists:classes,id',
            'schedule_id'   => 'required_if:type,KLASIKAL|nullable|exists:schedules,id',
            // Untuk Individu / Kelompok:
            'student_ids'   => 'required_if:type,INDIVIDU,KELOMPOK|array',
            'student_ids.*' => 'exists:users,id',
        ]);

        $appNow = AppTime::now();

        // Jika tipe Individu / Kelompok, schedule_date dan schedule_time wajib ada dan dicek
        if ($request->type !== 'KLASIKAL') {
            if (!$request->filled('schedule_date') || !$request->filled('schedule_time')) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Tanggal dan jam pelaksanaan wajib diisi!'
                ], 422);
            }
            $targetDateTime = Carbon::parse($request->schedule_date . ' ' . $request->schedule_time);
            if ($targetDateTime->lt($appNow)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Jadwal pelaksanaan tidak boleh di waktu yang telah berlalu! (Waktu Server: ' . $appNow->format('d/m/Y H:i') . ' WIB)'
                ], 422);
            }
        }

        try {
            $user = Auth::user();
            $type = $request->type;
            $results = [];

            if ($type === 'KLASIKAL') {
                $schedule = Schedule::with(['subject', 'class', 'teacher'])->findOrFail($request->schedule_id);

                // Tentukan schedule_date dan schedule_time otomatis dari jadwal mapel jika tidak dikirim dari UI
                $scheduleDate = $request->schedule_date;
                $scheduleTime = $request->schedule_time;

                if (empty($scheduleTime)) {
                    $scheduleTime = substr($schedule->start_time, 0, 5) . ' - ' . substr($schedule->end_time, 0, 5);
                }

                if (empty($scheduleDate)) {
                    $daysMap = [
                        'Senin' => 1, 'Selasa' => 2, 'Rabu' => 3, 'Kamis' => 4,
                        'Jumat' => 5, 'Sabtu' => 6, 'Minggu' => 7,
                    ];
                    $targetIso = $daysMap[$schedule->day_of_week] ?? null;
                    if ($targetIso !== null) {
                        $currentWeekMonday = $appNow->copy()->startOfWeek();
                        $computedDate = $currentWeekMonday->copy()->addDays($targetIso - 1);
                        // Jika hari jadwal dalam pekan ini sudah lewat dari sekarang, jadwalkan untuk pekan depan
                        $scheduleStartTimeStr = substr($schedule->start_time, 0, 5);
                        $checkDateTime = Carbon::parse($computedDate->format('Y-m-d') . ' ' . $scheduleStartTimeStr);
                        if ($checkDateTime->lt($appNow)) {
                            $computedDate->addWeek();
                        }
                        $scheduleDate = $computedDate->format('Y-m-d');
                    } else {
                        $scheduleDate = $appNow->format('Y-m-d');
                    }
                }

                // 1. Ambil seluruh siswa aktif di kelas tersebut
                $studentIds = ClassStudent::where('class_id', $request->class_id)
                    ->where('status', 'ACTIVE')
                    ->pluck('student_id');

                $repStudentId = $studentIds->first() ?? $user->id;

                // 2. Buat record di counseling_requests
                $counseling = CounselingRequest::create([
                    'id'            => (string) Str::uuid(),
                    'student_id'    => $repStudentId,
                    'guru_bk_id'    => $user->id,
                    'initiator'     => 'GURU_BK',
                    'topic'         => "[Bimbingan Klasikal] " . $request->topic,
                    'schedule_date' => $scheduleDate,
                    'schedule_time' => $scheduleTime,
                    'description'   => $request->description ?? "Bimbingan Klasikal menggantikan jadwal {$schedule->subject?->name} ({$schedule->teacher?->full_name})",
                    'status'        => 'APPROVED',
                ]);

                // 3. Menimpa Jurnal KBM (Classroom Hijacking)
                // Buat atau Update Journal untuk jadwal dan tanggal tersebut atas nama Guru BK
                $journal = Journal::updateOrCreate(
                    [
                        'schedule_id'   => $schedule->id,
                        'teaching_date' => $scheduleDate,
                    ],
                    [
                        'teacher_id'       => $user->id,
                        'class_id'         => $schedule->class_id,
                        'subject_id'       => $schedule->subject_id,
                        'topic_material'   => "Bimbingan Klasikal BK: " . $request->topic,
                        'description'      => $request->description ?? "Sesi bimbingan klasikal oleh Guru BK {$user->full_name}",
                        'is_bk_sosialisasi'=> true,
                        'status'           => 'Aktif',
                        'published_at'     => now(),
                    ]
                );

                return response()->json([
                    'status' => 'success',
                    'message' => 'Bimbingan klasikal berhasil dijadwalkan dan telah menimpa jurnal kelas!',
                    'data' => [
                        'counseling' => $counseling,
                        'journal' => $journal,
                    ]
                ]);
            }

            // INDIVIDU atau KELOMPOK
            $studentIds = $request->student_ids ?? [];
            if ($type === 'INDIVIDU' && count($studentIds) > 1) {
                $studentIds = array_slice($studentIds, 0, 1);
            }

            $prefixTopic = ($type === 'KELOMPOK') ? "[Bimbingan Kelompok] " : "[Bimbingan Individu] ";

            foreach ($studentIds as $sId) {
                $c = CounselingRequest::create([
                    'id'            => (string) Str::uuid(),
                    'student_id'    => $sId,
                    'guru_bk_id'    => $user->id,
                    'initiator'     => 'GURU_BK',
                    'topic'         => $prefixTopic . $request->topic,
                    'schedule_date' => $request->schedule_date,
                    'schedule_time' => $request->schedule_time,
                    'description'   => $request->description,
                    'status'        => 'APPROVED',
                ]);
                $results[] = $c;
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Jadwal bimbingan berhasil dibuat untuk siswa terkait!',
                'data' => $results,
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * POST /counseling — Siswa submit pengajuan bimbingan mandiri dengan memilih Guru BK.
     */
    public function store(Request $request)
    {
        $request->validate([
            'guru_bk_id'     => 'required|exists:users,id',
            'topic'          => 'required|string',
            'schedule_date'  => 'required|date',
            'schedule_time'  => 'required|string',
            'description'    => 'nullable|string',
        ]);

        $appNow = AppTime::now();
        $targetDateTime = Carbon::parse($request->schedule_date . ' ' . $request->schedule_time);
        if ($targetDateTime->lt($appNow)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Jadwal konsultasi tidak boleh di waktu yang telah berlalu! (Waktu Server: ' . $appNow->format('d/m/Y H:i') . ' WIB)'
            ], 422);
        }

        try {
            $user = Auth::user();

            $counseling = CounselingRequest::create([
                'id'            => (string) Str::uuid(),
                'student_id'    => $user->id,
                'guru_bk_id'    => $request->guru_bk_id,
                'initiator'     => 'STUDENT',
                'topic'         => $request->topic,
                'schedule_date' => $request->schedule_date,
                'schedule_time' => $request->schedule_time,
                'description'   => $request->description,
                'status'        => 'PENDING',
            ]);

            return response()->json(['status' => 'success', 'data' => $counseling]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * GET /counseling/siswa — Siswa melihat seluruh riwayat pengajuan bimbingannya (mandiri + panggilan BK).
     */
    public function siswaIndex()
    {
        try {
            $user = Auth::user();

            // Cari kelas siswa
            $classStudent = ClassStudent::where('student_id', $user->id)->where('status', 'ACTIVE')->with('class')->first();
            $className = 'Siswa';
            if ($classStudent && $classStudent->class) {
                $className = ($classStudent->class->grade_level ? "{$classStudent->class->grade_level} " : "") . $classStudent->class->name;
            }

            $data = CounselingRequest::where(function ($q) use ($user) {
                    $q->where('student_id', $user->id);
                })
                ->with(['guruBk.guruProfile', 'guruBk'])
                ->orderBy('schedule_date', 'desc')
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($c) use ($user, $className) {
                    $guruBk = $c->guruBk;
                    $guruBkName = $guruBk ? ($guruBk->full_name ?: $guruBk->username) : 'Guru BK';
                    $guruBkAvatar = $guruBk ? ($guruBk->avatar ?? $guruBk->profile_picture ?? null) : null;

                    $type = 'INDIVIDU';
                    if (str_contains($c->topic, '[Bimbingan Klasikal]')) {
                        $type = 'KLASIKAL';
                    } elseif (str_contains($c->topic, '[Bimbingan Kelompok]')) {
                        $type = 'KELOMPOK';
                    }

                    $hasLiked = \App\Models\CounselingLike::where('counseling_id', $c->id)
                        ->where('user_id', $user->id)
                        ->exists();

                    $commentsCount = \App\Models\CounselingComment::where('counseling_id', $c->id)->count();

                    return [
                        'id'                => $c->id,
                        'type'              => $type,
                        'student_id'        => $c->student_id,
                        'student_name'      => $user->full_name ?: $user->username,
                        'student_avatar'    => $user->avatar ?? $user->profile_picture ?? null,
                        'guru_bk_id'        => $c->guru_bk_id,
                        'guru_bk_name'      => $guruBkName,
                        'guru_bk_avatar'    => $guruBkAvatar,
                        'class_name'        => $className,
                        'topic'             => $c->topic,
                        'schedule_date'     => $c->schedule_date,
                        'schedule_time'     => $c->schedule_time,
                        'description'       => $c->description,
                        'status'            => $c->status,
                        'initiator'         => $c->initiator ?? 'STUDENT',
                        'check_in_time'     => $c->check_in_time,
                        'is_checked_in'     => !empty($c->check_in_time),
                        'is_late'           => (bool)$c->is_late,
                        'minutes_late'      => (int)$c->minutes_late,
                        'counseling_result' => $c->counseling_result,
                        'filled_at'         => $c->filled_at,
                        'is_filled'         => !empty($c->filled_at),
                        'rating'            => $c->rating ? (float)$c->rating : null,
                        'notes_evaluasi'    => $c->notes_evaluasi,
                        'likes'             => (int)($c->likes_count ?? 0),
                        'is_liked'          => $hasLiked,
                        'comments'          => $commentsCount,
                        'created_at'        => $c->created_at ? $c->created_at->format('Y-m-d H:i:s') : null,
                    ];
                });

            return response()->json(['status' => 'success', 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * GET /counseling/guru-bk/requests — Guru BK melihat agenda bimbingan (Klasikal, Kelompok, Individu) sesuai filter tanggal.
     */
    public function guruBkIndex(Request $request)
    {
        try {
            $user = Auth::user();
            $dateFilter = $request->date;

            // 1. Ambil dari counseling_requests
            $query = CounselingRequest::where(function ($q) use ($user) {
                    $q->where('guru_bk_id', $user->id)
                      ->orWhereNull('guru_bk_id');
                })
                ->with(['student.siswaProfile', 'student']);

            if (!empty($dateFilter)) {
                $query->whereDate('schedule_date', $dateFilter);
            }

            $counselings = $query->orderBy('schedule_date', 'asc')
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($c) use ($user) {
                    $student = $c->student;
                    
                    // Ambil kelas aktif siswa
                    $className = 'Siswa';
                    if ($student) {
                        $cs = ClassStudent::where('student_id', $student->id)
                            ->where('status', 'ACTIVE')
                            ->with('class')
                            ->first();
                        if ($cs && $cs->class) {
                            $className = ($cs->class->grade_level ? "{$cs->class->grade_level} " : "") . $cs->class->name;
                        }
                    }

                    $type = 'INDIVIDU';
                    if (str_contains($c->topic, '[Bimbingan Klasikal]')) {
                        $type = 'KLASIKAL';
                    } elseif (str_contains($c->topic, '[Bimbingan Kelompok]')) {
                        $type = 'KELOMPOK';
                    }

                    $hasLiked = \App\Models\CounselingLike::where('counseling_id', $c->id)
                        ->where('user_id', $user->id)
                        ->exists();

                    $commentsCount = \App\Models\CounselingComment::where('counseling_id', $c->id)->count();

                    return [
                        'id'                => $c->id,
                        'type'              => $type,
                        'student_id'        => $c->student_id,
                        'student_name'      => $student ? ($student->full_name ?: $student->username) : 'Siswa',
                        'student_avatar'    => $student ? ($student->avatar ?? $student->profile_picture ?? null) : null,
                        'class_name'        => $className,
                        'topic'             => $c->topic,
                        'schedule_date'     => $c->schedule_date,
                        'schedule_time'     => $c->schedule_time,
                        'description'       => $c->description,
                        'status'            => $c->status,
                        'initiator'         => $c->initiator ?? 'STUDENT',
                        'check_in_time'     => $c->check_in_time,
                        'is_checked_in'     => !empty($c->check_in_time),
                        'is_late'           => (bool)$c->is_late,
                        'minutes_late'      => (int)$c->minutes_late,
                        'counseling_result' => $c->counseling_result,
                        'filled_at'         => $c->filled_at,
                        'is_filled'         => !empty($c->filled_at),
                        'rating'            => $c->rating ? (float)$c->rating : null,
                        'notes_evaluasi'    => $c->notes_evaluasi,
                        'likes'             => (int)($c->likes_count ?? 0),
                        'is_liked'          => $hasLiked,
                        'comments'          => $commentsCount,
                        'created_at'        => $c->created_at ? $c->created_at->format('Y-m-d H:i:s') : null,
                    ];
                });

            // 2. Ambil dari journals hasil Classroom Hijacking Guru BK (is_bk_sosialisasi = true)
            $journalQuery = Journal::where('teacher_id', $user->id)
                ->where('is_bk_sosialisasi', true)
                ->with(['class', 'schedule.teacher', 'schedule.subject']);

            if (!empty($dateFilter)) {
                $journalQuery->whereDate('teaching_date', $dateFilter);
            }

            $journals = $journalQuery->orderBy('teaching_date', 'asc')
                ->get()
                ->map(function ($j) {
                    $className = $j->class ? (($j->class->grade_level ? "{$j->class->grade_level} " : "") . $j->class->name) : 'Kelas';
                    $startTime = $j->schedule ? substr($j->schedule->start_time, 0, 5) : '07:30';
                    $endTime = $j->schedule ? substr($j->schedule->end_time, 0, 5) : '';
                    $timeStr = $endTime ? "{$startTime} - {$endTime}" : $startTime;

                    return [
                        'id'                => 'journal-' . $j->id,
                        'type'              => 'KLASIKAL',
                        'student_id'        => null,
                        'student_name'      => "Seluruh Siswa ({$className})",
                        'student_avatar'    => null,
                        'class_name'        => $className,
                        'topic'             => $j->topic_material ?: '[Bimbingan Klasikal BK]',
                        'schedule_date'     => $j->teaching_date,
                        'schedule_time'     => $timeStr,
                        'description'       => $j->description ?? 'Bimbingan klasikal menggantikan jadwal KBM di kelas',
                        'status'            => 'APPROVED',
                        'initiator'         => 'GURU_BK',
                        'check_in_time'     => $j->check_in_time,
                        'is_checked_in'     => !empty($j->check_in_time),
                        'is_late'           => (bool)$j->is_late,
                        'minutes_late'      => (int)($j->minutes_late ?? 0),
                        'counseling_result' => $j->class_notes,
                        'filled_at'         => $j->filled_at,
                        'is_filled'         => !empty($j->filled_at),
                        'rating'            => null,
                        'notes_evaluasi'    => null,
                        'likes'             => (int)($j->likes_count ?? 0),
                        'is_liked'          => false,
                        'comments'          => 0,
                        'created_at'        => $j->created_at ? $j->created_at->format('Y-m-d H:i:s') : null,
                    ];
                });

            // Gabungkan dan filter duplikat jika topik klasikal yang sama sudah ada di counseling_requests
            $combined = $counselings->concat($journals)->unique(function ($item) {
                return $item['schedule_date'] . '_' . $item['topic'];
            })->values();

            return response()->json(['status' => 'success', 'data' => $combined]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * PUT /counseling/{id}/status — Guru BK menyetujui / memperbarui status bimbingan.
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:APPROVED,REJECTED,COMPLETED',
        ]);

        try {
            $counseling = CounselingRequest::findOrFail($id);
            $counseling->status = $request->status;
            $counseling->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Status bimbingan berhasil diperbarui',
                'data' => $counseling
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * POST /counseling/{id}/check-in — Guru BK melakukan presensi sesi bimbingan.
     * Logika: Jika lewat >20 menit dari waktu mulai, ditandai Terlambat.
     * WhatsApp trigger: Mengirim notifikasi WA ke Siswa dan Guru BK bahwa bimbingan telah dimulai.
     */
    public function checkIn(Request $request, $id)
    {
        try {
            $user = Auth::user();
            $counseling = CounselingRequest::with(['student', 'guruBk'])->findOrFail($id);

            if (!empty($counseling->check_in_time)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Sesi bimbingan ini sudah melakukan presensi sebelumnya pada ' . Carbon::parse($counseling->check_in_time)->format('H:i') . ' WIB.'
                ], 422);
            }

            $appNow = AppTime::now();

            // Hitung keterlambatan dari schedule_time
            $startTimeStr = explode('-', $counseling->schedule_time)[0];
            $startTimeStr = trim($startTimeStr);
            $targetDateTime = Carbon::parse($counseling->schedule_date . ' ' . $startTimeStr);

            $diffMinutes = $appNow->diffInMinutes($targetDateTime, false); // jika negatif, berarti sudah lewat jadwal
            $minutesLate = 0;
            $isLate = false;

            if ($appNow->gt($targetDateTime)) {
                $minutesLate = abs($diffMinutes);
                if ($minutesLate >= 20) {
                    $isLate = true;
                }
            }

            $counseling->check_in_time = $appNow;
            $counseling->is_late = $isLate;
            $counseling->minutes_late = $minutesLate;
            $counseling->status = 'APPROVED'; // Sedang aktif berjalan
            $counseling->save();

            // Dispatch WhatsApp Notification (Non-blocking / try-catch)
            $this->dispatchCounselingWhatsApp($counseling, 'START');

            return response()->json([
                'status' => 'success',
                'message' => $isLate
                    ? "Presensi berhasil dicatat (Terlambat {$minutesLate} menit)."
                    : "Presensi bimbingan tepat waktu berhasil dicatat!",
                'data' => [
                    'check_in_time' => $counseling->check_in_time,
                    'is_late' => $isLate,
                    'minutes_late' => $minutesLate,
                ]
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * POST /counseling/{id}/fill — Guru BK mengisi jurnal/notulensi bimbingan, rating, dan catatan evaluasi.
     */
    public function fillJournal(Request $request, $id)
    {
        $request->validate([
            'counseling_result' => 'required|string|min:5',
            'notes_evaluasi'    => 'nullable|string',
            'rating'            => 'nullable|numeric|min:1|max:5',
        ]);

        try {
            $counseling = CounselingRequest::findOrFail($id);

            $appNow = AppTime::now();
            $counseling->counseling_result = $request->counseling_result;
            $counseling->notes_evaluasi = $request->notes_evaluasi;
            if ($request->filled('rating')) {
                $counseling->rating = $request->rating;
            }
            $counseling->filled_at = $appNow;
            $counseling->status = 'COMPLETED';
            $counseling->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Jurnal bimbingan konseling berhasil disimpan!',
                'data' => $counseling,
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * PUT /counseling/{id}/update — Guru BK memperbarui isi bimbingan/jadwal.
     */
    public function updateCounseling(Request $request, $id)
    {
        $request->validate([
            'topic'         => 'sometimes|required|string',
            'schedule_date' => 'sometimes|required|date',
            'schedule_time' => 'sometimes|required|string',
            'description'   => 'nullable|string',
        ]);

        try {
            $counseling = CounselingRequest::findOrFail($id);
            if ($request->has('topic')) $counseling->topic = $request->topic;
            if ($request->has('schedule_date')) $counseling->schedule_date = $request->schedule_date;
            if ($request->has('schedule_time')) $counseling->schedule_time = $request->schedule_time;
            if ($request->has('description')) $counseling->description = $request->description;
            $counseling->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Data sesi bimbingan berhasil diperbarui!',
                'data' => $counseling,
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * POST /counseling/{id}/like — Toggle suka pada kartu sesi bimbingan.
     */
    public function toggleLike($id)
    {
        try {
            $user = Auth::user();
            $counseling = CounselingRequest::findOrFail($id);

            $existing = \App\Models\CounselingLike::where('counseling_id', $id)
                ->where('user_id', $user->id)
                ->first();

            if ($existing) {
                $existing->delete();
                $counseling->decrement('likes_count');
                $isLiked = false;
            } else {
                \App\Models\CounselingLike::create([
                    'counseling_id' => $id,
                    'user_id' => $user->id,
                ]);
                $counseling->increment('likes_count');
                $isLiked = true;
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'is_liked' => $isLiked,
                    'likes_count' => (int)$counseling->likes_count,
                ]
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * GET /counseling/{id}/comments — Mengambil daftar komentar sesi bimbingan.
     */
    public function getComments($id)
    {
        try {
            $user = Auth::user();
            $counseling = CounselingRequest::findOrFail($id);

            $comments = \App\Models\CounselingComment::where('counseling_id', $id)
                ->with(['user.siswaProfile', 'user.guruProfile', 'user.role'])
                ->orderBy('created_at', 'asc')
                ->get()
                ->map(function ($c) use ($user, $counseling) {
                    $isMe = $user && $c->user_id === $user->id;
                    $role = $c->user?->role?->name ?? ($c->user?->role_type ?? 'PENGGUNA');
                    $rawName = $c->user?->siswaProfile?->full_name 
                        ?: ($c->user?->guruProfile?->full_name 
                            ?: ($c->user?->full_name ?: ($c->user?->username ?? 'Pengguna')));

                    return [
                        'id'              => $c->id,
                        'counseling_id'   => $c->counseling_id,
                        'user_id'         => $c->user_id,
                        'author_name'     => $rawName,
                        'raw_author_name' => $rawName,
                        'author_role'     => $role,
                        'author_avatar'   => $c->user?->avatar ?? $c->user?->profile_picture ?? null,
                        'comment_text'    => $c->comment_text,
                        'created_at'      => $c->created_at ? $c->created_at->toIso8601String() : null,
                        'is_me'           => $isMe,
                        'can_delete'      => $isMe || ($user && $user->id === $counseling->guru_bk_id),
                    ];
                });

            return response()->json([
                'status' => 'success',
                'data' => $comments,
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * POST /counseling/{id}/comments — Mengirim komentar pada sesi bimbingan.
     */
    public function addComment(Request $request, $id)
    {
        $request->validate([
            'comment_text' => 'required|string|max:500',
        ]);

        try {
            $user = Auth::user();
            $counseling = CounselingRequest::findOrFail($id);
            $role = $user->role?->name ?? ($user->role_type ?? 'SISWA');

            $comment = \App\Models\CounselingComment::create([
                'counseling_id' => $id,
                'user_id'       => $user->id,
                'comment_text'  => $request->comment_text,
            ]);

            $rawName = $user->siswaProfile?->full_name 
                ?: ($user->guruProfile?->full_name 
                    ?: ($user->full_name ?: ($user->username ?? 'Pengguna')));

            return response()->json([
                'status' => 'success',
                'message' => 'Komentar bimbingan berhasil dikirim.',
                'data' => [
                    'id'              => $comment->id,
                    'counseling_id'   => $comment->counseling_id,
                    'user_id'         => $comment->user_id,
                    'author_name'     => 'Saya',
                    'raw_author_name' => $rawName,
                    'author_role'     => $role,
                    'author_avatar'   => $user->avatar ?? $user->profile_picture ?? null,
                    'comment_text'    => $comment->comment_text,
                    'created_at'      => $comment->created_at ? $comment->created_at->toIso8601String() : now()->toIso8601String(),
                    'is_me'           => true,
                    'can_delete'      => true,
                ]
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * DELETE /counseling/{id}/comments/{commentId} — Hapus komentar bimbingan.
     */
    public function deleteComment($id, $commentId)
    {
        try {
            $user = Auth::user();
            $counseling = CounselingRequest::findOrFail($id);
            $comment = \App\Models\CounselingComment::where('counseling_id', $id)
                ->where('id', $commentId)
                ->firstOrFail();

            $isMe = $user && $comment->user_id === $user->id;
            $isGuruBk = $user && $counseling->guru_bk_id === $user->id;

            if (!$isMe && !$isGuruBk) {
                return response()->json(['status' => 'error', 'message' => 'Tidak memiliki izin untuk menghapus komentar ini.'], 403);
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

    /**
     * POST /counseling/{id}/rating — Siswa atau Guru BK memberikan/memperbarui rating bintang.
     */
    public function submitRating(Request $request, $id)
    {
        $request->validate([
            'rating' => 'required|numeric|min:1|max:5',
        ]);

        try {
            $counseling = CounselingRequest::findOrFail($id);
            $counseling->rating = (float)$request->rating;
            $counseling->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Rating bimbingan berhasil disimpan!',
                'data' => [
                    'rating' => (float)$counseling->rating,
                ]
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Helper: Dispatch WhatsApp Notification saat sesi bimbingan dimulai.
     */
    private function dispatchCounselingWhatsApp(CounselingRequest $counseling, string $event = 'START'): void
    {
        $gatewayUrl = env('WA_GATEWAY_URL', 'http://127.0.0.1:3001/send-message');
        $gatewayKey = env('WA_GATEWAY_KEY', 'anise_secret_gateway_key_2026');

        $student = $counseling->student;
        $guruBk = $counseling->guruBk;

        $studentName = $student ? ($student->full_name ?: $student->username) : 'Siswa';
        $guruBkName = $guruBk ? ($guruBk->full_name ?: $guruBk->username) : 'Guru BK';
        $topic = $counseling->topic;
        $time = $counseling->schedule_time;
        $date = Carbon::parse($counseling->schedule_date)->isoFormat('dddd, D MMMM Y');

        $studentPhone = $student?->phone ?? $student?->siswaProfile?->phone ?? null;
        $guruPhone = $guruBk?->phone ?? $guruBk?->guruProfile?->phone ?? null;

        $msgForStudent = "🔔 *Pemberitahuan Sesi Bimbingan BK — ANIS-App*\n\n"
            . "Halo *{$studentName}*,\n"
            . "Sesi bimbingan konseling Anda telah *dimulai*.\n\n"
            . "📋 *Topik:* {$topic}\n"
            . "👨‍🏫 *Guru BK:* {$guruBkName}\n"
            . "📅 *Waktu:* {$date} ({$time} WIB)\n\n"
            . "Mohon segera hadir di ruang BK tepat waktu.\n"
            . "Terima kasih.";

        $msgForGuru = "🔔 *Sesi Bimbingan BK Dimulai — ANIS-App*\n\n"
            . "Halo *{$guruBkName}*,\n"
            . "Presensi sesi bimbingan bersama siswa *{$studentName}* telah berhasil dicatat.\n\n"
            . "📋 *Topik:* {$topic}\n"
            . "📅 *Waktu:* {$date} ({$time} WIB)\n\n"
            . "Setelah sesi berakhir, jangan lupa mengisi hasil evaluasi dan penilaian jurnal bimbingan.\n"
            . "Semoga lancar!";

        // Kirim ke siswa
        if ($studentPhone) {
            try {
                \Illuminate\Support\Facades\Http::timeout(5)
                    ->withHeaders(['x-api-key' => $gatewayKey, 'Content-Type' => 'application/json'])
                    ->post($gatewayUrl, ['phone' => $studentPhone, 'message' => $msgForStudent]);
            } catch (\Throwable $e) {
                \Illuminate\Support\Facades\Log::info("WA BK Student offline/error: " . $e->getMessage());
            }
        }

        // Kirim ke guru BK
        if ($guruPhone) {
            try {
                \Illuminate\Support\Facades\Http::timeout(5)
                    ->withHeaders(['x-api-key' => $gatewayKey, 'Content-Type' => 'application/json'])
                    ->post($gatewayUrl, ['phone' => $guruPhone, 'message' => $msgForGuru]);
            } catch (\Throwable $e) {
                \Illuminate\Support\Facades\Log::info("WA BK Guru offline/error: " . $e->getMessage());
            }
        }
    }
}
