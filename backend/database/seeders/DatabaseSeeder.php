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
        \App\Models\Jabatan::firstOrCreate(['name' => 'WAKASEK_KURIKULUM'], ['task_area' => 'Kurikulum']);
        \App\Models\Jabatan::firstOrCreate(['name' => 'WAKASEK_KESISWAAN'], ['task_area' => 'Kesiswaan']);
        \App\Models\Jabatan::firstOrCreate(['name' => 'WAKASEK_SARPRAS'], ['task_area' => 'Sarana Prasarana']);
        \App\Models\Jabatan::firstOrCreate(['name' => 'WAKASEK_HUMAS'], ['task_area' => 'Humas']);

        // 3. Create Sole Tata Usaha User (Clean State for Manual Testing)
        User::create([
            'full_name' => 'Tata Usaha',
            'username' => 'tu_dev',
            'email' => 'tu@dev.com',
            'password_hash' => \Illuminate\Support\Facades\Hash::make('dev123'),
            'role_id' => $roleTU->id,
            'is_active' => true,
            'gender' => 'L',
        ]);

        // 4. Create Habits
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

        // 5. Create Developer Contact
        \App\Models\Developer::updateOrCreate(
            ['email' => 'Helvetechaindonesia@gmail.com'],
            [
                'name' => 'Helvetecha Group',
                'phone' => '081931315944',
            ]
        );
    }
}
