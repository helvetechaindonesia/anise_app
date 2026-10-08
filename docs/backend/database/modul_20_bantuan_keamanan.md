# Dokumentasi Database & API: Modul 20 (Bantuan & Keamanan)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 08 Oktober 2026

Modul ini merupakan lapis perlindungan ganda (Security) bagi pengguna, serta pusat pengetahuan mandiri (FAQ) agar pengguna tidak terus-terusan membuat tiket komplain ke Helpdesk.

---

## 🗄️ 1. Struktur Database

Dua tabel utama disiapkan untuk mengelola modul ini:

### A. Tabel `faqs` (Pusat Bantuan)
- `id` (UUID)
- `question` (String): Pertanyaan yang sering diajukan.
- `answer` (Text): Jawaban resmi.
- `category` (String): `AKUN`, `JURNAL`, `NILAI`, dsb.
- `order_index` (Integer): Urutan tampil (FAQ paling populer ditaruh di atas).
- `is_active` (Boolean): Sakelar nyala/mati.

### B. Tabel `security_audit_logs` (Buku Hitam Keamanan)
Setiap aplikasi skala *Enterprise* wajib memiliki jejak *Audit Log* untuk melacak anomali keamanan.
- `id` (UUID)
- `user_id` (FK `users`)
- `event_type` (String): `FAILED_LOGIN_ATTEMPT`, `PASSWORD_CHANGED`, `LOGIN_NEW_DEVICE`.
- `ip_address` (String): IP perangkat.
- `user_agent` (String): Jenis HP/Browser yang digunakan.
- `metadata` (Text/JSON): Menyimpan detail ekstra seperti kordinat lokasi login.

---

## 🚀 2. Rencana API & Logic
- **Pendeteksi Perangkat Baru:** Setiap kali *user login*, API Modul 1 akan menembak data ke `security_audit_logs`. Jika `user_agent` atau `ip_address` berbeda dari sebelumnya, Modul 18 (Notifikasi) akan mengirim email peringatan: *"Login baru terdeteksi dari perangkat tidak dikenal"*.
- **Blokir Brute Force:** Jika `FAILED_LOGIN_ATTEMPT` tercatat lebih dari 5 kali dalam 10 menit untuk *user* yang sama, akun akan terkunci (*Locked*) secara otomatis.
