<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('employee_leaves', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('employee_id')->constrained('users')->cascadeOnDelete();
            $table->string('type'); // 'SAKIT', 'CUTI', 'DINAS_LUAR', 'IZIN'
            $table->text('reason');
            $table->date('start_date');
            $table->date('end_date');
            $table->string('attachment_path')->nullable();
            $table->string('status')->default('PENDING');
            
            $table->foreignUuid('approved_by')->nullable()->constrained('users')->nullOnDelete();
            
            // Biometric & Geofencing khusus Sakit/Izin
            $table->text('face_snapshot_url')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('employee_leaves');
    }
};
