<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\SchoolHoliday;
use Laravel\Sanctum\Sanctum;

class HolidayTest extends TestCase
{
    use RefreshDatabase;

    protected User $tuUser;

    protected function setUp(): void
    {
        parent::setUp();

        $tuRole = Role::create(['name' => 'TATA_USAHA']);
        $this->tuUser = User::create([
            'full_name' => 'Staf Tata Usaha',
            'username' => 'tu_tester',
            'email' => 'tu_test@dev.com',
            'password_hash' => bcrypt('password123'),
            'role_id' => $tuRole->id,
            'is_active' => true,
        ]);

        Sanctum::actingAs($this->tuUser);
    }

    public function test_can_list_holidays(): void
    {
        SchoolHoliday::create([
            'name' => 'Hari Kemerdekaan RI',
            'start_date' => '2026-08-17',
            'end_date' => '2026-08-17',
            'type' => 'NASIONAL',
        ]);

        $response = $this->getJson('/api/school/holidays');

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonCount(1, 'data');
    }

    public function test_can_create_holiday(): void
    {
        $payload = [
            'name' => 'Hari Raya Idul Fitri',
            'start_date' => '2026-04-01',
            'end_date' => '2026-04-03',
            'type' => 'NASIONAL',
            'description' => 'Libur Hari Raya Idul Fitri 1448 H',
        ];

        $response = $this->postJson('/api/school/holidays', $payload);

        $response->assertStatus(201)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonPath('data.name', 'Hari Raya Idul Fitri');

        $this->assertDatabaseHas('holidays', [
            'name' => 'Hari Raya Idul Fitri',
        ]);
    }

    public function test_can_update_holiday(): void
    {
        $holiday = SchoolHoliday::create([
            'name' => 'Libur Semester Awal',
            'start_date' => '2026-12-20',
            'end_date' => '2026-12-25',
            'type' => 'SEKOLAH',
        ]);

        $response = $this->putJson("/api/school/holidays/{$holiday->id}", [
            'name' => 'Libur Semester Ganjil Revisi',
        ]);

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success')
                 ->assertJsonPath('data.name', 'Libur Semester Ganjil Revisi');
    }

    public function test_can_delete_holiday(): void
    {
        $holiday = SchoolHoliday::create([
            'name' => 'Libur Uji Coba',
            'start_date' => '2026-09-01',
            'end_date' => '2026-09-01',
            'type' => 'KHUSUS',
        ]);

        $response = $this->deleteJson("/api/school/holidays/{$holiday->id}");

        $response->assertStatus(200)
                 ->assertJsonPath('status', 'success');

        $this->assertDatabaseMissing('holidays', [
            'id' => $holiday->id,
        ]);
    }

    public function test_can_check_if_date_is_holiday(): void
    {
        SchoolHoliday::create([
            'name' => 'Tahun Baru',
            'start_date' => '2027-01-01',
            'end_date' => '2027-01-01',
            'type' => 'NASIONAL',
        ]);

        $response = $this->getJson('/api/school/holidays-check?date=2027-01-01');

        $response->assertStatus(200)
                 ->assertJsonPath('data.is_holiday', true)
                 ->assertJsonPath('data.holiday.name', 'Tahun Baru');
    }
}
