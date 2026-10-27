<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Leave;
use App\Models\SchoolClass;
use App\Models\ClassStudent;
use App\Models\User;
use App\Services\FileStorageService;
use App\Services\AttendanceService;
use App\Traits\ApiResponser;
use Carbon\Carbon;
use App\Helpers\AppTime;
use Illuminate\Support\Facades\DB;

class LeaveController extends Controller
{
    use ApiResponser;

    /**
     * Submit Pengajuan Izin / Sakit / Dispensasi (Universal untuk Siswa & Pegawai)
     * Batas pengajuan untuk hari ini: Pukul 16.01 WIB
     */
    public function submitLeave(Request $request)
    {
        $request->validate([
            'type' => 'required|in:IZIN,SAKIT,DISPENSASI',
            'reason' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'exit_time' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'location_name' => 'nullable|string',
            'attachment' => 'nullable|file|max:10240',
            'face_image' => 'nullable|file|image|max:10240',
        ]);

        $user = $request->user();
        $now = AppTime::now();
        $todayStr = $now->format('Y-m-d');
        $currentTimeStr = $now->format('H:i');

        // Batas pengajuan perijinan adalah pukul 16.01 WIB untuk hari berjalan
        if ($request->start_date === $todayStr && $currentTimeStr > '16:01') {
            return response()->json([
                'success' => false,
                'message' => 'Batas waktu pengajuan perizinan untuk hari ini telah lewat (Maksimal pukul 16.01 WIB).',
            ], 422);
        }

        // 1. Simpan lampiran berkas jika ada
        $attachmentPath = null;
        if ($request->hasFile('attachment')) {
            $attachmentPath = FileStorageService::storeLeaveAttachment($request->file('attachment'), $user);
        }

        // 2. Simpan face snapshot kamera jika ada
        $faceSnapshotUrl = null;
        if ($request->hasFile('face_image')) {
            $faceSnapshotUrl = FileStorageService::storeLeaveFaceSnapshot($request->file('face_image'), $user);
        }

        // Format exit_time jika tipe DISPENSASI
        $exitTime = null;
        if ($request->type === 'DISPENSASI') {
            $exitTime = $request->exit_time ?: $now->format('H:i:s');
        }

        $leave = Leave::create([
            'user_id' => $user->id,
            'type' => $request->type,
            'reason' => $request->reason,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'exit_time' => $exitTime,
            'attachment_path' => $attachmentPath,
            'face_snapshot_url' => $faceSnapshotUrl,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'location_name' => $request->location_name,
            'status' => 'PENDING',
        ]);

        return $this->success($leave, 'Pengajuan ' . strtolower($request->type) . ' berhasil dikirim, menunggu persetujuan.');
    }

    /**
     * Mengambil daftar perizinan untuk verifikasi (Inbox Perijinan)
     * - Siswa: Hanya Wali Kelas dari kelas siswa bersangkutan yang berhak melihat & approve
     * - Tenaga Pendidik: Kepala Sekolah / Super Admin yang berhak melihat & approve
     */
    public function getPendingLeaves(Request $request)
    {
        $user = $request->user();
        $isTeacher = in_array($user->role_type, ['GURU', 'GURU_BK']);
        $isKepsek = in_array($user->role_type, ['KEPALA_SEKOLAH', 'SUPER_ADMIN']);

        $query = Leave::with(['user.studentClass', 'user.siswaProfile', 'user.guruProfile', 'approver'])
            ->orderBy('created_at', 'desc');

        if ($request->filled('type')) {
            $query->where('type', strtoupper($request->type));
        }

        if ($request->filled('status')) {
            $query->where('status', strtoupper($request->status));
        }

        if ($isTeacher) {
            // Cek kelas mana saja yang diwalikan oleh guru ini
            $myClassIds = SchoolClass::where('wali_kelas_id', $user->id)->pluck('id')->toArray();
            
            if (empty($myClassIds)) {
                return $this->success([], 'Anda belum ditugaskan sebagai Wali Kelas.');
            }

            // Ambil ID siswa yang terdaftar di kelas-kelas asuh guru ini
            $myStudentUserIds = ClassStudent::whereIn('class_id', $myClassIds)->pluck('student_id')->toArray();

            $query->whereIn('user_id', $myStudentUserIds);
        } elseif ($isKepsek) {
            // Kepala Sekolah melihat perizinan Tenaga Pendidik (Guru / Tendik)
            $guruRoleIds = DB::table('roles')->whereIn(DB::raw('UPPER(name)'), ['GURU', 'GURU_BK', 'TATA_USAHA'])->pluck('id')->toArray();
            $query->whereHas('user', function ($q) use ($guruRoleIds) {
                $q->whereIn('role_id', $guruRoleIds);
            });
        }

        $leaves = $query->get()->map(function ($item) use ($user) {
            $now = AppTime::now();
            $today = $now->format('Y-m-d');
            $currentTime = $now->format('H:i');

            // Tombol "Konfirmasi Kembali" untuk Dispensasi aktif jika:
            // 1. Status dispensasi = APPROVED
            // 2. Tanggal dispensasi adalah HARI INI
            // 3. Belum pernah dikonfirmasi kembali (returned_at null)
            // 4. Belum lewat pukul 18.01 WIB
            $canConfirmReturn = false;
            if ($item->type === 'DISPENSASI' && $item->status === 'APPROVED' && empty($item->returned_at)) {
                $isToday = Carbon::parse($item->start_date)->format('Y-m-d') === $today;
                if ($isToday && $currentTime <= '18:01') {
                    $canConfirmReturn = true;
                }
            }

            $item->can_confirm_return = $canConfirmReturn;
            return $item;
        });

        return $this->success($leaves);
    }

    /**
     * Riwayat pengajuan perizinan pribadi (History)
     */
    public function getMyLeaves(Request $request)
    {
        $user = $request->user();
        $query = Leave::where('user_id', $user->id)
            ->with('approver')
            ->orderBy('created_at', 'desc');

        if ($request->filled('type')) {
            $query->where('type', strtoupper($request->type));
        }

        return $this->success($query->get());
    }

    /**
     * Approval / Penolakan Perizinan
     * - Siswa: Hanya Wali Kelas
     * - Guru: Kepala Sekolah / Super Admin
     */
    public function updateLeaveStatus(Request $request, $id, AttendanceService $attendanceService)
    {
        $request->validate([
            'status' => 'required|in:APPROVED,REJECTED',
            'notes' => 'nullable|string',
        ]);

        $approver = $request->user();
        $leave = Leave::with('user')->findOrFail($id);

        $targetUser = $leave->user;
        $isTargetStudent = strtoupper($targetUser->role_type ?? '') === 'SISWA';

        // Validasi otoritas approver
        if ($isTargetStudent) {
            // Cek apakah approver adalah Wali Kelas dari siswa ini
            $studentClass = ClassStudent::where('student_id', $targetUser->id)->first();
            $isWaliKelas = false;
            if ($studentClass) {
                $isWaliKelas = SchoolClass::where('id', $studentClass->class_id)
                    ->where('wali_kelas_id', $approver->id)
                    ->exists();
            }

            if (!$isWaliKelas && !in_array($approver->role_type, ['SUPER_ADMIN', 'KEPALA_SEKOLAH'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Akses ditolak! Hanya Wali Kelas bersangkutan yang berhak menyetujui perizinan siswa ini.',
                ], 403);
            }
        } else {
            // Target adalah Guru/Tendik -> Approver harus Kepala Sekolah / Super Admin
            if (!in_array($approver->role_type, ['KEPALA_SEKOLAH', 'SUPER_ADMIN'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Akses ditolak! Hanya Kepala Sekolah yang berhak menyetujui perizinan tenaga pendidik.',
                ], 403);
            }
        }

        $leave->status = $request->status;
        $leave->approved_by = $approver->id;
        $leave->approval_notes = $request->notes;
        $leave->save();

        // JIKA DITOLAK: Beri notifikasi ke murid/pemohon tanpa mengubah status ke Alpha
        if ($request->status === 'REJECTED') {
            $notifTitle = 'Pengajuan ' . ucfirst(strtolower($leave->type)) . ' Ditolak';
            $rejectReason = !empty($request->notes) ? ": {$request->notes}" : '.';
            $notifMsg = "Mohon maaf, pengajuan {$leave->type} Anda untuk tanggal {$leave->start_date} ditolak oleh Wali Kelas / Pihak Sekolah{$rejectReason}";
            
            \App\Services\NotificationService::sendInAppNotification($targetUser->id, $notifTitle, $notifMsg);
        }

        // JIKA DISETUJUI, sinkronkan ke logic presensi hari ini secara realtime:
        if ($request->status === 'APPROVED') {
            $today = AppTime::now()->format('Y-m-d');
            $leaveStart = Carbon::parse($leave->start_date)->format('Y-m-d');
            $leaveEnd = Carbon::parse($leave->end_date)->format('Y-m-d');

            if ($today >= $leaveStart && $today <= $leaveEnd) {
                if ($leave->type === 'DISPENSASI') {
                    // Untuk Siswa: Terbit status PA pada jam dispensasi
                    // Untuk Pegawai: Terbit status PA yang didukung dispensasi (pulang resmi pada jam dispensasi)
                    $exitTime = $leave->exit_time ? Carbon::parse($today . ' ' . $leave->exit_time) : now();
                    
                    $existingAtt = DB::table('attendances')
                        ->where('user_id', $targetUser->id)
                        ->where('tanggal', $today)
                        ->first();

                    if ($existingAtt) {
                        DB::table('attendances')
                            ->where('id', $existingAtt->id)
                            ->update([
                                'jam_pulang' => $exitTime,
                                'status' => 'PA',
                                'updated_at' => now(),
                            ]);
                    } else {
                        DB::table('attendances')->insert([
                            'id' => (string) \Illuminate\Support\Str::uuid(),
                            'user_id' => $targetUser->id,
                            'tanggal' => $today,
                            'jam_masuk' => Carbon::parse($today . ' 07:00:00'),
                            'jam_pulang' => $exitTime,
                            'status' => 'PA',
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }

                    // Catat ke presensi_logs
                    DB::table('presensi_logs')->insert([
                        'id' => (string) \Illuminate\Support\Str::uuid(),
                        'user_id' => $targetUser->id,
                        'scan_time' => $exitTime,
                        'status' => 'PA',
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                } else {
                    // Tipe IZIN / SAKIT: Catat status IZIN/SAKIT agar hari ini dihitung sebagai hari nonaktif khusus user
                    $leaveStatusCode = $leave->type === 'SAKIT' ? 'S' : 'I';
                    $existingAtt = DB::table('attendances')
                        ->where('user_id', $targetUser->id)
                        ->where('tanggal', $today)
                        ->first();

                    if ($existingAtt) {
                        DB::table('attendances')
                            ->where('id', $existingAtt->id)
                            ->update([
                                'status' => $leaveStatusCode,
                                'updated_at' => now(),
                            ]);
                    } else {
                        DB::table('attendances')->insert([
                            'id' => (string) \Illuminate\Support\Str::uuid(),
                            'user_id' => $targetUser->id,
                            'tanggal' => $today,
                            'jam_masuk' => null,
                            'jam_pulang' => null,
                            'status' => $leaveStatusCode,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }
                }
            }
        }

        return $this->success($leave, 'Pengajuan perizinan berhasil ' . ($request->status === 'APPROVED' ? 'disetujui' : 'ditolak') . '.');
    }

    /**
     * Konfirmasi Kembali dari Dispensasi oleh Wali Kelas
     */
    public function confirmReturn(Request $request, $id)
    {
        $approver = $request->user();
        $leave = Leave::with('user')->findOrFail($id);

        if ($leave->type !== 'DISPENSASI') {
            return response()->json(['success' => false, 'message' => 'Konfirmasi kembali hanya berlaku untuk dispensasi.'], 400);
        }

        if ($leave->status !== 'APPROVED') {
            return response()->json(['success' => false, 'message' => 'Dispensasi belum disetujui.'], 400);
        }

        if (!empty($leave->returned_at)) {
            return response()->json(['success' => false, 'message' => 'Siswa sudah dikonfirmasi kembali sebelumnya.'], 400);
        }

        $now = AppTime::now();
        if ($now->format('H:i') > '18:01') {
            return response()->json(['success' => false, 'message' => 'Batas waktu konfirmasi kembali telah lewat (18.01 WIB).'], 422);
        }

        $leave->returned_at = $now;
        $leave->save();

        // Catat log kembali (K) di presensi_logs
        DB::table('presensi_logs')->insert([
            'id' => (string) \Illuminate\Support\Str::uuid(),
            'user_id' => $leave->user_id,
            'scan_time' => $now,
            'status' => 'K',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return $this->success($leave, 'Siswa berhasil dikonfirmasi kembali dari masa dispensasi.');
    }

    /**
     * Unduh lampiran surat/berkas izin dengan penamaan standar:
     * {Kategori Perijinan}_{Nama Siswa}_{Tingkat}_{Nama Kelas}_{DD/MM/YYYY}.{ext}
     */
    public function downloadAttachment($id)
    {
        try {
            $leave = Leave::with(['user.studentClass', 'user.siswaProfile'])->findOrFail($id);

            if (empty($leave->attachment_path)) {
                return response()->json(['status' => 'error', 'message' => 'Pengajuan perizinan ini tidak memiliki file lampiran.'], 404);
            }

            $rawPath = ltrim(str_replace('/storage/', '', $leave->attachment_path), '/');
            $rawPath = ltrim(str_replace('public/', '', $rawPath), '/');

            $fullPath = null;
            if (\Illuminate\Support\Facades\Storage::disk('public')->exists($rawPath)) {
                $fullPath = \Illuminate\Support\Facades\Storage::disk('public')->path($rawPath);
            } else {
                $candidatePath = storage_path('app/public/' . $rawPath);
                if (file_exists($candidatePath)) {
                    $fullPath = $candidatePath;
                }
            }

            if (!$fullPath || !file_exists($fullPath)) {
                return response()->json(['status' => 'error', 'message' => 'Berkas fisik lampiran tidak ditemukan di server.'], 404);
            }

            $ext = pathinfo($fullPath, PATHINFO_EXTENSION) ?: 'pdf';

            // Ekstrak data untuk penamaan: {Kategori Perijinan}_{Nama Siswa}_{Tingkat}_{Nama Kelas}_{DD/MM/YYYY}
            $category = ucfirst(strtolower($leave->type ?? 'Izin'));
            $user = $leave->user;
            $studentName = $user ? ($user->full_name ?: $user->username) : 'Siswa';
            
            $grade = '';
            $className = '';
            if ($user && $user->studentClass) {
                $grade = $user->studentClass->grade_level ? "Kelas_{$user->studentClass->grade_level}" : 'Kelas';
                $className = $user->studentClass->name ?? 'Siswa';
            } else {
                $grade = 'Kelas';
                $className = 'Siswa';
            }

            $dateFormatted = Carbon::parse($leave->start_date ?? $leave->created_at ?? now())->format('d_m_Y');

            // Format bersih nama file
            $slugCategory = \Illuminate\Support\Str::slug($category, '_');
            $slugName = \Illuminate\Support\Str::slug($studentName, '_');
            $slugGrade = \Illuminate\Support\Str::slug($grade, '_');
            $slugClass = \Illuminate\Support\Str::slug($className, '_');

            $fileName = "{$slugCategory}_{$slugName}_{$slugGrade}_{$slugClass}_{$dateFormatted}.{$ext}";

            return response()->download($fullPath, $fileName, [
                'Access-Control-Expose-Headers' => 'Content-Disposition',
            ]);
        } catch (\Throwable $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal mengunduh berkas lampiran: ' . $e->getMessage()], 500);
        }
    }
}
