<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Schedule;
use App\Models\Journal;
use App\Services\NotificationService;
use Carbon\Carbon;

class CheckKbmRemindersCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'kbm:check-reminders {--force : Jalankan pemindaian tanpa batas filter}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Memindai jadwal KBM untuk mengirim peringatan H-24 Jam penerbitan jurnal dan toleransi 15 menit presensi cam.';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $this->info("=== MEMULAI PEMINDAIAN JADWAL KBM & NOTIFIKASI ===");
        $now = Carbon::now();
        $this->info("Waktu saat ini: " . $now->toDateTimeString());

        $daysMap = [
            1 => 'Senin',
            2 => 'Selasa',
            3 => 'Rabu',
            4 => 'Kamis',
            5 => 'Jumat',
            6 => 'Sabtu',
            7 => 'Minggu',
        ];

        // ========================================================
        // 1. CEK H-24 JAM PENERBITAN JURNAL
        // Guru wajib menerbitkan jurnal maksimal 24 jam sebelum KBM
        // ========================================================
        $tomorrow = $now->copy()->addDay();
        $tomorrowDayName = $daysMap[$tomorrow->dayOfWeekIso] ?? '';
        $tomorrowDateStr = $tomorrow->format('Y-m-d');

        $this->info("\n[1] Memeriksa jadwal KBM besok ({$tomorrowDayName}, {$tomorrowDateStr})...");

        $upcomingSchedules = Schedule::where('day_of_week', $tomorrowDayName)
            ->with(['teacher.guruProfile', 'subject', 'class'])
            ->get();

        $h24NotifiedCount = 0;
        foreach ($upcomingSchedules as $sched) {
            // Cek apakah jurnal sudah diterbitkan untuk tanggal besok
            $journalExists = Journal::where('schedule_id', $sched->id)
                ->whereDate('teaching_date', $tomorrowDateStr)
                ->exists();

            if (!$journalExists) {
                $this->warn(" -> Jurnal belum terbit: {$sched->subject?->name} ({$sched->class?->grade_level} {$sched->class?->name}) - Guru: {$sched->teacher?->username}");
                NotificationService::notifyGuruH24Journal($sched, $tomorrow);
                $h24NotifiedCount++;
            }
        }
        $this->info("Selesai H-24 check: {$h24NotifiedCount} guru dikirim peringatan.");

        // ========================================================
        // 2. CEK TOLERANSI 15 MENIT PRESENSI CAM KBM AKTIF HARI INI
        // Guru wajib presensi cam maksimal toleransi 15 menit dari start_time
        // ========================================================
        $todayDayName = $daysMap[$now->dayOfWeekIso] ?? '';
        $todayDateStr = $now->format('Y-m-d');
        $currentTimeStr = $now->format('H:i:s');

        $this->info("\n[2] Memeriksa jadwal KBM hari ini ({$todayDayName}, {$todayDateStr}) yang sedang aktif...");

        $activeSchedules = Schedule::where('day_of_week', $todayDayName)
            ->where('start_time', '<=', $currentTimeStr)
            ->where('end_time', '>=', $currentTimeStr)
            ->with(['teacher.guruProfile', 'subject', 'class'])
            ->get();

        $camNotifiedCount = 0;
        foreach ($activeSchedules as $sched) {
            // Ambil jurnal yang sudah diterbitkan untuk jadwal hari ini
            $journal = Journal::where('schedule_id', $sched->id)
                ->whereDate('teaching_date', $todayDateStr)
                ->first();

            // Jika ada jurnal tapi guru BELUM melakukan presensi cam
            if ($journal && empty($journal->check_in_time)) {
                $startDateTime = Carbon::createFromFormat('Y-m-d H:i:s', "{$todayDateStr} {$sched->start_time}");
                $minutesElapsed = (int)$startDateTime->diffInMinutes($now, false);

                if ($minutesElapsed >= 10) {
                    $this->warn(" -> Guru belum presensi cam ({$minutesElapsed} menit berjalan): {$sched->subject?->name} - Guru: {$sched->teacher?->username}");
                    NotificationService::notifyGuruPresensiCamLate($sched, $journal, $minutesElapsed);
                    $camNotifiedCount++;
                }
            }
        }
        $this->info("Selesai Presensi Cam check: {$camNotifiedCount} guru dikirim peringatan keterlambatan.");

        $this->info("\n=== PEMINDAIAN SELESAI ===");
        return Command::SUCCESS;
    }
}
