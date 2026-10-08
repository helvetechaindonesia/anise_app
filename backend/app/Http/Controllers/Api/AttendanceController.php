<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    use ApiResponser;

    public function registerBiometric(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        $user->has_registered_biometric = true;
        $user->face_embedding = '["0.123", "0.456", "0.789"]';
        $user->save();

        return response()->json(['message' => 'Biometrik wajah berhasil didaftarkan']);
    }

    public function submitPresensiCam(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);
        if (!$user->has_registered_biometric) return response()->json(['message' => 'Wajah Anda belum didaftarkan di sistem.'], 400);

        $userLat = $request->lat;
        $userLng = $request->lng;
        if (!$userLat || !$userLng) return response()->json(['message' => 'Lokasi GPS tidak valid.'], 400);

        $settings = DB::table('school_settings')->whereIn('setting_key', ['geofence_lat', 'geofence_lng', 'geofence_radius'])->get()->pluck('setting_value', 'setting_key');
        $schoolLat = $settings['geofence_lat'] ?? null;
        $schoolLng = $settings['geofence_lng'] ?? null;
        $radius = $settings['geofence_radius'] ?? 50;

        if ($schoolLat && $schoolLng) {
            $earthRadius = 6371000;
            $latFrom = deg2rad($userLat); $lonFrom = deg2rad($userLng);
            $latTo = deg2rad($schoolLat); $lonTo = deg2rad($schoolLng);
            $latDelta = $latTo - $latFrom; $lonDelta = $lonTo - $lonFrom;
            $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
            $distance = $angle * $earthRadius;
            if ($distance > $radius) return response()->json(['message' => 'Presensi ditolak! Anda berada di luar radius sekolah (' . round($distance) . ' meter dari pusat).'], 400);
        }

        $today = now()->format('Y-m-d');
        $currentTime = now();
        $hour = (int)$currentTime->format('H');
        $timeString = $currentTime->format('H:i');

        $attendance = DB::table('attendances')->where('user_id', $user->id)->where('tanggal', $today)->first();
        $newStatus = '';

        if (!$attendance) {
            if ($timeString > '12:00') {
                $newStatus = 'PA';
                DB::table('presensi_logs')->insert(['id' => Str::uuid(), 'user_id' => $user->id, 'scan_time' => $currentTime->copy()->subMinutes(1), 'status' => 'TAM', 'created_at' => now(), 'updated_at' => now()]);
            } else {
                $newStatus = 'MASUK';
            }
            DB::table('attendances')->insert(['id' => Str::uuid(), 'user_id' => $user->id, 'tanggal' => $today, 'jam_masuk' => $currentTime, 'status' => $newStatus, 'created_at' => now(), 'updated_at' => now()]);
        } else {
            $lastStatus = $attendance->status;
            if ($hour >= 16 && $hour < 18) {
                $newStatus = ($lastStatus === 'PA') ? 'K' : 'PULANG';
            } else {
                if ($lastStatus === 'MASUK' || $lastStatus === 'K') $newStatus = 'PA';
                elseif ($lastStatus === 'PA') $newStatus = 'K';
                elseif ($lastStatus === 'PULANG') return response()->json(['message' => 'Anda sudah melakukan presensi pulang hari ini.'], 400);
                else $newStatus = 'PA';
            }
            DB::table('attendances')->where('id', $attendance->id)->update(['status' => $newStatus, 'updated_at' => now()]);
        }

        DB::table('presensi_logs')->insert(['id' => Str::uuid(), 'user_id' => $user->id, 'scan_time' => $currentTime, 'status' => $newStatus, 'created_at' => now(), 'updated_at' => now()]);
        return response()->json(['message' => 'Presensi berhasil! Status Anda saat ini: ' . $newStatus]);
    }

    public function getRiwayatPresensi(Request $request)
    {
        $user = $request->user();
        $logs = DB::table('attendances')->where('user_id', $user->id)->orderBy('tanggal', 'desc')->take(10)->get();
            
        $formattedLogs = $logs->map(function ($log) use ($user) {
            $isLate = in_array($log->status, ['TAM', 'PA', 'Terlambat', 'TAP', 'K']);
            $statusName = $log->status;
            
            if ($user->role === 'SISWA') {
                $statusMap = ['MASUK' => 'Hadir', 'K' => 'Kembali', 'PA' => 'Pulang Awal', 'TERLAMBAT' => 'Terlambat'];
                $statusName = $statusMap[$log->status] ?? $log->status;
            } else {
                $statusMap = ['MASUK' => 'Hadir Tepat', 'K' => 'Kembali', 'PA' => 'Pulang Awal', 'PULANG' => 'Pulang Tepat'];
                $statusName = $statusMap[$log->status] ?? $log->status;
            }

            $validator = null;
            if ($user->role === 'SISWA' && in_array($log->status, ['K', 'PA', 'TERLAMBAT'])) {
                $report = DB::table('laporan_telat_siswa')->join('users', 'laporan_telat_siswa.approved_by', '=', 'users.id')->where('siswa_id', $user->id)->select('users.full_name')->first();
                $validator = $report ? $report->full_name : 'Guru Wali (Auto)';
            }

            return [
                'hari' => Carbon::parse($log->tanggal)->locale('id')->dayName,
                'tanggal' => Carbon::parse($log->tanggal)->format('d M Y'),
                'waktu' => Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB',
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

    public function submitLaporanTelat(Request $request)
    {
        $request->validate(['siswa_id' => 'required|uuid', 'alasan' => 'required|string']);
        $pelapor = $request->user();
        if ($pelapor->role === 'SISWA') return response()->json(['message' => 'Siswa tidak dapat melapor.'], 403);

        $isGuruWali = DB::table('guru_wali_students')->where('guru_id', $pelapor->id)->where('student_id', $request->siswa_id)->exists();
        $status = $isGuruWali ? 'ACC_GURU_WALI' : 'PENDING';
        $approvedBy = $isGuruWali ? $pelapor->id : null;

        DB::table('laporan_telat_siswa')->insert([
            'id' => Str::uuid(), 'pelapor_id' => $pelapor->id, 'siswa_id' => $request->siswa_id, 'alasan' => $request->alasan, 'status' => $status, 'approved_by' => $approvedBy, 'waktu_telat' => now(), 'created_at' => now(), 'updated_at' => now(),
        ]);

        $msg = $isGuruWali ? 'Laporan berhasil disubmit dan otomatis di-ACC sebagai Guru Wali.' : 'Laporan berhasil dikirim, menunggu ACC Guru Wali.';
        return response()->json(['message' => $msg]);
    }
}
