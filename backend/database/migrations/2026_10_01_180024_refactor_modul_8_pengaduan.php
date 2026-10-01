<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Hapus tabel jadul yang kurang spesifik
        Schema::dropIfExists('student_reports');

        // 2. Bangun tabel Pengaduan Helpdesk modern
        Schema::create('complaints', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            
            // Kategori: FASILITAS, BULLYING, ASPIRASI
            $table->string('category'); 
            
            $table->string('title');
            $table->text('description');
            $table->string('attachment_url')->nullable(); // Bukti foto/dokumen
            
            // Status penanganan tiket
            $table->string('status')->default('PENDING'); // PENDING, ON_PROGRESS, RESOLVED, REJECTED
            
            // Tanggapan/balasan resmi dari pihak sekolah (Sarpras / Kesiswaan)
            $table->text('response_note')->nullable(); 
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('complaints');

        Schema::create('student_reports', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('report_title');
            $table->text('report_text');
            $table->string('status')->default('PENDING');
            $table->timestamps();
        });
    }
};
