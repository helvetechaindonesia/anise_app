# Dokumentasi User Flow (Per Segmen)

Dokumen ini berisi *user flow* detail untuk setiap segmen utama di aplikasi Anise, dilengkapi dengan diagram alur (*flowchart*) untuk membantu memvisualisasikan bagaimana pengguna berinteraksi dengan sistem.

---

## 1. Segmen Autentikasi & Akses Awal
Alur ketika pengguna (Siswa atau Guru) membuka aplikasi pertama kali.

```mermaid
flowchart TD
    A["Buka Aplikasi"] --> B{"Sudah Login?"}
    B -->|Belum| C["Halaman Login"]
    C --> D["Input Username & Password"]
    D --> E{"Validasi Backend"}
    E -->|Gagal| F["Tampilkan Pesan Error"]
    E -->|Sukses| G["Simpan JWT Token"]
    G --> H["Ambil Data Profil /api/user/me"]
    
    B -->|Sudah| H
    H --> I{"Cek Role"}
    I -->|SISWA| J["Masuk Dashboard Siswa"]
    I -->|GURU| K["Masuk Dashboard Guru"]
```

---

## 2. Segmen Presensi Harian (Face Recognition & GPS)
Alur ketika siswa atau guru melakukan absen harian di sekolah.

```mermaid
flowchart TD
    A["Klik Tombol Presensi"] --> B["Sistem Cek Izin Kamera & Lokasi"]
    B --> C["Muat Model AI & Profil Wajah Database"]
    C --> D["Tampilkan Kamera"]
    D --> E{"Wajah Cocok & Lokasi Valid?"}
    E -->|Tidak| F["Status: Wajah/Lokasi Tidak Dikenali"]
    E -->|Ya| G["Ambil Snapshot Foto & Koordinat"]
    G --> H["Kirim Data ke Backend POST /api/presensi"]
    H --> I["Simpan ke Tabel attendances & presensi_logs"]
    I --> J["Tampilkan Notif Sukses"]
    J --> K["Digital Card Berubah Jadi HADIR"]
```

---

## 3. Segmen Kegiatan Belajar Mengajar (KBM) & Jurnal
Alur interaksi harian antara guru yang masuk kelas dan siswa yang belajar.

```mermaid
flowchart TD
    A["Guru Buka Jadwal Hari Ini"] --> B["Pilih Kelas yang Sedang Berlangsung"]
    B --> C["Klik Isi Jurnal"]
    C --> D["Input Topik, Materi, dan Catatan"]
    D --> E{"Ada Tugas/PR?"}
    E -->|Ya| F["Buat Tugas & Upload Lampiran"]
    E -->|Tidak| G["Simpan Jurnal"]
    F --> G
    
    G --> H["Notifikasi Masuk ke HP Siswa di Kelas Tersebut"]
    H --> I["Siswa Buka Notifikasi Tugas"]
    I --> J["Siswa Kerjakan & Upload Jawaban"]
    J --> K["Guru Cek Pengumpulan Tugas"]
    K --> L["Guru Berikan Nilai & Feedback"]
```

---

## 4. Segmen Ulasan (Rating) Pengajaran Guru
Alur bagaimana siswa memberikan umpan balik anonim terhadap cara mengajar guru.

```mermaid
flowchart LR
    A["Siswa Buka Riwayat Jurnal Kelas"] --> B["Klik Beri Ulasan"]
    B --> C["Pilih Rating Bintang 1-5"]
    C --> D["Tulis Komentar Feedback"]
    D --> E["Kirim ke Database"]
    E --> F["Data Masuk ke Kalkulasi Bulanan KPI Guru"]
```

---

## 5. Segmen Kedisiplinan & Poin Siswa
Alur ketika ada pelanggaran tata tertib atau siswa mendapatkan prestasi.

```mermaid
flowchart TD
    A["Guru/Wali Kelas Lapor Kejadian"] --> B["Pilih Siswa & Jenis Poin"]
    B --> C["Upload Bukti Foto (Opsional)"]
    C --> D["Sistem Cek Regulasi Poin"]
    D --> E["Poin Siswa Dipotong/Ditambah"]
    E --> F["Kirim Notifikasi ke HP Siswa & Orang Tua"]
```

---

## 6. Segmen Pembiasaan Positif (Habit Tracker)
Alur pencatatan kegiatan positif harian siswa, seperti Sholat Dhuha atau Literasi.

```mermaid
flowchart TD
    A["Siswa Buka Menu Pembiasaan"] --> B["Pilih Kegiatan (misal: Sholat Dhuha)"]
    B --> C["Upload Foto Bukti Selfie / Kegiatan"]
    C --> D["Kirim Laporan"]
    D --> E["Masuk ke Daftar Tunggu Validasi"]
    E --> F["Guru / Wali Kelas Cek Laporan"]
    F --> G{"Laporan Valid?"}
    G -->|Valid| H["Laporan Disetujui (VERIFIED)"]
    G -->|Bohong / Tidak Valid| I["Laporan Ditolak (INVALID)"]
```

---

## 7. Segmen Penilaian Kinerja Guru (KPI Bulanan)
Alur otomatisasi yang merangkum performa guru di akhir bulan.

```mermaid
flowchart TD
    A["Setiap Akhir Bulan (Cron Job / Manual Trigger)"] --> B["Sistem Menarik Data"]
    B --> C["Kalkulasi: Persentase Kehadiran Mengajar"]
    B --> D["Kalkulasi: Kedisiplinan Mengisi Jurnal"]
    B --> E["Kalkulasi: Rata-rata Rating dari Siswa"]
    
    C --> F["Hitung Nilai Akhir sesuai Bobot kpi_indicators"]
    D --> F
    E --> F
    
    F --> G["Generate Rapor Kinerja Guru"]
    G --> H["Diserahkan ke Kepala Sekolah / Yayasan"]
```
