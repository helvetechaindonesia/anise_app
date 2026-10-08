<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\StudentLeave;
use App\Traits\ApiResponser;

class LeaveController extends Controller
{
    use ApiResponser;

    public function submitStudentLeave(Request $request)
    {
        $request->validate([
            'type' => 'required|in:DISPENSASI,IZIN',
            'reason' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
            'attachment' => 'nullable|file',
        ]);

        $attachmentPath = null;
        if ($request->hasFile('attachment')) {
            $attachmentPath = $request->file('attachment')->store('leaves', 'public');
        }

        $leave = StudentLeave::create([
            'student_id' => $request->user()->id,
            'type' => $request->type,
            'reason' => $request->reason,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'attachment_path' => $attachmentPath,
            'status' => 'PENDING',
        ]);

        return $this->success($leave, 'Pengajuan berhasil dikirim');
    }

    public function getStudentLeaves(Request $request)
    {
        $type = $request->query('type');
        $query = StudentLeave::with('student')->orderBy('created_at', 'desc');
        
        if ($type) {
            $query->where('type', $type);
        }

        return $this->success($query->get());
    }
}
