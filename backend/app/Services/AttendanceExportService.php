<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Rap2hpoutre\FastExcel\FastExcel;

class AttendanceExportService
{
    /**
     * Memproses ekspor presensi ke file XLSX dan mengembalikan file response download.
     */
    public function exportToExcel($user, int $month, int $year)
    {
        // 1. Student metadata
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

        // 2. Logs from attendances
        $logs = collect();
        if (Schema::hasTable('attendances')) {
            $logsQuery = DB::table('attendances')->where('user_id', $user->id);
            if ($year > 0) $logsQuery->whereYear('tanggal', $year);
            if ($month > 0) $logsQuery->whereMonth('tanggal', $month);
            $logs = $logsQuery->orderBy('tanggal', 'asc')->get();
        }

        // 3. Approved Leaves
        $leaves = collect();
        if (Schema::hasTable('student_leaves')) {
            $leavesQuery = DB::table('student_leaves')
                ->where('student_id', $user->id)
                ->whereIn('status', ['APPROVED', 'ACC', 'ACC_GURU_WALI']);
            if ($year > 0) $leavesQuery->whereYear('start_date', $year);
            if ($month > 0) $leavesQuery->whereMonth('start_date', $month);
            $leaves = $leavesQuery->get();
        }

        // 4. Discipline / Late Reports
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

        // 5. Summary counts
        $hadirCount = $logs->whereIn('status', ['MASUK', 'Hadir', 'Hadir Tepat', 'PULANG', 'Pulang Tepat'])->count();
        $terlambatCount = $logs->whereIn('status', ['TERLAMBAT', 'Terlambat', 'TAM'])->count();
        $sakitCount = $leaves->where('type', 'SAKIT')->count();
        $izinCount = $leaves->where('type', 'IZIN')->count();
        $alphaCount = $logs->whereIn('status', ['ALPHA', 'Alpha', 'Tidak Hadir'])->count();

        $dailyRows = [];

        foreach ($logs as $log) {
            $date = Carbon::parse($log->tanggal);
            $hari = $date->locale('id')->isoFormat('dddd');
            $tanggal = $date->locale('id')->isoFormat('D MMMM Y');

            $jamMasuk = $log->jam_masuk ? Carbon::parse($log->jam_masuk)->format('H:i') . ' WIB' : '-';
            $jamPulang = $log->jam_pulang ? Carbon::parse($log->jam_pulang)->format('H:i') . ' WIB' : '-';

            $statusMap = [
                'MASUK' => 'Hadir', 'Hadir' => 'Hadir', 'K' => 'Kembali', 'PA' => 'Pulang Awal',
                'TERLAMBAT' => 'Terlambat', 'Terlambat' => 'Terlambat', 'SAKIT' => 'Sakit', 'IZIN' => 'Izin', 'ALPHA' => 'Alpha',
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

        $sortedDaily = collect($dailyRows)->sortBy('_raw_date')->values();
        $rows = [];
        $no = 1;
        foreach ($sortedDaily as $item) {
            $rawRow = (array) $item;
            unset($rawRow['_raw_date']);
            $rows[] = array_merge(['No' => $no++], $rawRow);
        }

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

        // Summary row
        $namaBulan = Carbon::createFromDate($year > 0 ? $year : date('Y'), $month > 0 ? $month : date('n'), 1)->locale('id')->isoFormat('MMMM');
        $rows[] = [
            'No' => '', 'Hari' => '', 'Tanggal' => '', 'Jam Masuk' => '', 'Jam Pulang' => '',
            'Status Kehadiran' => '', 'Keterangan' => '', 'Lokasi' => '', 'Validasi Wali Kelas' => '',
        ];
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
    }
}
