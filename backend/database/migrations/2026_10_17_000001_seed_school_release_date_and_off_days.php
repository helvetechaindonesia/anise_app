<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();

        // 1. Tanggal rilis resmi aplikasi Anise (tidak bisa memilih tanggal mundur sebelum ini)
        DB::table('school_settings')->updateOrInsert(
            ['setting_key' => 'app_release_date'],
            [
                'setting_value' => '2026-10-26',
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );

        // 2. Default hari nonaktif mingguan sekolah (jika belum di-set)
        if (!DB::table('school_settings')->where('setting_key', 'school_off_days')->exists()) {
            DB::table('school_settings')->insert([
                'setting_key' => 'school_off_days',
                'setting_value' => json_encode(['Minggu']),
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
    }

    public function down(): void
    {
        DB::table('school_settings')->whereIn('setting_key', ['app_release_date'])->delete();
    }
};
