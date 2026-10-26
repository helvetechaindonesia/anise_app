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
use App\Http\Controllers\Api\ComplaintController;

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
use App\Http\Controllers\Api\HolidayController;

// ==========================================
// 1. AUTHENTICATION & RBAC
// ==========================================
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:forgot-password');
    Route::get('/session-status', [AuthController::class, 'sessionStatus']);
    
    Route::middleware(['auth:sanctum', 'check.session'])->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/profile', [AuthController::class, 'updateProfile']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

// ==========================================
// DEVELOPER & HELPDESK INFO (Public)
// ==========================================
Route::get('/dev/contact', [DevController::class, 'getContact']);
Route::get('/dev/status-presensi', [DevController::class, 'statusPresensi']);
Route::match(['get', 'post'], '/dev/seed-home-data', [DevController::class, 'seedHomeData']);
Route::match(['get', 'post'], '/dev/trigger-kbm-reminders', [JournalController::class, 'triggerKbmReminders']);
Route::match(['get', 'post'], '/dev/reset-clean', [DevController::class, 'resetClean']);
Route::match(['get', 'post'], '/dev/clear-presensi', [DevController::class, 'clearPresensi']);

// Export Presensi XLSX (Dapat diakses via Browser/Download Manager dengan parameter ?token=... atau Bearer Header)
Route::get('/attendance/export', [AttendanceController::class, 'exportPresensiXlsx']);

// Hari Nonaktif & Kalender Akademik Sekolah (Dapat diakses publik/authenticated)
Route::get('/journals/off-days', [JournalController::class, 'getOffDays']);

// Unduh Lampiran Berkas Jurnal (Dapat diakses semua pengguna / browser / downloader)
Route::get('/journals/{journalId}/download', [JournalController::class, 'downloadAttachment']);

// Unduh Lampiran Berkas Tugas & Jawaban Siswa (Dapat diakses semua pengguna / browser / downloader)
Route::get('/assignments/attachments/{attachmentId}/download', [AssignmentController::class, 'downloadTaskAttachment']);
Route::get('/assignments/submissions/{submissionId}/download', [AssignmentController::class, 'downloadSubmissionAttachment']);

Route::middleware(['auth:sanctum', 'check.session'])->group(function () {
    
    // ==========================================
    // 2. PRESENSI (ATTENDANCE)
    // ==========================================
    Route::prefix('attendance')->group(function () {
        Route::get('/', [AttendanceController::class, 'getRiwayatPresensi']);
        Route::get('/next-status', [AttendanceController::class, 'getNextPresensiStatus']);
        Route::get('/export', [AttendanceController::class, 'exportPresensiXlsx']);
        Route::post('/check-in-cam', [AttendanceController::class, 'submitPresensiCam']);
        Route::post('/biometric/register', [AttendanceController::class, 'registerBiometric']);
        Route::post('/laporan-telat', [AttendanceController::class, 'submitLaporanTelat']); // Bisa dipakai Guru/Satpam
    });

    // ==========================================
    // 3. PERIZINAN & DISPENSASI (LEAVES)
    // ==========================================
    Route::prefix('leaves')->group(function () {
        Route::post('/', [LeaveController::class, 'submitLeave']); // Siswa & Pegawai submit
        Route::get('/my', [LeaveController::class, 'getMyLeaves']); // Riwayat saya
        Route::get('/pending', [LeaveController::class, 'getPendingLeaves'])->middleware('role:GURU,GURU_BK,KEPALA_SEKOLAH,SUPER_ADMIN'); // Inbox Wali Kelas / Kepsek
        Route::put('/{id}/status', [LeaveController::class, 'updateLeaveStatus'])->middleware('role:GURU,GURU_BK,KEPALA_SEKOLAH,SUPER_ADMIN');
        Route::put('/{id}/confirm-return', [LeaveController::class, 'confirmReturn'])->middleware('role:GURU,GURU_BK,KEPALA_SEKOLAH,SUPER_ADMIN');
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
            Route::match(['post', 'put'], '/{journalId}/update', [JournalController::class, 'updateJournal']);
            Route::post('/', [JournalController::class, 'submitJournal']);
            Route::post('/{journalId}/check-in-cam', [JournalController::class, 'checkInCam']);
            Route::get('/{journalId}/class-students', [JournalController::class, 'getClassStudents']);
            Route::post('/{journalId}/fill', [JournalController::class, 'fillJournal']);
            Route::delete('/{journalId}', [JournalController::class, 'deleteJournal']);
            Route::get('/by-subject/{subjectId}', [JournalController::class, 'getJournalsBySubject']);
        });
        Route::get('/{journalId}/comments', [JournalController::class, 'getComments']);
        Route::delete('/{journalId}/comments/{commentId}', [JournalController::class, 'deleteComment']);
        Route::post('/{journalId}/like', [JournalController::class, 'toggleLike']);
        Route::post('/{journalId}/save', [JournalController::class, 'toggleSave']);
        Route::post('/{journalId}/comments', [JournalController::class, 'submitComment']);
        Route::get('/{journalId}/download', [JournalController::class, 'downloadAttachment']);
        Route::get('/off-days', [JournalController::class, 'getOffDays']);

        Route::middleware('role:SISWA')->group(function () {
            Route::get('/siswa', [JournalController::class, 'getSiswaJournals']);
            Route::post('/{journalId}/rate', [JournalController::class, 'submitRating']);
        });
    });

    // ==========================================
    // 5. PENUGASAN (ASSIGNMENTS)
    // ==========================================
    Route::prefix('assignments')->group(function () {
        Route::get('/attachments/{attachmentId}/download', [AssignmentController::class, 'downloadTaskAttachment']);
        Route::get('/submissions/{submissionId}/download', [AssignmentController::class, 'downloadSubmissionAttachment']);
        Route::middleware('role:SISWA')->group(function () {
            Route::get('/siswa', [AssignmentController::class, 'getSiswaTasks']);
            Route::get('/siswa/{id}', [AssignmentController::class, 'getTaskDetailForSiswa']);
            Route::post('/submit', [AssignmentController::class, 'submitTask']);
            Route::post('/{id}/request-late', [AssignmentController::class, 'requestLateSubmission']);
        });
        Route::middleware('role:GURU')->group(function () {
            Route::post('/', [AssignmentController::class, 'storeTask']);
            Route::get('/', [AssignmentController::class, 'getTasks']);
            Route::get('/late-requests', [AssignmentController::class, 'getLateSubmissionRequests']);
            Route::post('/late-requests/{requestId}/respond', [AssignmentController::class, 'respondLateSubmissionRequest']);
            Route::get('/{taskId}/submissions', [AssignmentController::class, 'getTaskSubmissions']);
            Route::post('/submissions/{submissionId}/grade', [AssignmentController::class, 'gradeSubmission']);
            Route::post('/{id}/update', [AssignmentController::class, 'updateTask']);
            Route::put('/{id}', [AssignmentController::class, 'updateTask']);
            Route::delete('/{id}', [AssignmentController::class, 'deleteTask']);
        });
    });

    // ==========================================
    // 7. G7 KAIH (HABITS)
    // ==========================================
    Route::prefix('g7kaih')->group(function () {
        Route::get('/', [HabitController::class, 'masterHabits']);
        Route::post('/log', [HabitController::class, 'submitLog']);
        Route::get('/prayer-log', [HabitController::class, 'getPrayerLog']);
        Route::post('/prayer-log', [HabitController::class, 'submitPrayerLog']);
        Route::get('/summary', [HabitController::class, 'getHabitStats']);
        Route::get('/guru-summary', [HabitController::class, 'guruHabitStats']);
        Route::get('/pending', [HabitController::class, 'pendingLogs']);
        Route::get('/monitored-students', [HabitController::class, 'monitoredStudents']);
    });

    // ==========================================
    // 8. HELPDESK & PENGADUAN (COMPLAINTS)
    // ==========================================
    Route::prefix('complaints')->group(function () {
        Route::get('/', [ComplaintController::class, 'index']);
        Route::post('/', [ComplaintController::class, 'store']);
        Route::get('/{id}', [ComplaintController::class, 'show']);
        Route::put('/{id}/status', [ComplaintController::class, 'updateStatus'])->middleware('role:TATA_USAHA,KEPALA_SEKOLAH,GURU,GURU_BK,SUPER_ADMIN');
        Route::delete('/{id}', [ComplaintController::class, 'destroy']);
    });

    Route::prefix('helpdesk')->group(function () {
        Route::middleware('role:SISWA')->post('/', [HelpdeskController::class, 'submitStudentReport']);
        Route::middleware('role:TATA_USAHA')->get('/all', [HelpdeskController::class, 'getStudentReports']);
    });

    // ==========================================
    // 9. KEDISIPLINAN
    // ==========================================
    Route::prefix('discipline')->group(function () {
        Route::middleware('role:GURU,GURU_BK,KEPALA_SEKOLAH,SUPER_ADMIN')->group(function () {
            Route::post('/reports', [DisciplineController::class, 'submitDisiplinReport']);
            Route::get('/reports', [DisciplineController::class, 'getDisiplinReports']);
            Route::get('/students', [DisciplineController::class, 'getStudentsList']);
            Route::put('/reports/{id}/approve', [DisciplineController::class, 'approveDisiplinReport']);
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
            Route::get('/klasikal/options', [CounselingController::class, 'getKlasikalOptions']);
            Route::get('/klasikal/schedules', [CounselingController::class, 'getKlasikalSchedules']);
            Route::post('/guru-bk/create', [CounselingController::class, 'storeByGuruBk']);
        });
    });

    // ==========================================
    // 13. KURIKULUM (MASTER DATA)
    // ==========================================
    Route::prefix('curriculum')->middleware('role:TATA_USAHA')->group(function () {
        // 1. Kelas & Wali Kelas
        Route::get('/classes', [CurriculumController::class, 'getClasses']);
        Route::post('/classes', [CurriculumController::class, 'storeClass']);
        Route::put('/classes/{id}', [CurriculumController::class, 'updateClass']);
        Route::delete('/classes/{id}', [CurriculumController::class, 'deleteClass']);
        Route::put('/classes/{id}/wali-kelas', [CurriculumController::class, 'assignWaliKelas']);
        
        // 2. Guru Wali & Siswa Asuh
        Route::get('/guru-wali', [CurriculumController::class, 'getGuruWali']);
        Route::post('/guru-wali', [CurriculumController::class, 'storeGuruWali']);
        Route::delete('/guru-wali/{id}', [CurriculumController::class, 'deleteGuruWali']);

        // 3. Mata Pelajaran (Mapel)
        Route::get('/subjects', [CurriculumController::class, 'getSubjects']);
        Route::post('/subjects', [CurriculumController::class, 'storeSubject']);
        Route::put('/subjects/{id}', [CurriculumController::class, 'updateSubject']);
        Route::delete('/subjects/{id}', [CurriculumController::class, 'deleteSubject']);
        
        // 4. Jadwal KBM
        Route::get('/schedules', [CurriculumController::class, 'getSchedules']);
        Route::post('/schedules', [CurriculumController::class, 'storeSchedule']);
        Route::put('/schedules/{id}', [CurriculumController::class, 'updateSchedule']);
        Route::delete('/schedules/{id}', [CurriculumController::class, 'deleteSchedule']);
        
        // 5. Penugasan Struktural
        Route::get('/assignments', [CurriculumController::class, 'getStructuralAssignments']);
        Route::post('/assignments', [CurriculumController::class, 'storeStructuralAssignment']);
        Route::delete('/assignments/{id}', [CurriculumController::class, 'deleteStructuralAssignment']);
        
        // 6. Kalender Akademik (Agenda Kegiatan & Sumatif)
        Route::get('/academic-calendars', [CurriculumController::class, 'getAcademicCalendars']);
        Route::post('/academic-calendars', [CurriculumController::class, 'storeAcademicCalendar']);
        Route::put('/academic-calendars/{id}', [CurriculumController::class, 'updateAcademicCalendar']);
        Route::delete('/academic-calendars/{id}', [CurriculumController::class, 'deleteAcademicCalendar']);

        // 7. Hari Libur (Holidays)
        Route::get('/holidays', [HolidayController::class, 'index']);
        Route::post('/holidays', [HolidayController::class, 'store']);
        Route::get('/holidays/{id}', [HolidayController::class, 'show']);
        Route::put('/holidays/{id}', [HolidayController::class, 'update']);
        Route::delete('/holidays/{id}', [HolidayController::class, 'destroy']);
        Route::get('/holidays-check', [HolidayController::class, 'checkDate']);

        // 8. Excel Parser
        Route::post('/parse/{type}', [ExcelParserKurikulumController::class, 'parseKurikulum']);
    });

    // Alias untuk /school/holidays sesuai test suite
    Route::prefix('school')->middleware('role:TATA_USAHA')->group(function () {
        Route::get('/holidays', [HolidayController::class, 'index']);
        Route::post('/holidays', [HolidayController::class, 'store']);
        Route::get('/holidays/{id}', [HolidayController::class, 'show']);
        Route::put('/holidays/{id}', [HolidayController::class, 'update']);
        Route::delete('/holidays/{id}', [HolidayController::class, 'destroy']);
        Route::get('/holidays-check', [HolidayController::class, 'checkDate']);
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
            Route::post('/jabatans', [UserController::class, 'storeJabatan']);
            Route::put('/jabatans/{id}', [UserController::class, 'updateJabatan']);
            Route::delete('/jabatans/{id}', [UserController::class, 'deleteJabatan']);
            
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
        Route::get('/operational-settings', [SchoolController::class, 'getOperationalSettings']);
        Route::post('/operational-settings', [SchoolController::class, 'updateOperationalSettings']);

        // Hari Libur & Kalender
        Route::apiResource('holidays', HolidayController::class);
        Route::get('/holidays-check', [HolidayController::class, 'checkDate']);
    });

    // ==========================================
    // 15B. MASTER DATA & PARSER ALIASES (TU Only)
    // ==========================================
    Route::prefix('master')->middleware('role:TATA_USAHA')->group(function () {
        // Users (Master User)
        Route::get('/users', [UserController::class, 'getUsers']);
        Route::post('/users', [UserController::class, 'storeUser']);
        Route::put('/users/{id}', [UserController::class, 'updateUser']);
        Route::delete('/users/{id}', [UserController::class, 'deleteUser']);
        Route::put('/users/{id}/freeze', [UserController::class, 'freezeUser']);

        // Kelas (Rombel)
        Route::get('/kelas', [CurriculumController::class, 'getClasses']);
        Route::post('/kelas', [CurriculumController::class, 'storeClass']);
        Route::put('/kelas/{id}', [CurriculumController::class, 'updateClass']);
        Route::delete('/kelas/{id}', [CurriculumController::class, 'deleteClass']);

        // Roles
        Route::get('/roles', [UserController::class, 'getRoles']);
        Route::put('/roles/{id}', [UserController::class, 'updateRole']);

        // Jabatans
        Route::get('/jabatans', [UserController::class, 'getJabatans']);
        Route::post('/jabatans', [UserController::class, 'storeJabatan']);
        Route::put('/jabatans/{id}', [UserController::class, 'updateJabatan']);
        Route::delete('/jabatans/{id}', [UserController::class, 'deleteJabatan']);

        // Geofence & Operational
        Route::get('/school-locations', [SchoolController::class, 'getLocations']);
        Route::post('/school-locations', [SchoolController::class, 'storeLocation']);
        Route::put('/school-locations/{id}', [SchoolController::class, 'updateLocation']);
        Route::delete('/school-locations/{id}', [SchoolController::class, 'deleteLocation']);
        Route::post('/school-locations/{id}/toggle', [SchoolController::class, 'toggleLocationStatus']);

        Route::get('/school-settings/geofence', [SchoolController::class, 'getGeofenceSettings']);
        Route::post('/school-settings/geofence', [SchoolController::class, 'updateGeofenceSettings']);
        Route::get('/school-settings/operational', [SchoolController::class, 'getOperationalSettings']);
        Route::post('/school-settings/operational', [SchoolController::class, 'updateOperationalSettings']);

        // Hari Libur (Holidays)
        Route::get('/holidays', [HolidayController::class, 'index']);
        Route::post('/holidays', [HolidayController::class, 'store']);
        Route::get('/holidays/{id}', [HolidayController::class, 'show']);
        Route::put('/holidays/{id}', [HolidayController::class, 'update']);
        Route::delete('/holidays/{id}', [HolidayController::class, 'destroy']);
        Route::get('/holidays-check', [HolidayController::class, 'checkDate']);

        // Kurikulum aliases for tu_kurikulum_screen
        Route::get('/wali-kelas', [UserController::class, 'getWaliKelas']);
        Route::get('/guru-wali', [UserController::class, 'getGuruWali']);
        Route::get('/penugasan', [CurriculumController::class, 'getStructuralAssignments']);
        Route::get('/mapel', [CurriculumController::class, 'getSubjects']);
        Route::get('/schedules', [CurriculumController::class, 'getSchedules']);
    });

    Route::prefix('parse')->middleware('role:TATA_USAHA')->group(function () {
        Route::post('/master-kelas', [ExcelParserController::class, 'parseMasterKelas']);
        Route::post('/master-role', [ExcelParserController::class, 'parseMasterRole']);
        Route::post('/master-jabatan', [ExcelParserController::class, 'parseMasterJabatan']);
        Route::post('/user/{type}', [ExcelParserUserController::class, 'parseUser']);
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
        Route::delete('/', [NotificationController::class, 'deleteAll']);
        Route::delete('/{id}', [NotificationController::class, 'deleteNotification']);
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
