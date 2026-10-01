<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Tambah Biodata
        Schema::table('users', function (Blueprint $table) {
            $table->string('avatar')->nullable()->after('full_name');
            $table->string('birth_place')->nullable()->after('religion');
            $table->date('birth_date')->nullable()->after('birth_place');
        });

        // 2. Ganti Nama Tabel Profil
        Schema::rename('siswa_profiles', 'student_profiles');
        // Sengaja dinamakan staff_profiles bukan teacher_profiles, alasannya di chat!
        Schema::rename('guru_profiles', 'staff_profiles'); 
    }

    public function down(): void
    {
        Schema::rename('student_profiles', 'siswa_profiles');
        Schema::rename('staff_profiles', 'guru_profiles');

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['avatar', 'birth_place', 'birth_date']);
        });
    }
};
