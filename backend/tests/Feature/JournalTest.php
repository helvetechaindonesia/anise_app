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

    public function test_can_get_off_days_from_database(): void
    {
        $guru = User::create([
            'full_name' => 'Pak Test Guru',
            'username' => 'guru_test_offdays',
            'email' => 'offdays@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->guruRole->id,
            'is_active' => true,
        ]);

        \App\Models\SchoolHoliday::create([
            'name' => 'Hari Libur Nasional Test',
            'start_date' => '2026-10-25',
            'end_date' => '2026-10-25',
            'type' => 'NASIONAL',
            'description' => 'Libur Nasional',
            'is_active' => true,
            'academic_year_id' => $this->academicYear->id,
        ]);

        Sanctum::actingAs($guru, ['*']);

        $response = $this->getJson('/api/journals/off-days');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ])
            ->assertJsonStructure([
                'status',
                'data' => [
                    'off_weekdays',
                    'holidays',
                ]
            ])
            ->assertJsonFragment([
                'name' => 'Hari Libur Nasional Test',
            ]);
    }

    public function test_guru_journals_includes_accurate_schedule_attributes(): void
    {
        $guru = User::create([
            'full_name' => 'Guru Pengampu Akurat',
            'username' => 'guru_akurat',
            'email' => 'akurat@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->guruRole->id,
            'is_active' => true,
        ]);

        $kelas = SchoolClass::create([
            'name' => 'XII IPA 1',
            'code' => '12-IPA-1',
            'grade_level' => 12,
            'academic_year_id' => $this->academicYear->id,
        ]);

        $mapel = Subject::create([
            'name' => 'Biologi Sel',
            'code' => 'BIO-12',
        ]);

        $schedule = Schedule::create([
            'class_id' => $kelas->id,
            'subject_id' => $mapel->id,
            'teacher_id' => $guru->id,
            'academic_year_id' => $this->academicYear->id,
            'day_of_week' => 'Senin',
            'start_time' => '07:30:00',
            'end_time' => '09:00:00',
        ]);

        Sanctum::actingAs($guru, ['*']);

        $response = $this->getJson('/api/journals/guru');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ])
            ->assertJsonFragment([
                'schedule_id' => $schedule->id,
                'subject_id' => $mapel->id,
                'class_id' => $kelas->id,
                'class_name' => '12 XII IPA 1',
            ]);
    }

    public function test_guru_can_publish_journal_with_task_and_attachment(): void
    {
        \Illuminate\Support\Facades\Storage::fake('public');

        $guru = User::create([
            'full_name' => 'Guru Penulis Jurnal',
            'username' => 'guru_jurnal_test',
            'email' => 'terbit@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->guruRole->id,
            'is_active' => true,
        ]);

        $kelas = SchoolClass::create([
            'name' => 'X MIPA 3',
            'code' => '10-MIPA-3',
            'grade_level' => 10,
            'academic_year_id' => $this->academicYear->id,
        ]);

        $mapel = Subject::create([
            'name' => 'Matematika Peminatan',
            'code' => 'MAT-PEM-10',
        ]);

        $schedule = Schedule::create([
            'class_id' => $kelas->id,
            'subject_id' => $mapel->id,
            'teacher_id' => $guru->id,
            'academic_year_id' => $this->academicYear->id,
            'day_of_week' => 'Monday',
            'start_time' => '07:30:00',
            'end_time' => '09:00:00',
        ]);

        Sanctum::actingAs($guru, ['*']);

        $fakeFile = \Illuminate\Http\UploadedFile::fake()->create('modul_vektor.pdf', 500, 'application/pdf');

        $payload = [
            'schedule_id' => "{$schedule->id}|2026-10-26",
            'subject_id' => $mapel->id,
            'topic_material' => 'Operasi Aljabar Vektor',
            'description' => 'Membahas konsep penjumlahan dan proyeksi vektor.',
            'has_task' => 1,
            'attachment' => $fakeFile,
        ];

        $response = $this->postJson('/api/journals/terbit', $payload);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Jurnal berhasil diterbitkan',
            ]);

        $journal = \App\Models\Journal::where('teacher_id', $guru->id)->first();
        $this->assertNotNull($journal);
        $this->assertTrue((bool)$journal->has_task);
        $this->assertNotNull($journal->attachment_url);
        $this->assertStringContainsString('/storage/journals/', $journal->attachment_url);

        // Pastikan JournalTask terbuat dan attachment tertaut
        $task = \App\Models\JournalTask::where('journal_id', $journal->id)->first();
        $this->assertNotNull($task);
        $this->assertEquals('Tugas: Operasi Aljabar Vektor', $task->title);
        $this->assertDatabaseHas('journal_task_attachments', [
            'journal_task_id' => $task->id,
            'attachment_name' => 'modul_vektor.pdf',
        ]);
    }

    public function test_assignment_api_syncs_journal_has_task(): void
    {
        $guru = User::create([
            'full_name' => 'Guru Penugasan Api',
            'username' => 'guru_assign_api',
            'email' => 'assign@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $this->guruRole->id,
            'is_active' => true,
        ]);

        $kelas = SchoolClass::create([
            'name' => 'XI IPS 1',
            'code' => '11-IPS-1',
            'grade_level' => 11,
            'academic_year_id' => $this->academicYear->id,
        ]);

        $mapel = Subject::create([
            'name' => 'Sosiologi',
            'code' => 'SOS-11',
        ]);

        $schedule = Schedule::create([
            'class_id' => $kelas->id,
            'subject_id' => $mapel->id,
            'teacher_id' => $guru->id,
            'academic_year_id' => $this->academicYear->id,
            'day_of_week' => 'Wednesday',
            'start_time' => '10:00:00',
            'end_time' => '11:30:00',
        ]);

        // Awalnya jurnal dibuat tanpa penugasan
        $journal = \App\Models\Journal::create([
            'teacher_id' => $guru->id,
            'schedule_id' => $schedule->id,
            'class_id' => $kelas->id,
            'subject_id' => $mapel->id,
            'teaching_date' => '2026-10-28',
            'topic_material' => 'Stratifikasi Sosial',
            'has_task' => false,
            'status' => 'Aktif',
        ]);

        $this->assertFalse((bool)$journal->has_task);

        Sanctum::actingAs($guru, ['*']);

        // Sekarang API POST /api/assignments dipanggil untuk menginput tugas baru
        $response = $this->postJson('/api/assignments', [
            'journal_id' => $journal->id,
            'title' => 'Tugas Analisis Stratifikasi',
            'description' => 'Kerjakan lembar kerja 3.1 di buku pegangan.',
            'due_date' => '2026-11-04 23:59:59',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        // Verifikasi bahwa kolom has_task di tabel journals otomatis sinkron menjadi true
        $journal->refresh();
        $this->assertTrue((bool)$journal->has_task);
    }
}
