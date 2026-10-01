<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Buang tabel lama yang bikin tumpang tindih
        Schema::dropIfExists('laporan_telat_siswa');
        Schema::dropIfExists('disiplin_reports');

        // 2. Buat tabel master pemersatu Modul 9 Disiplin
        Schema::create('discipline_reports', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            
            // Pelapor (Hanya untuk Guru/Tendik/Satpam. Siswa tidak boleh lapor ke sini)
            $table->foreignUuid('reporter_id')->constrained('users')->cascadeOnDelete();
            
            // Kategori: TERLAMBAT, KENAKALAN, SERAGAM, BOLOS
            $table->string('category');
            
            // Jembatan ke Sistem Poin (Berapa bobot dosa pelanggarannya)
            $table->foreignUuid('point_rule_id')->nullable()->constrained('point_rules')->nullOnDelete();
            
            $table->text('description');
            
            // Bukti foto sangat vital buat kasus kenakalan / seragam
            $table->string('attachment_url')->nullable();
            
            // Waktu spesifik pelanggaran (krusial buat telat / bolos)
            $table->timestamp('violation_time');
            
            // Status ACC 1 Pintu (PENDING, APPROVED, REJECTED)
            $table->string('status')->default('PENDING'); 
            
            // Jejak audit: Siapa Guru Wali yang memvalidasi (menekan tombol ACC)
            $table->foreignUuid('approved_by')->nullable()->constrained('users')->nullOnDelete(); 
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('discipline_reports');

        // Restore tabel lama sekadarnya untuk keperluan rollback
        Schema::create('disiplin_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignUuid('siswa_id')->constrained('users')->onDelete('cascade');
            $table->foreignUuid('reporter_id')->constrained('users')->onDelete('cascade');
            $table->string('category');
            $table->text('notes')->nullable();
            $table->enum('status', ['LAPORAN', 'INPUT'])->default('LAPORAN');
            $table->timestamps();
        });

        Schema::create('laporan_telat_siswa', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('pelapor_id');
            $table->uuid('siswa_id');
            $table->text('alasan');
            $table->string('status')->default('PENDING');
            $table->uuid('approved_by')->nullable();
            $table->timestamp('waktu_telat');
            $table->timestamps();
        });
    }
};
