<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\AcademicYear;
use App\Models\AcademicCalendar;
use Laravel\Sanctum\Sanctum;

class AcademicCalendarTest extends TestCase
{
    use RefreshDatabase;

    protected User $tuUser;
    protected AcademicYear $academicYear;

    protected function setUp(): void
    {
        parent::setUp();

        $tuRole = Role::create(['name' => 'TATA_USAHA']);
        $this->tuUser = User::create([
            'full_name' => 'Staf Tata Usaha',
            'username' => 'tu_kurikulum_tester',
            'email' => 'tu_kurikulum@dev.com',
            'password_hash' => bcrypt('password123'),
            'role_id' => $tuRole->id,
            'is_active' => true,
        ]);

        $this->academicYear = AcademicYear::create([
            'name' => '2026/2027 Ganjil',
            'semester' => 'GANJIL',
            'is_active' => true,
            'start_date' => '2026-07-01',
            'end_date' => '2026-12-31',
        ]);

        Sanctum::actingAs($this->tuUser);
    }

    public function test_can_list_academic_calendars(): void
    {
        AcademicCalendar::create([
            'academic_year_id' => $this->academicYear->id,
            'name' => 'Penilaian Tengah Semester (PTS) Ganjil',
            'start_date' => '2026-09-20',
            'end_date' => '2026-09-25',
            'is_holiday' => false,
        ]);

        $response = $this->getJson('/api/curriculum/academic-calendars');

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonCount(1, 'data');
    }

    public function test_can_create_academic_calendar(): void
    {
        $payload = [
            'name' => 'Penilaian Akhir Semester (PAS) Ganjil',
            'start_date' => '2026-12-01',
            'end_date' => '2026-12-10',
            'is_holiday' => false,
            'academic_year_id' => $this->academicYear->id,
        ];

        $response = $this->postJson('/api/curriculum/academic-calendars', $payload);

        $response->assertStatus(201)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonPath('data.name', 'Penilaian Akhir Semester (PAS) Ganjil');

        $this->assertDatabaseHas('academic_calendars', [
            'name' => 'Penilaian Akhir Semester (PAS) Ganjil',
        ]);
    }

    public function test_can_update_academic_calendar(): void
    {
        $calendar = AcademicCalendar::create([
            'academic_year_id' => $this->academicYear->id,
            'name' => 'Agenda Awal',
            'start_date' => '2026-10-01',
            'end_date' => '2026-10-03',
            'is_holiday' => false,
        ]);

        $response = $this->putJson("/api/curriculum/academic-calendars/{$calendar->id}", [
            'name' => 'Agenda Revisi Porseni',
        ]);

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonPath('data.name', 'Agenda Revisi Porseni');
    }

    public function test_can_delete_academic_calendar(): void
    {
        $calendar = AcademicCalendar::create([
            'academic_year_id' => $this->academicYear->id,
            'name' => 'Agenda Dihapus',
            'start_date' => '2026-11-01',
            'end_date' => '2026-11-02',
            'is_holiday' => false,
        ]);

        $response = $this->deleteJson("/api/curriculum/academic-calendars/{$calendar->id}");

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success');

        $this->assertDatabaseMissing('academic_calendars', [
            'id' => $calendar->id,
        ]);
    }

    public function test_can_create_academic_calendar_with_type_and_target_grade(): void
    {
        $payload = [
            'name' => 'Pelaksanaan ANBK Utama',
            'type' => 'ASESMEN',
            'start_date' => '2026-10-01',
            'end_date' => '2026-10-04',
            'target_grade' => 'XI',
            'is_holiday' => false,
            'academic_year_id' => $this->academicYear->id,
        ];

        $response = $this->postJson('/api/curriculum/academic-calendars', $payload);

        $response->assertStatus(201)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonPath('data.type', 'ASESMEN')
                 ->assertJsonPath('data.target_grade', 'XI');

        $this->assertDatabaseHas('academic_calendars', [
            'name' => 'Pelaksanaan ANBK Utama',
            'type' => 'ASESMEN',
            'target_grade' => 'XI',
        ]);
    }

    public function test_can_parse_kalender_akademik_real_excel(): void
    {
        $filePath = base_path('../master-file/Master_Kalender_Akademik.xlsx');
        if (!file_exists($filePath)) {
            $this->markTestSkipped('File master_kalender_akademik tidak ditemukan');
        }

        $uploadedFile = new \Illuminate\Http\UploadedFile(
            $filePath,
            'Master_Kalender_Akademik.xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            null,
            true
        );

        $response = $this->postJson('/api/curriculum/parse/kalender_akademik', [
            'file' => $uploadedFile,
        ]);

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success');

        $this->assertDatabaseHas('academic_calendars', [
            'name' => 'Peringatan Hari Sumpah Pemuda & Bulan Bahasa',
            'type' => 'SEREMONIAL',
            'target_grade' => 'SEMUA',
        ]);

        $this->assertDatabaseHas('academic_calendars', [
            'name' => 'Penilaian / Sumatif Akhir Semester (PAS/SAS) Ganjil',
            'type' => 'ASESMEN',
        ]);
    }

    public function test_can_parse_hari_libur_real_excel(): void
    {
        $filePath = base_path('../master-file/Master_Libur.xlsx');
        if (!file_exists($filePath)) {
            $this->markTestSkipped('File master_libur tidak ditemukan');
        }

        $uploadedFile = new \Illuminate\Http\UploadedFile(
            $filePath,
            'Master_Libur.xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            null,
            true
        );

        $response = $this->postJson('/api/curriculum/parse/hari_libur', [
            'file' => $uploadedFile,
        ]);

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success');

        $this->assertDatabaseHas('holidays', [
            'name' => 'Hari Raya Natal',
            'type' => 'NASIONAL',
        ]);

        $this->assertDatabaseHas('holidays', [
            'name' => 'Libur Akhir Semester Ganjil',
            'type' => 'SEKOLAH',
        ]);
    }

    public function test_can_create_academic_calendar_with_multi_grade_plus(): void
    {
        $payload = [
            'name' => 'Simulasi Bersama ANBK',
            'type' => 'ASESMEN',
            'start_date' => '2026-10-15',
            'end_date' => '2026-10-17',
            'target_grade' => 'X + XI',
            'is_holiday' => false,
            'academic_year_id' => $this->academicYear->id,
        ];

        $response = $this->postJson('/api/curriculum/academic-calendars', $payload);

        $response->assertStatus(201)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonPath('data.target_grade', 'X + XI');

        $this->assertDatabaseHas('academic_calendars', [
            'name' => 'Simulasi Bersama ANBK',
            'target_grade' => 'X + XI',
        ]);
    }

    public function test_can_create_holiday_with_single_waktu(): void
    {
        $payload = [
            'name' => 'Hari Libur Isra Miraj',
            'start_date' => '2026-02-15',
            'type' => 'NASIONAL',
        ];

        $response = $this->postJson('/api/curriculum/holidays', $payload);

        $response->assertStatus(201)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonPath('data.end_date', '2026-02-15');

        $this->assertDatabaseHas('holidays', [
            'name' => 'Hari Libur Isra Miraj',
            'start_date' => '2026-02-15',
            'end_date' => '2026-02-15',
        ]);
    }
}
