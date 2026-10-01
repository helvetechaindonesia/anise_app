# Dokumentasi Database: Modul 4 (Jurnal & Jadwal Mengajar)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 01 Oktober 2026

Modul ini adalah jantung kegiatan belajar mengajar (KBM). Mengadopsi prinsip **Micro-RPP**, guru tidak lagi dipusingkan dengan administrasi ribet. Cukup menerbitkan Jurnal sebelum kelas dimulai, melakukan absensi *Tap-In* berbasis geofencing & pengenalan wajah saat kelas dimulai, lalu mengisi laporan akhir kelas sebelum pukul 18.00.

---

## 🏗️ 1. Filosofi Jurnal KBM (Alur 3 Fase)

Jurnal KBM terhubung langsung dengan Master Jadwal KBM (Cangkang). Satu sesi KBM akan melalui 3 fase wajib:
1. **Fase Penerbitan (Maksimal H-1):** Guru memilih "cangkang" KBM yang tersedia, lalu mengisinya dengan materi, topik, dan lampiran. Siswa dapat melihat, membagikan, dan menyukai materi ini.
2. **Fase *Tap-In* (Sesuai Jam Pelajaran):** Tombol *Face Recog* akan aktif. Guru wajib melakukan *scan* wajah dan lokasi sebagai bukti kehadiran mengajar di kelas. 
3. **Fase Laporan Akhir (Maksimal 18.00 Hari H):** Guru mengisi hasil kejadian riil di kelas (Siswa yang bolos mapel tersebut, pelanggaran, atau keaktifan), beserta catatan khusus.

---

## 🗄️ 2. Detail Struktur Tabel

Total hanya ada 5 tabel langsing yang mengelola keseluruhan modul ini.

### A. Data Master (Cangkang)

#### 1. Tabel `schedules` (Jadwal KBM)
Ini adalah jadwal abadi yang dibuat oleh Tata Usaha atau Kurikulum. Berfungsi sebagai acuan utama batas waktu jurnal bisa diterbitkan dan di-*tap-in*.
- `id` (UUID).
- `academic_year_id`, `class_id`, `subject_id`, `teacher_id`: Relasi master.
- `day_of_week` (String): Hari KBM (Misal: Senin).
- `start_time` & `end_time` (Time): Rentang waktu KBM.
- `activity_name` (String, Nullable): Diisi jika bukan KBM biasa (Misal: Upacara, Senam).

---

### B. Pusat KBM (Jurnal & Laporan)

#### 2. Tabel `journals` (Super Jurnal)
Menggantikan tabel-tabel lama (Administrasi Guru & Absen Guru) menjadi satu wadah terpusat.
- `id` (UUID).
- `schedule_id` (FK): Relasi ke jadwal master (menarik data hari, jam, kelas).
- `teaching_date` (Date): Tanggal riil pelaksanaan kelas.
- **[Fase Penerbitan H-1]**
  - `published_at` (Timestamp): Waktu guru menerbitkan materi.
  - `topic_material` & `description`: Rangkuman materi Micro-RPP.
  - `attachment_url`: Lampiran PDF/PPT.
  - `has_task` (Boolean): Apakah hari ini ada tugas (Berhubungan dengan Modul 5).
- **[Fase Masuk Kelas (Tap-In)]**
  - `check_in_time` (Timestamp): Waktu pasti guru menekan absen wajah.
  - `face_snapshot_url`, `latitude`, `longitude`: Bukti GPS dan Biometrik KBM berjalan.
- **[Fase Pengisian Akhir]**
  - `filled_at` (Timestamp): Waktu guru mengunci/menyelesaikan jurnal.
  - `class_notes` (Text): Catatan dinamika kelas (Misal: "Siswa sangat antusias hari ini").
- `status` (Enum): `DRAFT`, `PUBLISHED` (Bisa diklik siswa), `ONGOING` (Kelas Sedang Berjalan), `COMPLETED` (Sudah diisi laporannya).

#### 3. Tabel `journal_student_records` (Catatan Anomali Siswa)
Digunakan saat guru mengisi Jurnal di fase akhir.
- `id` (UUID).
- `journal_id` (FK ke journals).
- `student_id` (FK ke users).
- `record_type` (Enum): 
  - `ABSENCE`: Siswa tidak hadir khusus di jam pelajaran ini (Bolos mapel).
  - `VIOLATION`: Siswa melakukan pelanggaran di kelas (Nanti di-copy oleh *Observer* ke Modul Disiplin).
  - `ACHIEVEMENT`: Keaktifan ekstra di kelas.
- `keterangan` (Text): Penjelasan rinci kejadian.

---

### C. Fitur Sosial & Interaksi Siswa

Siswa dapat berinteraksi dengan materi jurnal bagaikan di media sosial jika status jurnal sudah `PUBLISHED`.

#### 4. Tabel `journal_interactions` (Reaksi)
- `id` (UUID).
- `journal_id` (FK ke journals).
- `student_id` (FK ke users).
- `interaction_type` (Enum): `LIKE` (Menyukai materi), `SAVE` (Menyimpan materi ke profil), `SHARE`.

#### 5. Tabel `journal_comments` (Diskusi Kelas)
Berfungsi sebagai wadah tanya jawab (forum) mini khusus untuk materi hari itu.
- `id` (UUID).
- `journal_id` (FK ke journals).
- `user_id` (FK ke users, bisa diisi oleh siswa bertanya atau guru menjawab).
- `comment_text` (Text).

---

## 🔑 Aturan Emas Pengembangan (Modul 4)
1. **Toleransi Tap-In:** Validasi di *Backend Controller* harus mengizinkan guru melakukan `check_in_time` maksimal dengan toleransi keterlambatan (Misal: 20 menit) dari `start_time` yang tercatat di `schedules`. Di luar itu, KBM dianggap batal atau digantikan/diinval.
2. **Sinkronisasi Disiplin:** Saat ada rekaman bertipe `VIOLATION` masuk ke `journal_student_records`, *Event Listener* di Laravel wajib membuat salinan (*copy*) laporan tersebut ke tabel `disiplin_reports` (Modul 2) secara diam-diam (*background job*) agar Guru Wali dapat menindaklanjutinya.
