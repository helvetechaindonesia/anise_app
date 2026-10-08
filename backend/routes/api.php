<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\JournalController;
use App\Http\Controllers\Api\HabitController;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\CounselingController;
use App\Http\Controllers\Api\ExcelParserController;
use App\Http\Controllers\Api\ExcelParserUserController;
use App\Http\Controllers\Api\ExcelParserKurikulumController;

use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SchoolController;
use App\Http\Controllers\Api\CurriculumController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\LeaveController;
use App\Http\Controllers\Api\DisciplineController;
use App\Http\Controllers\Api\HelpdeskController;

use App\Http\Controllers\Api\AssessmentController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\AnnouncementController;
use App\Http\Controllers\Api\KpiController;
use App\Http\Controllers\Api\PointController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\LegalController;
use App\Http\Controllers\Api\SupportController;
use App\Http\Controllers\Api\DevController;

// ==========================================
// 1. AUTHENTICATION & RBAC
// ==========================================
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/profile', [AuthController::class, 'updateProfile']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    
    // ==========================================
    // 2. PRESENSI (ATTENDANCE)
    // ==========================================
    Route::prefix('attendance')->group(function () {
        Route::get('/', [AttendanceController::class, 'getRiwayatPresensi']);
        Route::post('/check-in-cam', [AttendanceController::class, 'submitPresensiCam']);
        Route::post('/biometric/register', [AttendanceController::class, 'registerBiometric']);
        Route::post('/laporan-telat', [AttendanceController::class, 'submitLaporanTelat']); // Bisa dipakai Guru/Satpam
    });

    // ==========================================
    // 3. PERIZINAN & DISPENSASI (LEAVES)
    // ==========================================
    Route::prefix('leaves')->group(function () {
        Route::get('/', [LeaveController::class, 'getStudentLeaves']); // TU/Guru lihat semua
        Route::post('/', [LeaveController::class, 'submitStudentLeave']); // Siswa submit
    });

    // ==========================================
    // 4. JURNAL MENGAJAR
    // ==========================================
    Route::prefix('journals')->group(function () {
        Route::middleware('role:GURU')->group(function () {
            Route::get('/schedules', [JournalController::class, 'mySchedules']);
            Route::get('/guru', [JournalController::class, 'getGuruJournals']);
            Route::get('/terbit-options', [JournalController::class, 'getTerbitOptions']);
            Route::post('/terbit', [JournalController::class, 'store']);
            Route::post('/', [JournalController::class, 'submitJournal']);
            Route::get('/by-subject/{subjectId}', [JournalController::class, 'getJournalsBySubject']);
        });
        Route::middleware('role:SISWA')->group(function () {
            Route::get('/siswa', [JournalController::class, 'getSiswaJournals']);
        });
    });

    // ==========================================
    // 5. PENUGASAN (ASSIGNMENTS)
    // ==========================================
    Route::prefix('assignments')->group(function () {
        Route::middleware('role:GURU')->group(function () {
            Route::post('/', [AssignmentController::class, 'storeTask']);
            Route::get('/', [AssignmentController::class, 'getTasks']);
        });
        Route::middleware('role:SISWA')->group(function () {
            Route::get('/siswa', [AssignmentController::class, 'getSiswaTasks']);
        });
    });

    // ==========================================
    // 7. G7 KAIH (HABITS)
    // ==========================================
    Route::prefix('g7kaih')->group(function () {
        Route::get('/stats', [HabitController::class, 'getHabitStats']);
        Route::get('/guru-stats', [HabitController::class, 'guruHabitStats']);
        Route::middleware('role:GURU')->get('/pending', [HabitController::class, 'pendingLogs']);
        Route::middleware('role:GURU,GURU_BK')->get('/monitored-students', [HabitController::class, 'monitoredStudents']);
        Route::middleware('role:SISWA')->group(function () {
            Route::get('/', [HabitController::class, 'masterHabits']);
            Route::post('/log', [HabitController::class, 'submitLog']);
        });
    });

    // ==========================================
    // 8. HELPDESK & PENGADUAN
    // ==========================================
    Route::prefix('helpdesk')->group(function () {
        Route::middleware('role:SISWA')->post('/', [HelpdeskController::class, 'submitStudentReport']);
        Route::middleware('role:TATA_USAHA')->get('/all', [HelpdeskController::class, 'getStudentReports']);
    });

    // ==========================================
    // 9. KEDISIPLINAN
    // ==========================================
    Route::prefix('discipline')->group(function () {
        Route::middleware('role:GURU')->group(function () {
            Route::post('/reports', [DisciplineController::class, 'submitDisiplinReport']);
            Route::get('/reports', [DisciplineController::class, 'getDisiplinReports']);
        });
    });

    // ==========================================
    // 10. BIMBINGAN KONSELING (BK)
    // ==========================================
    Route::prefix('counseling')->group(function () {
        Route::middleware('role:SISWA')->group(function () {
            Route::get('/guru-bk', [CounselingController::class, 'getGuruBk']);
            Route::post('/', [CounselingController::class, 'store']);
            Route::get('/siswa', [CounselingController::class, 'siswaIndex']);
        });
        Route::middleware('role:GURU_BK')->group(function () {
            Route::get('/requests', [CounselingController::class, 'guruBkIndex']);
            Route::put('/{id}/status', [CounselingController::class, 'updateStatus']);
        });
    });

    // ==========================================
    // 13. KURIKULUM (MASTER DATA)
    // ==========================================
    Route::prefix('curriculum')->middleware('role:TATA_USAHA')->group(function () {
        Route::get('/classes', [CurriculumController::class, 'getClasses']);
        Route::put('/classes/{id}', [CurriculumController::class, 'updateClass']);
        Route::delete('/classes/{id}', [CurriculumController::class, 'deleteClass']);
        
        Route::get('/subjects', [CurriculumController::class, 'getSubjects']);
        Route::delete('/subjects/{id}', [CurriculumController::class, 'deleteSubject']);
        
        Route::get('/schedules', [CurriculumController::class, 'getSchedules']);
        Route::delete('/schedules/{id}', [CurriculumController::class, 'deleteSchedule']);
        
        Route::get('/assignments', [CurriculumController::class, 'getStructuralAssignments']);
        Route::delete('/assignments/{id}', [CurriculumController::class, 'deleteStructuralAssignment']);
        
        // Excel Parser (TBD)
        Route::post('/parse/{type}', [ExcelParserKurikulumController::class, 'parseKurikulum']);
    });

    // ==========================================
    // 14. MANAJEMEN USER
    // ==========================================
    Route::prefix('users')->group(function () {
        // Master Data Users & Roles (TU Only)
        Route::middleware('role:TATA_USAHA')->group(function () {
            Route::get('/', [UserController::class, 'getUsers']);
            Route::post('/', [UserController::class, 'storeUser']);
            Route::put('/{id}', [UserController::class, 'updateUser']);
            Route::delete('/{id}', [UserController::class, 'deleteUser']);
            Route::put('/{id}/freeze', [UserController::class, 'freezeUser']);
            
            Route::get('/roles', [UserController::class, 'getRoles']);
            Route::put('/roles/{id}', [UserController::class, 'updateRole']);
            
            Route::get('/jabatans', [UserController::class, 'getJabatans']);
            Route::put('/jabatans/{id}', [UserController::class, 'updateJabatan']);
            
            Route::get('/wali-kelas', [UserController::class, 'getWaliKelas']);
            Route::get('/guru-wali', [UserController::class, 'getGuruWali']);

            // Parsers
            Route::post('/parse/role', [ExcelParserController::class, 'parseMasterRole']);
            Route::post('/parse/kelas', [ExcelParserController::class, 'parseMasterKelas']);
            Route::post('/parse/jabatan', [ExcelParserController::class, 'parseMasterJabatan']);
            Route::post('/parse/{type}', [ExcelParserUserController::class, 'parseUser']);
        });

        // Global access
        Route::get('/siswa/search', [UserController::class, 'searchSiswa']);
        Route::get('/siswa/all', [UserController::class, 'getAllSiswa']);
        Route::get('/siswa/teachers', [JournalController::class, 'getSiswaTeachers']); // from journal
        
        // Files
        Route::post('/files/upload', [UserController::class, 'uploadFile']);
        Route::get('/files', [UserController::class, 'getUserFiles']);
    });

    // ==========================================
    // 15. MANAJEMEN SEKOLAH
    // ==========================================
    Route::prefix('school')->middleware('role:TATA_USAHA')->group(function () {
        Route::get('/geofence', [SchoolController::class, 'getGeofenceSettings']);
        Route::post('/geofence', [SchoolController::class, 'updateGeofenceSettings']);
    });

    // ==========================================
    // 6. AGENDA PENILAIAN & RAPORT (Modul 6)
    // ==========================================
    Route::prefix('assessments')->group(function () {
        Route::get('/', [AssessmentController::class, 'getAgendas']);
        Route::post('/', [AssessmentController::class, 'storeAgenda']);
        Route::post('/{id}/scores', [AssessmentController::class, 'storeScores']);
    });

    // ==========================================
    // 11. SURAT MENYURAT
    // ==========================================
    Route::prefix('letters')->group(function () {
        Route::get('/incoming', [LetterController::class, 'getIncomingLetters']);
        Route::get('/outgoing', [LetterController::class, 'getOutgoingLetters']);
        Route::post('/outgoing', [LetterController::class, 'storeOutgoingLetter']);
    });

    // ==========================================
    // 12. SARPRAS (INVENTARIS)
    // ==========================================
    Route::prefix('inventory')->group(function () {
        Route::get('/items', [InventoryController::class, 'getItems']);
        Route::get('/loans', [InventoryController::class, 'getLoans']);
        Route::post('/loans', [InventoryController::class, 'requestLoan']);
        Route::put('/loans/{id}/return', [InventoryController::class, 'returnLoan']);
    });

    // ==========================================
    // 16. HUMAS & PENGUMUMAN
    // ==========================================
    Route::prefix('announcements')->group(function () {
        Route::get('/', [AnnouncementController::class, 'getAnnouncements']);
        Route::post('/', [AnnouncementController::class, 'storeAnnouncement']);
        Route::put('/{id}/read', [AnnouncementController::class, 'markAsRead']);
    });

    // ==========================================
    // 17A. KPI TENDIK
    // ==========================================
    Route::prefix('kpi')->group(function () {
        Route::get('/analysis', [KpiController::class, 'getAnalysis']);
        Route::get('/reports', [KpiController::class, 'getReports']);
        Route::get('/evaluations', [KpiController::class, 'getEvaluations']);
        Route::post('/evaluations', [KpiController::class, 'storeEvaluations']);
    });

    // ==========================================
    // 17B. POIN KEDISIPLINAN SISWA
    // ==========================================
    Route::prefix('points')->group(function () {
        Route::get('/balance', [PointController::class, 'getBalance']);
        Route::get('/rules', [PointController::class, 'getRules']);
        Route::get('/history', [PointController::class, 'getHistory']);
    });

    // ==========================================
    // 18. NOTIFIKASI
    // ==========================================
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'getNotifications']);
        Route::put('/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::put('/{id}/read', [NotificationController::class, 'markAsRead']);
    });

    // ==========================================
    // 19. PRIVACY & LEGAL
    // ==========================================
    Route::prefix('legal')->group(function () {
        Route::get('/{document_type}', [LegalController::class, 'getDocument']);
        Route::post('/consent', [LegalController::class, 'submitConsent']);
    });

    // ==========================================
    // 20. BANTUAN & KEAMANAN
    // ==========================================
    Route::prefix('support')->group(function () {
        Route::get('/faqs', [SupportController::class, 'getFaqs']);
        Route::get('/security-logs', [SupportController::class, 'getSecurityLogs']);
    });

    // ==========================================
    // 21. DEVELOPER MODE
    // ==========================================
    Route::prefix('dev')->group(function () {
        Route::get('/logs', [DevController::class, 'getLogs']);
        Route::post('/cache/clear', [DevController::class, 'clearCache']);
        Route::post('/impersonate/{user_id}', [DevController::class, 'impersonate']);
    });

});
