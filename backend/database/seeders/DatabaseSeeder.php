<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Create Academic Year
        $academicYear = \App\Models\AcademicYear::create([
            'name' => '2026/2027',
            'semester' => 'GANJIL',
            'is_active' => true,
            'start_date' => '2026-07-15',
            'end_date' => '2026-12-20',
        ]);

        // 2. Create Major
        $major = \App\Models\Major::create([
            'code' => 'MIPA',
            'name' => 'Matematika dan Ilmu Pengetahuan Alam',
        ]);

        // Create Roles
        $roleTU = \App\Models\Role::create(['name' => 'TATA_USAHA']);
        $roleKepsek = \App\Models\Role::create(['name' => 'KEPALA_SEKOLAH']);
        $roleGuru = \App\Models\Role::create(['name' => 'GURU', 'is_guru_wali' => true]);
        $roleGuruBK = \App\Models\Role::create(['name' => 'GURU_BK']);
        $roleSiswa = \App\Models\Role::create(['name' => 'SISWA']);

        // Create Jabatans
        $jabatanKurikulum = \App\Models\Jabatan::create(['name' => 'WAKASEK_KURIKULUM', 'task_area' => 'Kurikulum']);

        // 3. Create Tata Usaha User
        User::create([
            'full_name' => 'Staff Tata Usaha',
            'username' => 'tu1',
            'email' => 'tu@anise.com',
            'password_hash' => \Illuminate\Support\Facades\Hash::make('password123'),
            'role_id' => $roleTU->id,
            'is_active' => true,
        ]);

        // 4. Create Kepala Sekolah User
        User::create([
            'full_name' => 'Kepala Sekolah, M.Pd.',
            'username' => 'kepsek',
            'email' => 'kepsek@anise.com',
            'password_hash' => \Illuminate\Support\Facades\Hash::make('password123'),
            'role_id' => $roleKepsek->id,
            'is_active' => true,
        ]);

        // 5. Create Guru User & Profile
        $guru = User::create([
            'full_name' => 'Budi Santoso, S.Kom.',
            'username' => 'guru1',
            'email' => 'budi.guru@anise.com',
            'password_hash' => \Illuminate\Support\Facades\Hash::make('password123'),
            'role_id' => $roleGuru->id,
            'is_active' => true,
        ]);

        \App\Models\GuruProfile::create([
            'user_id' => $guru->id,
            'nip_nuptk' => '198001012010011001',
            'gender' => 'L',
            'employment_status' => 'PNS',
        ]);

        // Create Structural Assignment for Guru
        \App\Models\StructuralAssignment::create([
            'guru_id' => $guru->id,
            'jabatan_id' => $jabatanKurikulum->id,
            'academic_year_id' => $academicYear->id,
        ]);

        // 6. Create Guru BK User & Profile
        $guruBk = User::create([
            'full_name' => 'Yeni Setianingsih, S.Sos.',
            'username' => 'gurubk',
            'email' => 'yeni.bk@anise.com',
            'password_hash' => \Illuminate\Support\Facades\Hash::make('password123'),
            'role_id' => $roleGuruBK->id,
            'is_active' => true,
        ]);

        \App\Models\GuruProfile::create([
            'user_id' => $guruBk->id,
            'nip_nuptk' => '198502022010022002',
            'gender' => 'P',
            'employment_status' => 'PNS',
        ]);

        // 7. Create Class with Wali Kelas
        $schoolClass = \App\Models\SchoolClass::create([
            'academic_year_id' => $academicYear->id,
            'name' => 'X RPL 1',
            'grade_level' => 10,
            'major_id' => $major->id,
            'wali_kelas_id' => $guru->id,
        ]);

        // 8. Create Siswa User & Profile
        $siswa = User::create([
            'full_name' => 'Andi Wijaya',
            'username' => 'siswa1',
            'email' => 'andi.siswa@anise.com',
            'password_hash' => \Illuminate\Support\Facades\Hash::make('password123'),
            'role_id' => $roleSiswa->id,
            'is_active' => true,
        ]);

        \App\Models\SiswaProfile::create([
            'user_id' => $siswa->id,
            'nisn' => '0012345678',
            'nis' => '1001',
            'academic_year_id' => $academicYear->id,
            'gender' => 'L',
            'behavior_points' => 100,
        ]);

        // Assign Siswa to Class
        \App\Models\ClassStudent::create([
            'class_id' => $schoolClass->id,
            'student_id' => $siswa->id,
            'status' => 'ACTIVE',
        ]);

        // Assign Siswa to Guru BK as Wali Asuh (Mentor)
        \App\Models\GuruWaliStudent::create([
            'guru_id' => $guruBk->id,
            'student_id' => $siswa->id,
            'academic_year_id' => $academicYear->id,
        ]);

        // 9. Create Subjects & Schedule for Guru
        $subject = \App\Models\Subject::create([
            'code' => 'PBO',
            'name' => 'Pemrograman Berorientasi Objek',
        ]);

        \App\Models\Schedule::create([
            'academic_year_id' => $academicYear->id,
            'class_id' => $schoolClass->id,
            'subject_id' => $subject->id,
            'teacher_id' => $guru->id,
            'day_of_week' => 1, // Senin
            'start_time' => '07:00:00',
            'end_time' => '09:00:00',
        ]);

        // 10. Create Habits
        $habits = [
            ['code' => 'HBT01', 'title' => 'Bangun Pagi', 'category' => 'KEDISIPLINAN'],
            ['code' => 'HBT02', 'title' => 'Beribadah', 'category' => 'IBADAH'],
            ['code' => 'HBT03', 'title' => 'Berolahraga', 'category' => 'KESEHATAN'],
            ['code' => 'HBT04', 'title' => 'Makan Sehat & Bergizi', 'category' => 'KESEHATAN'],
            ['code' => 'HBT05', 'title' => 'Gemar Belajar', 'category' => 'AKADEMIK'],
            ['code' => 'HBT06', 'title' => 'Bermasyarakat', 'category' => 'SOSIAL'],
            ['code' => 'HBT07', 'title' => 'Tidur Cepat', 'category' => 'KEDISIPLINAN'],
        ];

        foreach ($habits as $habit) {
            \App\Models\Habit::create([
                'code' => $habit['code'],
                'title' => $habit['title'],
                'category' => $habit['category'],
            ]);
        }
    }
}
