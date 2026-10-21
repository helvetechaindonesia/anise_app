<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Console\Commands\CheckKbmRemindersCommand;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Jadwalkan pemindaian KBM setiap 1 menit agar notifikasi H-1 jam, KBM mulai, dan switch ke terlambat (menit ke-20) ditembakkan secara presisi
Schedule::command('kbm:check-reminders')->everyMinute();

// Jadwalkan reset siklus mingguan KBM setiap hari pukul 01:00 (eksekusi pada hari nonaktif pertama)
Schedule::command('kbm:weekly-reset')->dailyAt('01:00');
