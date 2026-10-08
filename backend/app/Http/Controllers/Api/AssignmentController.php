<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\JournalTask;
use App\Models\JournalTaskAttachment;
use App\Models\StudentTaskSubmission;
use App\Models\ClassStudent;
use Illuminate\Support\Facades\Auth;

class AssignmentController extends Controller
{
    public function storeTask(Request $request)
    {
        $request->validate([
            'journal_id' => 'required|exists:journals,id',
            'title' => 'required|string',
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

            if ($request->hasFile('attachment')) {
                $path = $request->file('attachment')->store('tasks', 'public');
                JournalTaskAttachment::create([
                    'journal_task_id' => $task->id,
                    'file_name' => $request->file('attachment')->getClientOriginalName(),
                    'file_url' => '/storage/' . $path
                ]);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Tugas berhasil dibuat.'
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getTasks()
    {
        try {
            $user = Auth::user();
            
            $tasks = JournalTask::whereHas('journal.schedule', function ($q) use ($user) {
                $q->where('teacher_id', $user->id);
            })
            ->with(['journal.schedule.class.major', 'journal.schedule.subject'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($task) {
                $schedule = $task->journal->schedule;
                $classObj = $schedule->class;
                $className = $classObj->grade_level . ' ' . $classObj->name;
                
                $submittedCount = StudentTaskSubmission::where('journal_task_id', $task->id)->count();
                $totalStudents = ClassStudent::where('class_id', $classObj->id)->count();

                return [
                    'id' => $task->id,
                    'title' => $task->title,
                    'description' => $task->description,
                    'due_date' => $task->due_date,
                    'created_at' => $task->created_at,
                    'subject_name' => $schedule->subject->name,
                    'class_name' => $className,
                    'submitted_count' => $submittedCount,
                    'total_students' => $totalStudents
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $tasks
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    public function getSiswaTasks()
    {
        try {
            $user = Auth::user();
            $classStudent = ClassStudent::where('student_id', $user->id)
                ->where('status', 'ACTIVE')
                ->first();
                
            if (!$classStudent) {
                return response()->json(['status' => 'success', 'data' => []]);
            }
            
            $classId = $classStudent->class_id;

            $tasks = JournalTask::whereHas('journal.schedule', function ($q) use ($classId) {
                $q->where('class_id', $classId);
            })
            ->with(['journal.schedule.subject', 'journal.schedule.teacher.guruProfile'])
            ->orderBy('due_date', 'asc')
            ->get()
            ->map(function ($task) {
                $sched = $task->journal->schedule;
                $teacherName = $sched->teacher->guruProfile ? $sched->teacher->guruProfile->full_name : $sched->teacher->username;
                
                return [
                    'id' => $task->id,
                    'title' => $task->title,
                    'description' => $task->description,
                    'due_date' => $task->due_date,
                    'attachment_path' => $task->attachment_path,
                    'subject' => $sched->subject->name,
                    'teacher' => $teacherName,
                    'created_at' => $task->created_at,
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $tasks
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}
