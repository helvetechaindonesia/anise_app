<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Drop old tables (verifikasi dan log lama)
        Schema::dropIfExists('habit_verifications');
        Schema::dropIfExists('student_habit_logs');

        // 2. Add religion to users (Biar deteksi extend ibadah bisa jalan)
        Schema::table('users', function (Blueprint $table) {
            $table->string('religion')->nullable()->after('gender');
        });

        // 3. Create generic user habit logs (Untuk umum)
        Schema::create('user_habit_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('habit_id')->constrained('habits')->cascadeOnDelete();
            $table->date('logged_date');
            $table->string('attachment_url')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });

        // 4. Create specialized Islamic prayer logs (Tabel Hemat Extend Khusus Muslim)
        Schema::create('user_prayer_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('logged_date');
            $table->boolean('is_subuh')->default(false);
            $table->boolean('is_dhuhur')->default(false);
            $table->boolean('is_asar')->default(false);
            $table->boolean('is_maghrib')->default(false);
            $table->boolean('is_isya')->default(false);
            $table->boolean('is_quran')->default(false);
            $table->timestamps();
            
            // Mencegah duplikasi: 1 user hanya punya 1 baris per hari
            $table->unique(['user_id', 'logged_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_prayer_logs');
        Schema::dropIfExists('user_habit_logs');
        
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('religion');
        });

        Schema::create('student_habit_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('habit_id')->constrained('habits')->cascadeOnDelete();
            $table->date('logged_date');
            $table->string('status')->default('PENDING');
            $table->timestamps();
        });

        Schema::create('habit_verifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('student_habit_log_id')->constrained('student_habit_logs')->cascadeOnDelete();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('status')->default('VERIFIED');
            $table->text('verification_note')->nullable();
            $table->timestamps();
        });
    }
};
