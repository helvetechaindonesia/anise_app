# 🗄️ Database Framework (Pemetaan & Standarisasi Tabel)

**Status:** Finalized Blueprint (Fase 1i)

Sesuai arsitektur *Clean Conditions*, seluruh struktur *database* kini telah dirapikan, dikelompokkan ke dalam 7 Divisi Entitas, dan distandarisasi penamaannya (*snake_case*, *plural*). Tabel-tabel ini adalah "Rak Penyimpanan" yang akan diakses eksklusif oleh **Helpers (Repositories)**.

## Divisi Data Induk & Kepegawaian (HRD)
- **`users`** -> Rak penyimpanan untuk entitas `User` (Akses via `UserRepository`).
- **`roles`** -> Rak penyimpanan untuk entitas `Role` (Akses via `RoleRepository`).
- **`school_profiles`** -> Rak penyimpanan untuk entitas `SchoolProfile` (Akses via `SchoolProfileRepository`).

## Divisi Master Akademik & Kurikulum
- **`classrooms`** -> Rak penyimpanan untuk entitas `Classroom` (Akses via `ClassroomRepository`).
- **`subjects`** -> Rak penyimpanan untuk entitas `Subject` (Akses via `SubjectRepository`).
- **`schedules`** -> Rak penyimpanan untuk entitas `Schedule` (Akses via `ScheduleRepository`).
- **`academic_years`** -> Rak penyimpanan untuk entitas `AcademicYear` (Akses via `AcademicYearRepository`).

## Divisi Kegiatan Belajar Mengajar (KBM)
- **`journals`** -> Rak penyimpanan untuk entitas `Journal` (Akses via `JournalRepository`).
- **`assignments`** -> Rak penyimpanan untuk entitas `Assignment` (Akses via `AssignmentRepository`).
- **`assessments`** -> Rak penyimpanan untuk entitas `Assessment` (Akses via `AssessmentRepository`).

## Divisi Kesiswaan, Disiplin & Ibadah
- **`attendances`** -> Rak penyimpanan untuk entitas `Attendance` (Akses via `AttendanceRepository`).
- **`leaves`** -> Rak penyimpanan untuk entitas `Leave` (Akses via `LeaveRepository`).
- **`habits`** -> Rak penyimpanan untuk entitas `Habit` (Akses via `HabitRepository`).
- **`disciplines`** -> Rak penyimpanan untuk entitas `Discipline` (Akses via `DisciplineRepository`).
- **`points`** -> Rak penyimpanan untuk entitas `Point` (Akses via `PointRepository`).

## Divisi Bimbingan Konseling (BK)
- **`counselings`** -> Rak penyimpanan untuk entitas `Counseling` (Akses via `CounselingRepository`).

## Divisi Logistik, Humas & Umum
- **`helpdesks`** -> Rak penyimpanan untuk entitas `Helpdesk` (Akses via `HelpdeskRepository`).
- **`inventories`** -> Rak penyimpanan untuk entitas `Inventory` (Akses via `InventoryRepository`).
- **`letters`** -> Rak penyimpanan untuk entitas `Letter` (Akses via `LetterRepository`).
- **`announcements`** -> Rak penyimpanan untuk entitas `Announcement` (Akses via `AnnouncementRepository`).

## Divisi Sistem, Keamanan & Laporan
- **`notifications`** -> Rak penyimpanan untuk entitas `Notification` (Akses via `NotificationRepository`).
- **`security_logs`** -> Rak penyimpanan untuk entitas `SecurityLog` (Akses via `SecurityLogRepository`).
- **`kpis`** -> Rak penyimpanan untuk entitas `Kpi` (Akses via `KpiRepository`).
- **`legals`** -> Rak penyimpanan untuk entitas `Legal` (Akses via `LegalRepository`).

---
> SOP Absolut: Struktur kolom tabel harus mencakup *timestamps* (`created_at`, `updated_at`) dan *soft deletes* (`deleted_at`) untuk entitas yang bersifat vital.
