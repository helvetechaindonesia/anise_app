<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\Schedule;
use App\Models\AcademicYear;
use App\Models\ClassStudent;
use Laravel\Sanctum\Sanctum;

class JournalTest extends TestCase
{
    use RefreshDatabase;

    protected $academicYear;
    protected $guruRole;
    protected $siswaRole;

    protected function setUp(): void
    {
        parent::setUp();

        $this->guruRole = Role::firstOrCreate(['name' => 'GURU']);
        $this->siswaRole = Role::firstOrCreate(['name' => 'SISWA']);

        $this->academicYear = AcademicYear::create([
            'name' => '2026/2027',
            'semester' => 'GANJIL',
            'start_date' => '2026-07-01',
            'end_date' => '2026-12-31',
            'is_active' => true,
        ]);
    }

    public function test_guru_can_get_my_schedules_and_classes(): void
    {
        $guru = User::create([
            'full_name' => 'Pak Budi Guru',
            'username' => 'guru_budi',
            'email' => 'budi@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->guruRole->id,
            'is_active' => true,
        ]);

        $kelasA = SchoolClass::create([
            'name' => 'X MIPA 1',
            'code' => '10-X-MIPA-1',
            'grade_level' => 10,
            'academic_year_id' => $this->academicYear->id,
        ]);

        $mapel = Subject::create([
            'name' => 'Fisika Dasar',
            'code' => 'FIS-10',
        ]);

        // Buat jadwal mengajar untuk guru Budi
        Schedule::create([
            'class_id' => $kelasA->id,
            'subject_id' => $mapel->id,
            'teacher_id' => $guru->id,
            'academic_year_id' => $this->academicYear->id,
            'day_of_week' => 'Monday',
            'start_time' => '07:30:00',
            'end_time' => '09:00:00',
        ]);

        // Tambah siswa aktif di kelasA
        $siswa = User::create([
            'full_name' => 'Andi Siswa',
            'username' => 'andi_10',
            'email' => 'andi@siswa.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->siswaRole->id,
            'is_active' => true,
        ]);

        ClassStudent::create([
            'class_id' => $kelasA->id,
            'student_id' => $siswa->id,
            'status' => 'ACTIVE',
        ]);

        Sanctum::actingAs($guru, ['*']);

        $response = $this->getJson('/api/journals/schedules');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ])
            ->assertJsonFragment([
                'class_id' => $kelasA->id,
                'subject_id' => $mapel->id,
                'class_name' => '10 X MIPA 1',
                'subject_name' => 'Fisika Dasar',
                'student_count' => 1,
            ]);
    }

    public function test_siswa_can_get_teachers_for_their_class(): void
    {
        $guru = User::create([
            'full_name' => 'Ibu Siti Guru',
            'username' => 'guru_siti',
            'email' => 'siti@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->guruRole->id,
            'is_active' => true,
        ]);

        $kelasB = SchoolClass::create([
            'name' => 'XI MIPA 2',
            'code' => '11-XI-MIPA-2',
            'grade_level' => 11,
            'academic_year_id' => $this->academicYear->id,
        ]);

        $mapelKimia = Subject::create([
            'name' => 'Kimia Organik',
            'code' => 'KIM-11',
        ]);

        Schedule::create([
            'class_id' => $kelasB->id,
            'subject_id' => $mapelKimia->id,
            'teacher_id' => $guru->id,
            'academic_year_id' => $this->academicYear->id,
            'day_of_week' => 'Tuesday',
            'start_time' => '09:15:00',
            'end_time' => '10:45:00',
        ]);

        $siswa = User::create([
            'full_name' => 'Bambang Siswa',
            'username' => 'bambang_11',
            'email' => 'bambang@siswa.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->siswaRole->id,
            'is_active' => true,
        ]);

        ClassStudent::create([
            'class_id' => $kelasB->id,
            'student_id' => $siswa->id,
            'status' => 'ACTIVE',
        ]);

        Sanctum::actingAs($siswa, ['*']);

        $response = $this->getJson('/api/users/siswa/teachers');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ])
            ->assertJsonFragment([
                'id' => $guru->id,
                'name' => 'Ibu Siti Guru',
                'subject' => 'Kimia Organik',
            ]);
    }

    public function test_siswa_without_class_returns_empty_array_gracefully(): void
    {
        $siswaBaru = User::create([
            'full_name' => 'Siswa Baru Belum Masuk Kelas',
            'username' => 'siswa_baru',
            'email' => 'baru@siswa.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->siswaRole->id,
            'is_active' => true,
        ]);

        Sanctum::actingAs($siswaBaru, ['*']);

        $response = $this->getJson('/api/users/siswa/teachers');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [],
            ]);
    }
}
