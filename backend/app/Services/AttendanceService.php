<?php

namespace App\Services;

use App\Helpers\AppTime;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AttendanceService
{
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
            } else {
                // Lewat 12:00 dan belum ada tap -> TAM, tap pertama dihitung sebagai Pulang Awal (PA)
                return [
                    'can_scan' => true,
                    'status' => 'PA',
                    'label' => 'Pulang Awal (PA) - Catatan: Tidak Absen Masuk (TAM)',
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
     */
    public function calculateTeacherKwkAndSummary($logs, $allEvents): array
    {
        $appNow = AppTime::now();
        $todayStr = $appNow->format('Y-m-d');
        $currentTimeStr = $appNow->format('H:i');

        $tapCount = 0;
        $totalKwkMinutes = 0;

        foreach ($logs as $log) {
            $logDateStr = substr((string)$log->tanggal, 0, 10);
            $isToday = ($logDateStr === $todayStr);
            $hasReturnedHome = !empty($log->jam_pulang);

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

            // Effective Masuk (TAM penalti 12:01:00)
            if ($log->status === 'TAM' || empty($log->jam_masuk)) {
                $effectiveMasuk = Carbon::parse($logDateStr . ' 12:01:00');
            } else {
                $masukTimeOnly = Carbon::parse($log->jam_masuk)->format('H:i:s');
                $effectiveMasuk = Carbon::parse($logDateStr . ' ' . $masukTimeOnly);
            }

            // Effective Pulang (TAP penalti 15:59:00)
            if ($isTapDay || empty($log->jam_pulang)) {
                $effectivePulang = Carbon::parse($logDateStr . ' 15:59:00');
            } else {
                $pulangTimeOnly = Carbon::parse($log->jam_pulang)->format('H:i:s');
                $effectivePulang = Carbon::parse($logDateStr . ' ' . $pulangTimeOnly);
            }

            // Rentang Kotor Kehadiran (Jam Pulang - Jam Masuk)
            $grossDurationMinutes = 0;
            if ($effectivePulang->gt($effectiveMasuk)) {
                $grossDurationMinutes = $effectivePulang->diffInMinutes($effectiveMasuk);
            }

            // Izin Keluar: Pasangan Siklus (Kembali - Pulang Awal)
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
                    $tempPaTime = null;
                }
            }

            // Jika status terakhir masih PA sampai akhir hari
            if ($tempPaTime !== null && $effectivePulang->gt($tempPaTime)) {
                $totalIzinKeluarMinutes += $effectivePulang->diffInMinutes($tempPaTime);
            }

            // Durasi Bersih Kerja = Kotor - Izin Keluar
            $netWorkingMinutes = max(0, $grossDurationMinutes - $totalIzinKeluarMinutes);

            // Standar kerja 8 jam (480 menit). Defisit = KWK
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
}
