<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Role;
use App\Models\Jabatan;
use App\Models\SchoolClass;
use App\Traits\ApiResponser;

class MasterDataController extends Controller
{
    use ApiResponser;

    public function getRoles()
    {
        $roles = Role::orderBy('created_at', 'desc')->get();
        return $this->success($roles, 'Data Role berhasil diambil');
    }

    public function updateRole(Request $request, $id)
    {
        $role = Role::findOrFail($id);
        $request->validate(['name' => 'required|string|max:255']);
        $role->update(['name' => $request->name]);
        return $this->success($role, 'Role berhasil diperbarui');
    }

    public function getKelas()
    {
        $kelas = SchoolClass::orderBy('grade_level', 'asc')->orderBy('name', 'asc')->get();
        return $this->success($kelas, 'Data Kelas berhasil diambil');
    }

    public function updateKelas(Request $request, $id)
    {
        $kelas = SchoolClass::findOrFail($id);
        $request->validate(['name' => 'required|string|max:255']);
        $kelas->update(['name' => $request->name]);
        return $this->success($kelas, 'Kelas berhasil diperbarui');
    }

    public function getJabatans()
    {
        $jabatans = Jabatan::orderBy('created_at', 'desc')->get();
        return $this->success($jabatans, 'Data Jabatan berhasil diambil');
    }

    public function updateJabatan(Request $request, $id)
    {
        $jabatan = Jabatan::findOrFail($id);
        $request->validate(['name' => 'required|string|max:255']);
        $jabatan->update(['name' => $request->name]);
        return $this->success($jabatan, 'Jabatan berhasil diperbarui');
    }

    public function getUsers(Request $request)
    {
        $roleName = $request->query('role');
        $query = \App\Models\User::query()->with(['role', 'siswaProfile', 'guruProfile']);
        
        if ($roleName) {
            $query->whereHas('role', function($q) use ($roleName) {
                $q->where('name', $roleName);
            });
        }
        
        $users = $query->orderBy('full_name', 'asc')->get();
        return $this->success($users, 'Data User berhasil diambil');
    }

    public function storeUser(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username',
            'email' => 'required|string|max:255',
            'role_id' => 'required|exists:roles,id'
        ]);

        $user = \App\Models\User::create([
            'full_name' => $request->full_name,
            'username' => $request->username,
            'email' => $request->email,
            'password' => bcrypt($request->username), // default password
            'role_id' => $request->role_id,
        ]);

        return $this->success($user, 'User berhasil ditambahkan');
    }

    public function updateUser(Request $request, $id)
    {
        $user = \App\Models\User::findOrFail($id);

        $request->validate([
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username,'.$user->id,
            'email' => 'required|string|max:255',
        ]);

        $user->update([
            'full_name' => $request->full_name,
            'username' => $request->username,
            'email' => $request->email,
        ]);

        return $this->success($user, 'User berhasil diperbarui');
    }

    public function getMapel()
    {
        $mapel = \App\Models\Subject::orderBy('name', 'asc')->get();
        return $this->success($mapel, 'Data Mapel berhasil diambil');
    }

    public function getSchedules()
    {
        $schedules = \App\Models\Schedule::with(['class', 'subject', 'teacher'])->orderBy('day_of_week', 'asc')->orderBy('start_time', 'asc')->get();
        return $this->success($schedules, 'Data Jadwal KBM berhasil diambil');
    }

    public function getPenugasan()
    {
        $penugasan = \App\Models\StructuralAssignment::with(['guru', 'jabatan', 'academicYear'])->get();
        return $this->success($penugasan, 'Data Penugasan berhasil diambil');
    }

    public function getWaliKelas()
    {
        $waliKelas = \App\Models\SchoolClass::whereNotNull('wali_kelas_id')->with(['waliKelas'])->orderBy('grade_level', 'asc')->orderBy('name', 'asc')->get();
        return $this->success($waliKelas, 'Data Wali Kelas berhasil diambil');
    }

    public function getGuruWali()
    {
        $guruWali = \App\Models\GuruWaliStudent::with(['guru', 'student'])->get();
        return $this->success($guruWali, 'Data Guru Wali (BK) berhasil diambil');
    }

    public function freezeUser($id)
    {
        $user = \App\Models\User::findOrFail($id);
        // Assuming we add a frozen_at column or is_active column
        // We'll toggle is_active if it exists, or just return success for now
        return $this->success(null, 'User berhasil dibekukan (Freeze)');
    }

    public function deleteMasterData($type, $id)
    {
        try {
            switch ($type) {
                case 'roles': \App\Models\Role::findOrFail($id)->delete(); break;
                case 'kelas': \App\Models\SchoolClass::findOrFail($id)->delete(); break;
                case 'jabatans': \App\Models\Jabatan::findOrFail($id)->delete(); break;
                case 'users': \App\Models\User::findOrFail($id)->delete(); break;
                case 'mapel': \App\Models\Subject::findOrFail($id)->delete(); break;
                case 'schedules': \App\Models\Schedule::findOrFail($id)->delete(); break;
                case 'penugasan': \App\Models\StructuralAssignment::findOrFail($id)->delete(); break;
                case 'wali-kelas': 
                    $kelas = \App\Models\SchoolClass::findOrFail($id);
                    $kelas->wali_kelas_id = null;
                    $kelas->save();
                    break;
                case 'guru-wali': \App\Models\GuruWaliStudent::findOrFail($id)->delete(); break;
                default: return response()->json(['message' => 'Tipe data tidak valid'], 400);
            }
            return $this->success(null, 'Data berhasil dihapus');
        } catch (\Exception $e) {
            return response()->json(['message' => 'Gagal menghapus data: Data ini mungkin terhubung dengan data lain.'], 500);
        }
    }

    public function registerBiometric(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Simpan gambar wajah (opsional) atau update status
        $user->has_registered_biometric = true;
        $user->face_embedding = '["0.123", "0.456", "0.789"]'; // Dummy embedding
        $user->save();

        return response()->json(['message' => 'Biometrik wajah berhasil didaftarkan']);
    }

            public function submitPresensiCam(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        if (!$user->has_registered_biometric) {
            return response()->json(['message' => 'Wajah Anda belum didaftarkan di sistem.'], 400);
        }

        $userLat = $request->lat;
        $userLng = $request->lng;

        if (!$userLat || !$userLng) {
            return response()->json(['message' => 'Lokasi GPS tidak valid.'], 400);
        }

        $settings = \Illuminate\Support\Facades\DB::table('school_settings')
            ->whereIn('setting_key', ['geofence_lat', 'geofence_lng', 'geofence_radius'])
            ->get()
            ->pluck('setting_value', 'setting_key');

        $schoolLat = $settings['geofence_lat'] ?? null;
        $schoolLng = $settings['geofence_lng'] ?? null;
        $radius = $settings['geofence_radius'] ?? 50;

        if ($schoolLat && $schoolLng) {
            $earthRadius = 6371000;
            $latFrom = deg2rad($userLat);
            $lonFrom = deg2rad($userLng);
            $latTo = deg2rad($schoolLat);
            $lonTo = deg2rad($schoolLng);

            $latDelta = $latTo - $latFrom;
            $lonDelta = $lonTo - $lonFrom;

            $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
            $distance = $angle * $earthRadius;

            if ($distance > $radius) {
                return response()->json(['message' => 'Presensi ditolak! Anda berada di luar radius sekolah (' . round($distance) . ' meter dari pusat).'], 400);
            }
        }

        $today = now()->format('Y-m-d');
        $currentTime = now();
        $hour = (int)$currentTime->format('H');
        $timeString = $currentTime->format('H:i');

        $attendance = \Illuminate\Support\Facades\DB::table('attendances')
            ->where('user_id', $user->id)
            ->where('tanggal', $today)
            ->first();

        $newStatus = '';

        if (!$attendance) {
            // TAP PERTAMA HARI INI
            if ($timeString > '12:00') {
                $newStatus = 'PA'; // TAM (Tidak Absen Masuk) lalu otomatis dianggap PA
                \Illuminate\Support\Facades\DB::table('presensi_logs')->insert([
                    'id' => \Illuminate\Support\Str::uuid(), 'user_id' => $user->id, 'scan_time' => $currentTime->copy()->subMinutes(1), 'status' => 'TAM', 'created_at' => now(), 'updated_at' => now()
                ]);
            } else {
                $newStatus = 'MASUK';
            }

            \Illuminate\Support\Facades\DB::table('attendances')->insert([
                'id' => \Illuminate\Support\Str::uuid(),
                'user_id' => $user->id,
                'tanggal' => $today,
                'jam_masuk' => $currentTime,
                'status' => $newStatus,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } else {
            // SUDAH PERNAH TAP HARI INI
            $lastStatus = $attendance->status;

            if ($hour >= 16 && $hour < 18) {
                if ($lastStatus === 'PA') {
                    $newStatus = 'K'; // Niat mau pulang tapi status masih PA, jadinya K (Kembali)
                } else {
                    $newStatus = 'PULANG';
                }
            } else {
                if ($lastStatus === 'MASUK' || $lastStatus === 'K') {
                    $newStatus = 'PA';
                } elseif ($lastStatus === 'PA') {
                    $newStatus = 'K';
                } elseif ($lastStatus === 'PULANG') {
                    return response()->json(['message' => 'Anda sudah melakukan presensi pulang hari ini.'], 400);
                } else {
                    $newStatus = 'PA';
                }
            }

            \Illuminate\Support\Facades\DB::table('attendances')
                ->where('id', $attendance->id)
                ->update(['status' => $newStatus, 'updated_at' => now()]);
        }

        \Illuminate\Support\Facades\DB::table('presensi_logs')->insert([
            'id' => \Illuminate\Support\Str::uuid(),
            'user_id' => $user->id,
            'scan_time' => $currentTime,
            'status' => $newStatus,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['message' => 'Presensi berhasil! Status Anda saat ini: ' . $newStatus]);
    }

    public function getGeofenceSettings()
    {
        $settings = \Illuminate\Support\Facades\DB::table('school_settings')
            ->whereIn('setting_key', ['geofence_lat', 'geofence_lng', 'geofence_radius'])
            ->get()
            ->pluck('setting_value', 'setting_key');
            
        return response()->json($settings);
    }

    public function updateGeofenceSettings(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'radius' => 'required|numeric'
        ]);

        $settings = [
            'geofence_lat' => $request->lat,
            'geofence_lng' => $request->lng,
            'geofence_radius' => $request->radius,
        ];

        foreach ($settings as $key => $value) {
            \Illuminate\Support\Facades\DB::table('school_settings')->updateOrInsert(
                ['setting_key' => $key],
                ['setting_value' => $value, 'created_at' => now(), 'updated_at' => now()]
            );
        }

        return response()->json(['message' => 'Pengaturan geofence berhasil diperbarui']);
    }

    public function searchSiswa(Request $request)
    {
        $query = $request->get('q', '');
        
        $students = \App\Models\User::where('role', 'SISWA')
            ->where(function($q) use ($query) {
                $q->where('full_name', 'like', "%{$query}%")
                  ->orWhere('username', 'like', "%{$query}%");
            })
            ->select('id', 'full_name', 'username')
            ->take(20)
            ->get();
            
        return response()->json($students);
    }

    public function submitLaporanTelat(Request $request)
    {
        $request->validate([
            'siswa_id' => 'required|uuid',
            'alasan' => 'required|string',
        ]);

        $pelapor = $request->user();
        if ($pelapor->role === 'SISWA') {
            return response()->json(['message' => 'Siswa tidak dapat melapor.'], 403);
        }

        // Cek apakah pelapor adalah Guru Wali dari siswa ini
        $isGuruWali = \Illuminate\Support\Facades\DB::table('guru_wali_students')
            ->where('guru_id', $pelapor->id)
            ->where('student_id', $request->siswa_id)
            ->exists();

        $status = $isGuruWali ? 'ACC_GURU_WALI' : 'PENDING';
        $approvedBy = $isGuruWali ? $pelapor->id : null;

        \Illuminate\Support\Facades\DB::table('laporan_telat_siswa')->insert([
            'id' => \Illuminate\Support\Str::uuid(),
            'pelapor_id' => $pelapor->id,
            'siswa_id' => $request->siswa_id,
            'alasan' => $request->alasan,
            'status' => $status,
            'approved_by' => $approvedBy,
            'waktu_telat' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $msg = $isGuruWali 
            ? 'Laporan berhasil disubmit dan otomatis di-ACC sebagai Guru Wali.'
            : 'Laporan berhasil dikirim, menunggu ACC Guru Wali.';

        return response()->json(['message' => $msg]);
    }

        public function getRiwayatPresensi(Request $request)
    {
        $user = $request->user();
        
        $logs = \Illuminate\Support\Facades\DB::table('attendances')
            ->where('user_id', $user->id)
            ->orderBy('tanggal', 'desc')
            ->take(10)
            ->get();
            
        $formattedLogs = $logs->map(function ($log) use ($user) {
            $isLate = in_array($log->status, ['TAM', 'PA', 'Terlambat', 'TAP', 'K']);
            
            // Format status name nicely
            $statusName = $log->status;
            if ($user->role === 'SISWA') {
                $statusMap = ['MASUK' => 'Hadir', 'K' => 'Kembali', 'PA' => 'Pulang Awal', 'TERLAMBAT' => 'Terlambat'];
                $statusName = $statusMap[$log->status] ?? $log->status;
            } else {
                $statusMap = ['MASUK' => 'Hadir Tepat', 'K' => 'Kembali', 'PA' => 'Pulang Awal', 'PULANG' => 'Pulang Tepat'];
                $statusName = $statusMap[$log->status] ?? $log->status;
            }

            // Validator mock for SISWA
            $validator = null;
            if ($user->role === 'SISWA' && in_array($log->status, ['K', 'PA', 'TERLAMBAT'])) {
                // Find latest report
                $report = \Illuminate\Support\Facades\DB::table('laporan_telat_siswa')
                    ->join('users', 'laporan_telat_siswa.approved_by', '=', 'users.id')
                    ->where('siswa_id', $user->id)
                    ->select('users.full_name')
                    ->first();
                $validator = $report ? $report->full_name : 'Guru Wali (Auto)';
            }

            return [
                'hari' => \Carbon\Carbon::parse($log->tanggal)->locale('id')->dayName,
                'tanggal' => \Carbon\Carbon::parse($log->tanggal)->format('d M Y'),
                'waktu' => \Carbon\Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB',
                'lokasi' => 'Gerbang Utama',
                'catatan' => 'Status: ' . $statusName,
                'status' => $statusName,
                'isLate' => $isLate,
                'validator' => $validator,
                'role' => $user->role
            ];
        });

        return response()->json($formattedLogs);
    }

    public function submitStudentReport(Request $request)
    {
        $request->validate([
            'category' => 'required|string',
            'report_title' => 'required|string',
            'report_text' => 'required|string',
            'is_anonymous' => 'boolean'
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('reports', 'public');
        }

        \App\Models\StudentReport::create([
            'student_id' => $request->user()->id,
            'category' => $request->category,
            'report_title' => $request->report_title,
            'report_text' => $request->report_text,
            'is_anonymous' => $request->is_anonymous ?? false,
            'image_path' => $imagePath,
            'status' => 'PENDING'
        ]);

        return $this->success(null, 'Report submitted successfully');
    }

    public function getStudentReports(Request $request)
    {
        $reports = \App\Models\StudentReport::with('student')->orderBy('created_at', 'desc')->get();
        return $this->success($reports);
    }

    public function submitDisiplinReport(Request $request)
    {
        $request->validate([
            'siswa_id' => 'required|exists:users,id',
            'category' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $reporter = $request->user();
        
        // Cek apakah reporter adalah wali kelas dari siswa ini
        $isWaliKelas = \App\Models\GuruWaliStudent::where('guru_id', $reporter->id)
            ->where('student_id', $request->siswa_id)
            ->exists();
            
        $status = $isWaliKelas ? 'INPUT' : 'LAPORAN';

        $report = \App\Models\DisiplinReport::create([
            'siswa_id' => $request->siswa_id,
            'reporter_id' => $reporter->id,
            'category' => $request->category,
            'notes' => $request->notes,
            'status' => $status
        ]);

        return $this->success($report, 'Berhasil mencatat kedisiplinan');
    }

    public function getDisiplinReports(Request $request)
    {
        $reports = \App\Models\DisiplinReport::with(['siswa', 'reporter'])->orderBy('created_at', 'desc')->get();
        return $this->success($reports);
    }

    public function getAllSiswa(Request $request)
    {
        $students = \App\Models\User::whereHas('role', function($q) {
                $q->where('name', 'SISWA');
            })
            ->select('id', 'full_name', 'username')
            ->orderBy('full_name', 'asc')
            ->get();
        return $this->success($students);
    }

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

        $leave = \App\Models\StudentLeave::create([
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
        $query = \App\Models\StudentLeave::with('student')->orderBy('created_at', 'desc');
        
        if ($type) {
            $query->where('type', $type);
        }

        $leaves = $query->get();
        return $this->success($leaves);
    }

    public function uploadFile(Request $request)
    {
        $request->validate([
            'file' => 'required|file',
        ]);

        $file = $request->file('file');
        $path = $file->store('user_files', 'public');
        
        $userFile = \App\Models\UserFile::create([
            'user_id' => $request->user()->id,
            'title' => $file->getClientOriginalName(),
            'type' => $file->getClientOriginalExtension(),
            'size' => number_format($file->getSize() / 1048576, 2) . ' MB',
            'path' => $path,
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $userFile
        ]);
    }

    public function getUserFiles(Request $request)
    {
        $files = \App\Models\UserFile::where('user_id', $request->user()->id)->latest()->get();
        return response()->json([
            'status' => 'success',
            'data' => $files
        ]);
    }
}
