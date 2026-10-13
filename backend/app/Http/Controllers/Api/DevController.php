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
