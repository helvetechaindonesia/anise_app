<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('task_late_submission_requests')) {
            Schema::create('task_late_submission_requests', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('journal_task_id')->constrained('journal_tasks')->cascadeOnDelete();
                $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
                $table->foreignUuid('teacher_id')->nullable()->constrained('users')->nullOnDelete();
                $table->text('reason'); // Alasan / ucapan maaf
                $table->enum('status', ['PENDING', 'APPROVED', 'REJECTED'])->default('PENDING');
                $table->text('teacher_note')->nullable(); // Pesan nasihat dari guru
                $table->timestamp('extended_until')->nullable(); // Batas waktu 2x24 jam jika disetujui
                $table->timestamp('responded_at')->nullable();
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('task_late_submission_requests');
    }
};
