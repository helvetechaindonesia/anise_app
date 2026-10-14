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

        $data = [
            'geofence_lat' => (string) ($settings['geofence_lat'] ?? '-6.200000'),
            'geofence_lng' => (string) ($settings['geofence_lng'] ?? '106.816666'),
            'geofence_radius' => (string) ($settings['geofence_radius'] ?? '100'),
        ];

        return response()->json($data);
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

    public function getOperationalSettings()
    {
        $settings = DB::table('school_settings')
            ->whereIn('setting_key', ['school_system_days', 'school_off_days'])
            ->get()->pluck('setting_value', 'setting_key');

        $systemDays = $settings['school_system_days'] ?? '5_DAYS';
        $rawOff = $settings['school_off_days'] ?? null;
        $offDays = $rawOff ? json_decode($rawOff, true) : ['SATURDAY', 'SUNDAY'];
        if (!is_array($offDays)) {
            $offDays = ['SATURDAY', 'SUNDAY'];
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'school_system_days' => $systemDays,
                'school_off_days' => $offDays,
            ]
        ]);
    }

    public function updateOperationalSettings(Request $request)
    {
        $request->validate([
            'school_system_days' => 'required|string|in:5_DAYS,6_DAYS,CUSTOM',
            'school_off_days' => 'required|array',
            'school_off_days.*' => 'string',
        ]);

        $settings = [
            'school_system_days' => $request->school_system_days,
            'school_off_days' => json_encode($request->school_off_days),
        ];

        foreach ($settings as $key => $value) {
            DB::table('school_settings')->updateOrInsert(
                ['setting_key' => $key],
                ['setting_value' => $value, 'created_at' => now(), 'updated_at' => now()]
            );
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Pengaturan hari libur rutin sekolah berhasil disimpan',
            'data' => [
                'school_system_days' => $request->school_system_days,
                'school_off_days' => $request->school_off_days,
            ]
        ]);
    }
}
