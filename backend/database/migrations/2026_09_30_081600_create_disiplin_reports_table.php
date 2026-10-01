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
        Schema::create('disiplin_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignUuid('siswa_id')->constrained('users')->onDelete('cascade');
            $table->foreignUuid('reporter_id')->constrained('users')->onDelete('cascade');
            $table->string('category');
            $table->text('notes')->nullable();
            $table->enum('status', ['LAPORAN', 'INPUT'])->default('LAPORAN');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('disiplin_reports');
    }
};
