<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class ServerTravelCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'server:travel {time? : Waktu tujuan (contoh: "2026-10-30 09:09:55" atau "reset")}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Atur waktu virtual aplikasi (Virtual Time Travel) untuk keperluan debugging KBM tanpa merusak jam OS server';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $timeInput = $this->argument('time');

        // Jika user mengetik: php artisan server:travel reset
        if ($timeInput === 'reset') {
            Cache::forget('app_mock_time');
            $this->info("✅ Waktu virtual aplikasi DIRESET ke waktu asli sistem.");
            $this->line("Waktu sekarang (Real): " . Carbon::now()->toDateTimeString());
            return 0;
        }

        // Jika tanpa argumen, tampilkan status waktu saat ini
        if (empty($timeInput)) {
            $mockTime = Cache::get('app_mock_time');
            if ($mockTime) {
                $this->warn("⚠️  Waktu virtual sedang AKTIF:");
                $this->line("Virtual Time: {$mockTime}");
                $this->line("Real System Time: " . Carbon::now()->toDateTimeString());
                $this->line("\nUntuk mereset kembali ke normal, ketik: php artisan server:travel reset");
            } else {
                $this->info("Normal. Waktu aplikasi mengikuti real system time: " . Carbon::now()->toDateTimeString());
            }
            return 0;
        }

        // Validasi format tanggal & jam
        try {
            $parsed = Carbon::parse($timeInput);
            $formatted = $parsed->format('Y-m-d H:i:s');
            
            // Simpan waktu virtual di cache (selama 7 hari kecuali direset)
            Cache::put('app_mock_time', $formatted, now()->addDays(7));

            $this->info("🚀 VIRTUAL TIME TRAVEL BERHASIL DIAKTIFKAN!");
            $this->warn("Waktu Virtual Baru : {$formatted} ({$parsed->locale('id')->isoFormat('dddd, D MMMM Y')})");
            $this->line("Waktu Real Server  : " . Carbon::now()->toDateTimeString());
            $this->line("\nSemua kalkulasi KBM, kartu jadwal, notifikasi, dan toleransi 20 menit sekarang berjalan di jam ini.");
            $this->line("Untuk mengembalikan ke waktu normal, jalankan: php artisan server:travel reset");
            return 0;
        } catch (\Exception $e) {
            $this->error("Format waktu tidak valid! Contoh format yang benar: '2026-10-30 09:09:55'");
            return 1;
        }
    }
}
