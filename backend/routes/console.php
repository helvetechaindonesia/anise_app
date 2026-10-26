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

// Otomatisasi TAM (pukul 12:01) dan TAP (pukul 18:01) untuk pegawai presensi
Schedule::command('attendance:auto-tam-tap')->everyMinute();

// Otomatisasi Masuk Sementara Seluruh Siswa pada pukul 07:00 WIB
Schedule::command('student:auto-morning-attendance')->dailyAt('07:00');

// Finalisasi Akumulasi Presensi Siswa pada pukul 18:01 WIB
Schedule::command('student:finalize-attendance')->dailyAt('18:01');
