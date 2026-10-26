<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use App\Models\CounselingRequest;
use App\Models\User;
use App\Models\Role;

class CounselingController extends Controller
{
    /**
     * GET /counseling/guru-bk — Mengambil daftar seluruh Guru BK yang aktif untuk dropdown siswa.
     */
    public function getGuruBk()
    {
        try {
            $roleBk = Role::where('name', 'GURU_BK')->first();
            $roleBkId = $roleBk ? $roleBk->id : null;

            // Cari semua user dengan role GURU_BK atau yang memiliki nama BK
            $guruList = User::where('is_active', true)
                ->where(function ($q) use ($roleBkId) {
                    if ($roleBkId) {
                        $q->where('role_id', $roleBkId);
                    }
                    $q->orWhere('full_name', 'ILIKE', '%BK%')
                      ->orWhere('username', 'ILIKE', '%bk%');
                })
                ->select('id', 'full_name', 'username', 'email')
                ->orderBy('full_name', 'asc')
                ->get()
                ->map(function ($g) {
                    return [
                        'id' => $g->id,
                        'name' => $g->full_name ?: $g->username,
                        'email' => $g->email ?? '',
                    ];
                });

            // Jika belum ada data guru BK spesifik, fallback ke guru umum agar dropdown tidak kosong
            if ($guruList->isEmpty()) {
                $roleGuru = Role::where('name', 'GURU')->first();
                $guruList = User::where('is_active', true)
                    ->when($roleGuru, fn($q) => $q->where('role_id', $roleGuru->id))
                    ->limit(5)
                    ->get()
                    ->map(function ($g) {
                        return [
                            'id' => $g->id,
                            'name' => ($g->full_name ?: $g->username) . ' (Guru Pembimbing)',
                            'email' => $g->email ?? '',
                        ];
                    });
            }

            return response()->json([
                'status' => 'success',
                'data' => $guruList,
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * POST /counseling — Siswa submit pengajuan bimbingan dengan memilih Guru BK.
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

        try {
            $user = Auth::user();

            $counseling = CounselingRequest::create([
                'id'            => (string) Str::uuid(),
                'student_id'    => $user->id,
                'guru_bk_id'    => $request->guru_bk_id,
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
     * GET /counseling/siswa — Siswa melihat seluruh riwayat pengajuan bimbingannya.
     */
    public function siswaIndex()
    {
        try {
            $user = Auth::user();
            $data = CounselingRequest::where('student_id', $user->id)
                ->with('guruBk')
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
     * GET /counseling/guru-bk/requests — Guru BK melihat permohonan bimbingan yang masuk ke dirinya.
     */
    public function guruBkIndex(Request $request)
    {
        try {
            $user = Auth::user();

            $query = CounselingRequest::where(function ($q) use ($user) {
                    $q->where('guru_bk_id', $user->id)
                      ->orWhereNull('guru_bk_id'); // Memungkinkan melihat bimbingan unassigned
                })
                ->with(['student.siswaProfile.schoolClass', 'student']);

            if ($request->filled('date')) {
                $query->whereDate('schedule_date', $request->date);
            }

            $data = $query->orderBy('schedule_date', 'asc')
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($c) {
                    $student = $c->student;
                    $className = $student?->siswaProfile?->schoolClass?->name ?? 'Siswa';
                    return [
                        'id'            => $c->id,
                        'student_name'  => $student ? ($student->full_name ?: $student->username) : 'Siswa',
                        'class_name'    => $className,
                        'topic'         => $c->topic,
                        'schedule_date' => $c->schedule_date,
                        'schedule_time' => $c->schedule_time,
                        'description'   => $c->description,
                        'status'        => $c->status,
                        'created_at'    => $c->created_at ? $c->created_at->format('Y-m-d H:i:s') : null,
                    ];
                });

            return response()->json(['status' => 'success', 'data' => $data]);
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
