<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\AttendanceService;
use App\Helpers\AppTime;

class AutoStudentMorningAttendanceCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'student:auto-morning-attendance';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Akumulasi otomatis masuk sementara seluruh siswa aktif serentak pada pukul 07.00 WIB';

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
        $this->info("Menjalankan akumulasi otomatis presensi masuk siswa untuk tanggal {$today}...");

        $created = $this->attendanceService->autoGenerateMorningStudentAttendance($today);
        $this->info("Selesai! Berhasil membuat {$created} presensi masuk sementara siswa.");

        return 0;
    }
}
