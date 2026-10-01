<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('structural_assignments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('guru_id')->constrained('users')->cascadeOnDelete();
            $table->enum('role_title', ['WAKASEK_KESISWAAN', 'WAKASEK_KURIKULUM', 'WAKASEK_SARPRAS', 'WAKASEK_HUMAS', 'STAF_KHUSUS', 'BENDAHARA']);
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('structural_assignments');
    }
};
