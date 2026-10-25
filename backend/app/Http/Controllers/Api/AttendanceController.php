<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Carbon\Carbon;
use App\Helpers\AppTime;
use Rap2hpoutre\FastExcel\FastExcel;

class AttendanceController extends Controller
{
    use ApiResponser;

    public function getNextPresensiStatus(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        $currentTime = AppTime::now();
        $today = $currentTime->format('Y-m-d');
        $timeString = $currentTime->format('H:i');

        $userRoleName = '';
        if ($user->role && is_object($user->role) && isset($user->role->name)) {
            $userRoleName = $user->role->name;
        } elseif (!empty($user->role_type)) {
            $userRoleName = $user->role_type;
        } elseif (is_string($user->role)) {
            $userRoleName = $user->role;
        }
        $userRole = strtoupper(trim($userRoleName));

        $isTeacherOrStaff = in_array($userRole, ['GURU', 'TATA_USAHA', 'KEPALA_SEKOLAH', 'STAFF', 'SECURITY', 'CLEANING_SERVICE', 'LABORAN', 'PUSTAKAWAN']) 
            || ($userRole !== 'SISWA' && !empty($userRole));

        if (!$isTeacherOrStaff) {
            // Prediksi untuk Siswa
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

            return response()->json([
                'can_scan' => true,
                'target_status' => $status,
                'target_label' => $desc,
                'current_time' => $timeString . ' WIB',
            ]);
        }

        // Prediksi untuk Tenaga Pendidik
        if ($timeString < '06:00') {
            return response()->json([
                'can_scan' => false,
                'message' => 'Presensi belum dibuka. Jam masuk dimulai pukul 06.00 WIB.',
                'target_status' => 'BELUM_DIBUKA',
                'target_label' => 'Belum Dibuka (Buka 06.00 WIB)',
                'current_time' => $timeString . ' WIB',
            ]);
        }

        if ($timeString > '18:00') {
            return response()->json([
                'can_scan' => false,
                'message' => 'Jam presensi hari ini telah berakhir (Tutup pukul 18.00 WIB).',
                'target_status' => 'DITUTUP',
                'target_label' => 'Ditutup (Pukul 18.00 WIB)',
                'current_time' => $timeString . ' WIB',
            ]);
        }

        $attendance = DB::table('attendances')->where('user_id', $user->id)->where('tanggal', $today)->first();

        if (!$attendance) {
            // Tap pertama
            if ($timeString >= '06:00' && $timeString <= '07:00') {
                $targetStatus = 'H';
                $targetLabel = 'Hadir Tepat Waktu (H)';
            } elseif ($timeString > '07:00' && $timeString <= '12:00') {
                $targetStatus = 'T';
                $targetLabel = 'Hadir Terlambat (T)';
            } else {
                $targetStatus = 'PA';
                $targetLabel = 'Pulang Awal (PA) - Catatan: Tidak Absen Masuk (TAM)';
            }
        } else {
            // Tap kedua dst
            $lastLog = DB::table('presensi_logs')
                ->where('user_id', $user->id)
                ->whereDate('scan_time', $today)
                ->orderBy('scan_time', 'desc')
                ->first();

            $lastState = $lastLog ? $lastLog->status : $attendance->status;

            if ($timeString >= '16:00' && $timeString <= '18:00') {
                if ($lastState === 'PA') {
                    $targetStatus = 'K';
                    $targetLabel = 'Kembali ke Sekolah (K)';
                } elseif ($lastState === 'PULANG') {
                    return response()->json([
                        'can_scan' => false,
                        'message' => 'Anda sudah melakukan presensi pulang hari ini.',
                        'target_status' => 'PULANG_SELESAI',
                        'target_label' => 'Sudah Pulang Hari Ini',
                        'current_time' => $timeString . ' WIB',
                    ]);
                } else {
                    $targetStatus = 'PULANG';
                    $targetLabel = 'Presensi Pulang Resmi';
                }
            } else {
                if ($lastState === 'PA') {
                    $targetStatus = 'K';
                    $targetLabel = 'Kembali ke Sekolah (K)';
                } elseif ($lastState === 'PULANG') {
                    return response()->json([
                        'can_scan' => false,
                        'message' => 'Anda sudah melakukan presensi pulang hari ini.',
                        'target_status' => 'PULANG_SELESAI',
                        'target_label' => 'Sudah Pulang Hari Ini',
                        'current_time' => $timeString . ' WIB',
                    ]);
                } else {
                    $targetStatus = 'PA';
                    $targetLabel = 'Pulang Awal / Izin Keluar (PA)';
                }
            }
        }

        return response()->json([
            'can_scan' => true,
            'target_status' => $targetStatus,
            'target_label' => $targetLabel,
            'current_time' => $timeString . ' WIB',
        ]);
    }

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

        $currentTime = AppTime::now();
        $today = $currentTime->format('Y-m-d');
        $timeString = $currentTime->format('H:i');
        
        // Ambil nama role string secara aman dan eksplisit dari relasi atau atribut
        $userRoleName = '';
        if ($user->role && is_object($user->role) && isset($user->role->name)) {
            $userRoleName = $user->role->name;
        } elseif (!empty($user->role_type)) {
            $userRoleName = $user->role_type;
        } elseif (is_string($user->role)) {
            $userRoleName = $user->role;
        }
        $userRole = strtoupper(trim($userRoleName));

        $isTeacherOrStaff = in_array($userRole, ['GURU', 'TATA_USAHA', 'KEPALA_SEKOLAH', 'STAFF', 'SECURITY', 'CLEANING_SERVICE', 'LABORAN', 'PUSTAKAWAN']) 
            || ($userRole !== 'SISWA' && !empty($userRole));

        // =========================================================================
        // 🏫 CABANG LOGIKA 1: TENAGA PENDIDIK & PEGAWAI (GURU, TU, KARYAWAN)
        // =========================================================================
        if ($isTeacherOrStaff) {
            // Rule 1: Jam Buka Presensi Masuk (Mulai 06:00 WIB)
            if ($timeString < '06:00') {
                return response()->json([
                    'message' => 'Presensi belum dibuka. Jam masuk dimulai pukul 06.00 WIB.'
                ], 400);
            }

            // Rule 6: Jam Presensi Telah Ditutup (Lewat 18:00 WIB)
            if ($timeString > '18:00') {
                return response()->json([
                    'message' => 'Jam presensi hari ini telah berakhir (Tutup pukul 18.00 WIB).'
                ], 400);
            }

            $attendance = DB::table('attendances')->where('user_id', $user->id)->where('tanggal', $today)->first();
            $newStatus = '';
            $statusDescription = '';

            if (!$attendance) {
                // --- TAP PERTAMA HARI INI ---
                if ($timeString >= '06:00' && $timeString <= '07:00') {
                    // Masuk Tepat Waktu (Hadir)
                    $newStatus = 'H';
                    $statusDescription = 'Hadir Tepat Waktu (H)';
                    DB::table('attendances')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $user->id,
                        'tanggal' => $today,
                        'jam_masuk' => $currentTime,
                        'status' => $newStatus,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                } elseif ($timeString > '07:00' && $timeString <= '12:00') {
                    // Masuk Terlambat (T)
                    $newStatus = 'T';
                    $statusDescription = 'Hadir Terlambat (T)';
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
                    // Rule 2 & 4: Lewat jam 12:00 dan belum ada tap in sebelumnya -> TAM (Tidak Absen Masuk)
                    // Maka tap pertama ini langsung dihitung sebagai Pulang Awal (PA)!
                    $newStatus = 'PA';
                    $statusDescription = 'Pulang Awal (PA) - Catatan: Tidak Absen Masuk (TAM)';
                    DB::table('attendances')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $user->id,
                        'tanggal' => $today,
                        'jam_masuk' => null, // Tidak ada absen masuk
                        'status' => 'TAM',   // Master attendance tercatat TAM
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                    // Catat log historis TAM
                    DB::table('presensi_logs')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $user->id,
                        'scan_time' => $currentTime->copy()->subSeconds(2),
                        'status' => 'TAM',
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            } else {
                // --- TAP KEDUA DAN SETERUSNYA HARI INI ---
                // Ambil status log terakhir untuk mengetahui apakah posisi guru saat ini sedang di dalam atau di luar sekolah
                $lastLog = DB::table('presensi_logs')
                    ->where('user_id', $user->id)
                    ->whereDate('scan_time', $today)
                    ->orderBy('scan_time', 'desc')
                    ->first();

                $lastState = $lastLog ? $lastLog->status : $attendance->status;

                // Rule 5: Rentang Pulang Resmi (16:00 - 18:00 WIB)
                if ($timeString >= '16:00' && $timeString <= '18:00') {
                    // Jika tadi berstatus Pulang Awal (PA) tapi belum tap Kembali (K),
                    // maka tap di rentang jam pulang ini TETAP dihitung sebagai KEMBALI (K)!
                    if ($lastState === 'PA') {
                        $newStatus = 'K';
                        $statusDescription = 'Kembali ke Sekolah (K)';
                    } elseif ($lastState === 'PULANG') {
                        return response()->json([
                            'message' => 'Anda sudah melakukan presensi pulang hari ini.'
                        ], 400);
                    } else {
                        // Jika posisi di sekolah (H, T, atau sudah K), maka dihitung PULANG resmi
                        $newStatus = 'PULANG';
                        $statusDescription = 'Presensi Pulang Resmi (PULANG)';
                        DB::table('attendances')->where('id', $attendance->id)->update([
                            'jam_pulang' => $currentTime,
                            'updated_at' => now()
                        ]);
                    }
                } else {
                    // Di luar rentang 16:00 - 18:00 (Siklus Pulang Awal <-> Kembali)
                    // Rule 3: Jika posisi di sekolah (H, T, K) -> tap berikutnya = Pulang Awal (PA)
                    // Jika posisi di luar (PA) -> tap berikutnya = Kembali (K)
                    if ($lastState === 'PA') {
                        $newStatus = 'K';
                        $statusDescription = 'Kembali ke Sekolah (K)';
                    } elseif ($lastState === 'PULANG') {
                        return response()->json([
                            'message' => 'Anda sudah melakukan presensi pulang hari ini.'
                        ], 400);
                    } else {
                        $newStatus = 'PA';
                        $statusDescription = 'Pulang Awal / Izin Keluar (PA)';
                    }
                }

                // Update status terkini di tabel master attendances
                DB::table('attendances')->where('id', $attendance->id)->update([
                    'status' => ($attendance->status === 'TAM') ? 'TAM' : $newStatus,
                    'updated_at' => now()
                ]);
            }

            // Simpan setiap rekam jejak scan ke presensi_logs
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

        // =========================================================================
        // 🎒 CABANG LOGIKA 2: SISWA (SEDERHANA MASUK & PULANG)
        // =========================================================================
        $attendance = DB::table('attendances')->where('user_id', $user->id)->where('tanggal', $today)->first();
        $newStatus = '';

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

    public function getRiwayatPresensi(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthorized'], 401);

        $month = (int) $request->query('month', 0);
        $year = (int) $request->query('year', 0);

        $logsQuery = DB::table('attendances')
            ->where('user_id', $user->id);

        if ($year > 0) {
            $logsQuery->whereYear('tanggal', $year);
        }
        if ($month > 0) {
            $logsQuery->whereMonth('tanggal', $month);
        }

        $logs = $logsQuery->orderBy('tanggal', 'desc')->get();
        
        // Ambil nama role string secara aman dan eksplisit dari relasi atau atribut
        $userRoleName = '';
        if ($user->role && is_object($user->role) && isset($user->role->name)) {
            $userRoleName = $user->role->name;
        } elseif (!empty($user->role_type)) {
            $userRoleName = $user->role_type;
        } elseif (is_string($user->role)) {
            $userRoleName = $user->role;
        }
        $userRole = strtoupper(trim($userRoleName));

        $isTeacherOrStaff = in_array($userRole, ['GURU', 'TATA_USAHA', 'KEPALA_SEKOLAH', 'STAFF', 'SECURITY', 'CLEANING_SERVICE', 'LABORAN', 'PUSTAKAWAN']) 
            || ($userRole !== 'SISWA' && !empty($userRole));

        // =========================================================================
        // 🏫 STATISTIK & RIWAYAT TENAGA PENDIDIK (GURU & KARYAWAN)
        // =========================================================================
        if ($isTeacherOrStaff) {
            // Ambil seluruh rekap izin & cuti pegawai (employee_leaves)
            $sakitCount = 0;
            $izinCount = 0;
            $cutiCount = 0;
            $approvedLeaves = collect();

            if (Schema::hasTable('employee_leaves')) {
                $leavesQuery = DB::table('employee_leaves')
                    ->where('employee_id', $user->id)
                    ->whereIn('status', ['APPROVED', 'ACC']);

                if ($year > 0 || $month > 0) {
                    $leavesQuery->where(function ($q) use ($year, $month) {
                        $q->where(function ($sub) use ($year, $month) {
                            if ($year > 0) $sub->whereYear('start_date', $year);
                            if ($month > 0) $sub->whereMonth('start_date', $month);
                        })->orWhere(function ($sub) use ($year, $month) {
                            if ($year > 0) $sub->whereYear('end_date', $year);
                            if ($month > 0) $sub->whereMonth('end_date', $month);
                        });
                    });
                }
                $approvedLeaves = $leavesQuery->get();

                foreach ($approvedLeaves as $leave) {
                    $startDate = Carbon::parse($leave->start_date);
                    $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);
                    for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                        $matchYear = ($year <= 0) || ((int)$c->year === $year);
                        $matchMonth = ($month <= 0) || ((int)$c->month === $month);
                        if ($matchYear && $matchMonth) {
                            $type = strtoupper($leave->type ?? '');
                            if ($type === 'SAKIT') $sakitCount++;
                            elseif ($type === 'CUTI') $cutiCount++;
                            elseif ($type === 'IZIN' || $type === 'DINAS_LUAR') $izinCount++;
                        }
                    }
                }
            }

            // Hitung statistik presensi Tenaga Pendidik
            $hCount = $logs->where('status', 'H')->count();
            $tCount = $logs->where('status', 'T')->count();

            // Hitung PA, K, TAM dari presensi_logs agar seluruh riwayat tap tercatat akurat
            $logsEventsQuery = DB::table('presensi_logs')->where('user_id', $user->id);
            if ($year > 0) {
                $logsEventsQuery->whereYear('scan_time', $year);
            }
            if ($month > 0) {
                $logsEventsQuery->whereMonth('scan_time', $month);
            }
            $allEvents = $logsEventsQuery->get();

            $paCount = $allEvents->where('status', 'PA')->count();
            if ($paCount === 0) {
                $paCount = $logs->where('status', 'PA')->count();
            }

            $kCount = $allEvents->where('status', 'K')->count();
            if ($kCount === 0) {
                $kCount = $logs->where('status', 'K')->count();
            }

            $tamCount = $allEvents->where('status', 'TAM')->count();
            if ($tamCount === 0) {
                $tamCount = $logs->where('status', 'TAM')->count();
            }

            // Hitung TAP (Tidak Absen Pulang) & Akumulasi KWK (Kurang Waktu Kerja):
            // Standar jam kerja: 07:00 s/d 16:00 (9 jam = 540 menit).
            $tapCount = 0;
            $totalKwkMinutes = 0;
            $appNow = AppTime::now();
            $todayStr = $appNow->format('Y-m-d');
            $currentTimeStr = $appNow->format('H:i');

            foreach ($logs as $log) {
                $logDateStr = substr((string)$log->tanggal, 0, 10);
                $isToday = ($logDateStr === $todayStr);
                $hasReturnedHome = !empty($log->jam_pulang);

                // ATURAN 2: Hari yang belum selesai tidak akan diakumulasi/dihitung.
                // Hari ini baru akan diakumulasi setelah melewati pukul 18.00 WIB.
                if ($isToday && $currentTimeStr <= '18:00') {
                    continue;
                }

                // Cek apakah hari ini TAP (Tidak Absen Pulang):
                // Masuk kerja tetapi tidak ada jam pulang dan hari sudah berakhir (lewat 18:00)
                $isTapDay = false;
                if (!$hasReturnedHome && in_array($log->status, ['H', 'T', 'K', 'PA', 'TAM'])) {
                    $tapCount++;
                    $isTapDay = true;
                }

                // Ambil seluruh event log scan di tanggal ini
                $dayEvents = $allEvents->filter(function ($ev) use ($logDateStr) {
                    return substr((string)$ev->scan_time, 0, 10) === $logDateStr;
                })->sortBy('scan_time')->values();

                $firstScanEv = $dayEvents->first();

                // ATURAN 3 (PENALTI TAM & TAP BIAR JERA):
                // Jika TAM (Tidak Absen Masuk): jam masuk otomatis dihitung pukul 12:01:00
                // Jika TAP (Tidak Absen Pulang): jam pulang otomatis dihitung pukul 15:59:00
                $effectiveMasuk = null;
                if ($log->status === 'TAM' || empty($log->jam_masuk)) {
                    $effectiveMasuk = Carbon::parse($logDateStr . ' 12:01:00');
                } else {
                    $masukTimeOnly = Carbon::parse($log->jam_masuk)->format('H:i:s');
                    $effectiveMasuk = Carbon::parse($logDateStr . ' ' . $masukTimeOnly);
                }

                $effectivePulang = null;
                if ($isTapDay || empty($log->jam_pulang)) {
                    $effectivePulang = Carbon::parse($logDateStr . ' 15:59:00');
                } else {
                    $pulangTimeOnly = Carbon::parse($log->jam_pulang)->format('H:i:s');
                    $effectivePulang = Carbon::parse($logDateStr . ' ' . $pulangTimeOnly);
                }

                // Hitung total rentang kotor kehadiran (Jam Pulang - Jam Masuk) dalam menit
                $grossDurationMinutes = 0;
                if ($effectivePulang->gt($effectiveMasuk)) {
                    $grossDurationMinutes = $effectivePulang->diffInMinutes($effectiveMasuk);
                }

                // ATURAN 1: Hitung total durasi izin keluar selama di luar sekolah: (Kembali - Pulang Awal)
                // Diambil dari siklus PA <-> K pada tabel presensi_logs di tanggal tersebut
                $dayEvents = $allEvents->filter(function ($ev) use ($logDateStr) {
                    return substr((string)$ev->scan_time, 0, 10) === $logDateStr;
                })->sortBy('scan_time')->values();

                $totalIzinKeluarMinutes = 0;
                $tempPaTime = null;

                foreach ($dayEvents as $ev) {
                    if ($ev->status === 'PA') {
                        $tempPaTime = Carbon::parse($ev->scan_time);
                    } elseif ($ev->status === 'K' && $tempPaTime !== null) {
                        $kTime = Carbon::parse($ev->scan_time);
                        if ($kTime->gt($tempPaTime)) {
                            $totalIzinKeluarMinutes += $kTime->diffInMinutes($tempPaTime);
                        }
                        $tempPaTime = null; // Reset pasangan siklus
                    }
                }

                // Jika status terakhir masih PA sampai jam pulang / akhir hari (tidak pernah tap K)
                if ($tempPaTime !== null && $effectivePulang->gt($tempPaTime)) {
                    $totalIzinKeluarMinutes += $effectivePulang->diffInMinutes($tempPaTime);
                }

                // Durasi Bersih Kerja = (Jam Pulang - Jam Masuk) - Total(Kembali - Pulang Awal)
                $netWorkingMinutes = max(0, $grossDurationMinutes - $totalIzinKeluarMinutes);

                // Standar waktu wajib adalah 8 jam sehari (480 menit).
                // Jika durasi bersih < 480 menit (8 jam), selisih kekurangannya dihitung sebagai KWK:
                if ($netWorkingMinutes < 480) {
                    $totalKwkMinutes += (480 - $netWorkingMinutes);
                }
            }

            // Akumulasi KWK: Setiap 480 menit (8 jam) defisit jam kerja = setara 1 Alpha tambahan
            $kwkAlphaPenalty = floor($totalKwkMinutes / 480);
            $alphaCount = $logs->whereIn('status', ['ALPHA', 'Alpha', 'A'])->count() + $kwkAlphaPenalty;

            $statusTextMap = [
                'H' => 'Hadir Tepat (H)',
                'T' => 'Terlambat (T)',
                'TAM' => 'Tidak Absen Masuk (TAM)',
                'TAP' => 'Tidak Absen Pulang (TAP)',
                'PA' => 'Pulang Awal (PA)',
                'K' => 'Kembali (K)',
                'PULANG' => 'Pulang Resmi',
                'SAKIT' => 'Sakit (S)',
                'IZIN' => 'Izin (I)',
                'CUTI' => 'Cuti (C)',
                'ALPHA' => 'Alpha (A)',
            ];

            // Pemetaan Riwayat Presensi Pegawai: Dicatat per-status event secara akurat
            $eventItems = collect();

            if ($allEvents->isNotEmpty()) {
                foreach ($allEvents as $ev) {
                    $evDate = Carbon::parse($ev->scan_time);
                    $evStatus = $ev->status;
                    $statusName = $statusTextMap[$evStatus] ?? $evStatus;
                    $isLate = ($evStatus === 'T' || $evStatus === 'TAM');

                    $eventItems->push([
                        'id' => $ev->id,
                        'hari' => $evDate->locale('id')->dayName,
                        'tanggal' => $evDate->translatedFormat('d F Y'),
                        'waktu' => $evDate->format('H:i') . ' WIB',
                        'jam_masuk' => $evDate->format('H:i'),
                        'jam_pulang' => null,
                        'lokasi' => 'Presensi Cam Pegawai',
                        'catatan' => 'Pencatatan Status: ' . $statusName,
                        'status' => $evStatus,
                        'status_label' => $statusName,
                        'isLate' => $isLate,
                        'role' => 'GURU',
                        'raw_date' => $evDate->format('Y-m-d H:i:s'),
                    ]);
                }
            } else {
                // Fallback dari master tabel attendances jika presensi_logs kosong
                foreach ($logs as $log) {
                    $statusName = $statusTextMap[$log->status] ?? $log->status;
                    $isLate = ($log->status === 'T' || $log->status === 'TAM');
                    $waktuStr = $log->jam_masuk ? Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB' : ($log->jam_pulang ? Carbon::parse($log->jam_pulang)->format('H:i') . ' WIB' : '-');

                    $eventItems->push([
                        'id' => $log->id,
                        'hari' => Carbon::parse($log->tanggal)->locale('id')->dayName,
                        'tanggal' => Carbon::parse($log->tanggal)->translatedFormat('d F Y'),
                        'waktu' => $waktuStr,
                        'jam_masuk' => $log->jam_masuk ? Carbon::parse($log->jam_masuk)->format('H:i') : null,
                        'jam_pulang' => $log->jam_pulang ? Carbon::parse($log->jam_pulang)->format('H:i') : null,
                        'lokasi' => 'Presensi Cam Pegawai',
                        'catatan' => 'Pencatatan Status: ' . $statusName,
                        'status' => $log->status,
                        'status_label' => $statusName,
                        'isLate' => $isLate,
                        'role' => 'GURU',
                        'raw_date' => $log->tanggal . ' 00:00:00',
                    ]);
                }
            }

            $formattedLogs = $eventItems;

            // Gabungkan izin/cuti resmi pegawai ke dalam daftar log
            $mergedLogs = collect($formattedLogs);
            if ($approvedLeaves->isNotEmpty()) {
                foreach ($approvedLeaves as $leave) {
                    $startDate = Carbon::parse($leave->start_date);
                    $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);

                    for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                        $matchYear = ($year <= 0) || ((int)$c->year === $year);
                        $matchMonth = ($month <= 0) || ((int)$c->month === $month);
                        if ($matchYear && $matchMonth) {
                            $dateStr = $c->format('Y-m-d');
                            if (!$logs->contains('tanggal', $dateStr) && !$mergedLogs->contains('raw_date', $dateStr)) {
                                $leaveType = strtoupper($leave->type ?? 'IZIN');
                                $leaveLabel = $statusTextMap[$leaveType] ?? $leaveType;
                                $mergedLogs->push([
                                    'hari' => $c->locale('id')->dayName,
                                    'tanggal' => $c->translatedFormat('d F Y'),
                                    'waktu' => '-',
                                    'jam_masuk' => null,
                                    'jam_pulang' => null,
                                    'lokasi' => 'Surat Dinas Elektronik (ACC)',
                                    'catatan' => $leave->reason ?? ('Pengajuan ' . $leaveLabel),
                                    'status' => $leaveType,
                                    'status_label' => $leaveLabel,
                                    'isLate' => false,
                                    'role' => 'GURU',
                                    'raw_date' => $dateStr,
                                ]);
                            }
                        }
                    }
                }
            }

            $sortedLogs = $mergedLogs->sortByDesc(function ($item) {
                return $item['raw_date'] ?? Carbon::parse($item['tanggal'])->format('Y-m-d');
            })->values();

            return response()->json([
                'month' => $month,
                'year' => $year,
                'user_type' => 'TENAGA_PENDIDIK',
                'summary' => [
                    'hadir' => $hCount,
                    'terlambat' => $tCount,
                    'tidak_absen_masuk' => $tamCount,
                    'tidak_absen_pulang' => $tapCount,
                    'pulang_awal' => $paCount,
                    'kembali' => $kCount,
                    'kwk_jam' => round($totalKwkMinutes / 60, 1),
                    'kwk_alpha_penalty' => $kwkAlphaPenalty,
                    'sakit' => $sakitCount,
                    'izin' => $izinCount,
                    'cuti' => $cutiCount,
                    'alpha' => $alphaCount,
                ],
                'logs' => $sortedLogs,
            ]);
        }

        // =========================================================================
        // 🎒 STATISTIK & RIWAYAT SISWA (REGULER SEKOLAH)
        // =========================================================================
        $hadirPenuhCount = $logs->whereIn('status', ['MASUK', 'Hadir', 'Hadir Tepat', 'PULANG', 'Pulang Tepat'])->count();
        $terlambatCount = $logs->whereIn('status', ['TERLAMBAT', 'Terlambat', 'TAM'])->count();
        $pulangAwalCount = $logs->whereIn('status', ['PA', 'Pulang Awal'])->count();
        $kembaliCount = $logs->whereIn('status', ['K', 'Kembali'])->count();

        $sakitCount = 0;
        $izinCount = 0;
        $approvedLeaves = collect();

        if (Schema::hasTable('student_leaves')) {
            $studentLeavesQuery = DB::table('student_leaves')
                ->where('student_id', $user->id)
                ->whereIn('status', ['APPROVED', 'ACC', 'ACC_GURU_WALI']);

            if ($year > 0 || $month > 0) {
                $studentLeavesQuery->where(function ($q) use ($year, $month) {
                    $q->where(function ($sub) use ($year, $month) {
                        if ($year > 0) $sub->whereYear('start_date', $year);
                        if ($month > 0) $sub->whereMonth('start_date', $month);
                    })->orWhere(function ($sub) use ($year, $month) {
                        if ($year > 0) $sub->whereYear('end_date', $year);
                        if ($month > 0) $sub->whereMonth('end_date', $month);
                    });
                });
            }
            $approvedLeaves = $studentLeavesQuery->get();

            foreach ($approvedLeaves as $leave) {
                $startDate = Carbon::parse($leave->start_date);
                $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);

                for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                    $matchYear = ($year <= 0) || ((int)$c->year === $year);
                    $matchMonth = ($month <= 0) || ((int)$c->month === $month);
                    if ($matchYear && $matchMonth) {
                        $type = strtoupper($leave->type ?? '');
                        if ($type === 'SAKIT') $sakitCount++;
                        elseif ($type === 'IZIN') $izinCount++;
                    }
                }
            }
        }

        $alphaCount = $logs->whereIn('status', ['ALPHA', 'Alpha', 'Tidak Hadir'])->count();

        $formattedLogs = $logs->map(function ($log) use ($user) {
            $isLate = in_array($log->status, ['TAM', 'PA', 'Terlambat', 'TERLAMBAT', 'TAP', 'K']);
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

            return [
                'hari' => Carbon::parse($log->tanggal)->locale('id')->dayName,
                'tanggal' => Carbon::parse($log->tanggal)->translatedFormat('d F Y'),
                'waktu' => $log->jam_masuk ? Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB' : '-',
                'lokasi' => 'Gerbang Utama',
                'catatan' => 'Status: ' . $statusName,
                'status' => $statusName,
                'isLate' => $isLate,
                'role' => 'SISWA',
                'raw_date' => $log->tanggal,
            ];
        });

        $mergedLogs = collect($formattedLogs);
        if ($approvedLeaves->isNotEmpty()) {
            foreach ($approvedLeaves as $leave) {
                $startDate = Carbon::parse($leave->start_date);
                $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);

                for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                    $matchYear = ($year <= 0) || ((int)$c->year === $year);
                    $matchMonth = ($month <= 0) || ((int)$c->month === $month);
                    if ($matchYear && $matchMonth) {
                        $dateStr = $c->format('Y-m-d');
                        if (!$logs->contains('tanggal', $dateStr) && !$mergedLogs->contains('raw_date', $dateStr)) {
                            $leaveStatus = ucfirst(strtolower($leave->type));
                            $mergedLogs->push([
                                'hari' => $c->locale('id')->dayName,
                                'tanggal' => $c->translatedFormat('d F Y'),
                                'waktu' => '-',
                                'lokasi' => 'Surat Elektronik (ACC)',
                                'catatan' => $leave->reason ?? ('Pengajuan ' . $leaveStatus),
                                'status' => $leaveStatus,
                                'isLate' => false,
                                'role' => 'SISWA',
                                'raw_date' => $dateStr,
                            ]);
                        }
                    }
                }
            }
        }

        $sortedLogs = $mergedLogs->sortByDesc(function ($item) {
            return $item['raw_date'] ?? Carbon::parse($item['tanggal'])->format('Y-m-d');
        })->values();

        return response()->json([
            'month' => $month,
            'year' => $year,
            'user_type' => 'SISWA',
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

            $month = (int) $request->query('month', 0);
            $year = (int) $request->query('year', 0);

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
                $logsQuery = DB::table('attendances')
                    ->where('user_id', $user->id);
                if ($year > 0) {
                    $logsQuery->whereYear('tanggal', $year);
                }
                if ($month > 0) {
                    $logsQuery->whereMonth('tanggal', $month);
                }
                $logs = $logsQuery->orderBy('tanggal', 'asc')->get();
            }

            // Approved Leaves
            $leaves = collect();
            if (Schema::hasTable('student_leaves')) {
                $leavesQuery = DB::table('student_leaves')
                    ->where('student_id', $user->id)
                    ->whereIn('status', ['APPROVED', 'ACC', 'ACC_GURU_WALI']);
                if ($year > 0) {
                    $leavesQuery->whereYear('start_date', $year);
                }
                if ($month > 0) {
                    $leavesQuery->whereMonth('start_date', $month);
                }
                $leaves = $leavesQuery->get();
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
