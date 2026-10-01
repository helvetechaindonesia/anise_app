<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('laporan_telat_siswa', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('pelapor_id'); // Tendik / Guru yang melapor
            $table->uuid('siswa_id'); // Siswa yang telat
            $table->text('alasan');
            $table->string('status')->default('PENDING'); // PENDING, ACC_GURU_WALI, ACC_WALI_KELAS, ACC_BK, ACC_KESISWAAN, TOLAK
            $table->uuid('approved_by')->nullable(); // Siapa yang meng-ACC terakhir
            $table->timestamp('waktu_telat');
            
            $table->timestamps();

            // Foreign keys
            $table->foreign('pelapor_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('siswa_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('approved_by')->references('id')->on('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('laporan_telat_siswa');
    }
};
