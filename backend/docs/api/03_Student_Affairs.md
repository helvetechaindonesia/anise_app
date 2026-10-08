# Dokumentasi API - Grup 3: Kesiswaan & Kedisiplinan

## 📍 Modul 2: Presensi (Kehadiran)
**Base URL:** `/api/attendance`
**Controller:** `AttendanceController`

Manajemen check-in wajah, geofence, dan laporan telat.

### 1. Pendaftaran Biometrik Wajah
- **Endpoint:** `POST /biometric/register`
- **Notes:** Menyimpan `face_embedding` ke tabel `users`.

### 2. Absen Kamera (Check-in / Check-out)
- **Endpoint:** `POST /check-in-cam`
- **Body Request:** Kordinat GPS `lat` dan `lng`.
- **Logika Geofence:** Menggunakan rumus Haversine untuk menghitung jarak *user* ke titik pusat sekolah (berdasarkan tabel `school_settings`).
- **Logika Jam:** Otomatis mendeteksi MASUK, PULANG AWAL (PA), KEMBALI (K), atau PULANG berdasarkan jam di server.

### 3. Riwayat Presensi
- **Endpoint:** `GET /`
- **Notes:** Siswa dan Guru memiliki terjemahan status absen yang berbeda di *frontend*.

---

## 💌 Modul 3: Perizinan & Dispensasi
**Base URL:** `/api/leaves`
**Controller:** `LeaveController`

### 1. Pengajuan Izin
- **Endpoint:** `POST /`
- **Body Request:** `type` (DISPENSASI/IZIN), rentang tanggal, alasan, dan file lampiran bukti sakit.

---

## 🕌 Modul 7: Gerakan 7 KAIH
**Base URL:** `/api/g7kaih`
**Controller:** `HabitController`

Pencatatan ibadah harian dan kegiatan positif siswa.

### 1. Log Ibadah (Siswa)
- **Endpoint:** `POST /log`
- **Body Request:** `habit_id`, `photo`.

### 2. Monitoring (Guru / BK)
- **Endpoint:** `GET /monitored-students`
- **Notes:** Menampilkan anak wali (jika Wali Kelas) atau anak asuh (jika Guru BK).

---

## 👮‍♂️ Modul 9: Kedisiplinan
**Base URL:** `/api/discipline`
**Controller:** `DisciplineController`

### 1. Input Lapor Pelanggaran
- **Endpoint:** `POST /reports`
- **Notes:** Jika yang melapor adalah Wali Kelas dari siswa tersebut, status langsung diset `INPUT`. Jika guru lain, status `LAPORAN`.

---

## 🛋️ Modul 10: Bimbingan Konseling (BK)
**Base URL:** `/api/counseling`
**Controller:** `CounselingController`

### 1. Request Jadwal Curhat (Siswa)
- **Endpoint:** `POST /`
- **Body Request:** `guru_id`, `counseling_date`, `topic`.

### 2. List Sesi BK (Guru BK)
- **Endpoint:** `GET /requests`
- **Notes:** Guru BK dapat mengubah status laporan (`APPROVED`, `COMPLETED`, dll) via endpoint `PUT /{id}/status`.

---

## 💯 Modul 17B: Poin Kedisiplinan Siswa
**Base URL:** `/api/points`
**Controller:** `PointController` (Boilerplate)

*Fitur belum diimplementasikan.*
- Direncanakan untuk mengelola sistem potong saldo poin, katalog pasal pelanggaran, dan riwayat mutasi poin.
