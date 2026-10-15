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
}
