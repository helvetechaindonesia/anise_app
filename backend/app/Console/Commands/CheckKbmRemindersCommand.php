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
        $todayDayName = $daysMap[$now->dayOfWeekIso] ?? '';
        $todayDateStr = $now->format('Y-m-d');
        $currentTimeStr = $now->format('H:i:s');

        $tomorrow = $now->copy()->addDay();
        $tomorrowDayName = $daysMap[$tomorrow->dayOfWeekIso] ?? '';
        $tomorrowDateStr = $tomorrow->format('Y-m-d');

        $force = (bool)$this->option('force');
        $h24NotifiedCount = 0;

        // Target pemindaian: Sisa sesi hari ini yang belum mulai & sesi besok yang dalam rentang 24 jam
        $scanTargets = [
            [
                'dayName' => $todayDayName,
                'targetDate' => $now->copy(),
                'dateStr' => $todayDateStr,
                'onlyFuture' => true,
            ],
            [
                'dayName' => $tomorrowDayName,
                'targetDate' => $tomorrow,
                'dateStr' => $tomorrowDateStr,
                'onlyFuture' => false,
            ]
        ];

        foreach ($scanTargets as $target) {
            $dayName = $target['dayName'];
            $targetDate = $target['targetDate'];
            $targetDateStr = $target['dateStr'];
            $onlyFuture = $target['onlyFuture'];

            $this->info("\n[1] Memeriksa jadwal KBM ({$dayName}, {$targetDateStr})...");

            $schedulesQuery = Schedule::where('day_of_week', $dayName)
                ->whereNotNull('teacher_id')
                ->whereNotNull('subject_id')
                ->whereNull('activity_name')
                ->with(['teacher.guruProfile', 'subject', 'class']);

            if ($onlyFuture) {
                $schedulesQuery->where('start_time', '>', $currentTimeStr);
            }

            $schedules = $schedulesQuery->get()->filter(function ($sched) {
                // Abaikan kegiatan luar mapel (KEG)
                return $sched->subject && $sched->subject->code !== 'KEG' && empty($sched->activity_name);
            });

            foreach ($schedules as $sched) {
                if (!$sched->teacher) continue;

                // Hitung selisih waktu persis ke waktu mulai KBM
                $startDateTime = Carbon::createFromFormat('Y-m-d H:i:s', "{$targetDateStr} {$sched->start_time}");
                $minutesUntilKbm = $now->diffInMinutes($startDateTime, false);

                // Hanya proses jika KBM belum lewat dan berada dalam jendela H-24 jam (<= 1440 menit)
                if ($minutesUntilKbm < 0 || $minutesUntilKbm > 1440) {
                    continue;
                }

                // Cek apakah jurnal sudah diterbitkan untuk tanggal KBM tersebut
                $journalExists = Journal::where('schedule_id', $sched->id)
                    ->whereDate('teaching_date', $targetDateStr)
                    ->exists();

                if (!$journalExists) {
                    $subjectName = $sched->subject?->name ?? 'Mata Pelajaran';

                    // Anti-spam deduplikasi jika tidak --force
                    if (!$force) {
                        $alreadyNotified = \App\Models\Notification::where('user_id', $sched->teacher_id)
                            ->where('title', 'like', '%H-24%')
                            ->where('message', 'like', "%{$subjectName}%")
                            ->where('message', 'like', "%{$targetDateStr}%")
                            ->where('created_at', '>=', $now->copy()->subHours(20))
                            ->exists();

                        if ($alreadyNotified) {
                            $this->line(" -> [Skip] Guru {$sched->teacher->username} ({$subjectName} {$targetDateStr}) sudah menerima notifikasi H-24.");
                            continue;
                        }
                    }

                    // Ambil nomor WA dari master user (kolom phone di users, fallback ke guruProfile)
                    $phone = !empty($sched->teacher->phone) ? $sched->teacher->phone : ($sched->teacher->guruProfile?->phone ?? '-');
                    $this->warn(" -> Peringatan H-24 ke {$sched->teacher->username} (WA: {$phone}): {$subjectName} ({$sched->class?->grade_level} {$sched->class?->name})");

                    // Kirim notifikasi in-app ke tabel notifications dan pesan WhatsApp via gateway API
                    NotificationService::notifyGuruH24Journal($sched, $targetDate);
                    $h24NotifiedCount++;
                }
            }
        }
        $this->info("Selesai H-24 check: {$h24NotifiedCount} guru dikirim peringatan.");

        // ========================================================
        // 2. CEK TOLERANSI 15 MENIT PRESENSI CAM KBM AKTIF HARI INI
        // Guru wajib presensi cam maksimal toleransi 15 menit dari start_time
        // ========================================================
        $this->info("\n[2] Memeriksa jadwal KBM hari ini ({$todayDayName}, {$todayDateStr}) yang sedang aktif...");

        $activeSchedules = Schedule::where('day_of_week', $todayDayName)
            ->whereNotNull('subject_id')
            ->whereNull('activity_name')
            ->where('start_time', '<=', $currentTimeStr)
            ->where('end_time', '>=', $currentTimeStr)
            ->with(['teacher.guruProfile', 'subject', 'class'])
            ->get()
            ->filter(function ($sched) {
                // Abaikan kegiatan non-mapel (KEG)
                return $sched->subject && $sched->subject->code !== 'KEG' && empty($sched->activity_name);
            });

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
