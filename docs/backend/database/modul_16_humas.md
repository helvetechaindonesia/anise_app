# Dokumentasi Database & API: Modul 16 (Humas & Pengumuman)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 06 Oktober 2026

Modul 16 berfungsi sebagai pusat informasi (Mading Digital) dan sistem penyiaran (Broadcast/Push Notification) di aplikasi Anise. Fitur ini dirancang sangat ringan dan efisien untuk meminimalkan beban input Tata Usaha.

---

## 🗄️ 1. Ekosistem Tabel Humas

Hanya terdapat 2 tabel utama dalam modul ini.

### A. Tabel `announcements` (Master Pengumuman)
Tabel ini dioptimalkan untuk diisi secara massal melalui *Upload File Excel*. Oleh karena itu, *field* waktunya diubah menjadi format tanggal (*Date*) biasa, sedangkan detail spesifik waktu ditaruh di dalam teks konten.

- `id` (UUID).
- `title` (String): Judul pengumuman (Contoh: "Pengambilan Raport Ganjil").
- `content` (Text, Nullable): Berisi rincian lengkap. (Misal: "Sesi 1: Jam 08.00 s/d 10.00 di GOR Sekolah").
- `agenda_start_date` (Date): Tanggal mulai. Sangat penting karena digunakan *Backend* untuk mengurutkan daftar pengumuman di aplikasi agar agenda yang terdekat muncul di paling atas.
- `agenda_end_date` (Date, Nullable): Tanggal selesai. Dikosongkan jika agenda hanya 1 hari.
- `target_audience` (Enum): `ALL`, `STUDENT`, `TEACHER`, `TATA_USAHA`, `KEPALA_SEKOLAH`. Menentukan siapa yang berhak melihat pengumuman ini di layar HP-nya.
- `has_been_pushed` (Boolean): *Default: false*. Sebagai penanda *state* di UI apakah pengumuman ini sudah dikirim Notifikasi *Push*-nya atau belum.
- `author_id` (FK ke `users`): Menyimpan ID admin yang mengunggah pengumuman.
- `deleted_at`: Menggunakan sistem *Soft Delete* agar arsip pengumuman lama tidak menumpuk tapi tetap tersimpan.

### B. Tabel `announcement_reads` (Read Receipts / Jejak Baca)
Berfungsi agar sekolah tahu siapa saja *User* yang sudah membaca pengumuman penting.
- `id` (UUID).
- `announcement_id` (FK ke `announcements`).
- `user_id` (FK ke `users`).
- `read_at` (Timestamp): Otomatis mencatat kapan *User* pertama kali membuka detail pengumuman. 
- *Constraint:* `Unique(announcement_id, user_id)` agar *user* yang membuka pengumuman berulang kali tidak menyebabkan data ganda.

---

## 🚀 2. Rencana API Endpoint & Logic Tersembunyi

### A. Alur *Upload* Excel (Untuk TU)
- **`POST /api/announcements/import`**:
  - *Backend* menerima *file* Excel berisi 4 kolom: `Judul`, `Isi`, `Tanggal Mulai`, `Tanggal Selesai`, dan `Target`.
  - Secara otomatis *Backend* men-*generate* `id`, mencatat waktu `created_at`, dan mengatur `has_been_pushed = false` untuk semua baris yang masuk.

### B. Alur Eksekusi Push Notification (Tombol Broadcast)
- **`POST /api/announcements/{id}/push`**:
  - Endpoint ini dipicu saat Admin menekan tombol "Kirim Notifikasi" di *Dashboard*.
  - **Logic Filter Target:** *Backend* mengecek `target_audience`. Jika targetnya adalah `STUDENT`, *Backend* akan melakukan *Query* ke tabel `users` untuk mencari semua siswa yang memiliki `fcm_token` di tabel `user_devices`.
  - Setelah *looping* pengiriman berhasil, ubah *state* di tabel: `UPDATE announcements SET has_been_pushed = true WHERE id = {id}`.
  - UI *Frontend* otomatis merubah tombol "Kirim Notifikasi" menjadi teks statis warna abu-abu bertuliskan "Terkirim".

### C. Alur Keterbacaan (Read Receipt)
- **`GET /api/announcements/{id}`**:
  - Setiap kali *User* (Murid/Guru) membuka detail pengumuman di aplikasi HP, *Frontend* memanggil *endpoint* ini.
  - Secara *background*, API ini akan mengecek apakah sudah ada data di `announcement_reads`. Jika belum, sistem akan men- *generate* rekaman baca (*insert*) tanpa menghalangi *response* ke HP *User*.

---

## 🕸️ 3. Peta Ketergantungan (Cross-Module Dependencies)

1. **Modul 1 (Autentikasi):** Membutuhkan data *roles* dan `fcm_token` di `user_devices` untuk mengirimkan *Push Notification*.
2. **Modul 18 (Notifikasi):** Seluruh hasil dari Modul Humas ini terintegrasi erat dengan *Actionable Notifications* di Modul 18.
