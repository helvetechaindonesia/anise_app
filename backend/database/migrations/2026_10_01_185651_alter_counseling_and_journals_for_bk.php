<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('counseling_requests', function (Blueprint $table) {
            // Menandai siapa yang membuat jadwal (STUDENT = Ajukan mandiri, GURU_BK = Panggilan paksa)
            $table->string('initiator')->default('STUDENT')->after('guru_bk_id'); 
            
            // Kolom untuk Guru BK mengetik hasil/notulensi setelah sesi selesai
            $table->text('counseling_result')->nullable()->after('status');
        });

        Schema::table('journals', function (Blueprint $table) {
            // Flag khusus untuk menandai bahwa jurnal ini adalah hasil "pembajakan" jadwal oleh Guru BK untuk sosialisasi
            $table->boolean('is_bk_sosialisasi')->default(false)->after('topic_material');
        });
    }

    public function down(): void
    {
        Schema::table('counseling_requests', function (Blueprint $table) {
            $table->dropColumn(['initiator', 'counseling_result']);
        });

        Schema::table('journals', function (Blueprint $table) {
            $table->dropColumn('is_bk_sosialisasi');
        });
    }
};
