# Dokumentasi Database: Modul 2 (Presensi & Smart Attendance)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 01 Oktober 2026

Dokumen ini membedah struktur *database* untuk Modul 2 yang berfokus pada sistem absensi cerdas (Geofencing & Face Recognition khusus Tendik) dan sistem pelaporan absensi Siswa (Auto-Hadir & Tilang).

---

## 🏗️ 1. Filosofi Arsitektur Presensi

Sistem presensi di Anise dibangun dengan membedakan perlakuan antara **Tendik (Guru/Staf)** dan **Siswa** demi efisiensi *resource* *server* dan *storage*:
1. **Siswa (Auto-Hadir):** Ratusan/ribuan siswa tidak melakukan *scan* wajah setiap pagi (bisa membuat *server down*). Secara *default*, sistem menganggap semua siswa Hadir. Jika ada siswa yang terlambat atau membolos, Tendik/Guru Piket akan melaporkannya lewat sistem, dan sistem akan meng-*override* status absen siswa tersebut.
2. **Tendik (Face Recognition + Geofencing):** Tendik diwajibkan melakukan *scan* wajah dan validasi lokasi (*GPS*) saat absen masuk maupun absen pulang.
3. **Pemisahan Modul:** Presensi Kelas/KBM (*teacher_attendances*) dipisah ke Modul Jurnal Mengajar. Sistem Perizinan (Sakit/Izin) dipisah ke Modul Perizinan.

---

## 🗄️ 2. Detail Struktur Tabel

### A. Inti Absensi

#### 1. Tabel `attendances` (Buku Rekap Harian)
Merupakan hasil akhir/rekap absensi harian untuk seluruh *user* (Siswa & Tendik).
- `id` (UUID).
- `user_id` (FK ke users).
- `tanggal` (Date): Tanggal presensi.
- `jam_masuk` (Timestamp, Nullable): Jam berapa *user* *check-in*. (Untuk siswa, akan diisi waktu *cron job* berjalan atau waktu riil jika di-*update* manual).
- `jam_pulang` (Timestamp, Nullable): Jam berapa *user* *check-out* dari sekolah.
- `status` (String): Menggunakan *String* biasa tanpa Enum/Tabel Master untuk mempercepat *query*.
  - *Siswa:* Hadir, Terlambat, Pulang Awal, Kembali, Tidak Hadir (Alpha/Izin/Sakit).
  - *Tendik:* Hadir, Terlambat, Pulang Awal, Kembali, TAM (Tidak Absen Masuk), TAP (Tidak Absen Pulang), Tidak Hadir.
- `pulang_awal_reason` (Text, Nullable): Alasan jika *user* melakukan *check-out* sebelum waktunya.

#### 2. Tabel `presensi_logs` (Riwayat Mentah Scan AI)
Hanya berlaku bagi *user* yang wajib *scan* wajah (Tendik).
- `id` (UUID).
- `user_id` (FK ke users).
- `scan_time` (Timestamp): Waktu pasti kamera mendeteksi wajah.
- `status` (String): Status pindaian (Berhasil / Gagal / Palsu).
- `snapshot_url` (Text, Nullable): *Link URL* ke foto hasil *capture* kamera sebagai bukti verifikasi.
- `latitude` & `longitude` (Decimal, 10,8 & 11,8): Titik koordinat GPS asli dari *smartphone user* saat menekan tombol absen (berguna untuk audit jika *user* memanipulasi *Fake GPS*).

---

### B. Infrastruktur Pendukung

#### 1. Tabel `geofence_locations` (Titik Koordinat Absen)
Mengelola daftar area di mana Tendik diizinkan melakukan absen masuk. Sekolah dapat memiliki lebih dari 1 titik gerbang.
- `id` (UUID).
- `name` (String): Nama lokasi (Misal: "Gerbang Utama", "Gedung TU").
- `latitude` & `longitude` (Decimal): Koordinat pusat area.
- `radius_meters` (Integer): Jari-jari batas sah absensi (Misal: 50 meter).
- `is_active` (Boolean): Mematikan lokasi jika tidak dipakai lagi.

#### 2. Tabel `laporan_telat_siswa` (Sistem Tilang)
Tempat masuknya laporan keterlambatan dari Guru Piket.
- `pelapor_id` (FK ke users): Siapa yang memergoki siswa telat.
- `siswa_id` (FK ke users): Siswa yang telat.
- `waktu_telat` (Timestamp): Jam pasti siswa kedapatan telat.
- `alasan` (Text): Catatan dari pelapor.
- `status` (String): Tahapan *approval* (PENDING, ACC_GURU_WALI, dll).
- `approved_by` (FK ke users): Siapa yang mengeksekusi ACC terakhir.

---

## 🔑 Aturan Emas Pengembangan (Modul 2)
1. **Cron Job Harian:** Backend **wajib** memiliki proses latar belakang (Scheduler) yang berjalan tepat pukul 00:00 untuk men-*generate* *row* baru di tabel `attendances` untuk seluruh Siswa aktif dengan status awal "Hadir".
2. **Magic Merge Laporan Telat:** Jika pembuat rekor di `laporan_telat_siswa` adalah Guru Wali (yang terhubung lewat relasi `classes.wali_kelas_id`), maka laporan tersebut otomatis berstatus `ACC` dan langsung mengubah status `attendances` harian siswa menjadi "Terlambat".
3. **Hardcode Status:** Jangan pernah membuat tabel baru (relasi *join*) hanya untuk menyimpan Master Data Status Absensi. Percayakan validasi pada *Form Request* Laravel.
