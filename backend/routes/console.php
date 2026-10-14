<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;
use App\Console\Commands\CheckKbmRemindersCommand;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('kbm:check-reminders', function () {
    $this->call(CheckKbmRemindersCommand::class);
})->purpose('Memindai jadwal KBM untuk peringatan H-24 terbit jurnal dan 15 menit presensi cam');

Schedule::command('kbm:check-reminders')->everyFifteenMinutes();
