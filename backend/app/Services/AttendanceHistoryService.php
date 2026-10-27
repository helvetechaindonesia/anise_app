<?php

namespace App\Services;

use App\Models\AcademicYear;
use App\Helpers\AppTime;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AttendanceHistoryService
{
    protected AttendanceService $attendanceService;
    protected GeofenceService $geofenceService;

    public function __construct(
        AttendanceService $attendanceService,
        GeofenceService $geofenceService
    ) {
        $this->attendanceService = $attendanceService;
        $this->geofenceService = $geofenceService;
    }

    /**
     * Memproses riwayat dan ringkasan statistik untuk Tenaga Pendidik / Pegawai
     */
    public function getTeacherHistory($user, int $month, int $year): array
    {
        // 1. Sinkronisasi instan TAM & TAP
        $this->attendanceService->syncSingleUserTamTap($user->id);

        // 2. Query data attendances master
        $logsQuery = DB::table('attendances')->where('user_id', $user->id);
        if ($year > 0) $logsQuery->whereYear('tanggal', $year);
        if ($month > 0) $logsQuery->whereMonth('tanggal', $month);
        $logs = $logsQuery->orderBy('tanggal', 'desc')->get();

        // 3. Query cuti & izin pegawai (tabel leaves & employee_leaves)
        $sakitCount = 0;
        $izinCount = 0;
        $cutiCount = 0;
        $approvedLeaves = collect();

        // Ambil dari tabel universal leaves
        if (Schema::hasTable('leaves')) {
            $leavesQuery = DB::table('leaves')
                ->where('user_id', $user->id)
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
            $approvedLeaves = $approvedLeaves->concat($leavesQuery->get());
        }

        // Ambil juga dari employee_leaves jika ada
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
            $approvedLeaves = $approvedLeaves->concat($leavesQuery->get());
        }

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

        // 4. Hitung presensi_logs
        $logsEventsQuery = DB::table('presensi_logs')->where('user_id', $user->id);
        if ($year > 0) $logsEventsQuery->whereYear('scan_time', $year);
        if ($month > 0) $logsEventsQuery->whereMonth('scan_time', $month);
        $allEvents = $logsEventsQuery->get();

        $hCount = $logs->where('status', 'H')->count();
        $tCount = $logs->where('status', 'T')->count();
        $paCount = $allEvents->where('status', 'PA')->count() ?: $logs->where('status', 'PA')->count();
        $kCount = $allEvents->where('status', 'K')->count() ?: $logs->where('status', 'K')->count();
        $tamCount = $allEvents->where('status', 'TAM')->count() ?: $logs->where('status', 'TAM')->count();

        // 5. Hitung KWK & TAP lewat kalkulator AttendanceService
        $kwkSummary = $this->attendanceService->calculateTeacherKwkAndSummary($logs, $allEvents);
        $tapCount = $kwkSummary['tap_count'];
        $totalKwkMinutes = $kwkSummary['total_kwk_minutes'];
        $kwkAlphaPenalty = $kwkSummary['kwk_alpha_penalty'];
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

        // 6. Buat Event Items
        $primaryLocation = $this->geofenceService->getPrimaryLocationName();
        $eventItems = collect();
        if ($allEvents->isNotEmpty()) {
            foreach ($allEvents as $ev) {
                $evDate = Carbon::parse($ev->scan_time);
                $evStatus = $ev->status;
                $statusName = $statusTextMap[$evStatus] ?? $evStatus;
                $isLate = ($evStatus === 'T' || $evStatus === 'TAM');
                
                $lat = isset($ev->latitude) && $ev->latitude !== null ? (float) $ev->latitude : null;
                $lng = isset($ev->longitude) && $ev->longitude !== null ? (float) $ev->longitude : null;
                $lokasiName = $this->geofenceService->findClosestLocationName($lat, $lng);

                $eventItems->push([
                    'id' => $ev->id,
                    'hari' => $evDate->locale('id')->dayName,
                    'tanggal' => $evDate->translatedFormat('d F Y'),
                    'waktu' => $evDate->format('H:i') . ' WIB',
                    'jam_masuk' => $evDate->format('H:i'),
                    'jam_pulang' => null,
                    'lokasi' => $lokasiName,
                    'catatan' => 'Pencatatan Status: ' . $statusName,
                    'status' => $evStatus,
                    'status_label' => $statusName,
                    'isLate' => $isLate,
                    'role' => 'GURU',
                    'raw_date' => $evDate->format('Y-m-d H:i:s'),
                ]);
            }
        } else {
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
                    'lokasi' => $primaryLocation,
                    'catatan' => 'Pencatatan Status: ' . $statusName,
                    'status' => $log->status,
                    'status_label' => $statusName,
                    'isLate' => $isLate,
                    'role' => 'GURU',
                    'raw_date' => $log->tanggal . ' 00:00:00',
                ]);
            }
        }

        // 7. Gabungkan izin resmi (hanya sampai hari berjalan / AppTime::now(), hari esok menunggu cron harian)
        $mergedLogs = collect($eventItems);
        $todayStr = AppTime::now()->format('Y-m-d');

        // Pastikan record log yang sudah ada untuk hari ini adaptif jika memiliki approved leave
        if ($approvedLeaves->isNotEmpty()) {
            $mergedLogs = $mergedLogs->map(function ($item) use ($approvedLeaves, $statusTextMap) {
                $rawDate = isset($item['raw_date']) ? substr($item['raw_date'], 0, 10) : null;
                if ($rawDate) {
                    $matchedLeave = $approvedLeaves->first(function ($leave) use ($rawDate) {
                        $s = Carbon::parse($leave->start_date)->format('Y-m-d');
                        $e = Carbon::parse($leave->end_date ?? $leave->start_date)->format('Y-m-d');
                        return $rawDate >= $s && $rawDate <= $e;
                    });
                    if ($matchedLeave) {
                        $typeUpper = strtoupper($matchedLeave->type ?? 'IZIN');
                        $leaveLabel = $statusTextMap[$typeUpper] ?? $typeUpper;
                        $item['status'] = $typeUpper;
                        $item['status_label'] = $leaveLabel;
                        $item['catatan'] = $matchedLeave->reason ?? ('Pengajuan ' . $leaveLabel);
                        $item['lokasi'] = 'Surat Dinas Elektronik (ACC)';
                    }
                }
                return $item;
            });

            foreach ($approvedLeaves as $leave) {
                $startDate = Carbon::parse($leave->start_date);
                $endDate = Carbon::parse($leave->end_date ?? $leave->start_date);

                for ($c = $startDate->copy(); $c->lte($endDate); $c->addDay()) {
                    $dateStr = $c->format('Y-m-d');
                    // Riwayat presensi untuk hari esok belum waktunya muncul (hanya sampai hari berjalan <= today)
                    if ($dateStr > $todayStr) {
                        continue;
                    }

                    $matchYear = ($year <= 0) || ((int)$c->year === $year);
                    $matchMonth = ($month <= 0) || ((int)$c->month === $month);
                    if ($matchYear && $matchMonth) {
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

        return [
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
        ];
    }

    /**
     * Memproses riwayat dan ringkasan statistik untuk Siswa
     */
    public function getStudentHistory($user, int $month, int $year): array
    {
        $logsQuery = DB::table('attendances')->where('user_id', $user->id);
        if ($year > 0) $logsQuery->whereYear('tanggal', $year);
        if ($month > 0) $logsQuery->whereMonth('tanggal', $month);
        $logs = $logsQuery->orderBy('tanggal', 'desc')->get();

        $hadirPenuhCount = $logs->whereIn('status', ['MASUK', 'Hadir', 'Hadir Tepat', 'PULANG', 'Pulang Tepat'])->count();
        $terlambatCount = $logs->whereIn('status', ['TERLAMBAT', 'Terlambat', 'TAM'])->count();
        $pulangAwalCount = $logs->whereIn('status', ['PA', 'Pulang Awal'])->count();
        $kembaliCount = $logs->whereIn('status', ['K', 'Kembali'])->count();

        $sakitCount = 0;
        $izinCount = 0;
        $approvedLeaves = collect();

        // 1. Ambil dari tabel universal leaves
        if (Schema::hasTable('leaves')) {
            $leavesQuery = DB::table('leaves')
                ->where('user_id', $user->id)
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
            $approvedLeaves = $approvedLeaves->concat($leavesQuery->get());
        }

        // 2. Ambil dari tabel student_leaves jika ada
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
            $approvedLeaves = $approvedLeaves->concat($studentLeavesQuery->get());
        }

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

        $alphaCount = $logs->whereIn('status', ['ALPHA', 'Alpha', 'Tidak Hadir'])->count();

        $todayStr = AppTime::now()->format('Y-m-d');
        $primaryLocation = $this->geofenceService->getPrimaryLocationName();

        $formattedLogs = $logs->map(function ($log) use ($user, $approvedLeaves, $primaryLocation) {
            $isLate = in_array($log->status, ['TAM', 'PA', 'Terlambat', 'TERLAMBAT', 'TAP', 'K', 'T']);
            $statusMap = [
                'MASUK' => 'Hadir Tepat (H)', 
                'Hadir' => 'Hadir Tepat (H)',
                'H' => 'Hadir Tepat (H)',
                'K' => 'Kembali (K)', 
                'PA' => 'Pulang Awal (PA)', 
                'TERLAMBAT' => 'Terlambat (T)',
                'Terlambat' => 'Terlambat (T)',
                'T' => 'Terlambat (T)',
                'TAM' => 'Tidak Absen Masuk (TAM)',
                'TAP' => 'Tidak Absen Pulang (TAP)',
                'S' => 'Sakit (S)',
                'SAKIT' => 'Sakit (S)',
                'Sakit' => 'Sakit (S)',
                'I' => 'Izin (I)',
                'IZIN' => 'Izin (I)',
                'Izin' => 'Izin (I)',
                'A' => 'Alpha (A)',
                'ALPHA' => 'Alpha (A)',
                'Alpha' => 'Alpha (A)',
            ];
            
            $status = $log->status;
            $statusName = $statusMap[$status] ?? $status;
            $locationName = $primaryLocation;
            $catatanStr = 'Status: ' . $statusName;

            // Cek apakah tanggal log ini bertepatan dengan izin yang di-ACC
            $logDate = Carbon::parse($log->tanggal)->format('Y-m-d');
            if ($approvedLeaves->isNotEmpty()) {
                $matchedLeave = $approvedLeaves->first(function ($leave) use ($logDate) {
                    $s = Carbon::parse($leave->start_date)->format('Y-m-d');
                    $e = Carbon::parse($leave->end_date ?? $leave->start_date)->format('Y-m-d');
                    return $logDate >= $s && $logDate <= $e;
                });
                if ($matchedLeave) {
                    $typeUpper = strtoupper($matchedLeave->type ?? 'IZIN');
                    $status = ($typeUpper === 'SAKIT') ? 'S' : (($typeUpper === 'DISPENSASI') ? 'PA' : 'I');
                    $statusName = ($typeUpper === 'SAKIT') ? 'Sakit (S)' : (($typeUpper === 'DISPENSASI') ? 'Dispensasi (DIS)' : 'Izin (I)');
                    $locationName = 'Surat Elektronik (ACC)';
                    $catatanStr = $matchedLeave->reason ?? ('Pengajuan ' . $statusName);
                    $isLate = false;
                }
            }

            return [
                'hari' => Carbon::parse($log->tanggal)->locale('id')->dayName,
                'tanggal' => Carbon::parse($log->tanggal)->translatedFormat('d F Y'),
                'waktu' => $log->jam_masuk ? Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB' : '-',
                'lokasi' => $locationName,
                'catatan' => $catatanStr,
                'status' => $status,
                'status_label' => $statusName,
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
                    $dateStr = $c->format('Y-m-d');
                    // Riwayat presensi untuk besok/lusa belum waktunya muncul (hanya sampai hari berjalan <= today)
                    if ($dateStr > $todayStr) {
                        continue;
                    }

                    $matchYear = ($year <= 0) || ((int)$c->year === $year);
                    $matchMonth = ($month <= 0) || ((int)$c->month === $month);
                    if ($matchYear && $matchMonth) {
                        if (!$logs->contains('tanggal', $dateStr) && !$mergedLogs->contains('raw_date', $dateStr)) {
                            $typeUpper = strtoupper($leave->type ?? 'IZIN');
                            $leaveLabel = ($typeUpper === 'SAKIT') ? 'Sakit (S)' : (($typeUpper === 'DISPENSASI') ? 'Dispensasi (DIS)' : 'Izin (I)');
                            $leaveCode = ($typeUpper === 'SAKIT') ? 'S' : (($typeUpper === 'DISPENSASI') ? 'PA' : 'I');
                            $mergedLogs->push([
                                'hari' => $c->locale('id')->dayName,
                                'tanggal' => $c->translatedFormat('d F Y'),
                                'waktu' => '-',
                                'lokasi' => 'Surat Elektronik (ACC)',
                                'catatan' => $leave->reason ?? ('Pengajuan ' . $leaveLabel),
                                'status' => $leaveCode,
                                'status_label' => $leaveLabel,
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

        return [
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
        ];
    }
}
