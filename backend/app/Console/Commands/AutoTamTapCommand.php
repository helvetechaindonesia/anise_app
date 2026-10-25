<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;
use App\Helpers\AppTime;
use App\Services\HolidayService;

class AutoTamTapCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'attendance:auto-tam-tap';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Otomatis catat TAM (pukul 12:01) dan TAP (pukul 18:01 dengan jam pulang 15:59) bagi pegawai';

    protected HolidayService $holidayService;

    public function __construct(HolidayService $holidayService)
    {
        parent::__construct();
        $this->holidayService = $holidayService;
    }

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $appNow = AppTime::now();
        $today = $appNow->format('Y-m-d');
        $currentTimeStr = $appNow->format('H:i');

        // Cek hari libur mingguan atau khusus sekolah
        $holidayCheck = $this->holidayService->checkDate($today);
        if (!empty($holidayCheck['is_holiday'])) {
            $this->info("Hari ini ({$today}) adalah hari non-aktif / libur. Melewati proses auto TAM & TAP.");
            return 0;
        }

        // Ambil semua pegawai aktif (Semua non-SISWA: Guru, TU, Staff, dll)
        $teacherRoles = ['GURU', 'TATA_USAHA', 'KEPALA_SEKOLAH', 'STAFF', 'SECURITY', 'CLEANING_SERVICE', 'LABORAN', 'PUSTAKAWAN'];
        
        $employees = DB::table('users')
            ->leftJoin('roles', 'users.role_id', '=', 'roles.id')
            ->where('users.is_active', true)
            ->where(function ($q) use ($teacherRoles) {
                $q->whereIn(DB::raw('UPPER(roles.name)'), $teacherRoles)
                  ->orWhereIn(DB::raw('UPPER(users.role_type)'), $teacherRoles)
                  ->orWhere(function ($sub) {
                      $sub->whereNotNull('roles.name')->where(DB::raw('UPPER(roles.name)'), '!=', 'SISWA');
                  })
                  ->orWhere(function ($sub) {
                      $sub->whereNotNull('users.role_type')->where(DB::raw('UPPER(users.role_type)'), '!=', 'SISWA');
                  });
            })
            ->select('users.id', 'users.full_name')
            ->get();

        if ($employees->isEmpty()) {
            $this->info("Tidak ada pegawai aktif ditemukan.");
            return 0;
        }

        $tamRecordedCount = 0;
        $tapRecordedCount = 0;

        // =========================================================================
        // 1. OTOMATIS CATAT TAM JIKA WAKTU SUDAH MELEWATI 12:00 (MULAI 12:01 WIB)
        // =========================================================================
        if ($currentTimeStr >= '12:01') {
            $tamScanTime = Carbon::parse($today . ' 12:01:00');

            foreach ($employees as $emp) {
                // Cek apakah pegawai sedang izin/cuti resmi yang di-ACC hari ini
                $hasLeave = DB::table('employee_leaves')
                    ->where('employee_id', $emp->id)
                    ->whereIn('status', ['APPROVED', 'ACC'])
                    ->where('start_date', '<=', $today)
                    ->where(function ($q) use ($today) {
                        $q->where('end_date', '>=', $today)
                          ->orWhereNull('end_date');
                    })
                    ->exists();

                if ($hasLeave) {
                    continue;
                }

                // Cek apakah sudah ada record attendance hari ini
                $attendance = DB::table('attendances')
                    ->where('user_id', $emp->id)
                    ->where('tanggal', $today)
                    ->first();

                if (!$attendance) {
                    // Buat master attendance TAM
                    DB::table('attendances')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $emp->id,
                        'tanggal' => $today,
                        'jam_masuk' => null,
                        'jam_pulang' => null,
                        'status' => 'TAM',
                        'created_at' => $tamScanTime,
                        'updated_at' => $tamScanTime,
                    ]);

                    // Catat presensi_logs TAM
                    DB::table('presensi_logs')->insert([
                        'id' => Str::uuid(),
                        'user_id' => $emp->id,
                        'scan_time' => $tamScanTime,
                        'status' => 'TAM',
                        'latitude' => null,
                        'longitude' => null,
                        'created_at' => $tamScanTime,
                        'updated_at' => $tamScanTime,
                    ]);

                    $tamRecordedCount++;
                }
            }
        }

        // =========================================================================
        // 2. OTOMATIS CATAT TAP JIKA WAKTU SUDAH MELEWATI 18:00 (MULAI 18:01 WIB)
        // =========================================================================
        if ($currentTimeStr >= '18:01') {
            $tapTime = Carbon::parse($today . ' 15:59:00');

            foreach ($employees as $emp) {
                $attendance = DB::table('attendances')
                    ->where('user_id', $emp->id)
                    ->where('tanggal', $today)
                    ->first();

                // Pegawai yang tercatat hadir/masuk/TAM tapi belum absen pulang
                if ($attendance && empty($attendance->jam_pulang) && $attendance->status !== 'TAP') {
                    // Update master attendance dengan jam pulang sanksi 15:59:00
                    DB::table('attendances')
                        ->where('id', $attendance->id)
                        ->update([
                            'jam_pulang' => $tapTime,
                            'status' => ($attendance->status === 'TAM') ? 'TAM' : 'TAP',
                            'updated_at' => now(),
                        ]);

                    // Cek apakah presensi_logs sudah memiliki event TAP hari ini
                    $hasTapLog = DB::table('presensi_logs')
                        ->where('user_id', $emp->id)
                        ->whereDate('scan_time', $today)
                        ->where('status', 'TAP')
                        ->exists();

                    if (!$hasTapLog) {
                        DB::table('presensi_logs')->insert([
                            'id' => Str::uuid(),
                            'user_id' => $emp->id,
                            'scan_time' => $tapTime,
                            'status' => 'TAP',
                            'latitude' => null,
                            'longitude' => null,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }

                    $tapRecordedCount++;
                }
            }
        }

        $this->info("Eksekusi Auto TAM & TAP Berhasil pada {$appNow->toDateTimeString()}:");
        $this->line("- TAM baru tercatat: {$tamRecordedCount} pegawai");
        $this->line("- TAP baru tercatat: {$tapRecordedCount} pegawai");

        return 0;
    }
}
