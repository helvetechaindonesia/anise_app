<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('nik')->nullable()->after('full_name');
            $table->enum('gender', ['L', 'P'])->nullable()->after('nik');
            $table->text('face_biometric')->nullable()->after('password_hash');
        });

        Schema::table('guru_profiles', function (Blueprint $table) {
            $table->dropColumn('gender');
        });

        Schema::table('siswa_profiles', function (Blueprint $table) {
            $table->dropColumn(['gender', 'behavior_points']);
        });
    }

    public function down(): void
    {
        Schema::table('siswa_profiles', function (Blueprint $table) {
            $table->enum('gender', ['L', 'P'])->nullable();
            $table->integer('behavior_points')->default(100);
        });

        Schema::table('guru_profiles', function (Blueprint $table) {
            $table->enum('gender', ['L', 'P'])->nullable();
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['nik', 'gender', 'face_biometric']);
        });
    }
};
