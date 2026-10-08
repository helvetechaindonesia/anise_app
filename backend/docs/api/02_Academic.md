# Dokumentasi API - Grup 2: Akademik & Kurikulum

## 🗓️ Modul 13: Kurikulum & Master Data
**Base URL:** `/api/curriculum`
**Controller:** `CurriculumController`

Mencakup data Kelas, Mata Pelajaran, Jadwal, dan Penugasan Struktural. Umumnya dikelola oleh Tata Usaha.

### 1. Daftar Kelas & Mapel
- **Endpoint Kelas:** `GET /classes`
- **Endpoint Mapel:** `GET /subjects`
- **Notes:** Diurutkan berdasarkan `grade_level` dan nama alfabet.

### 2. Manajemen Jadwal (Schedule)
- **Endpoint:** `GET /schedules`
- **Response:** Relasi jadwal ke Guru, Kelas, dan Mapel.

---

## 📓 Modul 4: Jurnal Mengajar
**Base URL:** `/api/journals`
**Controller:** `JournalController`

Guru wajib mengisi jurnal setelah mengajar. Data ini di-generate otomatis dari Modul 13 (Jadwal).

### 1. Opsi Terbit Jurnal (Guru)
- **Endpoint:** `GET /terbit-options`
- **Notes:** Mengkalkulasi tanggal 1 bulan ke depan berdasarkan hari mengajar guru tersebut (menggunakan Carbon).

### 2. Submit Jurnal Baru (Guru)
- **Endpoint:** `POST /terbit`
- **Body Request:** `schedule_id` (format unik: `id|YYYY-MM-DD`), `topic_material`, `has_task`.

### 3. Riwayat Jurnal (Siswa)
- **Endpoint:** `GET /siswa`
- **Notes:** Siswa hanya bisa melihat jurnal untuk kelasnya (difilter berdasarkan `ClassStudent`).

---

## 📝 Modul 5: Penugasan (PR)
**Base URL:** `/api/assignments`
**Controller:** `AssignmentController`

Manajemen tugas/PR yang terhubung langsung dengan `journal_id`.

### 1. Buat Tugas (Guru)
- **Endpoint:** `POST /`
- **Body Request:** `journal_id`, `title`, `description`, `due_date`, `attachment`.
- **Notes:** Termasuk upload file (disimpan di `/storage/tasks/`).

### 2. Daftar Tugas Siswa
- **Endpoint:** `GET /siswa`
- **Notes:** Diurutkan berdasarkan `due_date` terdekat.

---

## 📊 Modul 6: Agenda Penilaian & Raport
**Base URL:** `/api/assessments`
**Controller:** `AssessmentController` (Boilerplate)

*Fitur ini akan dibangun pada fase selanjutnya.*

### Rencana Endpoint:
- `GET /` -> Menampilkan daftar agenda ujian (UTS/UAS/UH).
- `POST /` -> Membuat agenda ujian.
- `POST /{id}/scores` -> Input nilai ujian secara bulk.
