<?php

namespace App\Services;

use App\Models\GeofenceLocation;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class GeofenceService
{
    /**
     * Memverifikasi apakah koordinat pengguna berada dalam radius sekolah/lokasi presensi aktif.
     *
     * @param float $userLat
     * @param float $userLng
     * @return array [ 'is_inside' => bool, 'distance_meters' => float, 'closest_name' => string, 'message' => string|null ]
     */
    public function verifyCoordinates(float $userLat, float $userLng): array
    {
        $earthRadius = 6371000; // Radius bumi dalam meter
        $latFrom = deg2rad($userLat);
        $lonFrom = deg2rad($userLng);

        $hasMatched = false;
        $minDistance = null;
        $closestName = '';

        // 1. Cek tabel geofence_locations jika ada
        if (Schema::hasTable('geofence_locations')) {
            $activeLocations = GeofenceLocation::where('is_active', true)->get();
            if ($activeLocations->isNotEmpty()) {
                foreach ($activeLocations as $loc) {
                    $latTo = deg2rad($loc->latitude);
                    $lonTo = deg2rad($loc->longitude);
                    $latDelta = $latTo - $latFrom;
                    $lonDelta = $lonTo - $lonFrom;
                    $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
                    $distance = $angle * $earthRadius;

                    if ($minDistance === null || $distance < $minDistance) {
                        $minDistance = $distance;
                        $closestName = $loc->name;
                    }

                    if ($distance <= $loc->radius_meters) {
                        $hasMatched = true;
                        break;
                    }
                }

                if (!$hasMatched) {
                    return [
                        'is_inside' => false,
                        'distance_meters' => round($minDistance ?? 0),
                        'closest_name' => $closestName,
                        'message' => 'Presensi ditolak! Anda berada di luar radius lokasi sekolah (' . round($minDistance ?? 0) . ' meter dari ' . $closestName . ').'
                    ];
                }

                return [
                    'is_inside' => true,
                    'distance_meters' => round($minDistance ?? 0),
                    'closest_name' => $closestName,
                    'message' => null
                ];
            }
        }

        // 2. Fallback ke school_settings jika geofence_locations belum dikonfigurasi
        $settings = DB::table('school_settings')
            ->whereIn('setting_key', ['geofence_lat', 'geofence_lng', 'geofence_radius'])
            ->get()
            ->pluck('setting_value', 'setting_key');

        $schoolLat = $settings['geofence_lat'] ?? null;
        $schoolLng = $settings['geofence_lng'] ?? null;
        $radius = (float) ($settings['geofence_radius'] ?? 50);

        if ($schoolLat && $schoolLng) {
            $latTo = deg2rad((float)$schoolLat);
            $lonTo = deg2rad((float)$schoolLng);
            $latDelta = $latTo - $latFrom;
            $lonDelta = $lonTo - $lonFrom;
            $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
            $distance = $angle * $earthRadius;

            if ($distance > $radius) {
                return [
                    'is_inside' => false,
                    'distance_meters' => round($distance),
                    'closest_name' => 'Pusat Sekolah',
                    'message' => 'Presensi ditolak! Anda berada di luar radius sekolah (' . round($distance) . ' meter dari pusat).'
                ];
            }

            return [
                'is_inside' => true,
                'distance_meters' => round($distance),
                'closest_name' => 'Pusat Sekolah',
                'message' => null
            ];
        }

        // Default: jika tidak ada setting geofence sama sekali, izinkan (dev/testing mode)
        return [
            'is_inside' => true,
            'distance_meters' => 0,
            'closest_name' => 'Lokasi Terdaftar',
            'message' => null
        ];
    }

    /**
     * Mengambil nama lokasi geofence utama atau fallback dari setting sekolah.
     */
    public function getPrimaryLocationName(): string
    {
        if (Schema::hasTable('geofence_locations')) {
            $first = GeofenceLocation::where('is_active', true)->orderBy('created_at', 'asc')->first();
            if ($first && !empty($first->name)) {
                return $first->name;
            }
        }

        $settingName = DB::table('school_settings')->where('setting_key', 'school_name')->value('setting_value');
        if (!empty($settingName)) {
            return $settingName;
        }

        return 'Kampus Utama / Gerbang Depan';
    }

    /**
     * Mencari nama lokasi geofence terdekat dari koordinat lat & lng.
     */
    public function findClosestLocationName(?float $lat, ?float $lng): string
    {
        if ($lat === null || $lng === null) {
            return $this->getPrimaryLocationName();
        }

        $res = $this->verifyCoordinates((float)$lat, (float)$lng);
        return !empty($res['closest_name']) ? $res['closest_name'] : $this->getPrimaryLocationName();
    }
}
