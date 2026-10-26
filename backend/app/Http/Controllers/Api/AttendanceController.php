<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Helpers\AppTime;
use App\Services\AttendanceService;
use App\Services\AttendanceHistoryService;
use App\Services\AttendanceExportService;
use App\Services\GeofenceService;
use App\Services\FaceAiService;

class AttendanceController extends Controller
{
    use ApiResponser;

    protected AttendanceService $attendanceService;
    protected AttendanceHistoryService $historyService;
    protected AttendanceExportService $exportService;
    protected GeofenceService $geofenceService;

    public function __construct(
        AttendanceService $attendanceService,
        AttendanceHistoryService $historyService,
        AttendanceExportService $exportService,
        GeofenceService $geofenceService
    ) {
        $this->attendanceService = $attendanceService;
        $this->historyService = $historyService;
        $this->exportService = $exportService;
        $this->geofenceService = $geofenceService;
    }

    /**
     * Prediksi Status Presensi Berikutnya
     */
    public function getNextPresensiStatus(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        $currentTime = AppTime::now();
        $today = $currentTime->format('Y-m-d');
        $timeString = $currentTime->format('H:i');

        $userRoleName = $this->resolveRoleName($user);
        $userRole = strtoupper(trim($userRoleName));

        $isTeacherOrStaff = in_array($userRole, ['GURU', 'TATA_USAHA', 'KEPALA_SEKOLAH', 'STAFF', 'SECURITY', 'CLEANING_SERVICE', 'LABORAN', 'PUSTAKAWAN']) 
            || ($userRole !== 'SISWA' && !empty($userRole));

        if (!$isTeacherOrStaff) {
            // Prediksi Siswa
            $attendance = DB::table('attendances')->where('user_id', $user->id)->where('tanggal', $today)->first();
            if (!$attendance) {
                $status = ($timeString > '07:00') ? 'TERLAMBAT' : 'MASUK';
                $desc = ($timeString > '07:00') ? 'Masuk Terlambat' : 'Masuk Sekolah';
            } elseif ($attendance->status === 'PULANG') {
                return response()->json([
                    'can_scan' => false,
                    'message' => 'Anda sudah presensi pulang hari ini.'
                ]);
            } else {
                $status = 'PULANG';
                $desc = 'Presensi Pulang Sekolah';
            }

            $primaryLocName = $this->geofenceService->getPrimaryLocationName();
            return response()->json([
                'can_scan' => true,
                'target_status' => $status,
                'target_label' => $desc,
                'current_time' => $timeString . ' WIB',
                'location_name' => $primaryLocName,
            ]);
        }

        // Prediksi Tenaga Pendidik
        $prediction = $this->attendanceService->determineNextTeacherStatus($user, $currentTime);
        $primaryLocName = $this->geofenceService->getPrimaryLocationName();

        if (!$prediction['can_scan']) {
            return response()->json([
                'can_scan' => false,
                'message' => $prediction['message'] ?? 'Presensi tidak dapat dilakukan saat ini.',
                'target_status' => $prediction['status'],
                'target_label' => $prediction['label'],
                'current_time' => $timeString . ' WIB',
                'location_name' => $primaryLocName,
            ]);
        }

        return response()->json([
            'can_scan' => true,
            'target_status' => $prediction['status'],
            'target_label' => $prediction['label'],
            'current_time' => $timeString . ' WIB',
            'location_name' => $primaryLocName,
        ]);
    }

    /**
     * Registrasi Biometrik Wajah 512-D
     */
    public function registerBiometric(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        if ($request->hasFile('face_image')) {
            $aiResult = FaceAiService::extractEmbedding($request->file('face_image'));
            if (!$aiResult['success'] || empty($aiResult['embedding'])) {
                return response()->json([
                    'message' => 'Pendaftaran biometrik ditolak: ' . $aiResult['message']
                ], 400);
            }

            $user->face_embedding = json_encode($aiResult['embedding']);
            try {
                $path = $request->file('face_image')->store('biometrics', 'public');
                if (\Illuminate\Support\Facades\Schema::hasColumn('users', 'biometric_photo_path')) {
                    $user->biometric_photo_path = $path;
                }
            } catch (\Throwable $e) {}

        } elseif ($request->filled('face_embedding')) {
            $user->face_embedding = is_array($request->face_embedding) 
                ? json_encode($request->face_embedding) 
                : $request->face_embedding;
        } else {
            return response()->json(['message' => 'Foto wajah tidak ditemukan. Harap ambil foto wajah yang jelas.'], 400);
        }

        $user->has_registered_biometric = true;
        $user->save();

        return response()->json(['message' => 'Biometrik wajah berhasil didaftarkan dan diaktivasi']);
    }

    /**
     * Submit Presensi Kamera (Geofence + Biometric AI)
     */
    public function submitPresensiCam(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);
        if (!$user->has_registered_biometric) return response()->json(['message' => 'Wajah Anda belum didaftarkan di sistem.'], 400);

        // 1. Verifikasi Biometrik Wajah
        if ($user->face_embedding) {
            if ($request->hasFile('face_image')) {
                $verifyResult = FaceAiService::verifyFace($request->file('face_image'), $user->face_embedding);
                if (!$verifyResult['success'] || !$verifyResult['verified']) {
                    $similarityPercent = round(($verifyResult['similarity'] ?? 0) * 100);
                    return response()->json([
                        'message' => 'Presensi ditolak! ' . ($verifyResult['message'] ?? 'Wajah tidak cocok dengan akun terdaftar.') . " (Kecocokan: {$similarityPercent}%)"
                    ], 400);
                }
            }
        }

        // 2. Verifikasi Geofence via GeofenceService
        $userLat = (float) $request->lat;
        $userLng = (float) $request->lng;
        if (!$userLat || !$userLng) return response()->json(['message' => 'Lokasi GPS tidak valid.'], 400);

        $geofenceResult = $this->geofenceService->verifyCoordinates($userLat, $userLng);
        if (!$geofenceResult['is_inside']) {
            return response()->json(['message' => $geofenceResult['message']], 400);
        }

        $currentTime = AppTime::now();
        $today = $currentTime->format('Y-m-d');
        $timeString = $currentTime->format('H:i');

        $userRoleName = $this->resolveRoleName($user);
        $userRole = strtoupper(trim($userRoleName));

        $isTeacherOrStaff = in_array($userRole, ['GURU', 'TATA_USAHA', 'KEPALA_SEKOLAH', 'STAFF', 'SECURITY', 'CLEANING_SERVICE', 'LABORAN', 'PUSTAKAWAN']) 
            || ($userRole !== 'SISWA' && !empty($userRole));

        // 3. CABANG TENAGA PENDIDIK
        if ($isTeacherOrStaff) {
            if ($timeString < '06:00') {
                return response()->json(['message' => 'Presensi belum dibuka. Jam masuk dimulai pukul 06.00 WIB.'], 400);
            }
            if ($timeString > '18:00') {
                return response()->json(['message' => 'Jam presensi hari ini telah berakhir (Tutup pukul 18.00 WIB).'], 400);
            }

            $prediction = $this->attendanceService->determineNextTeacherStatus($user, $currentTime);
            if (!$prediction['can_scan']) {
                return response()->json(['message' => $prediction['message'] ?? 'Presensi tidak dapat dilakukan saat ini.'], 400);
            }

            $newStatus = $prediction['status'];
            $statusDescription = $prediction['label'];
            $isFirstTap = $prediction['is_first_tap'] ?? false;

            $attendance = DB::table('attendances')->where('user_id', $user->id)->where('tanggal', $today)->first();

            if (!$attendance) {
                if ($prediction['is_tam'] ?? false) {
                    $tamScanTime = Carbon::parse($today . ' 12:01:00');
                    DB::table('attendances')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $user->id,
                        'tanggal' => $today,
                        'jam_masuk' => null,
                        'jam_pulang' => ($newStatus === 'PULANG') ? $currentTime : null,
                        'status' => 'TAM',
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);

                    DB::table('presensi_logs')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $user->id,
                        'scan_time' => $tamScanTime,
                        'status' => 'TAM',
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                } else {
                    DB::table('attendances')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $user->id,
                        'tanggal' => $today,
                        'jam_masuk' => $currentTime,
                        'status' => $newStatus,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            } else {
                $updateData = ['updated_at' => now()];
                if ($newStatus === 'PULANG') {
                    $updateData['jam_pulang'] = $currentTime;
                    $updateData['status'] = ($attendance->status === 'TAM') ? 'TAM' : 'PULANG';
                } else {
                    $updateData['status'] = ($attendance->status === 'TAM') ? 'TAM' : $newStatus;
                }
                DB::table('attendances')->where('id', $attendance->id)->update($updateData);
            }

            DB::table('presensi_logs')->insert([
                'id' => Str::uuid(),
                'user_id' => $user->id,
                'scan_time' => $currentTime,
                'status' => $newStatus,
                'latitude' => $userLat,
                'longitude' => $userLng,
                'created_at' => now(),
                'updated_at' => now()
            ]);

            return response()->json([
                'message' => 'Presensi berhasil! Status Anda: ' . $statusDescription,
                'status_code' => $newStatus,
                'status_description' => $statusDescription,
                'time' => $currentTime->format('H:i:s') . ' WIB'
            ]);
        }

        // 4. CABANG SISWA
        $attendance = DB::table('attendances')->where('user_id', $user->id)->where('tanggal', $today)->first();
        if (!$attendance) {
            $newStatus = ($timeString > '07:00') ? 'TERLAMBAT' : 'MASUK';
            DB::table('attendances')->insert([
                'id' => Str::uuid(),
                'user_id' => $user->id,
                'tanggal' => $today,
                'jam_masuk' => $currentTime,
                'status' => $newStatus,
                'created_at' => now(),
                'updated_at' => now()
            ]);
        } else {
            if ($attendance->status === 'PULANG') {
                return response()->json(['message' => 'Siswa sudah melakukan presensi pulang hari ini.'], 400);
            }
            $newStatus = 'PULANG';
            DB::table('attendances')->where('id', $attendance->id)->update([
                'status' => $newStatus,
                'jam_pulang' => $currentTime,
                'updated_at' => now()
            ]);
        }

        DB::table('presensi_logs')->insert([
            'id' => Str::uuid(),
            'user_id' => $user->id,
            'scan_time' => $currentTime,
            'status' => $newStatus,
            'latitude' => $userLat,
            'longitude' => $userLng,
            'created_at' => now(),
            'updated_at' => now()
        ]);

        return response()->json(['message' => 'Presensi berhasil! Status: ' . $newStatus]);
    }

    /**
     * Riwayat Presensi & Statistik
     */
    public function getRiwayatPresensi(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        $month = (int) $request->query('month', 0);
        $year = (int) $request->query('year', 0);

        $userRoleName = $this->resolveRoleName($user);
        $userRole = strtoupper(trim($userRoleName));

        $isTeacherOrStaff = in_array($userRole, ['GURU', 'TATA_USAHA', 'KEPALA_SEKOLAH', 'STAFF', 'SECURITY', 'CLEANING_SERVICE', 'LABORAN', 'PUSTAKAWAN']) 
            || ($userRole !== 'SISWA' && !empty($userRole));

        if ($isTeacherOrStaff) {
            return response()->json($this->historyService->getTeacherHistory($user, $month, $year));
        }

        return response()->json($this->historyService->getStudentHistory($user, $month, $year));
    }

    /**
     * Ekspor Presensi XLSX
     */
    public function exportPresensiXlsx(Request $request)
    {
        try {
            $user = null;
            if ($request->bearerToken()) {
                $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($request->bearerToken());
                if ($accessToken) $user = $accessToken->tokenable;
            }
            if (!$user && $request->filled('token')) {
                $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($request->query('token'));
                if ($accessToken) $user = $accessToken->tokenable;
            }
            if (!$user && $request->user()) {
                $user = $request->user();
            }
            if (!$user) {
                return response()->json(['message' => 'Unauthorized: Token autentikasi tidak valid atau telah berakhir.'], 401);
            }

            $month = (int) $request->query('month', 0);
            $year = (int) $request->query('year', 0);

            return $this->exportService->exportToExcel($user, $month, $year);
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memproses ekspor presensi: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Laporan Keterlambatan Siswa (Guru / Satpam)
     */
    public function submitLaporanTelat(Request $request)
    {
        $request->validate(['siswa_id' => 'required|uuid', 'alasan' => 'required|string']);
        $pelapor = $request->user();
        if ($pelapor->role === 'SISWA') return response()->json(['message' => 'Siswa tidak dapat melapor.'], 403);

        $isGuruWali = DB::table('guru_wali_students')->where('guru_id', $pelapor->id)->where('student_id', $request->siswa_id)->exists();
        $status = $isGuruWali ? 'ACC_GURU_WALI' : 'PENDING';
        $approvedBy = $isGuruWali ? $pelapor->id : null;

        DB::table('laporan_telat_siswa')->insert([
            'id' => Str::uuid(),
            'pelapor_id' => $pelapor->id,
            'siswa_id' => $request->siswa_id,
            'alasan' => $request->alasan,
            'status' => $status,
            'approved_by' => $approvedBy,
            'waktu_telat' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $msg = $isGuruWali ? 'Laporan berhasil disubmit dan otomatis di-ACC sebagai Guru Wali.' : 'Laporan berhasil dikirim, menunggu ACC Guru Wali.';
        return response()->json(['message' => $msg]);
    }

    /**
     * Helper resolusi role user
     */
    protected function resolveRoleName($user): string
    {
        if ($user->role && is_object($user->role) && isset($user->role->name)) {
            return $user->role->name;
        } elseif (!empty($user->role_type)) {
            return $user->role_type;
        } elseif (is_string($user->role)) {
            return $user->role;
        }
        return '';
    }
}
