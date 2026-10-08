<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SchoolController extends Controller
{
    public function getGeofenceSettings()
    {
        $settings = DB::table('school_settings')
            ->whereIn('setting_key', ['geofence_lat', 'geofence_lng', 'geofence_radius'])
            ->get()->pluck('setting_value', 'setting_key');
        return response()->json($settings);
    }

    public function updateGeofenceSettings(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'radius' => 'required|numeric'
        ]);

        $settings = [
            'geofence_lat' => $request->lat,
            'geofence_lng' => $request->lng,
            'geofence_radius' => $request->radius,
        ];

        foreach ($settings as $key => $value) {
            DB::table('school_settings')->updateOrInsert(
                ['setting_key' => $key],
                ['setting_value' => $value, 'created_at' => now(), 'updated_at' => now()]
            );
        }

        return response()->json(['message' => 'Pengaturan geofence berhasil diperbarui']);
    }
}
