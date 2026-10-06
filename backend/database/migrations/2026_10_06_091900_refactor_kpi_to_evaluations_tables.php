<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. HANCURKAN TABEL LAMA YANG BERBASIS POIN ANGKA (Karena tidak dipakai lagi)
        Schema::dropIfExists('teacher_kpi_period_summaries');
        Schema::dropIfExists('kpi_indicators');

        // 2. BANGUN TABEL BARU BERBASIS EVALUASI SUBJEKTIF KEPSEK
        Schema::create('teacher_evaluations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('evaluator_id')->constrained('users')->cascadeOnDelete(); // Kepala Sekolah
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();
            
            // Enum disesuaikan dengan standar E-Kinerja PMM Kemdikbud
            $table->enum('praktik_kinerja', ['DI_BAWAH_EKSPEKTASI', 'SESUAI_EKSPEKTASI', 'DI_ATAS_EKSPEKTASI'])->nullable();
            $table->enum('perilaku_kerja', ['DI_BAWAH_EKSPEKTASI', 'SESUAI_EKSPEKTASI', 'DI_ATAS_EKSPEKTASI'])->nullable();
            
            // Predikat Akhir
            $table->enum('predikat_kinerja', ['SANGAT_KURANG', 'KURANG', 'CUKUP', 'BAIK', 'SANGAT_BAIK'])->nullable();
            
            $table->text('notes')->nullable(); // Catatan pembinaan dari Kepsek
            $table->boolean('is_published')->default(false); // true jika Kepsek klik "Kirim Penilaian"
            
            $table->timestamps();
            
            // Cegah Kepsek menilai guru yang sama 2x di semester yang sama
            $table->unique(['teacher_id', 'academic_year_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teacher_evaluations');
        
        // Rollback ke tabel lama (Jaga-jaga)
        Schema::create('kpi_indicators', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code')->unique();
            $table->decimal('weight_percentage', 5, 2);
            $table->timestamps();
        });

        Schema::create('teacher_kpi_period_summaries', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();
            $table->smallInteger('period_month');
            $table->decimal('final_kpi_score', 5, 2);
            $table->timestamps();
        });
    }
};
