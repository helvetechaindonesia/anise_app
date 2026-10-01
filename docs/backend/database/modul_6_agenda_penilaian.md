# Dokumentasi Database: Modul 6 (Agenda Penilaian & Ujian)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 01 Oktober 2026

Modul ini dirancang khusus untuk memfasilitasi ujian-ujian besar yang bersifat sumatif (UTS/UAS) maupun ujian formatif dadakan (Ulangan Harian/Kuis).

> [!NOTE]
> Modul ini **hanya** menyimpan data kalender, jadwal detail ujian, dan nilai angka mentah siswa. Pengolahan sistem Raport (dengan rumus pembobotan kompleks dan penilaian kelakuan subjektif Kurikulum Merdeka) tidak disertakan di MVP tahap ini.

---

## 🏗️ 1. Filosofi Dua Alam Penilaian (⚠️ PENTING!)

Tabel `assessments` di modul ini didesain fleksibel untuk melayani 2 "hajat" yang berbeda:

1. **Hajat Sekolah (Ujian Sumatif):**
   Ujian besar (seperti UTS atau UAS) yang dibuat oleh Admin/Kurikulum. Ujian ini **WAJIB** terikat pada `academic_calendar_id` (Lapis Master 1) karena harus tunduk pada rentang waktu kalender pendidikan sekolah. Karena judulnya sudah pasti (menarik dari nama kalender), maka kolom `title` pada tabel `assessments` dibiarkan **kosong/null**.

2. **Hajat Guru (Ujian Formatif):**
   Ujian dadakan atau ulangan harian yang dibuat oleh Guru Mata Pelajaran. Guru bisa membuat ini kapan saja tanpa terikat kalender pendidikan. Maka untuk ujian jenis ini, `academic_calendar_id` **dibiarkan kosong/null**, namun kolom `title` **WAJIB DIISI** oleh guru (Misal: "Ulangan Bab 1: Aljabar").

---

## 🗄️ 2. Detail Struktur Tabel

Total terdapat 3 tabel utama yang saling berelasi.

### A. Lapis 1: Master Kalender (Hanya Untuk Sumatif)

#### 1. Tabel `academic_calendars` (Kalender Pendidikan)
Tabel ini digunakan untuk mencatat agenda besar sekolah secara general.
- `id` (UUID).
- `academic_year_id` (FK): Tahun ajaran saat ini.
- `name` (String): Nama agenda besar (Misal: "Pelaksanaan UTS", "Pekan Porseni", "Libur Idul Fitri").
- `start_date` & `end_date` (Date): Rentang waktu kegiatan tersebut berlangsung.
- `is_holiday` (Boolean): Jika bernilai `True`, maka sistem *cron job* presensi akan membaca hari tersebut sebagai hari libur.

---

### B. Lapis 2: Pelaksanaan & Penilaian

#### 2. Tabel `assessments` (Cangkang Jadwal Ujian Dua Alam)
Tabel fleksibel penampung detail ujian.
- `id` (UUID).
- `academic_calendar_id` (FK, Nullable): Terhubung ke agenda kalender JIKA ini ujian Sumatif. Kosong jika ujian Formatif.
- `title` (String, Nullable): Nama spesifik ujian JIKA ini ujian Formatif. Kosong jika ujian Sumatif (karena ditarik dari kalender).
- `class_id` & `subject_id` (FK): Kelas dan mata pelajaran yang diujikan.
- `teacher_id` (FK): Guru pengawas atau pembuat soal ujian.
- `assessment_type` (String/Enum): Tipe ujian (Misal: `UH`, `UTS`, `UAS`, `PRAKTIK`).
- `date` (Date): Tanggal eksekusi ujian.
- `start_time` & `end_time` (Time, Nullable): Rentang jam pelaksanaan.

#### 3. Tabel `assessment_grades` (Input Nilai Ujian)
Tabel untuk menampung hasil ujian (nilai mentah) siswa.
- `id` (UUID).
- `assessment_id` (FK): Terhubung ke cangkang ujian.
- `student_id` (FK): Siswa yang mendapatkan nilai.
- `score` (Decimal 5,2, Nullable): Nilai murni ujian (Misal: 85.50).
- `remedial_score` (Decimal 5,2, Nullable): Nilai perbaikan. Jika siswa mengikuti perbaikan (*remedial*), nilainya masuk sini tanpa menghapus jejak nilai asli (`score`).
- `notes` (Text, Nullable): Catatan evaluasi dari guru.

---

## 🔑 Aturan Emas Pengembangan (Modul 6)
1. **Validasi Formatif vs Sumatif:** *Backend Controller* harus mengunci logika validasi ini: 
   - Jika `assessment_type` adalah `UTS` atau `UAS`, maka payload *request* harus menyertakan `academic_calendar_id`. 
   - Jika `assessment_type` adalah `UH` (Ulangan Harian), maka payload *request* harus menyertakan `title`.
2. **Prioritas Remedial:** Jika API mengkalkulasi nilai akhir siswa, sistem harus memprioritaskan pengecekan kolom `remedial_score`. Jika `remedial_score` tidak *null*, maka nilai itulah yang dianggap sebagai nilai akhir (tapi `score` asli tetap dirender ke *frontend* dengan coretan visual).
