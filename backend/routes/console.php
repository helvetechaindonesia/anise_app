<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Console\Commands\CheckKbmRemindersCommand;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Jadwalkan pemindaian KBM setiap 15 menit
Schedule::command('kbm:check-reminders')->everyFifteenMinutes();

// Jadwalkan reset siklus mingguan KBM setiap hari pukul 01:00 (eksekusi pada hari nonaktif pertama)
Schedule::command('kbm:weekly-reset')->dailyAt('01:00');
