<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\Artisan;

class DevController extends Controller
{
    use ApiResponser;

    public function getLogs(Request $request)
    {
        return $this->success(['logs' => '']);
    }

    public function clearCache(Request $request)
    {
        Artisan::call('optimize:clear');
        return $this->success(null, 'Cache cleared');
    }

    public function impersonate(Request $request, $user_id)
    {
        return $this->success(null, 'Impersonating user ' . $user_id);
    }

    public function seedHomeData(Request $request)
    {
        try {
            $seeder = new \Database\Seeders\HomeSiswaSeeder();
            $seeder->run();
            return $this->success(null, 'Data asli Home Siswa (7 Guru Pengajar, 5 Tugas Aktif, dan Riwayat Presensi Lengkap) berhasil disuntikkan ke database!');
        } catch (\Throwable $e) {
            return $this->error('Gagal menyuntikkan data: ' . $e->getMessage(), 500);
        }
    }

    public function resetClean(Request $request)
    {
        try {
            Artisan::call('migrate:fresh', [
                '--seed' => true,
                '--force' => true,
            ]);
            return $this->success(null, 'Platform berhasil di-reset bersih! Database segar dengan tepat 1 user: tu@dev.com (password: dev123).');
        } catch (\Throwable $e) {
            return $this->error('Gagal reset database: ' . $e->getMessage(), 500);
        }
    }

    public function clearPresensi(Request $request)
    {
        try {
            \Illuminate\Support\Facades\DB::table('presensi_logs')->delete();
            \Illuminate\Support\Facades\DB::table('attendances')->delete();
            return $this->success(null, 'Seluruh riwayat presensi (attendances & presensi_logs) berhasil dikosongkan!');
        } catch (\Throwable $e) {
            return $this->error('Gagal mengosongkan presensi: ' . $e->getMessage(), 500);
        }
    }

    public function statusPresensi(Request $request)
    {
        $appTime = \App\Helpers\AppTime::now();
        $realTime = \Carbon\Carbon::now();
        $mockCache = \Illuminate\Support\Facades\Cache::get('app_mock_time');
        $mockFile = file_exists(storage_path('app/mock_time.txt')) ? trim(file_get_contents(storage_path('app/mock_time.txt'))) : null;

        $latestAttendances = \App\Models\Attendance::latest()->take(5)->get();
        $latestLogs = \App\Models\PresensiLog::latest()->take(5)->get();

        $activeUserId = $latestAttendances->first()?->user_id;
        $activeUser = $activeUserId ? \App\Models\User::find($activeUserId) : null;
        $activeRoleName = $activeUser && $activeUser->role ? $activeUser->role->name : ($activeUser ? $activeUser->role_type : 'NONE');

        // Cari semua user dengan nama mirip
        $matchedUsers = \App\Models\User::where('full_name', 'like', '%Afrida%')
            ->orWhere('full_name', 'like', '%Safrida%')
            ->get()
            ->map(fn($u) => [
                'id' => $u->id,
                'name' => $u->full_name,
                'email' => $u->email,
                'role_id' => $u->role_id,
                'role_type' => $u->role_type,
                'role_name' => $u->role?->name,
            ]);

        return response()->json([
            'status' => 'OK',
            'time_info' => [
                'effective_app_time' => $appTime->toDateTimeString(),
                'real_system_time' => $realTime->toDateTimeString(),
                'mock_time_cache' => $mockCache,
                'mock_time_file' => $mockFile,
            ],
            'actual_attendance_user' => [
                'id' => $activeUser?->id,
                'name' => $activeUser?->full_name,
                'email' => $activeUser?->email,
                'role_id' => $activeUser?->role_id,
                'role_type' => $activeUser?->role_type,
                'resolved_role_name' => $activeRoleName,
            ],
            'matched_users_afrida' => $matchedUsers,
            'latest_attendances_table' => $latestAttendances,
            'latest_presensi_logs_table' => $latestLogs,
        ]);
    }

    public function getContact(Request $request)
    {
        $developer = \App\Models\Developer::first();

        if (!$developer) {
            $developer = (object) [
                'name' => 'Helvetecha Group',
                'email' => 'Helvetechaindonesia@gmail.com',
                'phone' => '081931315944',
            ];
        }

        $cleanPhone = preg_replace('/[^0-9]/', '', $developer->phone);
        if (str_starts_with($cleanPhone, '0')) {
            $cleanPhone = '62' . substr($cleanPhone, 1);
        }

        $waUrl = 'https://wa.me/' . $cleanPhone . '?text=' . urlencode('Halo Tim Developer Helvetecha, saya butuh bantuan terkait aplikasi Anise.');

        return $this->success([
            'name' => $developer->name,
            'email' => $developer->email,
            'phone' => $developer->phone,
            'whatsapp_phone' => $cleanPhone,
            'whatsapp_url' => $waUrl,
        ], 'Kontak developer berhasil diambil');
    }
}
