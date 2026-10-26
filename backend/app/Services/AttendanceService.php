<?php

namespace App\Services;

use App\Helpers\AppTime;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AttendanceService
{
    protected HolidayService $holidayService;

    public function __construct(HolidayService $holidayService)
    {
        $this->holidayService = $holidayService;
    }

    /**
     * Tentukan status presensi berikutnya untuk pegawai (Guru / Karyawan).
     * Digunakan secara seragam oleh getNextPresensiStatus() dan submitPresensiCam().
     */
    public function determineNextTeacherStatus($user, Carbon $currentTime, $attendance = null, $lastLog = null): array
    {
        $today = $currentTime->format('Y-m-d');
        $timeString = $currentTime->format('H:i');

        // Batasan jam operasional
        if ($timeString < '06:00') {
            return [
                'can_scan' => false,
                'message' => 'Presensi belum dibuka. Jam masuk dimulai pukul 06.00 WIB.',
                'status' => 'BELUM_DIBUKA',
                'label' => 'Belum Dibuka (Buka 06.00 WIB)',
                'is_first_tap' => true,
            ];
        }

        if ($timeString > '18:00') {
            return [
                'can_scan' => false,
                'message' => 'Jam presensi hari ini telah berakhir (Tutup pukul 18.00 WIB).',
                'status' => 'DITUTUP',
                'label' => 'Ditutup (Pukul 18.00 WIB)',
                'is_first_tap' => false,
            ];
        }

        if (!$attendance) {
            $attendance = DB::table('attendances')
                ->where('user_id', $user->id)
                ->where('tanggal', $today)
                ->first();
        }

        // Tap pertama hari ini
        if (!$attendance) {
            if ($timeString >= '06:00' && $timeString <= '07:00') {
                return [
                    'can_scan' => true,
                    'status' => 'H',
                    'label' => 'Hadir Tepat Waktu (H)',
                    'is_first_tap' => true,
                    'is_tam' => false,
                ];
            } elseif ($timeString > '07:00' && $timeString <= '12:00') {
                return [
                    'can_scan' => true,
                    'status' => 'T',
                    'label' => 'Hadir Terlambat (T)',
                    'is_first_tap' => true,
                    'is_tam' => false,
                ];
            } elseif ($timeString > '12:00' && $timeString < '16:00') {
                // Lewat 12:00 dan belum ada tap -> TAM, tap pertama di rentang siang dihitung sebagai Pulang Awal (PA)
                return [
                    'can_scan' => true,
                    'status' => 'PA',
                    'label' => 'Pulang Awal (PA) - Catatan: Tidak Absen Masuk (TAM)',
                    'is_first_tap' => true,
                    'is_tam' => true,
                ];
            } else {
                // Rentang Jam Pulang Resmi (16:00 - 18:00 WIB) tapi belum pernah tap sama sekali dari pagi:
                // Langsung dicatat sebagai PULANG resmi dengan catatan TAM (masuk dihitung 12:01)!
                return [
                    'can_scan' => true,
                    'status' => 'PULANG',
                    'label' => 'Presensi Pulang Resmi (PULANG) - Catatan: Tidak Absen Masuk (TAM)',
                    'is_first_tap' => true,
                    'is_tam' => true,
                ];
            }
        }

        // Tap kedua dan seterusnya
        if (!$lastLog) {
            $lastLog = DB::table('presensi_logs')
                ->where('user_id', $user->id)
                ->whereDate('scan_time', $today)
                ->orderBy('scan_time', 'desc')
                ->first();
        }

        $lastState = $lastLog ? $lastLog->status : $attendance->status;

        // Rentang Jam Pulang Resmi (16:00 - 18:00 WIB)
        if ($timeString >= '16:00' && $timeString <= '18:00') {
            if ($lastState === 'PA') {
                return [
                    'can_scan' => true,
                    'status' => 'K',
                    'label' => 'Kembali ke Sekolah (K)',
                    'is_first_tap' => false,
                ];
            } elseif ($lastState === 'PULANG') {
                return [
                    'can_scan' => false,
                    'message' => 'Anda sudah melakukan presensi pulang hari ini.',
                    'status' => 'PULANG_SELESAI',
                    'label' => 'Sudah Pulang Hari Ini',
                    'is_first_tap' => false,
                ];
            } else {
                return [
                    'can_scan' => true,
                    'status' => 'PULANG',
                    'label' => 'Presensi Pulang Resmi (PULANG)',
                    'is_first_tap' => false,
                ];
            }
        }

        // Di luar rentang 16:00 - 18:00 (Siklus PA <-> K)
        if ($lastState === 'PA') {
            return [
                'can_scan' => true,
                'status' => 'K',
                'label' => 'Kembali ke Sekolah (K)',
                'is_first_tap' => false,
            ];
        } elseif ($lastState === 'PULANG') {
            return [
                'can_scan' => false,
                'message' => 'Anda sudah melakukan presensi pulang hari ini.',
                'status' => 'PULANG_SELESAI',
                'label' => 'Sudah Pulang Hari Ini',
                'is_first_tap' => false,
            ];
        } else {
            return [
                'can_scan' => true,
                'status' => 'PA',
                'label' => 'Pulang Awal / Izin Keluar (PA)',
                'is_first_tap' => false,
            ];
        }
    }

    /**
     * Mesin Kalkulasi KWK (Kurang Waktu Kerja), TAP (Tidak Absen Pulang), dan Ringkasan Statistik.
     * Standar jam kerja wajib: 8 jam (480 menit).
     * Sanksi TAM: Jam masuk otomatis dihitung 12:01.
     * Sanksi TAP: Jam pulang otomatis dicatat 15:59 (diakumulasi setelah 18:00 WIB).
     * Hari libur/non-aktif: dilewati (tidak dihitung defisit KWK).
     */
    public function calculateTeacherKwkAndSummary($logs, $allEvents): array
    {
        $appNow = AppTime::now();
        $todayStr = $appNow->format('Y-m-d');
        $currentTimeStr = $appNow->format('H:i');

        $tapCount = 0;
        $totalKwkMinutes = 0;

        foreach ($logs as $log) {
            // Normalisasi tanggal log ke timezone Asia/Jakarta untuk mencegah mismatch UTC/WIB
            $logDateStr = Carbon::parse($log->tanggal)->setTimezone('Asia/Jakarta')->format('Y-m-d');
            $isToday = ($logDateStr === $todayStr);
            $hasReturnedHome = !empty($log->jam_pulang);

            // ATURAN HARI NON-AKTIF: Cek apakah hari libur rutin (weekend) atau libur khusus sekolah
            $holidayCheck = $this->holidayService->checkDate($logDateStr);
            if (!empty($holidayCheck['is_holiday'])) {
                continue; // Hari non-aktif tidak dihitung KWK
            }

            // Hari aktif hari ini tidak diakumulasi sebelum melewati pukul 18.00 WIB
            if ($isToday && $currentTimeStr <= '18:00') {
                continue;
            }

            // TAP (Tidak Absen Pulang): Hari sudah selesai (lewat 18:00) tapi tidak ada jam pulang
            $isTapDay = false;
            if (!$hasReturnedHome && in_array($log->status, ['H', 'T', 'K', 'PA', 'TAM'])) {
                $tapCount++;
                $isTapDay = true;
            }

            // Ambil semua event scan di hari ini (normalisasi ke Asia/Jakarta)
            $dayEvents = $allEvents->filter(function ($ev) use ($logDateStr) {
                return Carbon::parse($ev->scan_time)->setTimezone('Asia/Jakarta')->format('Y-m-d') === $logDateStr;
            })->sortBy('scan_time')->values();

            // 1. Tentukan Jam Masuk Efektif
            // Jika ada event masuk resmi (H/T) gunakan jam scan masuk, jika TAM (atau tanpa jam masuk) gunakan 12:01:00
            $firstMasukEvent = $dayEvents->first(function ($ev) {
                return in_array($ev->status, ['H', 'T']);
            });

            if ($firstMasukEvent) {
                $masukTimeOnly = Carbon::parse($firstMasukEvent->scan_time)->setTimezone('Asia/Jakarta')->format('H:i:s');
                $effectiveMasuk = Carbon::parse($logDateStr . ' ' . $masukTimeOnly, 'Asia/Jakarta');
            } elseif (!empty($log->jam_masuk) && $log->status !== 'TAM') {
                $masukTimeOnly = Carbon::parse($log->jam_masuk)->setTimezone('Asia/Jakarta')->format('H:i:s');
                $effectiveMasuk = Carbon::parse($logDateStr . ' ' . $masukTimeOnly, 'Asia/Jakarta');
            } else {
                $effectiveMasuk = Carbon::parse($logDateStr . ' 12:01:00', 'Asia/Jakarta');
            }

            // 2. Tentukan Jam Pulang Efektif
            // Cari event scan PULANG di hari ini
            $pulangEvent = $dayEvents->first(function ($ev) {
                return $ev->status === 'PULANG';
            });

            if ($pulangEvent) {
                $pulangTimeOnly = Carbon::parse($pulangEvent->scan_time)->setTimezone('Asia/Jakarta')->format('H:i:s');
                $effectivePulang = Carbon::parse($logDateStr . ' ' . $pulangTimeOnly, 'Asia/Jakarta');
            } elseif (!empty($log->jam_pulang)) {
                $pulangTimeOnly = Carbon::parse($log->jam_pulang)->setTimezone('Asia/Jakarta')->format('H:i:s');
                $effectivePulang = Carbon::parse($logDateStr . ' ' . $pulangTimeOnly, 'Asia/Jakarta');
            } else {
                // Tidak ada jam pulang sampai penutupan dinas (TAP penalti 15:59:00)
                $effectivePulang = Carbon::parse($logDateStr . ' 15:59:00', 'Asia/Jakarta');
            }

            // 3. Hitung Durasi Kotor (Jam Pulang - Jam Masuk)
            $grossDurationMinutes = 0;
            if ($effectivePulang->gt($effectiveMasuk)) {
                $grossDurationMinutes = $effectivePulang->diffInMinutes($effectiveMasuk);
            }

            // 4. Hitung Izin Keluar (Kembali - Pulang Awal)
            $totalIzinKeluarMinutes = 0;
            $tempPaTime = null;

            foreach ($dayEvents as $ev) {
                if ($ev->status === 'PA') {
                    $tempPaTime = Carbon::parse($ev->scan_time);
                } elseif ($ev->status === 'K') {
                    if ($tempPaTime !== null) {
                        $kTime = Carbon::parse($ev->scan_time);
                        // Jika jam K lebih besar dari PA, tambahkan selisih menitnya. Jika sama menit (misal 12:15 ke 12:15), selisihnya 0 menit.
                        if ($kTime->gte($tempPaTime)) {
                            $totalIzinKeluarMinutes += $kTime->diffInMinutes($tempPaTime);
                        }
                    }
                    // PA resmi ditutup oleh event Kembali (K)
                    $tempPaTime = null;
                }
            }

            // Jika status terakhir masih PA tanpa pernah tap Kembali sampai jam pulang
            if ($tempPaTime !== null && $effectivePulang->gt($tempPaTime)) {
                $totalIzinKeluarMinutes += $effectivePulang->diffInMinutes($tempPaTime);
            }

            // 5. Durasi Bersih Kerja = Kotor - Izin Keluar
            $netWorkingMinutes = max(0, $grossDurationMinutes - $totalIzinKeluarMinutes);

            // Standar wajib 8 jam (480 menit). Defisit = KWK
            if ($netWorkingMinutes < 480) {
                $totalKwkMinutes += (480 - $netWorkingMinutes);
            }
        }

        // Setiap 480 menit (8 jam) defisit jam kerja = setara 1 Alpha tambahan
        $kwkAlphaPenalty = floor($totalKwkMinutes / 480);

        return [
            'tap_count' => $tapCount,
            'total_kwk_minutes' => $totalKwkMinutes,
            'kwk_jam' => round($totalKwkMinutes / 60, 1),
            'kwk_alpha_penalty' => $kwkAlphaPenalty,
        ];
    }

    /**
     * Sinkronisasi instan TAM & TAP untuk user spesifik saat memanggil API.
     * Menjamin data TAM (12:01) dan TAP (18:01) langsung tercatat di DB tanpa delay cron.
     */
    public function syncSingleUserTamTap(string $userId): void
    {
        $appNow = AppTime::now();
        $today = $appNow->format('Y-m-d');
        $currentTimeStr = $appNow->format('H:i');

        // Cek hari libur
        $holidayCheck = $this->holidayService->checkDate($today);
        if (!empty($holidayCheck['is_holiday'])) {
            return;
        }

        // Cek cuti
        $hasLeave = DB::table('employee_leaves')
            ->where('employee_id', $userId)
            ->whereIn('status', ['APPROVED', 'ACC'])
            ->where('start_date', '<=', $today)
            ->where(function ($q) use ($today) {
                $q->where('end_date', '>=', $today)->orWhereNull('end_date');
            })
            ->exists();

        if ($hasLeave) {
            return;
        }

        // 1. Auto TAM setelah 12:00 (mulai 12:01) jika belum ada presensi hari ini
        if ($currentTimeStr >= '12:01') {
            $attendance = DB::table('attendances')
                ->where('user_id', $userId)
                ->where('tanggal', $today)
                ->first();

            if (!$attendance) {
                $tamScanTime = Carbon::parse($today . ' 12:01:00');
                DB::table('attendances')->insert([
                    'id' => Str::uuid(),
                    'user_id' => $userId,
                    'tanggal' => $today,
                    'jam_masuk' => null,
                    'jam_pulang' => null,
                    'status' => 'TAM',
                    'created_at' => $tamScanTime,
                    'updated_at' => $tamScanTime,
                ]);

                DB::table('presensi_logs')->insert([
                    'id' => Str::uuid(),
                    'user_id' => $userId,
                    'scan_time' => $tamScanTime,
                    'status' => 'TAM',
                    'created_at' => $tamScanTime,
                    'updated_at' => $tamScanTime,
                ]);
            }
        }

        // 2. Auto TAP setelah 18:00 (mulai 18:01) jika belum tap pulang
        if ($currentTimeStr >= '18:01') {
            $attendance = DB::table('attendances')
                ->where('user_id', $userId)
                ->where('tanggal', $today)
                ->first();

            if ($attendance && empty($attendance->jam_pulang) && $attendance->status !== 'TAP') {
                $tapTime = Carbon::parse($today . ' 15:59:00');
                DB::table('attendances')
                    ->where('id', $attendance->id)
                    ->update([
                        'jam_pulang' => $tapTime,
                        'status' => ($attendance->status === 'TAM') ? 'TAM' : 'TAP',
                        'updated_at' => now(),
                    ]);

                $hasTapLog = DB::table('presensi_logs')
                    ->where('user_id', $userId)
                    ->whereDate('scan_time', $today)
                    ->where('status', 'TAP')
                    ->exists();

                if (!$hasTapLog) {
                    DB::table('presensi_logs')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $userId,
                        'scan_time' => $tapTime,
                        'status' => 'TAP',
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
        }
    }

    /**
     * 1. Otomatisasi Masuk Sementara Seluruh Siswa pada Pukul 07.00 WIB.
     * Membuat record attendance awal dengan status 'MASUK' (Hadir Tepat Waktu) untuk semua siswa aktif.
     */
    public function autoGenerateMorningStudentAttendance(string $targetDate = null): int
    {
        $dateStr = $targetDate ?? AppTime::now()->format('Y-m-d');
        
        // Cek apakah hari libur/non-aktif
        $holidayCheck = $this->holidayService->checkDate($dateStr);
        if (!empty($holidayCheck['is_holiday'])) {
            return 0;
        }

        // Ambil role SISWA
        $siswaRole = DB::table('roles')->where(DB::raw('UPPER(name)'), 'SISWA')->first();
        $siswaRoleId = $siswaRole ? $siswaRole->id : null;

        $students = DB::table('users')
            ->where('is_active', true)
            ->where(function ($q) use ($siswaRoleId) {
                if ($siswaRoleId) {
                    $q->where('role_id', $siswaRoleId);
                }
                $q->orWhere(DB::raw('UPPER(role_type)'), 'SISWA');
            })
            ->pluck('id');

        $createdCount = 0;
        $morningTime = Carbon::parse($dateStr . ' 07:00:00');

        foreach ($students as $studentId) {
            $exists = DB::table('attendances')
                ->where('user_id', $studentId)
                ->where('tanggal', $dateStr)
                ->exists();

            if (!$exists) {
                DB::table('attendances')->insert([
                    'id' => (string) Str::uuid(),
                    'user_id' => $studentId,
                    'tanggal' => $dateStr,
                    'jam_masuk' => $morningTime,
                    'jam_pulang' => null,
                    'status' => 'MASUK',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                $createdCount++;
            }
        }

        return $createdCount;
    }

    /**
     * 2. Finalisasi Presensi Siswa pada Pukul 18.01 WIB.
     * Mengecek apakah ada laporan keterlambatan valid (INPUT atau LAPORAN yang di-approve Guru Wali).
     * Jika ada, status presensi diupdate menjadi 'TERLAMBAT'.
     * Jika tidak ada, dipastikan statusnya tetap 'MASUK' (Hadir Tepat Waktu).
     */
    public function finalizeStudentAttendance(string $targetDate = null): array
    {
        $dateStr = $targetDate ?? AppTime::now()->format('Y-m-d');

        // Cek hari libur
        $holidayCheck = $this->holidayService->checkDate($dateStr);
        if (!empty($holidayCheck['is_holiday'])) {
            return ['terlambat' => 0, 'hadir' => 0];
        }

        $siswaRole = DB::table('roles')->where(DB::raw('UPPER(name)'), 'SISWA')->first();
        $siswaRoleId = $siswaRole ? $siswaRole->id : null;

        $students = DB::table('users')
            ->where('is_active', true)
            ->where(function ($q) use ($siswaRoleId) {
                if ($siswaRoleId) {
                    $q->where('role_id', $siswaRoleId);
                }
                $q->orWhere(DB::raw('UPPER(role_type)'), 'SISWA');
            })
            ->pluck('id');

        $terlambatCount = 0;
        $hadirCount = 0;

        foreach ($students as $studentId) {
            // Cek apakah ada record terlambat yang valid (INPUT atau LAPORAN approved)
            $isLate = DB::table('disiplin_reports')
                ->where('siswa_id', $studentId)
                ->whereDate('created_at', $dateStr)
                ->where(function ($q) {
                    $q->where(DB::raw('UPPER(category)'), 'LIKE', '%TERLAMBAT%')
                      ->orWhere(DB::raw('UPPER(category)'), 'LIKE', '%TELAT%');
                })
                ->where(function ($q) {
                    $q->where('status', 'INPUT')
                      ->orWhere('status', 'APPROVED');
                })
                ->exists();

            $attendance = DB::table('attendances')
                ->where('user_id', $studentId)
                ->where('tanggal', $dateStr)
                ->first();

            if ($attendance) {
                if ($isLate) {
                    DB::table('attendances')
                        ->where('id', $attendance->id)
                        ->update([
                            'status' => 'TERLAMBAT',
                            'updated_at' => now(),
                        ]);
                    $terlambatCount++;
                } else {
                    // Pastikan tetap MASUK / Hadir jika belum diset izin/sakit
                    if (in_array($attendance->status, ['MASUK', 'H'])) {
                        $hadirCount++;
                    }
                }
            } else {
                // Jika belum ada record attendance sama sekali, buatkan
                DB::table('attendances')->insert([
                    'id' => (string) Str::uuid(),
                    'user_id' => $studentId,
                    'tanggal' => $dateStr,
                    'jam_masuk' => Carbon::parse($dateStr . ' 07:00:00'),
                    'jam_pulang' => null,
                    'status' => $isLate ? 'TERLAMBAT' : 'MASUK',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                if ($isLate) {
                    $terlambatCount++;
                } else {
                    $hadirCount++;
                }
            }
        }

        return ['terlambat' => $terlambatCount, 'hadir' => $hadirCount];
    }
}
