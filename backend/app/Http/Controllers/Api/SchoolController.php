<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use App\Models\GeofenceLocation;
use App\Traits\ApiResponser;

class SchoolController extends Controller
{
    use ApiResponser;

    /**
     * Memastikan tabel geofence_locations ada dan memiliki minimal 1 titik default.
     */
    private function ensureGeofenceTable(): void
    {
        if (!Schema::hasTable('geofence_locations')) {
            Schema::create('geofence_locations', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name');
                $table->decimal('latitude', 10, 8);
                $table->decimal('longitude', 11, 8);
                $table->integer('radius_meters')->default(100);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        if (GeofenceLocation::count() === 0) {
            $settings = DB::table('school_settings')
                ->whereIn('setting_key', ['geofence_lat', 'geofence_lng', 'geofence_radius'])
                ->get()->pluck('setting_value', 'setting_key');

            GeofenceLocation::create([
                'name' => 'Kampus Utama / Gerbang Depan',
                'latitude' => (float) ($settings['geofence_lat'] ?? -6.200000),
                'longitude' => (float) ($settings['geofence_lng'] ?? 106.816666),
                'radius_meters' => (int) ($settings['geofence_radius'] ?? 100),
                'is_active' => true,
            ]);
        }
    }

    /**
     * Mengambil semua titik lokasi geofence sekolah.
     */
    public function getLocations(Request $request)
    {
        $this->ensureGeofenceTable();
        $locations = GeofenceLocation::orderBy('created_at', 'asc')->get();
        return $this->success($locations, 'Daftar titik lokasi sekolah');
    }

    /**
     * Menambahkan titik lokasi baru.
     */
    public function storeLocation(Request $request)
    {
        $this->ensureGeofenceTable();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius_meters' => 'nullable|integer|min:10|max:10000',
            'is_active' => 'nullable|boolean',
        ]);

        $location = GeofenceLocation::create([
            'name' => trim($validated['name']),
            'latitude' => (float) $validated['latitude'],
            'longitude' => (float) $validated['longitude'],
            'radius_meters' => (int) ($validated['radius_meters'] ?? 100),
            'is_active' => $request->has('is_active') ? (bool) $request->is_active : true,
        ]);

        return $this->success($location, 'Titik lokasi berhasil ditambahkan', 201);
    }

    /**
     * Memperbarui titik lokasi yang ada.
     */
    public function updateLocation(Request $request, $id)
    {
        $this->ensureGeofenceTable();

        $location = GeofenceLocation::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'latitude' => 'sometimes|required|numeric',
            'longitude' => 'sometimes|required|numeric',
            'radius_meters' => 'nullable|integer|min:10|max:10000',
            'is_active' => 'nullable|boolean',
        ]);

        if (isset($validated['name'])) {
            $validated['name'] = trim($validated['name']);
        }
        if (isset($validated['latitude'])) {
            $validated['latitude'] = (float) $validated['latitude'];
        }
        if (isset($validated['longitude'])) {
            $validated['longitude'] = (float) $validated['longitude'];
        }
        if (isset($validated['radius_meters'])) {
            $validated['radius_meters'] = (int) $validated['radius_meters'];
        }

        $location->update($validated);

        return $this->success($location, 'Titik lokasi berhasil diperbarui');
    }

    /**
     * Menghapus titik lokasi.
     */
    public function deleteLocation($id)
    {
        $this->ensureGeofenceTable();

        $location = GeofenceLocation::findOrFail($id);
        $location->delete();

        return $this->success(null, 'Titik lokasi berhasil dihapus');
    }

    /**
     * Mengubah status aktif / nonaktif titik lokasi.
     */
    public function toggleLocationStatus($id)
    {
        $this->ensureGeofenceTable();

        $location = GeofenceLocation::findOrFail($id);
        $location->is_active = !$location->is_active;
        $location->save();

        $statusStr = $location->is_active ? 'diaktifkan' : 'dinonaktifkan';
        return $this->success($location, "Titik lokasi berhasil {$statusStr}");
    }

    /**
     * Endpoint lama Geofence (backward compatibility).
     */
    public function getGeofenceSettings()
    {
        $this->ensureGeofenceTable();

        $first = GeofenceLocation::where('is_active', true)->first()
            ?? GeofenceLocation::first();

        $locations = GeofenceLocation::orderBy('created_at', 'asc')->get();

        $data = [
            'name' => (string) ($first?->name ?? 'Titik Utama Sekolah'),
            'geofence_lat' => (string) ($first?->latitude ?? '-6.200000'),
            'geofence_lng' => (string) ($first?->longitude ?? '106.816666'),
            'geofence_radius' => (string) ($first?->radius_meters ?? '100'),
            'locations' => $locations,
        ];

        return response()->json($data);
    }

    public function updateGeofenceSettings(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'radius' => 'required|numeric',
            'name' => 'nullable|string|max:255',
        ]);

        $this->ensureGeofenceTable();

        $first = GeofenceLocation::first();
        if ($first) {
            $first->update([
                'name' => $request->filled('name') ? trim($request->name) : $first->name,
                'latitude' => (float) $request->lat,
                'longitude' => (float) $request->lng,
                'radius_meters' => (int) $request->radius,
            ]);
        } else {
            GeofenceLocation::create([
                'name' => $request->filled('name') ? trim($request->name) : 'Titik Utama Sekolah',
                'latitude' => (float) $request->lat,
                'longitude' => (float) $request->lng,
                'radius_meters' => (int) $request->radius,
                'is_active' => true,
            ]);
        }

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
            'school_system_days' => 'nullable|string|in:5_DAYS,6_DAYS,CUSTOM',
            'school_off_days' => 'required|array',
            'school_off_days.*' => 'string',
        ]);

        $systemDays = $request->school_system_days ?? 'CUSTOM';

        $settings = [
            'school_system_days' => $systemDays,
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
            'message' => 'Pengaturan hari nonaktif sekolah berhasil disimpan',
            'data' => [
                'school_system_days' => $systemDays,
                'school_off_days' => $request->school_off_days,
            ]
        ]);
    }
}
