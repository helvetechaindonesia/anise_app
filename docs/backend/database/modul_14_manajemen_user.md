# Dokumentasi UI/UX & API: Modul 14 (Manajemen User & Biodata)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Jika Modul 1 (Autentikasi & RBAC) adalah *Engine Database*, maka Modul 14 ini adalah **Dashboard UI/UX** yang digunakan oleh Tata Usaha / Admin untuk mengoperasikan data tersebut. 

Halaman ini berfungsi layaknya mesin CRM (*Customer Relationship Management*) sekolah. Seluruh modul lain (Tugas, Raport, Disiplin, Perizinan, Aduan, Jurnal) menarik data identitas dari modul ini.

---

## 🛠️ 1. Rencana Antarmuka (UI/UX) Manajemen User

*Frontend* WAJIB menyediakan antarmuka khusus untuk Admin (Tata Usaha) dengan fitur-fitur berikut:

### A. Dashboard Utama "Data Pengguna"
- **Tabel Data:** Menampilkan daftar *user* dengan kolom `Nama`, `Role` (Jabatan), `Status` (Aktif/Blokir), dan tombol Aksi.
- **Filter & Pencarian:** Wajib menyediakan *filter* berdsarkan "Tipe User" (Semua / Pegawai / Siswa) dan pencarian *real-time* (berdasarkan NISN/NIP atau Nama).

### B. Fitur *Upload* Foto Profil (Avatar)
- Admin dan *User* bersangkutan bisa mengubah foto profil (kolom `avatar`).
- UI harus menyediakan alat *Crop* gambar sirkular secara *Client-side* sebelum diunggah ke *server* untuk menghemat ukuran *file*.

### C. Manajemen Status Akun (Kill Switch)
- **Tombol Blokir:** Jika diklik, *Frontend* menembak API untuk mengubah `is_active = false`. Sistem langsung me- *logout* paksa (*kill session*) user tersebut dari seluruh perangkat (berguna jika HP hilang atau siswa dikeluarkan).
- **Fitur Lulus / Alumni (SoftDelete):** Saat siswa lulus, akunnya tidak di- *drop* dari *database*. Cukup jalankan fungsi *Soft Delete* agar data masa lalunya tetap utuh di Modul Raport & Jurnal.

---

## 🚀 2. Rencana API Endpoint & Logic Tersembunyi

*Backend* bertugas melayani antarmuka di atas dengan *endpoint* yang kuat dan aman. Seluruh *endpoint* wajib divalidasi dengan *middleware RBAC* (Pengecekan *Permission*).

### A. Endpoint CRUD User & Profil 
- **`POST /api/users` (Create User):**
  - **Logic:** *Backend* menerima satu beban *request* (JSON) yang berisi biodata (NIK, TTL, Agama). 
  - Jika `role_id` yang dipilih masuk dalam "Spesies Pegawai", *Backend* otomatis membuatkan *record* juga di `staff_profiles`. 
  - Jika "Spesies Siswa", otomatis membuat *record* di `student_profiles`.
- **`PUT /api/users/{id}/avatar` (Upload Foto):**
  - Menerima *file* gambar, menyimpan ke Object Storage/Disk, meresize-nya (misal: max 500x500px), dan menyimpan URL-nya di kolom `avatar`.

### B. Endpoint Keamanan (*Security Ops*)
- **`POST /api/users/{id}/reset-password`:** 
  - Ditembak oleh Admin TU jika ada orang tua/guru yang gaptek dan lupa *password*. Otomatis me-*reset password* menjadi "123456" atau menggunakan tanggal lahir (`birth_date` dengan format ddmmyyyy).
- **`POST /api/users/{id}/toggle-status`:**
  - Fungsi: Membalikkan nilai `is_active` (Blokir/Unblokir).
  - **Trigger Logic:** Jika status berubah menjadi *Blokir*, *Backend* wajib menghapus *Token API* yang sedang aktif dan mengirim *command* FCM Logout ke `user_devices`.

### C. Penjaga Gerbang (*Middleware*)
- *Backend* dilarang keras melakukan validasi *hardcode* tipe *Role* seperti `if (user.role == 'TATA_USAHA')`. 
- **Wajib menggunakan *Permissions***: `if (user.can('manage_users'))`. Ini menjamin agar di kemudian hari, Kepala Sekolah atau peran lain bisa diberi hak akses manajemen *user* melalui tabel `role_permissions` tanpa menyentuh *source code*.

---

## 🕸️ 3. Peta Ketergantungan (Cross-Module Dependencies)

Tabel `users` di Modul 1 ini selalu ditarik datanya oleh modul-modul berikut:
1. **Modul 2 (Presensi):** Membutuhkan `face_embedding` untuk mesin absen AI.
2. **Modul 3 (Perizinan):** Membutuhkan nama *user* pembuat surat.
3. **Modul 5 (Tugas):** Membutuhkan ID Guru pembuat tugas dan ID Siswa pengumpul tugas.
4. **Modul 7 (Gerakan 7K):** Menyimpan *track record* perbuatan baik siswa dan guru *validator*-nya.
5. **Modul 9 (Disiplin):** Melibatkan 3 *User* sekaligus dalam 1 lapor (Pelapor, Terdakwa, dan Validator).
6. **Modul 10 (Bimbingan Konseling):** Pengalihan tugas bimbingan ke Guru BK spesifik.
7. **Modul 13 (Kurikulum):** Pengaturan *Role* struktural di sekolah.
