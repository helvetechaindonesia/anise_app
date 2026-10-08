# 📡 API & State Framework (Pemetaan Endpoint & Routing)

**Status:** Finalized Blueprint (Fase 1j)

Sesuai arsitektur *Clean Conditions*, seluruh rute API (*Endpoints*) kini telah dirapikan, dikelompokkan ke dalam 7 Divisi Entitas, dan distandarisasi penamaannya (RESTful, *kebab-case*, *plural*). API ini di- *serve* oleh **Waiters (Controllers)** dan ditangkap oleh **State Managers (Riverpod Providers)** di Frontend.

## Divisi Data Induk & Kepegawaian (HRD)
- **`/api/users`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `UserController`, di-plating oleh `UserResource`, dan ditangkap oleh `userProvider`.
- **`/api/roles`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `RoleController`, di-plating oleh `RoleResource`, dan ditangkap oleh `roleProvider`.
- **`/api/school-profiles`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `SchoolProfileController`, di-plating oleh `SchoolProfileResource`, dan ditangkap oleh `schoolprofileProvider`.

## Divisi Master Akademik & Kurikulum
- **`/api/classrooms`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `ClassroomController`, di-plating oleh `ClassroomResource`, dan ditangkap oleh `classroomProvider`.
- **`/api/subjects`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `SubjectController`, di-plating oleh `SubjectResource`, dan ditangkap oleh `subjectProvider`.
- **`/api/schedules`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `ScheduleController`, di-plating oleh `ScheduleResource`, dan ditangkap oleh `scheduleProvider`.
- **`/api/academic-years`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `AcademicYearController`, di-plating oleh `AcademicYearResource`, dan ditangkap oleh `academicyearProvider`.

## Divisi Kegiatan Belajar Mengajar (KBM)
- **`/api/journals`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `JournalController`, di-plating oleh `JournalResource`, dan ditangkap oleh `journalProvider`.
- **`/api/assignments`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `AssignmentController`, di-plating oleh `AssignmentResource`, dan ditangkap oleh `assignmentProvider`.
- **`/api/assessments`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `AssessmentController`, di-plating oleh `AssessmentResource`, dan ditangkap oleh `assessmentProvider`.

## Divisi Kesiswaan, Disiplin & Ibadah
- **`/api/attendances`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `AttendanceController`, di-plating oleh `AttendanceResource`, dan ditangkap oleh `attendanceProvider`.
- **`/api/leaves`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `LeaveController`, di-plating oleh `LeaveResource`, dan ditangkap oleh `leaveProvider`.
- **`/api/habits`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `HabitController`, di-plating oleh `HabitResource`, dan ditangkap oleh `habitProvider`.
- **`/api/disciplines`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `DisciplineController`, di-plating oleh `DisciplineResource`, dan ditangkap oleh `disciplineProvider`.
- **`/api/points`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `PointController`, di-plating oleh `PointResource`, dan ditangkap oleh `pointProvider`.

## Divisi Bimbingan Konseling (BK)
- **`/api/counselings`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `CounselingController`, di-plating oleh `CounselingResource`, dan ditangkap oleh `counselingProvider`.

## Divisi Logistik, Humas & Umum
- **`/api/helpdesks`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `HelpdeskController`, di-plating oleh `HelpdeskResource`, dan ditangkap oleh `helpdeskProvider`.
- **`/api/inventories`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `InventoryController`, di-plating oleh `InventoryResource`, dan ditangkap oleh `inventoryProvider`.
- **`/api/letters`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `LetterController`, di-plating oleh `LetterResource`, dan ditangkap oleh `letterProvider`.
- **`/api/announcements`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `AnnouncementController`, di-plating oleh `AnnouncementResource`, dan ditangkap oleh `announcementProvider`.

## Divisi Sistem, Keamanan & Laporan
- **`/api/notifications`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `NotificationController`, di-plating oleh `NotificationResource`, dan ditangkap oleh `notificationProvider`.
- **`/api/security-logs`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `SecurityLogController`, di-plating oleh `SecurityLogResource`, dan ditangkap oleh `securitylogProvider`.
- **`/api/kpis`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `KpiController`, di-plating oleh `KpiResource`, dan ditangkap oleh `kpiProvider`.
- **`/api/legals`** -> Endpoint REST (GET, POST, PUT, DELETE) dilayani oleh `LegalController`, di-plating oleh `LegalResource`, dan ditangkap oleh `legalProvider`.

---
> SOP Absolut: Seluruh pemanggilan endpoint harus melewati *Middleware/API Gateway* untuk validasi Token (Auth), dan Response JSON WAJIB mematuhi format baku *BaseController*.
