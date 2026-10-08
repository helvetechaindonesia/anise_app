# 🕵️‍♂️ Blueprint QC (Tim Unit Tests)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `tests/Feature/` (atau `tests/Unit/`)

Sesuai kerangka *Layered Architecture by Clean Conditions*, dokumen ini adalah cetak biru untuk seluruh tim **QC (Quality Control / Tests)**.
Tugas utama QC adalah menguji setiap masakan yang baru saja ditata oleh *Platter (Resources)* sebelum benar-benar diantarkan oleh Waiter ke meja *user*.

Sesuai standar operasional, jumlah dan penempatan tim QC ini **SAMA PERSIS 1:1** dengan tim Platter. 
Satu QC hanya fokus memeriksa dan mengicip 1 jenis piring (Entitas JSON).

Berikut adalah daftar Tukang Icip (Tests) yang dibutuhkan:

---

## 👥 Divisi Data Induk & Kepegawaian (HRD)
- **`UserTest`** -> Tukang icip endpoint & JSON *User*.
- **`RoleTest`** -> Tukang icip endpoint & JSON *Role*.
- **`SchoolProfileTest`** -> Tukang icip endpoint & JSON *SchoolProfile*.

## 🗓️ Divisi Master Akademik & Kurikulum
- **`ClassroomTest`** -> Tukang icip endpoint & JSON *Classroom*.
- **`SubjectTest`** -> Tukang icip endpoint & JSON *Subject*.
- **`ScheduleTest`** -> Tukang icip endpoint & JSON *Schedule*.
- **`AcademicYearTest`** -> Tukang icip endpoint & JSON *AcademicYear*.

## 📓 Divisi Kegiatan Belajar Mengajar (KBM)
- **`JournalTest`** -> Tukang icip endpoint & JSON *Journal*.
- **`AssignmentTest`** -> Tukang icip endpoint & JSON *Assignment*.
- **`AssessmentTest`** -> Tukang icip endpoint & JSON *Assessment*.

## 👮‍♂️ Divisi Kesiswaan, Disiplin & Ibadah
- **`AttendanceTest`** -> Tukang icip endpoint & JSON *Attendance*.
- **`LeaveTest`** -> Tukang icip endpoint & JSON *Leave*.
- **`HabitTest`** -> Tukang icip endpoint & JSON *Habit*.
- **`DisciplineTest`** -> Tukang icip endpoint & JSON *Discipline*.
- **`PointTest`** -> Tukang icip endpoint & JSON *Point*.

## 🛋️ Divisi Bimbingan Konseling (BK)
- **`CounselingTest`** -> Tukang icip endpoint & JSON *Counseling*.

## 🪑 Divisi Logistik, Humas & Umum
- **`HelpdeskTest`** -> Tukang icip endpoint & JSON *Helpdesk*.
- **`InventoryTest`** -> Tukang icip endpoint & JSON *Inventory*.
- **`LetterTest`** -> Tukang icip endpoint & JSON *Letter*.
- **`AnnouncementTest`** -> Tukang icip endpoint & JSON *Announcement*.

## ⚙️ Divisi Sistem, Keamanan & Laporan
- **`NotificationTest`** -> Tukang icip endpoint & JSON *Notification*.
- **`SecurityLogTest`** -> Tukang icip endpoint & JSON *SecurityLog*.
- **`KpiTest`** -> Tukang icip endpoint & JSON *Kpi*.
- **`LegalTest`** -> Tukang icip endpoint & JSON *Legal*.
