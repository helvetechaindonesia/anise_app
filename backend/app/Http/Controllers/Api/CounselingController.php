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
            // 1. Cari user mandiri dengan Role 'GURU_BK' atau akun Wartono / BK
            $guruBkUsers = User::where('is_active', true)
                ->where(function ($q) {
                    $q->whereHas('role', function ($r) {
                        $r->where('name', 'GURU_BK')
                          ->orWhere('name', 'ILIKE', '%BK%')
                          ->orWhere('name', 'ILIKE', '%bimbingan%');
                    })
                    ->orWhere('username', 'ILIKE', '%bk%')
                    ->orWhere('username', 'ILIKE', '%wartono%')
                    ->orWhere('full_name', 'ILIKE', '%wartono%')
                    ->orWhere('full_name', 'ILIKE', '%BK%')
                    ->orWhere('full_name', 'ILIKE', '%Bimbingan%')
                    ->orWhere('full_name', 'ILIKE', '%Konseling%');
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
            'schedule_date' => 'required|date',
            'schedule_time' => 'required|string',
            'description'   => 'nullable|string',
            // Untuk Klasikal:
            'class_id'      => 'required_if:type,KLASIKAL|nullable|exists:classes,id',
            'schedule_id'   => 'required_if:type,KLASIKAL|nullable|exists:schedules,id',
            // Untuk Individu / Kelompok:
            'student_ids'   => 'required_if:type,INDIVIDU,KELOMPOK|array',
            'student_ids.*' => 'exists:users,id',
        ]);

        $appNow = AppTime::now();
        $targetDateTime = Carbon::parse($request->schedule_date . ' ' . $request->schedule_time);
        if ($targetDateTime->lt($appNow)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Jadwal pelaksanaan tidak boleh di waktu yang telah berlalu! (Waktu Server: ' . $appNow->format('d/m/Y H:i') . ' WIB)'
            ], 422);
        }

        try {
            $user = Auth::user();
            $type = $request->type;
            $results = [];

            if ($type === 'KLASIKAL') {
                $schedule = Schedule::with(['subject', 'class', 'teacher'])->findOrFail($request->schedule_id);

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
                    'schedule_date' => $request->schedule_date,
                    'schedule_time' => $request->schedule_time,
                    'description'   => $request->description ?? "Bimbingan Klasikal menggantikan jadwal {$schedule->subject?->name} ({$schedule->teacher?->full_name})",
                    'status'        => 'APPROVED',
                ]);

                // 3. Menimpa Jurnal KBM (Classroom Hijacking)
                // Buat atau Update Journal untuk jadwal dan tanggal tersebut atas nama Guru BK
                $journal = Journal::updateOrCreate(
                    [
                        'schedule_id'   => $schedule->id,
                        'teaching_date' => $request->schedule_date,
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

            // Cari kelas siswa untuk bimbingan klasikal
            $classStudent = ClassStudent::where('student_id', $user->id)->where('status', 'ACTIVE')->first();
            $classId = $classStudent?->class_id;

            $data = CounselingRequest::where(function ($q) use ($user) {
                    $q->where('student_id', $user->id);
                })
                ->with('guruBk')
                ->orderBy('schedule_date', 'desc')
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($c) {
                    return [
                        'id'            => $c->id,
                        'topic'         => $c->topic,
                        'schedule_date' => $c->schedule_date,
                        'schedule_time' => $c->schedule_time,
                        'description'   => $c->description,
                        'status'        => $c->status,
                        'initiator'     => $c->initiator ?? 'STUDENT',
                        'guru_bk_name'  => $c->guruBk ? ($c->guruBk->full_name ?: $c->guruBk->username) : 'Guru BK',
                        'created_at'    => $c->created_at ? $c->created_at->format('Y-m-d H:i:s') : null,
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
                ->map(function ($c) {
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

                    return [
                        'id'            => $c->id,
                        'type'          => $type,
                        'student_name'  => $student ? ($student->full_name ?: $student->username) : 'Siswa',
                        'class_name'    => $className,
                        'topic'         => $c->topic,
                        'schedule_date' => $c->schedule_date,
                        'schedule_time' => $c->schedule_time,
                        'description'   => $c->description,
                        'status'        => $c->status,
                        'initiator'     => $c->initiator ?? 'STUDENT',
                        'created_at'    => $c->created_at ? $c->created_at->format('Y-m-d H:i:s') : null,
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
                        'id'            => 'journal-' . $j->id,
                        'type'          => 'KLASIKAL',
                        'student_name'  => "Seluruh Siswa ({$className})",
                        'class_name'    => $className,
                        'topic'         => $j->topic_material ?: '[Bimbingan Klasikal BK]',
                        'schedule_date' => $j->teaching_date,
                        'schedule_time' => $timeStr,
                        'description'   => $j->description ?? 'Bimbingan klasikal menggantikan jadwal KBM di kelas',
                        'status'        => 'APPROVED',
                        'initiator'     => 'GURU_BK',
                        'created_at'    => $j->created_at ? $j->created_at->format('Y-m-d H:i:s') : null,
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
}
