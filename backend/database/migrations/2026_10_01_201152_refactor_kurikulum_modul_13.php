<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Ganti guru_bk_classes menjadi guru_bk_students
        Schema::dropIfExists('guru_bk_classes');

        Schema::create('guru_bk_students', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('guru_bk_id')->constrained('users')->cascadeOnDelete(); // Guru BK nya
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete(); // Anak asuhnya
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete(); // Histori tahun ajaran
            $table->timestamps();
        });

        // 2. Modifikasi tabel classes agar major_id boleh kosong (Untuk SMA N 1 Peunaron yang gapake jurusan di kelas 10)
        Schema::table('classes', function (Blueprint $table) {
            $table->dropForeign(['major_id']);
            $table->uuid('major_id')->nullable()->change();
            $table->foreign('major_id')->references('id')->on('majors')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('classes', function (Blueprint $table) {
            $table->dropForeign(['major_id']);
            $table->uuid('major_id')->nullable(false)->change();
            $table->foreign('major_id')->references('id')->on('majors')->cascadeOnDelete();
        });

        Schema::dropIfExists('guru_bk_students');
        
        Schema::create('guru_bk_classes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('guru_bk_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
            $table->timestamps();
        });
    }
};
