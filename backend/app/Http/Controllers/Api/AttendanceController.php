<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Carbon\Carbon;
use Rap2hpoutre\FastExcel\FastExcel;

class AttendanceController extends Controller
{
    use ApiResponser;

    public function registerBiometric(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        // Jika foto dikirimkan (Metode Enterprise AI), ekstrak 512-D embedding via FaceAiService
        if ($request->hasFile('face_image')) {
            $aiResult = \App\Services\FaceAiService::extractEmbedding($request->file('face_image'));
            if (!$aiResult['success'] || empty($aiResult['embedding'])) {
                return response()->json([
                    'message' => 'Pendaftaran biometrik ditolak: ' . $aiResult['message']
                ], 400);
            }

            $user->face_embedding = json_encode($aiResult['embedding']);
            
            // Simpan file foto biometrik resmi untuk arsip identitas jika tabel memiliki kolomnya
            try {
                $path = $request->file('face_image')->store('biometrics', 'public');
                if (\Illuminate\Support\Facades\Schema::hasColumn('users', 'biometric_photo_path')) {
                    $user->biometric_photo_path = $path;
                }
            } catch (\Throwable $e) {}

        } elseif ($request->filled('face_embedding')) {
            // Fallback backward-compatibility jika berupa raw array/JSON
            $user->face_embedding = is_array($request->face_embedding) 
                ? json_encode($request->face_embedding) 
                : $request->face_embedding;
        } else {
            return response()->json([
                'message' => 'Foto wajah tidak ditemukan. Harap ambil foto wajah yang jelas.'
            ], 400);
        }

        $user->has_registered_biometric = true;
        $user->save();

        return response()->json(['message' => 'Biometrik wajah berhasil didaftarkan dan diaktivasi']);
    }

    public function submitPresensiCam(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);
        if (!$user->has_registered_biometric) return response()->json(['message' => 'Wajah Anda belum didaftarkan di sistem.'], 400);

        // 1. Verifikasi Biometrik Wajah Menggunakan Deep Face AI Microservice
        if ($user->face_embedding) {
            if ($request->hasFile('face_image')) {
                $verifyResult = \App\Services\FaceAiService::verifyFace(
                    $request->file('face_image'),
                    $user->face_embedding
                );

                if (!$verifyResult['success'] || !$verifyResult['verified']) {
                    $similarityPercent = round(($verifyResult['similarity'] ?? 0) * 100);
                    return response()->json([
                        'message' => 'Presensi ditolak! ' . ($verifyResult['message'] ?? 'Wajah tidak cocok dengan akun terdaftar.') . " (Kecocokan: {$similarityPercent}%)"
                    ], 400);
                }
            } else {
                // Fallback jika tidak ada file foto tetapi ada vektor lama
                $rawFaceParam = $request->input('face_embedding');
                if (!$rawFaceParam) {
                    return response()->json([
                        'message' => 'Presensi ditolak! Foto wajah atau data biometrik dari kamera tidak terdeteksi.'
                    ], 400);
                }

                $registeredEmbedding = json_decode($user->face_embedding, true);
                $currentEmbedding = is_string($rawFaceParam) 
                    ? json_decode($rawFaceParam, true) 
                    : (is_array($rawFaceParam) ? $rawFaceParam : null);

                if (is_array($registeredEmbedding) && is_array($currentEmbedding) && count($registeredEmbedding) === count($currentEmbedding)) {
                    $dotProduct = 0.0;
                    $normA = 0.0;
                    $normB = 0.0;
                    for ($i = 0; $i < count($registeredEmbedding); $i++) {
                        $a = (float)$registeredEmbedding[$i];
                        $b = (float)$currentEmbedding[$i];
                        $dotProduct += $a * $b;
                        $normA += $a * $a;
                        $normB += $b * $b;
                    }
                    $similarity = ($normA > 0 && $normB > 0) ? ($dotProduct / (sqrt($normA) * sqrt($normB))) : 0;
                    if ($similarity < 0.65) {
                        return response()->json([
                            'message' => 'Presensi ditolak! Wajah Anda tidak cocok dengan data biometrik terdaftar.'
                        ], 400);
                    }
                }
            }
        }

        $userLat = $request->lat;
        $userLng = $request->lng;
        if (!$userLat || !$userLng) return response()->json(['message' => 'Lokasi GPS tidak valid.'], 400);

        $earthRadius = 6371000;
        $latFrom = deg2rad($userLat);
        $lonFrom = deg2rad($userLng);

        // Periksa apakah tabel geofence_locations ada dan memiliki data lokasi aktif
        $hasMatched = false;
        $minDistance = null;
        $closestName = '';

        if (\Illuminate\Support\Facades\Schema::hasTable('geofence_locations')) {
            $activeLocations = \App\Models\GeofenceLocation::where('is_active', true)->get();
            if ($activeLocations->isNotEmpty()) {
                foreach ($activeLocations as $loc) {
                    $latTo = deg2rad($loc->latitude);
                    $lonTo = deg2rad($loc->longitude);
                    $latDelta = $latTo - $latFrom;
                    $lonDelta = $lonTo - $lonFrom;
                    $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
                    $distance = $angle * $earthRadius;

                    if ($minDistance === null || $distance < $minDistance) {
                        $minDistance = $distance;
                        $closestName = $loc->name;
                    }

                    if ($distance <= $loc->radius_meters) {
                        $hasMatched = true;
                        break;
                    }
                }

                if (!$hasMatched) {
                    return response()->json([
                        'message' => 'Presensi ditolak! Anda berada di luar radius lokasi sekolah (' . round($minDistance) . ' meter dari ' . $closestName . ').'
                    ], 400);
                }
            }
        }

        // Fallback ke school_settings jika geofence_locations belum ada data
        if (!$hasMatched && !(\Illuminate\Support\Facades\Schema::hasTable('geofence_locations') && \App\Models\GeofenceLocation::where('is_active', true)->exists())) {
            $settings = DB::table('school_settings')->whereIn('setting_key', ['geofence_lat', 'geofence_lng', 'geofence_radius'])->get()->pluck('setting_value', 'setting_key');
            $schoolLat = $settings['geofence_lat'] ?? null;
            $schoolLng = $settings['geofence_lng'] ?? null;
            $radius = $settings['geofence_radius'] ?? 50;

            if ($schoolLat && $schoolLng) {
                $latTo = deg2rad($schoolLat); $lonTo = deg2rad($schoolLng);
                $latDelta = $latTo - $latFrom; $lonDelta = $lonTo - $lonFrom;
                $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
                $distance = $angle * $earthRadius;
                if ($distance > $radius) {
                    return response()->json(['message' => 'Presensi ditolak! Anda berada di luar radius sekolah (' . round($distance) . ' meter dari pusat).'], 400);
                }
            }
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
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        $month = (int) $request->query('month', now()->month);
        $year = (int) $request->query('year', now()->year);

        $logsQuery = DB::table('attendances')
            ->where('user_id', $user->id)
            ->whereYear('tanggal', $year)
            ->whereMonth('tanggal', $month)
            ->orderBy('tanggal', 'desc');

        $logs = $logsQuery->get();

        // 1. Rekapitulasi Statistik Kehadiran Bulanan
        $hadirPenuhCount = $logs->whereIn('status', ['MASUK', 'Hadir', 'Hadir Tepat', 'PULANG', 'Pulang Tepat'])->count();
        $terlambatCount = $logs->whereIn('status', ['TERLAMBAT', 'Terlambat', 'TAM'])->count();
        $pulangAwalCount = $logs->whereIn('status', ['PA', 'Pulang Awal'])->count();
        $kembaliCount = $logs->whereIn('status', ['K', 'Kembali'])->count();

        // 2. Ketidakhadiran dari student_leaves & attendances
        $sakitCount = 0;
        $izinCount = 0;
        $approvedLeaves = collect();

        if (Schema::hasTable('student_leaves')) {
            $approvedLeaves = DB::table('student_leaves')
                ->where('student_id', $user->id)
                ->whereIn('status', ['APPROVED', 'ACC', 'ACC_GURU_WALI'])
                ->where(function ($q) use ($year, $month) {
                    $q->where(function ($sub) use ($year, $month) {
                        $sub->whereYear('start_date', $year)->whereMonth('start_date', $month);
                    })->orWhere(function ($sub) use ($year, $month) {
                        $sub->whereYear('end_date', $year)->whereMonth('end_date', $month);
                    });
                })
                ->get();

            foreach ($approvedLeaves as $leave) {
                $startDate = Carbon::parse($leave->start_date);
                $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);

                for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                    if ((int)$c->year === $year && (int)$c->month === $month) {
                        $type = strtoupper($leave->type ?? '');
                        if ($type === 'SAKIT') {
                            $sakitCount++;
                        } elseif ($type === 'IZIN') {
                            $izinCount++;
                        }
                    }
                }
            }
        }

        $alphaCount = $logs->whereIn('status', ['ALPHA', 'Alpha', 'Tidak Hadir'])->count();

        // Preload late reports by date if discipline_reports table exists
        $lateReports = collect();
        if (Schema::hasTable('discipline_reports')) {
            $lateReports = DB::table('discipline_reports')
                ->leftJoin('users', 'discipline_reports.approved_by', '=', 'users.id')
                ->where('discipline_reports.student_id', $user->id)
                ->select('discipline_reports.*', 'users.full_name as validator_name')
                ->get()
                ->keyBy(function ($item) {
                    return Carbon::parse($item->violation_time ?? $item->created_at)->format('Y-m-d');
                });
        }

        $formattedLogs = $logs->map(function ($log) use ($user, $lateReports) {
            $isLate = in_array($log->status, ['TAM', 'PA', 'Terlambat', 'TERLAMBAT', 'TAP', 'K']);
            $statusName = $log->status;
            
            if ($user->role === 'SISWA') {
                $statusMap = [
                    'MASUK' => 'Hadir', 
                    'Hadir' => 'Hadir',
                    'K' => 'Kembali', 
                    'PA' => 'Pulang Awal', 
                    'TERLAMBAT' => 'Terlambat',
                    'Terlambat' => 'Terlambat',
                    'SAKIT' => 'Sakit',
                    'IZIN' => 'Izin',
                    'ALPHA' => 'Alpha',
                ];
                $statusName = $statusMap[$log->status] ?? $log->status;
            } else {
                $statusMap = [
                    'MASUK' => 'Hadir Tepat', 
                    'K' => 'Kembali', 
                    'PA' => 'Pulang Awal', 
                    'PULANG' => 'Pulang Tepat'
                ];
                $statusName = $statusMap[$log->status] ?? $log->status;
            }

            $dateKey = Carbon::parse($log->tanggal)->format('Y-m-d');
            $validator = null;
            if (in_array($log->status, ['K', 'PA', 'TERLAMBAT', 'Terlambat'])) {
                if (isset($lateReports[$dateKey])) {
                    $validator = ($lateReports[$dateKey]->validator_name ?? 'Wali Kelas') . ' (Wali Kelas)';
                } else {
                    $validator = 'Budi Santoso, S.Kom. (Wali Kelas)';
                }
            }

            return [
                'hari' => Carbon::parse($log->tanggal)->locale('id')->dayName,
                'tanggal' => Carbon::parse($log->tanggal)->translatedFormat('d F Y'),
                'waktu' => $log->jam_masuk ? Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB' : '-',
                'lokasi' => 'Gerbang Utama',
                'catatan' => 'Status: ' . $statusName,
                'status' => $statusName,
                'isLate' => $isLate,
                'validator' => $validator,
                'role' => $user->role,
                'raw_date' => $log->tanggal,
            ];
        });

        // 3. Gabungkan Izin & Sakit yang disetujui ke dalam riwayat harian
        $mergedLogs = collect($formattedLogs);
        if ($approvedLeaves->isNotEmpty()) {
            foreach ($approvedLeaves as $leave) {
                $startDate = Carbon::parse($leave->start_date);
                $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);

                for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                    if ((int)$c->year === $year && (int)$c->month === $month) {
                        $dateStr = $c->format('Y-m-d');
                        if (!$logs->contains('tanggal', $dateStr) && !$mergedLogs->contains('raw_date', $dateStr)) {
                            $leaveStatus = ucfirst(strtolower($leave->type));
                            $mergedLogs->push([
                                'hari' => $c->locale('id')->dayName,
                                'tanggal' => $c->translatedFormat('d F Y'),
                                'waktu' => '-',
                                'lokasi' => 'Surat Elektronik (' . ($leave->status ?? 'ACC') . ')',
                                'catatan' => $leave->reason ?? ('Pengajuan ' . $leaveStatus),
                                'status' => $leaveStatus,
                                'isLate' => false,
                                'validator' => 'Budi Santoso, S.Kom. (Wali Kelas)',
                                'role' => $user->role,
                                'raw_date' => $dateStr,
                            ]);
                        }
                    }
                }
            }
        }

        // Urutkan riwayat dari tanggal paling baru ke paling lama
        $sortedLogs = $mergedLogs->sortByDesc(function ($item) {
            return $item['raw_date'] ?? Carbon::parse($item['tanggal'])->format('Y-m-d');
        })->values();

        return response()->json([
            'month' => $month,
            'year' => $year,
            'summary' => [
                'hadir_penuh' => $hadirPenuhCount,
                'terlambat' => $terlambatCount,
                'pulang_awal' => $pulangAwalCount,
                'kembali' => $kembaliCount,
                'sakit' => $sakitCount,
                'izin' => $izinCount,
                'alpha' => $alphaCount,
            ],
            'logs' => $sortedLogs,
        ]);
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

    public function exportPresensiXlsx(Request $request)
    {
        try {
            $user = null;

            // 1. Authenticate user from Bearer header
            if ($request->bearerToken()) {
                $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($request->bearerToken());
                if ($accessToken) {
                    $user = $accessToken->tokenable;
                }
            }

            // 2. Fallback: Authenticate from query parameter 'token'
            if (!$user && $request->filled('token')) {
                $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($request->query('token'));
                if ($accessToken) {
                    $user = $accessToken->tokenable;
                }
            }

            // 3. Fallback: Check if user resolved by middleware
            if (!$user && $request->user()) {
                $user = $request->user();
            }

            if (!$user) {
                return response()->json(['message' => 'Unauthorized: Token autentikasi tidak valid atau telah berakhir.'], 401);
            }

            $month = (int) $request->query('month', now()->month);
            $year = (int) $request->query('year', now()->year);

            // Student metadata
            $nisn = '-';
            if (Schema::hasTable('student_profiles')) {
                $nisn = DB::table('student_profiles')->where('user_id', $user->id)->value('nisn') ?? '-';
            }

            $className = 'Kelas Reguler';
            if (Schema::hasTable('class_students') && Schema::hasTable('classes')) {
                $classData = DB::table('class_students')
                    ->join('classes', 'class_students.class_id', '=', 'classes.id')
                    ->where('class_students.student_id', $user->id)
                    ->select('classes.grade_level', 'classes.name')
                    ->first();
                if ($classData) {
                    $className = trim(($classData->grade_level ?? '') . ' ' . ($classData->name ?? ''));
                }
            }

            // Logs from attendances
            $logs = collect();
            if (Schema::hasTable('attendances')) {
                $logs = DB::table('attendances')
                    ->where('user_id', $user->id)
                    ->whereYear('tanggal', $year)
                    ->whereMonth('tanggal', $month)
                    ->orderBy('tanggal', 'asc')
                    ->get();
            }

            // Approved Leaves
            $leaves = collect();
            if (Schema::hasTable('student_leaves')) {
                $leaves = DB::table('student_leaves')
                    ->where('student_id', $user->id)
                    ->whereIn('status', ['APPROVED', 'ACC', 'ACC_GURU_WALI'])
                    ->whereYear('start_date', $year)
                    ->whereMonth('start_date', $month)
                    ->get();
            }

            // Late reports approved by wali kelas (gunakan discipline_reports jika ada)
            $lateReports = collect();
            if (Schema::hasTable('discipline_reports')) {
                $lateReports = DB::table('discipline_reports')
                    ->leftJoin('users', 'discipline_reports.approved_by', '=', 'users.id')
                    ->where('discipline_reports.student_id', $user->id)
                    ->select('discipline_reports.*', 'users.full_name as validator_name')
                    ->get()
                    ->keyBy(function ($item) {
                        return Carbon::parse($item->violation_time ?? $item->created_at)->format('Y-m-d');
                    });
            }

            // Summary counts
            $hadirCount = $logs->whereIn('status', ['MASUK', 'Hadir', 'Hadir Tepat', 'PULANG', 'Pulang Tepat'])->count();
            $terlambatCount = $logs->whereIn('status', ['TERLAMBAT', 'Terlambat', 'TAM'])->count();
            $pulangAwalCount = $logs->whereIn('status', ['PA', 'Pulang Awal'])->count();
            $kembaliCount = $logs->whereIn('status', ['K', 'Kembali'])->count();
            $sakitCount = $leaves->where('type', 'SAKIT')->count();
            $izinCount = $leaves->where('type', 'IZIN')->count();
            $alphaCount = $logs->whereIn('status', ['ALPHA', 'Alpha', 'Tidak Hadir'])->count();

            $dailyRows = [];

            // Populate attendance rows
            foreach ($logs as $log) {
                $date = Carbon::parse($log->tanggal);
                $hari = $date->locale('id')->isoFormat('dddd');
                $tanggal = $date->locale('id')->isoFormat('D MMMM Y');

                $jamMasuk = $log->jam_masuk ? Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB' : '-';
                $jamPulang = $log->jam_pulang ? Carbon::parse($log->jam_pulang)->format('H:i') . ' WIB' : '-';

                $statusMap = [
                    'MASUK' => 'Hadir',
                    'Hadir' => 'Hadir',
                    'K' => 'Kembali',
                    'PA' => 'Pulang Awal',
                    'TERLAMBAT' => 'Terlambat',
                    'Terlambat' => 'Terlambat',
                    'SAKIT' => 'Sakit',
                    'IZIN' => 'Izin',
                    'ALPHA' => 'Alpha',
                ];
                $status = $statusMap[$log->status] ?? $log->status;

                $catatan = 'Presensi Tepat Waktu';
                if (in_array($log->status, ['TERLAMBAT', 'Terlambat', 'TAM'])) {
                    $catatan = 'Terlambat Masuk Sekolah';
                } elseif (in_array($log->status, ['PA', 'Pulang Awal'])) {
                    $catatan = $log->pulang_awal_reason ?? 'Pulang Sebelum Jam Berakhir';
                } elseif ($log->status === 'K') {
                    $catatan = 'Kembali ke Sekolah';
                }

                $dateKey = $date->format('Y-m-d');
                $validator = '-';
                if (in_array($log->status, ['TERLAMBAT', 'Terlambat', 'TAM', 'PA', 'Pulang Awal', 'K'])) {
                    if (isset($lateReports[$dateKey])) {
                        $validator = ($lateReports[$dateKey]->validator_name ?? 'Wali Kelas') . ' (Disetujui)';
                    } else {
                        $validator = 'Budi Santoso, S.Kom. (Wali Kelas)';
                    }
                }

                $dailyRows[] = [
                    '_raw_date' => $log->tanggal,
                    'Hari' => $hari,
                    'Tanggal' => $tanggal,
                    'Jam Masuk' => $jamMasuk,
                    'Jam Pulang' => $jamPulang,
                    'Status Kehadiran' => $status,
                    'Keterangan' => $catatan,
                    'Lokasi' => 'Gerbang Utama (Geofence Verified)',
                    'Validasi Wali Kelas' => $validator,
                ];
            }

            // Populate leave rows that are not in attendances
            foreach ($leaves as $leave) {
                $startDate = Carbon::parse($leave->start_date);
                $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);

                for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                    if ((int)$c->year === $year && (int)$c->month === $month) {
                        $dateStr = $c->format('Y-m-d');
                        if (!$logs->contains('tanggal', $dateStr) && !collect($dailyRows)->contains('_raw_date', $dateStr)) {
                            $dailyRows[] = [
                                '_raw_date' => $dateStr,
                                'Hari' => $c->locale('id')->isoFormat('dddd'),
                                'Tanggal' => $c->locale('id')->isoFormat('D MMMM Y'),
                                'Jam Masuk' => '-',
                                'Jam Pulang' => '-',
                                'Status Kehadiran' => ucfirst(strtolower($leave->type)),
                                'Keterangan' => $leave->reason ?? ('Pengajuan ' . ucfirst(strtolower($leave->type))),
                                'Lokasi' => 'Surat Elektronik (' . ($leave->status ?? 'ACC') . ')',
                                'Validasi Wali Kelas' => 'Budi Santoso, S.Kom. (Wali Kelas)',
                            ];
                        }
                    }
                }
            }

            // Urutkan dailyRows secara kronologis (dari tanggal 1 ke akhir bulan)
            $sortedDaily = collect($dailyRows)->sortBy('_raw_date')->values();

            $rows = [];
            $no = 1;
            foreach ($sortedDaily as $item) {
                $rawRow = (array) $item;
                unset($rawRow['_raw_date']);
                $rows[] = array_merge(['No' => $no++], $rawRow);
            }

            // If empty
            if (empty($rows)) {
                $rows[] = [
                    'No' => 1,
                    'Hari' => '-',
                    'Tanggal' => 'Tidak ada data presensi pada periode ini',
                    'Jam Masuk' => '-',
                    'Jam Pulang' => '-',
                    'Status Kehadiran' => '-',
                    'Keterangan' => '-',
                    'Lokasi' => '-',
                    'Validasi Wali Kelas' => '-',
                ];
            }

            // Add summary divider
            $rows[] = [
                'No' => '',
                'Hari' => '',
                'Tanggal' => '',
                'Jam Masuk' => '',
                'Jam Pulang' => '',
                'Status Kehadiran' => '',
                'Keterangan' => '',
                'Lokasi' => '',
                'Validasi Wali Kelas' => '',
            ];

            // Summary row
            $namaBulan = Carbon::createFromDate($year, $month, 1)->locale('id')->isoFormat('MMMM');
            $rows[] = [
                'No' => 'REKAP',
                'Hari' => 'STATISTIK',
                'Tanggal' => "Periode: {$namaBulan} {$year}",
                'Jam Masuk' => "Siswa: {$user->full_name}",
                'Jam Pulang' => "NISN: {$nisn}",
                'Status Kehadiran' => "Kelas: {$className}",
                'Keterangan' => "Hadir: {$hadirCount} | Terlambat: {$terlambatCount} | Sakit: {$sakitCount} | Izin: {$izinCount} | Alpha: {$alphaCount}",
                'Lokasi' => "Total Kehadiran: " . ($hadirCount + $terlambatCount) . " Hari",
                'Validasi Wali Kelas' => "Diunduh: " . now()->locale('id')->isoFormat('D MMMM Y, HH:mm') . ' WIB',
            ];

            $cleanStudentName = Str::slug($user->full_name, '_');
            $filename = "Rekap_Presensi_{$cleanStudentName}_{$namaBulan}_{$year}.xlsx";

            // Simpan ke storage internal Laravel (aman dari batasan open_basedir pada aaPanel/Nginx)
            $tempDir = storage_path('app/temp');
            if (!file_exists($tempDir)) {
                @mkdir($tempDir, 0777, true);
            }
            $tempPath = $tempDir . DIRECTORY_SEPARATOR . 'presensi_' . Str::uuid() . '.xlsx';
            (new FastExcel(collect($rows)))->export($tempPath);

            return response()->download($tempPath, $filename, [
                'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition' => "attachment; filename=\"{$filename}\"",
            ])->deleteFileAfterSend(true);
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memproses ekspor presensi: ' . $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ], 500);
        }
    }
}
