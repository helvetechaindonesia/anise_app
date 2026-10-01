# Dokumentasi Database: Modul 6 (Agenda Penilaian & Ujian)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 01 Oktober 2026

Modul ini dirancang khusus untuk memfasilitasi ujian-ujian besar yang bersifat sumatif atau normatif (seperti Ulangan Harian, Ujian Tengah Semester, hingga Ujian Akhir Semester). 

> [!NOTE]
> Modul ini **hanya** menyimpan data kalender, jadwal detail ujian, dan nilai angka mentah siswa. Pengolahan sistem Raport (dengan rumus pembobotan kompleks dan penilaian kelakuan subjektif Kurikulum Merdeka) tidak disertakan di MVP tahap ini.

---

## 🏗️ 1. Filosofi Dua Lapis Master Data (⚠️ PENTING!)

Untuk menjaga kerapian struktur data sekolah, pengisian jadwal ujian di sistem ini menerapkan konsep **2 Lapis Data Master**. Artinya, Admin/Kurikulum wajib mengisi data berurutan:

1. **Lapis 1 (Kalender General):** Sekolah membuat agenda besar terlebih dahulu (Misal: "Pelaksanaan UTS Ganjil"). Agenda ini memiliki rentang waktu secara keseluruhan (Misal: 1 September - 14 September).
2. **Lapis 2 (Jadwal Detail per Mapel):** Setelah Lapis 1 dibuat, barulah Admin/Guru memecah jadwal ujian tersebut secara rinci per mata pelajaran dan kelas (Misal: Ujian Matematika Kelas 10A dilaksanakan pada 2 September jam 08:00).

---

## 🗄️ 2. Detail Struktur Tabel

Total terdapat 3 tabel utama yang saling berelasi.

### A. Lapis 1: Master Kalender

#### 1. Tabel `academic_calendars` (Kalender Pendidikan)
Tabel ini digunakan untuk mencatat agenda besar sekolah secara general.
- `id` (UUID).
- `academic_year_id` (FK): Tahun ajaran saat ini.
- `name` (String): Nama agenda besar (Misal: "Pelaksanaan UTS", "Pekan Porseni", "Libur Idul Fitri").
- `start_date` & `end_date` (Date): Rentang waktu kegiatan tersebut berlangsung.
- `is_holiday` (Boolean): Jika bernilai `True`, maka sistem *cron job* presensi akan membaca hari tersebut sebagai hari libur, sehingga tidak ada siswa yang dihitung Alpha/Terlambat, dan fitur *Tap-In* Jurnal mengajar dinonaktifkan.

---

### B. Lapis 2: Pelaksanaan & Penilaian

#### 2. Tabel `assessments` (Cangkang Jadwal Ujian)
Tabel ini adalah turunan (detail) dari kalender akademik. Digunakan untuk merinci ujian apa saja yang ada di dalam agenda tersebut.
- `id` (UUID).
- `academic_calendar_id` (FK): Terhubung ke agenda kalender (Misal: Nempel ke event "UTS Ganjil").
- `class_id` & `subject_id` (FK): Kelas dan mata pelajaran yang diujikan (Misal: Kelas 10A, Matematika).
- `teacher_id` (FK): Guru pengawas atau pembuat soal ujian.
- `assessment_type` (String/Enum): Tipe ujian (Misal: `UH`, `UTS`, `UAS`, `PRAKTIK`).
- `date` (Date): Tanggal pasti ujian tersebut dieksekusi.
- `start_time` & `end_time` (Time, Nullable): Rentang waktu ujian (Misal: 07:00 - 08:30).

#### 3. Tabel `assessment_grades` (Input Nilai Ujian)
Tabel untuk menampung hasil ujian (nilai mentah) siswa.
- `id` (UUID).
- `assessment_id` (FK): Terhubung ke jadwal ujian.
- `student_id` (FK): Siswa yang mendapatkan nilai.
- `score` (Decimal 5,2, Nullable): Nilai murni ujian (Misal: 85.50).
- `remedial_score` (Decimal 5,2, Nullable): Jika siswa mengikuti perbaikan (*remedial*), nilai perbaikannya dimasukkan ke sini tanpa menghapus jejak nilai asli (`score`).
- `notes` (Text, Nullable): Catatan evaluasi dari guru untuk ujian siswa tersebut.

---

## 🔑 Aturan Emas Pengembangan (Modul 6)
1. **Pemisahan Logika Absensi:** Karena ujian (Tabel `assessments`) berjalan secara mandiri dan tidak terhubung dengan `schedules` harian Modul 4, maka jika ada siswa yang absen saat ujian, status absennya tetap mengacu pada Modul 2 (Presensi Gerbang/Harian).
2. **Prioritas Remedial:** Jika API mengkalkulasi nilai akhir siswa, sistem harus memprioritaskan pengecekan kolom `remedial_score`. Jika `remedial_score` tidak *null*, maka nilai itulah yang dianggap sebagai nilai akhir ujian tersebut.
