<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\AttendanceService;
use App\Helpers\AppTime;

class FinalizeStudentAttendanceCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'student:finalize-attendance';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Finalisasi akumulasi presensi siswa pada pukul 18.01 WIB (evaluasi keterlambatan vs hadir tepat waktu)';

    protected AttendanceService $attendanceService;

    public function __construct(AttendanceService $attendanceService)
    {
        parent::__construct();
        $this->attendanceService = $attendanceService;
    }

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $today = AppTime::now()->format('Y-m-d');
        $this->info("Menjalankan finalisasi presensi siswa untuk tanggal {$today}...");

        $res = $this->attendanceService->finalizeStudentAttendance($today);
        $this->info("Selesai! {$res['terlambat']} siswa ditetapkan Terlambat, {$res['hadir']} siswa Hadir Tepat Waktu.");

        return 0;
    }
}
