<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;

Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function () {
    Route::get('/habits/stats', [HabitController::class, 'getHabitStats']);
    Route::get('/habits/guru-stats', [HabitController::class, 'guruHabitStats']);

        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/profile', [AuthController::class, 'updateProfile']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/files/upload', [\App\Http\Controllers\Api\MasterDataController::class, 'uploadFile']);
        Route::get('/files', [\App\Http\Controllers\Api\MasterDataController::class, 'getUserFiles']);
    Route::post('/users/presensi-cam', [\App\Http\Controllers\Api\MasterDataController::class, 'submitPresensiCam']);
    Route::post('/users/biometric/register', [\App\Http\Controllers\Api\MasterDataController::class, 'registerBiometric']);
    });
});

// Example route using CheckRole middleware
Route::middleware(['auth:sanctum', 'role:TATA_USAHA,KEPALA_SEKOLAH'])->group(function () {
    Route::get('/admin/dashboard', function() {
        return response()->json(['message' => 'Admin access granted']);
    });
});

use App\Http\Controllers\Api\JournalController;
use App\Http\Controllers\Api\HabitController;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/habits/stats', [HabitController::class, 'getHabitStats']);
    Route::get('/habits/guru-stats', [HabitController::class, 'guruHabitStats']);

    // Guru Routes
    Route::middleware('role:GURU')->group(function () {
        Route::get('/journals/schedules', [JournalController::class, 'mySchedules']);
        Route::get('/journals/guru', [JournalController::class, 'getGuruJournals']);
        Route::get('/journals/terbit-options', [JournalController::class, 'getTerbitOptions']);
        Route::post('/journals/terbit', [JournalController::class, 'store']);
        Route::post('/journals', [JournalController::class, 'submitJournal']);
        Route::get('/journals/by-subject/{subjectId}', [JournalController::class, 'getJournalsBySubject']);
        Route::post('/tasks', [JournalController::class, 'storeTask']);
        Route::get('/tasks', [JournalController::class, 'getTasks']);
        
        Route::get('/habits/pending', [HabitController::class, 'pendingLogs']);
        
        Route::post('/users/disiplin-reports', [\App\Http\Controllers\Api\MasterDataController::class, 'submitDisiplinReport']);
        Route::get('/users/disiplin-reports', [\App\Http\Controllers\Api\MasterDataController::class, 'getDisiplinReports']);
        Route::get('/users/all-siswa', [\App\Http\Controllers\Api\MasterDataController::class, 'getAllSiswa']);
        Route::get('/users/leaves', [\App\Http\Controllers\Api\MasterDataController::class, 'getStudentLeaves']);
    });

        // Habit Routes for Guru/BK
    Route::middleware('role:GURU,GURU_BK')->group(function () {
        Route::get('/habits/monitored-students', [HabitController::class, 'monitoredStudents']);
    });

    // Siswa Routes
    Route::middleware('role:SISWA')->group(function () {
        Route::get('/users/siswa/teachers', [JournalController::class, 'getSiswaTeachers']);
        Route::get('/tasks/siswa', [JournalController::class, 'getSiswaTasks']);
        Route::post('/users/reports', [\App\Http\Controllers\Api\MasterDataController::class, 'submitStudentReport']);
        Route::get('/habits', [HabitController::class, 'masterHabits']);
        Route::get('/journals/siswa', [JournalController::class, 'getSiswaJournals']);
        Route::post('/habits/log', [HabitController::class, 'submitLog']);
        Route::post('/users/leaves', [\App\Http\Controllers\Api\MasterDataController::class, 'submitStudentLeave']);
        // Counseling (Bimbingan BK)
        Route::get('/counseling/guru-bk', [\App\Http\Controllers\Api\CounselingController::class, 'getGuruBk']);
        Route::post('/counseling', [\App\Http\Controllers\Api\CounselingController::class, 'store']);
        Route::get('/counseling/siswa', [\App\Http\Controllers\Api\CounselingController::class, 'siswaIndex']);
    });

    // Guru BK Routes
    Route::middleware('role:GURU_BK')->group(function () {
        Route::get('/counseling/guru-bk/requests', [\App\Http\Controllers\Api\CounselingController::class, 'guruBkIndex']);
        Route::put('/counseling/{id}/status', [\App\Http\Controllers\Api\CounselingController::class, 'updateStatus']);
    });

    // Tata Usaha Routes
    Route::middleware('role:TATA_USAHA')->group(function () {
        Route::get('/users/reports', [\App\Http\Controllers\Api\MasterDataController::class, 'getStudentReports']);
        Route::get('/users/leaves', [\App\Http\Controllers\Api\MasterDataController::class, 'getStudentLeaves']);
        // Master Data
        Route::get('/users/riwayat-presensi', [\App\Http\Controllers\Api\MasterDataController::class, 'getRiwayatPresensi']);
        Route::get('/users/siswa/search', [\App\Http\Controllers\Api\MasterDataController::class, 'searchSiswa']);
        Route::post('/users/laporan-telat', [\App\Http\Controllers\Api\MasterDataController::class, 'submitLaporanTelat']);
        Route::get('/master/school-settings/geofence', [\App\Http\Controllers\Api\MasterDataController::class, 'getGeofenceSettings']);
        Route::post('/master/school-settings/geofence', [\App\Http\Controllers\Api\MasterDataController::class, 'updateGeofenceSettings']);
        Route::get('/master/roles', [\App\Http\Controllers\Api\MasterDataController::class, 'getRoles']);
        Route::put('/master/roles/{id}', [\App\Http\Controllers\Api\MasterDataController::class, 'updateRole']);
        Route::get('/master/kelas', [\App\Http\Controllers\Api\MasterDataController::class, 'getKelas']);
        Route::put('/master/kelas/{id}', [\App\Http\Controllers\Api\MasterDataController::class, 'updateKelas']);
        Route::get('/master/jabatans', [\App\Http\Controllers\Api\MasterDataController::class, 'getJabatans']);
        Route::put('/master/jabatans/{id}', [\App\Http\Controllers\Api\MasterDataController::class, 'updateJabatan']);
        Route::get('/master/users', [\App\Http\Controllers\Api\MasterDataController::class, 'getUsers']);
        Route::post('/master/users', [\App\Http\Controllers\Api\MasterDataController::class, 'storeUser']);
        Route::put('/master/users/{id}', [\App\Http\Controllers\Api\MasterDataController::class, 'updateUser']);
        Route::get('/master/mapel', [\App\Http\Controllers\Api\MasterDataController::class, 'getMapel']);
        Route::get('/master/schedules', [\App\Http\Controllers\Api\MasterDataController::class, 'getSchedules']);
        Route::get('/master/penugasan', [\App\Http\Controllers\Api\MasterDataController::class, 'getPenugasan']);
        Route::get('/master/wali-kelas', [\App\Http\Controllers\Api\MasterDataController::class, 'getWaliKelas']);
        Route::get('/master/guru-wali', [\App\Http\Controllers\Api\MasterDataController::class, 'getGuruWali']);

        // Delete Endpoints
        Route::delete('/master/{type}/{id}', [\App\Http\Controllers\Api\MasterDataController::class, 'deleteMasterData']);
        // Freeze Endpoint
        Route::put('/master/users/{id}/freeze', [\App\Http\Controllers\Api\MasterDataController::class, 'freezeUser']);

        // Parser
        Route::post('/parse/master-role', [\App\Http\Controllers\Api\ExcelParserController::class, 'parseMasterRole']);
        Route::post('/parse/master-kelas', [\App\Http\Controllers\Api\ExcelParserController::class, 'parseMasterKelas']);
        Route::post('/parse/master-jabatan', [\App\Http\Controllers\Api\ExcelParserController::class, 'parseMasterJabatan']);

        // Parser User
        Route::post('/parse/user/{type}', [\App\Http\Controllers\Api\ExcelParserUserController::class, 'parseUser']);

        // Parser Kurikulum
        Route::post('/parse/kurikulum/{type}', [\App\Http\Controllers\Api\ExcelParserKurikulumController::class, 'parseKurikulum']);
    });
});

















