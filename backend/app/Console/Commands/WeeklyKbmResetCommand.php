<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class WeeklyKbmResetCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'kbm:weekly-reset {--force : Paksa eksekusi reset siklus mingguan tanpa menunggu jadwal hari nonaktif}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Mereset siklus mingguan KBM sekolah pada pukul 01:00 di hari nonaktif pertama (misal: Minggu atau Sabtu)';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $this->info("=== MEMULAI SIKLUS RESET MINGGUAN KBM ===");
        $now = Carbon::now();
        $this->info("Waktu saat ini: " . $now->toDateTimeString());

        // 1. Ambil setting hari nonaktif mingguan sekolah dari school_settings
        $offDaysSetting = DB::table('school_settings')
            ->where('setting_key', 'school_off_days')
            ->value('setting_value');

        $offDays = [];
        if ($offDaysSetting) {
            $decoded = json_decode($offDaysSetting, true);
            if (is_array($decoded)) {
                $offDays = $decoded;
            }
        }
        if (empty($offDays)) {
            $offDays = ['Minggu'];
        }

        $dayToIso = [
            'senin' => 1, 'monday' => 1,
            'selasa' => 2, 'tuesday' => 2,
            'rabu' => 3, 'wednesday' => 3,
            'kamis' => 4, 'thursday' => 4,
            'jumat' => 5, 'friday' => 5,
            'sabtu' => 6, 'saturday' => 6,
            'minggu' => 7, 'sunday' => 7,
        ];
        $isoToDay = [
            1 => 'Senin',
            2 => 'Selasa',
            3 => 'Rabu',
            4 => 'Kamis',
            5 => 'Jumat',
            6 => 'Sabtu',
            7 => 'Minggu',
        ];

        $offDayIsos = [];
        foreach ($offDays as $d) {
            $clean = strtolower(trim($d));
            if (isset($dayToIso[$clean])) {
                $offDayIsos[] = $dayToIso[$clean];
            }
        }
        sort($offDayIsos);

        $firstOffDayIso = !empty($offDayIsos) ? $offDayIsos[0] : 7;
        $firstOffDayName = $isoToDay[$firstOffDayIso] ?? 'Minggu';

        $this->info("Hari nonaktif sekolah: " . implode(', ', $offDays));
        $this->info("Hari nonaktif pertama: {$firstOffDayName} (ISO: {$firstOffDayIso})");

        $force = (bool)$this->option('force');
        $todayIso = $now->dayOfWeekIso;

        if (!$force && $todayIso !== $firstOffDayIso) {
            $todayName = $isoToDay[$todayIso] ?? 'Unknown';
            $this->info("Hari ini adalah {$todayName}, bukan hari nonaktif pertama ({$firstOffDayName}). Reset mingguan dilewati.");
            return 0;
        }

        // Kalkulasi awal pekan baru (Senin pekan depan)
        $nextMonday = $now->copy()->addWeek()->startOfWeek();
        $nextMondayStr = $nextMonday->format('Y-m-d');

        $this->info("Mereset siklus aktif KBM ke pekan baru mulai: {$nextMondayStr}");

        // Simpan log & timestamp reset ke school_settings
        DB::table('school_settings')->updateOrInsert(
            ['setting_key' => 'last_weekly_reset_at'],
            [
                'setting_value' => $now->toDateTimeString(),
                'updated_at' => $now,
            ]
        );

        DB::table('school_settings')->updateOrInsert(
            ['setting_key' => 'current_active_week_start'],
            [
                'setting_value' => $nextMondayStr,
                'updated_at' => $now,
            ]
        );

        Log::info("Siklus mingguan KBM berhasil direset untuk pekan baru ({$nextMondayStr}) pada hari nonaktif ({$firstOffDayName}) pukul 01:00.");

        $this->info("=== SIKLUS RESET MINGGUAN SELESAI DENGAN SUKSES ===");
        return 0;
    }
}
