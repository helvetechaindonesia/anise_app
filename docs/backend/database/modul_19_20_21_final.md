# Dokumentasi Database & API: Modul 19, 20, dan 21 (Kuartal 7 - Final)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 08 Oktober 2026

Tiga modul terakhir ini adalah *Support Systems* yang sangat ringan. Pendekatannya tidak membutuhkan banyak tabel baru karena memanfaatkan fondasi dari modul-modul sebelumnya (terutama Modul 1 dan Modul 15).

---

## ⚖️ 1. Modul 19: Privacy and Legal
Menangani Kebijakan Privasi (*Privacy Policy*) dan Syarat & Ketentuan (*Terms of Service*).

- **Pendekatan Database:** **TIDAK ADA TABEL BARU.**
- **Logika:** Teks panjang legalitas ini disimpan menggunakan tabel `school_settings` (dari Modul 15 Manajemen Sekolah) dengan sistem *Key-Value*.
  - `key`: `privacy_policy` -> `value`: `<p>Teks HTML privasi...</p>`
  - `key`: `terms_of_service` -> `value`: `<p>Teks HTML syarat...</p>`
- Ini memungkinkan Admin Tata Usaha mengedit isi dokumen legal kapan saja dari *Dashboard* tanpa harus mengubah kodingan *Frontend*.

---

## 🛟 2. Modul 20: Bantuan dan Keamanan
Pusat bantuan mandiri untuk *user* (FAQ) dan pusat pengaturan keamanan akun.

- **Pendekatan Database (Bantuan):** Dibuat 1 tabel baru yaitu **`faqs`**.
  - `id` (UUID)
  - `question` (String): Pertanyaan (Misal: "Bagaimana cara reset password?")
  - `answer` (Text): Jawaban.
  - `category` (String): Pengelompokan (Misal: `AKUN`, `JURNAL`, `NILAI`).
  - `order_index` (Integer): Urutan tampil di UI.
  - `is_active` (Boolean): *Toggle* nyala/mati.

- **Pendekatan Database (Keamanan):** **TIDAK ADA TABEL BARU.**
  - Fitur Ganti Password, Reset PIN, dan Ganti Email sepenuhnya me-*reuse* logika dari Modul 1 (Autentikasi). 

---

## 👨‍💻 3. Modul 21: Developer Mode
Fitur eksklusif untuk perbaikan dan *debugging* aplikasi secara *live* tanpa membongkar *server*.

- **Pendekatan Database:** **TIDAK ADA TABEL BARU.**
- **Logika Akses:** Hanya terbuka bagi *User* yang memiliki *Role Inti* = `SUPER_ADMIN`.
- **Fitur di UI:**
  - *Log Viewer:* Membaca file `laravel.log` secara visual dari dalam aplikasi.
  - *Clear Cache Button:* Tombol ajaib untuk menjalankan perintah `php artisan cache:clear` melalui API `POST /api/dev/clear-cache`.
  - *Bypass Feature:* Memungkinkan tim Dev berpura-pura *login* sebagai murid (Impersonasi) untuk mengecek *bug* laporan (*Impersonate User*).
