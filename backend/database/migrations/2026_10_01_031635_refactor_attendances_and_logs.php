<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->timestamp('jam_pulang')->nullable()->after('jam_masuk');
            $table->text('pulang_awal_reason')->nullable()->after('status');
        });

        Schema::table('presensi_logs', function (Blueprint $table) {
            $table->decimal('latitude', 10, 8)->nullable()->after('snapshot_url');
            $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
        });
    }

    public function down(): void
    {
        Schema::table('presensi_logs', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude']);
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn(['jam_pulang', 'pulang_awal_reason']);
        });
    }
};
