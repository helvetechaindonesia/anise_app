<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use App\Models\CounselingRequest;
use App\Models\GuruBkClass;
use App\Models\ClassStudent;

class CounselingController extends Controller
{
    // GET /counseling/guru-bk — siswa get assigned guru BK
    public function getGuruBk()
    {
        try {
            $user = Auth::user();
            $classStudent = ClassStudent::where('student_id', $user->id)
                ->where('status', 'ACTIVE')
                ->first();

            if (!$classStudent) {
                return response()->json(['status' => 'error', 'message' => 'Kelas tidak ditemukan'], 404);
            }

            $guruBkClass = GuruBkClass::where('class_id', $classStudent->class_id)
                ->with('guru')
                ->first();

            if (!$guruBkClass || !$guruBkClass->guru) {
                return response()->json(['status' => 'error', 'message' => 'Guru BK tidak ditemukan untuk kelas ini'], 404);
            }

            $guru = $guruBkClass->guru;
            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $guru->id,
                    'name' => $guru->full_name ?: $guru->username,
                    'email' => $guru->email,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // POST /counseling — siswa submit pengajuan bimbingan
    public function store(Request $request)
    {
        $request->validate([
            'topic'          => 'required|string',
            'schedule_date'  => 'required|date',
            'schedule_time'  => 'required|string',
            'description'    => 'nullable|string',
        ]);

        try {
            $user = Auth::user();
            $classStudent = ClassStudent::where('student_id', $user->id)
                ->where('status', 'ACTIVE')
                ->first();

            $guruBkId = null;
            if ($classStudent) {
                $guruBkClass = GuruBkClass::where('class_id', $classStudent->class_id)->first();
                $guruBkId = $guruBkClass?->guru_id;
            }

            $counseling = CounselingRequest::create([
                'id'            => Str::uuid(),
                'student_id'    => $user->id,
                'guru_bk_id'    => $guruBkId,
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

    // GET /counseling/siswa — siswa lihat riwayat pengajuan
    public function siswaIndex()
    {
        try {
            $user = Auth::user();
            $data = CounselingRequest::where('student_id', $user->id)
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
                        'created_at'    => $c->created_at,
                    ];
                });

            return response()->json(['status' => 'success', 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // GET /counseling/guru-bk/requests — guru BK lihat semua pengajuan masuk
    public function guruBkIndex()
    {
        try {
            $user = Auth::user();
            $data = CounselingRequest::where('guru_bk_id', $user->id)
                ->with('student')
                ->orderBy('schedule_date', 'asc')
                ->get()
                ->map(function ($c) {
                    return [
                        'id'            => $c->id,
                        'student_name'  => $c->student ? ($c->student->full_name ?: $c->student->username) : '-',
                        'topic'         => $c->topic,
                        'schedule_date' => $c->schedule_date,
                        'schedule_time' => $c->schedule_time,
                        'description'   => $c->description,
                        'status'        => $c->status,
                        'created_at'    => $c->created_at,
                    ];
                });

            return response()->json(['status' => 'success', 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    // PUT /counseling/{id}/status — guru BK update status
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:APPROVED,REJECTED,COMPLETED',
        ]);

        try {
            $counseling = CounselingRequest::findOrFail($id);
            $counseling->status = $request->status;
            $counseling->save();

            return response()->json(['status' => 'success', 'data' => $counseling]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}
