<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Attendance;
use App\Models\PresensiLog;
use App\Models\EmployeeLeave;
use Carbon\Carbon;
use App\Helpers\AppTime;
use Illuminate\Support\Str;

class AttendanceTest extends TestCase
{
    use RefreshDatabase;

    protected User $guru;
    protected User $siswa;

    protected function setUp(): void
    {
        parent::setUp();

        // Siapkan role & user Guru
        $guruRole = Role::firstOrCreate(['name' => 'GURU', 'guard_name' => 'sanctum']);
        $this->guru = User::factory()->create([
            'id' => (string) Str::uuid(),
            'name' => 'Guru Penjas',
            'email' => 'guru@anise.test',
            'role' => 'GURU',
            'has_registered_biometric' => true,
        ]);

        // Siapkan user Siswa
        $this->siswa = User::factory()->create([
            'id' => (string) Str::uuid(),
            'name' => 'Siswa Pintar',
            'email' => 'siswa@anise.test',
            'role' => 'SISWA',
            'has_registered_biometric' => true,
        ]);
    }

    /**
     * Test pengambilan riwayat & rekap presensi Tenaga Pendidik.
     */
    public function test_get_riwayat_presensi_tenaga_pendidik(): void
    {
        Attendance::create([
            'user_id' => $this->guru->id,
            'tanggal' => Carbon::now()->format('Y-m-d'),
            'jam_masuk' => Carbon::now()->format('Y-m-d 06:45:00'),
            'status' => 'H',
        ]);

        $response = $this->actingAs($this->guru)
            ->getJson('/api/attendance');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'month',
                'year',
                'user_type',
                'summary' => [
                    'hadir',
                    'terlambat',
                    'tidak_absen_masuk',
                    'tidak_absen_pulang',
                    'pulang_awal',
                    'kembali',
                    'kwk_jam',
                    'sakit',
                    'cuti',
                    'alpha',
                ],
                'logs',
            ]);

        $this->assertEquals('TENAGA_PENDIDIK', $response->json('user_type'));
        $this->assertEquals(1, $response->json('summary.hadir'));
    }

    /**
     * Test aturan penolakan presensi sebelum jam 06:00 WIB.
     */
    public function test_presensi_cam_rejected_before_06_am(): void
    {
        // Mock waktu server ke pukul 05:30:00
        AppTime::travel('2026-10-30 05:30:00');

        $response = $this->actingAs($this->guru)
            ->postJson('/api/attendance/check-in-cam', [
                'lat' => -6.200000,
                'lng' => 106.816666,
                'face_embedding' => array_fill(0, 128, 0.05),
            ]);

        // Harus ditolak dengan HTTP 400
        $response->assertStatus(400);
        $this->assertStringContainsString('Presensi belum dibuka', $response->json('message'));

        AppTime::reset();
    }
}
