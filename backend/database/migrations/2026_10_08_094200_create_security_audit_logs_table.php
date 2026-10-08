<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('security_audit_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('event_type'); // e.g., FAILED_LOGIN, PASSWORD_CHANGED, UNRECOGNIZED_DEVICE
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->text('metadata')->nullable(); // JSON data (e.g. location, device info)
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('security_audit_logs');
    }
};
