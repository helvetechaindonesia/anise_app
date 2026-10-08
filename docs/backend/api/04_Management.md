# Dokumentasi API - Grup 4: Manajemen Sekolah & Fasilitas

## 🏫 Modul 15: Manajemen Sekolah
**Base URL:** `/api/school`
**Controller:** `SchoolController`

### 1. Pengaturan Geofence
- **Endpoint:** `GET /geofence` dan `POST /geofence`
- **Body Request:** `lat`, `lng`, `radius` (meter).
- **Notes:** Parameter ini krusial dan dipakai oleh `AttendanceController` untuk memblokir presensi dari luar area sekolah.

---

## 🛠️ Modul 8: Helpdesk & Pengaduan
**Base URL:** `/api/helpdesk`
**Controller:** `HelpdeskController`

### 1. Lapor Kerusakan Fasilitas (Siswa)
- **Endpoint:** `POST /`
- **Body Request:** `report_title`, `report_text`, `is_anonymous`, `image`.
- **Notes:** Bisa digunakan untuk melapor proyektor rusak, AC bocor, dll. Jika `is_anonymous` true, nama tidak akan ditampilkan ke TU.

### 2. Daftar Laporan (TU / Sarpras)
- **Endpoint:** `GET /all`
- **Middleware:** `role:TATA_USAHA`

---

## 📨 Modul 11: Surat Menyurat
**Base URL:** `/api/letters`
**Controller:** `LetterController` (Boilerplate)

*Fitur belum diimplementasikan.*
- Arsip digital untuk surat masuk dan surat keluar sekolah.

---

## 🪑 Modul 12: Sarpras (Inventaris)
**Base URL:** `/api/inventory`
**Controller:** `InventoryController` (Boilerplate)

*Fitur belum diimplementasikan.*
- Katalog barang, sistem pinjam-kembali (Misal: Pinjam LCD Proyektor, Kamera, Bola Basket).

---

## 📢 Modul 16: Humas & Pengumuman
**Base URL:** `/api/announcements`
**Controller:** `AnnouncementController` (Boilerplate)

*Fitur belum diimplementasikan.*
- Penyiaran informasi massal (*Broadcast*) yang terintegrasi dengan Firebase Cloud Messaging (Push Notifications).

---

## 📈 Modul 17A: KPI Tendik
**Base URL:** `/api/kpi`
**Controller:** `KpiController` (Boilerplate)

*Fitur belum diimplementasikan.*
- Form penilaian Kepala Sekolah terhadap performa guru (berdasarkan absensi dan kepatuhan pengisian Jurnal).
