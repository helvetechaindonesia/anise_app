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
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('role_type');
            $table->foreignUuid('role_id')->nullable()->constrained('roles')->nullOnDelete();
        });

        Schema::table('structural_assignments', function (Blueprint $table) {
            $table->dropColumn('role_title');
            $table->foreignUuid('jabatan_id')->nullable()->constrained('jabatans')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['role_id']);
            $table->dropColumn('role_id');
            $table->enum('role_type', ['TATA_USAHA', 'KEPALA_SEKOLAH', 'GURU', 'GURU_BK', 'SISWA'])->default('SISWA');
        });

        Schema::table('structural_assignments', function (Blueprint $table) {
            $table->dropForeign(['jabatan_id']);
            $table->dropColumn('jabatan_id');
            $table->enum('role_title', ['WAKASEK_KESISWAAN', 'WAKASEK_KURIKULUM', 'WAKASEK_SARPRAS', 'WAKASEK_HUMAS', 'STAF_KHUSUS', 'BENDAHARA'])->default('STAF_KHUSUS');
        });
    }
};
