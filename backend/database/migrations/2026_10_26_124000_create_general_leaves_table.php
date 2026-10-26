<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('leaves')) {
            Schema::create('leaves', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
                $table->string('type'); // 'IZIN', 'SAKIT', 'DISPENSASI'
                $table->text('reason');
                $table->date('start_date');
                $table->date('end_date');
                $table->time('exit_time')->nullable(); // Khusus dispensasi: jam keluar
                $table->timestamp('returned_at')->nullable(); // Konfirmasi kembali oleh Wali Kelas/Kepsek
                
                // Bukti Lampiran & Face Snapshot
                $table->string('attachment_path')->nullable();
                $table->string('face_snapshot_url')->nullable();
                $table->decimal('latitude', 10, 8)->nullable();
                $table->decimal('longitude', 11, 8)->nullable();

                // Status & Approver
                $table->string('status')->default('PENDING'); // PENDING, APPROVED, REJECTED
                $table->foreignUuid('approved_by')->nullable()->constrained('users')->nullOnDelete();
                $table->text('approval_notes')->nullable();

                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('leaves');
    }
};
