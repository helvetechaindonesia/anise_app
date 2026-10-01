# Dokumentasi Database & API: Modul 15 (Manajemen Sekolah)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul 15 adalah inti dari **Konfigurasi Global & White-Labeling** aplikasi Anise. Modul ini memungkinkan aplikasi untuk digunakan oleh institusi manapun tanpa perlu menyentuh *source code*. Modul ini bersifat independen dan sering di-*query* oleh modul lain.

---

## ⚙️ 1. Ekosistem Tabel Manajemen Sekolah

Hanya terdapat 2 tabel utama dalam modul ini yang mengatur identitas dan batas fisik sekolah.

### A. Tabel `school_settings` (Identitas & Konfigurasi)
Tabel ini menggunakan pola *Key-Value Pair* agar skemanya fleksibel tanpa perlu menambah kolom baru (menghindari migrasi terus-menerus).
- `id` (Primary Key).
- `setting_key` (String, *Unique*): Nama variabel konfigurasi.
- `setting_value` (Text, Nullable): Nilai konfigurasi. Bisa berupa angka, string, URL gambar, atau bahkan string JSON.

**Contoh Data Wajib yang Harus Tersedia:**
1. `school_name` -> "SMA N 1 Peunaron"
2. `school_npsn` -> "10123456"
3. `school_logo_url` -> "https://storage.com/logo.png"
4. `headmaster_name` -> "Drs. Budi Santoso"
5. `headmaster_nip` -> "198001012005011003"
6. `app_timezone` -> "Asia/Jakarta"

### B. Tabel `geofence_locations` (Batas Fisik / Zonasi GPS)
Infrastruktur yang mendasari kecerdasan Modul 2 (Presensi). Mengunci aplikasi agar sadar lokasi.
- `id` (UUID).
- `name` (String): Nama zona (Misal: *Gerbang Utama*, *Gedung Praktik*).
- `latitude` (Decimal): Titik kordinat X.
- `longitude` (Decimal): Titik kordinat Y.
- `radius_meters` (Integer): Luas toleransi batas area presensi dari titik pusat (Misal: `50` meter).
- `is_active` (Boolean): Jika *false*, zona ini tidak bisa dipakai untuk absen.

---

## 🚀 2. Rencana UI/UX & API Endpoint

Saat ini, antarmuka untuk mengatur konfigurasi ini masih kosong. *Frontend* dan *Backend* wajib mengimplementasikan hal berikut:

### A. Fitur "Pengaturan Aplikasi" (UI)
- **Tab Identitas Sekolah:** Formulir untuk mengunggah Logo Sekolah, Nama Sekolah, dan detail Kepala Sekolah.
- **Tab Zona Presensi:** Terintegrasi dengan *Google Maps* atau *Leaflet.js*. Admin cukup menggeser *pin* di atas peta, dan radius lingkarannya akan langsung terlihat secara visual. Otomatis mendapatkan nilai *Latitude* dan *Longitude*.

### B. Endpoint `school_settings`
- **`GET /api/settings`:** Menarik semua *setting* yang sifatnya publik (Logo, Nama Sekolah) agar *Frontend* bisa merender tampilan beranda sebelum *login*.
- **`PUT /api/settings`:** Endpoint bagi Admin (Superadmin) untuk mengirim *array* JSON berisi *key-value* yang ingin di-*update*.

### C. Endpoint `geofence_locations`
- **`POST /api/geofence`:** Menyimpan zona baru dari hasil klik *pin* di peta UI.
- **Logika Validasi Presensi (Di Modul 2):** *Backend* secara *real-time* harus membandingkan GPS *User* (hasil POST presensi wajah) dengan `latitude/longitude` zona aktif menggunakan **Rumus Haversine**. Jika jarak > `radius_meters`, berikan *response* error `403 Out of Bounds`.

---

## 🕸️ 3. Peta Ketergantungan (Cross-Module Dependencies)

Tabel di Modul 15 ditarik datanya oleh:
1. **Seluruh Frontend:** Butuh `school_logo_url` dan `school_name` untuk kosmetik aplikasi.
2. **Modul 2 (Presensi):** Ketergantungan mutlak pada `geofence_locations` untuk validasi titik absen.
3. **Modul 6 (Raport):** Menarik `headmaster_name` dan NIP dari `school_settings` untuk merender PDF Tanda Tangan Kepsek di akhir semester.
4. **Modul 10 & 11 (Surat Menyurat):** Menarik KOP Surat dari identitas yayasan di `school_settings`.
