# Dokumentasi Database: Modul 13 (Kurikulum & Master Data)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul 13 (Kurikulum) adalah **"God Module"** yang berfungsi sebagai pusat pengaturan *Master Data* sekolah. Hampir seluruh modul lain (Raport, Jurnal, BK, Disiplin, Perizinan) sangat bergantung pada data yang diproduksi di modul ini.

---

## 🏛️ 1. Ekosistem Tabel Kurikulum

Tabel-tabel di bawah ini dirancang fleksibel untuk mengakomodasi berbagai sistem kurikulum di Indonesia (termasuk Kurikulum Merdeka di SMA N 1 Peunaron).

### A. Waktu & Identitas Dasar
1. **`academic_years`:** Menyimpan tahun ajaran aktif (Misal: 2026/2027 Ganjil). Jika data ini bergeser, seluruh aplikasi akan beralih ke tahun ajaran baru.
2. **`majors`:** Menyimpan data jurusan. *(Catatan: Dipertahankan untuk kompatibilitas dengan SMK/MA, namun penggunaannya di tabel `classes` diubah menjadi `Nullable`).*
3. **`academic_calendars`:** Menyimpan agenda tahunan sekolah, termasuk agenda ujian (berelasi dengan Modul 6 - Raport).
4. **`holidays`:** Menyimpan data libur nasional/sekolah agar mesin presensi (Modul 2) tidak memberikan status "ALFA" pada siswa/guru di hari libur.

### B. Struktur Pembelajaran & Kelas
1. **`subjects`:** Data mata pelajaran beserta KKM.
2. **`classes`:** Data Rombongan Belajar (Rombel). 
   - Kolom `major_id` bersifat *Nullable* (Boleh kosong untuk sekolah tanpa penjurusan di awal).
   - Kolom `name` bebas diisi dengan nama unik (Misal: "10 Cut Nyak Dhien").
   - Kolom `wali_kelas_id` menyimpan "Kades" atau penguasa teritorial ruang kelas tersebut.
3. **`class_students`:** Tabel historis yang merekam siswa mana saja yang berada di kelas tertentu pada tahun ajaran tertentu.

### C. Pemetaan Personal (Mentor & Polisi Area)
Tabel ini digunakan untuk pemetaan lintas kelas (berbasis siswa asuh), bukan berbasis ruang kelas. Tujuannya agar rekam jejak bimbingan tidak hilang ketika siswa naik kelas.
1. **`guru_wali_students`:** Memetakan 1 Guru Wali (sebagai "RW" / *Mentor*) dengan anak-anak asuhnya (Lintas Kelas). Berfungsi untuk *routing* persetujuan izin (Modul 3) dan validasi awal disiplin (Modul 9).
2. **`guru_bk_students`:** Memetakan 1 Guru BK dengan anak-anak asuhnya. Berfungsi untuk *routing* notifikasi pengajuan bimbingan (Modul 10) dan deteksi sanksi poin kritis.

### D. Jantung KBM (Jadwal)
- **`schedules`:** Master jadwal pelajaran (Hari, Jam, Kelas, Guru, Mapel). Tabel ini menjadi landasan pacu bagi fitur Jurnal Mengajar (Modul 4) dan Pembajakan Kelas oleh Guru BK/Inval.

---

## 🚀 2. Instruksi UI & Logic API Endpoint

Mengingat input data kurikulum bisa mencapai ribuan baris, *Frontend* dan *Backend* **WAJIB** mengikuti panduan UI dan API berikut:

### A. Fitur "Master Data Importer" (Upload Excel)
Wakasek Kurikulum tidak boleh dipaksa menginput siswa dan jadwal satu per satu lewat tombol "+ Tambah".
- **UI:** Halaman Kurikulum wajib memiliki fitur "Upload Master Data (Excel/CSV)".
- **API `POST /api/kurikulum/import-master`:** 
  - *Backend* bertugas memecah 1 *file* Excel besar menjadi *insert* ke tabel `classes`, `class_students`, `guru_wali_students`, dan `guru_bk_students`.
  - Jika di Excel ada kolom "Guru BK" atau "Guru Wali" di samping nama siswa, *Backend* wajib membaca itu dan melakukan `INSERT` otomatis ke tabel pivot `guru_bk_students` dan `guru_wali_students` dengan menyertakan `academic_year_id` yang sedang aktif.

### B. Fitur `academic_calendars` (Agenda Kurikulum)
- **UI:** Disajikan dalam bentuk antarmuka Kalender Visual (seperti Google Calendar) di *dashboard* Kurikulum.
- **API `GET /api/academic-calendars`:** Digunakan untuk menampilkan daftar acara di beranda semua *user*.
- **Logic Raport:** API ini harus memiliki *flag* atau relasi khusus ke tabel `assessments` (Modul 6). Ketika Kurikulum menambahkan agenda bernama "Penilaian Akhir Semester (PAS)", *Backend* harus membuka gerbang input nilai raport untuk guru-guru mapel.

### C. Fitur `holidays` (Sinkronisasi Libur)
- **UI:** Tergabung dalam tampilan Kalender Visual Kurikulum, ditandai dengan warna merah.
- **API `POST /api/holidays/sync`:** *Backend* bisa mempermudah tugas Kurikulum dengan menarik data libur nasional dari API Publik Pemerintah (otomatis mengisi tabel `holidays` 1 tahun penuh).
- **Logic Presensi:** Cron Job harian (Modul 2) **WAJIB** mengecek API `GET /api/holidays/check?date=TODAY` sebelum menjalankan hukuman "ALFA". Jika hari itu libur, hukuman ALFA dibatalkan secara sistematis.
