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

            $journals = \App\Models\Journal::whereHas('schedule', function ($q) use ($classId) {
                $q->where('class_id', $classId);
            })
            ->with(['schedule.subject', 'schedule.teacher.guruProfile', 'tasks'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($journal) {
                $sched = $journal->schedule;
                $teacherName = $sched->teacher->guruProfile ? $sched->teacher->guruProfile->full_name : $sched->teacher->username;
                
                return [
                    'id' => $journal->id,
                    'topic' => $journal->topic_material,
                    'description' => $journal->description,
                    'created_at' => $journal->created_at,
                    'teaching_date' => $journal->teaching_date,
                    'subject' => $sched->subject->name,
                    'teacher' => $teacherName,
                    'start_time' => $sched->start_time,
                    'end_time' => $sched->end_time,
                    'day_of_week' => $sched->day_of_week,
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
