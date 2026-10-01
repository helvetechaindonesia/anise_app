# Dokumentasi Database: Modul 1 (Autentikasi, Profil, & RBAC)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 01 Oktober 2026

Dokumen ini membedah struktur *database* untuk Modul 1, yang merupakan pondasi paling dasar dari seluruh ekosistem aplikasi Anise. Jika modul ini goyah, seluruh aplikasi akan hancur.

---

## 🏗️ 1. Filosofi Arsitektur Dasar

Pada awal pengembangan, aplikasi menggunakan sistem yang kaku (misal: penentuan kasta pengguna menggunakan `Enum` keras di dalam tabel `users`). Di MVP 1.A ini, arsitektur dirombak total menjadi **Role-Based Access Control (RBAC)** modular dan berstandar *Enterprise*.

**Konsep Utama:**
1. **Pemisahan Identitas (Users) dan Fisik (Profiles):** Tabel `users` hanya menyimpan data keamanan dan *login*. Data yang bersifat fisik atau akademis dipisah ke tabel spesifik (`guru_profiles` / `siswa_profiles`).
2. **Fleksibilitas Jabatan:** Seorang guru tidak di-cap statis. Penugasannya bisa berganti-ganti setiap tahun (menjadi Wakasek, Wali Kelas, dll) melalui tabel *Pivot* khusus.
3. **Keamanan Ekstra:** Menggunakan UUID agar *ID User* tidak bisa ditebak (anti-scrapping) dan mengadopsi fitur `SoftDeletes` untuk mencegah data terhapus permanen dari *database*.

---

## 🗄️ 2. Detail Struktur Tabel

### A. Core Authentication (Keamanan Inti)

#### 1. Tabel `users`
Merupakan tabel pusat dari seluruh nyawa di dalam sistem.
- `id` (UUID): Kunci utama yang panjang dan tidak bisa ditebak.
- `full_name`, `username`, `email`: Identitas dasar.
- `nik` (String): Nomor Induk Kependudukan (Universal untuk semua).
- `gender` (Enum: L/P): Jenis kelamin, dipusatkan di sini agar tidak *redundant* di profil.
- `password_hash`: *Password* terenkripsi (Bcrypt).
- `face_biometric` (Text): Menyimpan enkripsi pemetaan geometri wajah hasil pindaian AI, digunakan untuk verifikasi absen.
- `phone`, `address`: Data kontak dasar.
- `role_id` (UUID): Kunci tamu (FK) yang mengarah ke tabel `roles`.
- `is_active` (Boolean): *Switch* untuk mematikan akun tanpa harus menghapus datanya.
- `deleted_at`: Sistem *SoftDelete*.

#### 2. Tabel `user_sessions_history`
Berfungsi sebagai "CCTV Sistem" untuk mendeteksi anomali *login*.
- `user_id` (FK): Pemilik sesi.
- `ip_address`: Melacak lokasi jaringan.
- `user_agent`: Mencatat apakah *user login* pakai Android, iPhone, atau Chrome PC.
- `login_at` & `logout_at`: Waktu sesi aktif.

#### 3. Tabel `user_devices`
Infrastruktur *Push Notification* otomatis.
- `user_id` (FK): Pemilik HP.
- `device_id`: Serial/IMEI perangkat fisik.
- `fcm_token` (String): *Token* unik dari Firebase Cloud Messaging. Digunakan *backend* untuk menembakkan notifikasi peringatan/tugas agar HP berbunyi seperti WhatsApp.
- `device_type`: OS perangkat (android/ios).

---

### B. Core Profiles (Data Fisik Akademis)

Untuk mencegah tabel `users` membengkak ratusan kolom, data akademis dipecah ke dua tabel ekstensi. Keduanya menggunakan `user_id` sebagai *Primary Key* sekaligus *Foreign Key* (relasi 1-to-1 mutlak).

#### 1. Tabel `guru_profiles`
- `nip_nuptk` (String): Nomor Induk Pegawai.
- `employment_status`: Status kepegawaian (PNS / Honorer / GTY).
- `deleted_at`: *SoftDelete*.

#### 2. Tabel `siswa_profiles`
- `nis` & `nisn`: Nomor Induk Siswa.
- `academic_year_id` (FK): Menyimpan data "Tahun Angkatan Masuk" si siswa.
- `parent_name`: Nama Wali Murid untuk keperluan kontak darurat BK.
- `deleted_at`: *SoftDelete*.

---

### C. RBAC (Role-Based Access Control) & Penugasan Tambahan

Sistem dinamis untuk mengatur hak akses (*Permissions*) tanpa perlu bongkar kode sumber (*Hardcode*).

#### 1. Tabel `roles`
Kasta utama pengguna.
- `name`: (Contoh: KEPALA_SEKOLAH, GURU, SISWA, TATA_USAHA).
- `is_guru_wali`: Tanda khusus apakah *Role* ini berhak mengampu sebuah kelas (Wali Kelas).

#### 2. Tabel `permissions` & `role_permissions`
- `permissions.name`: Aksi spesifik (Contoh: `create-jurnal`, `approve-presensi`, `delete-siswa`).
- `role_permissions` (Pivot): Menyambungkan "Role GURU" dengan izin "create-jurnal". Jika Yayasan meminta jabatan baru, Admin cukup menyentang *permissions* ini di *dashboard* tanpa bantuan *programmer*.

#### 3. Tabel `jabatans` (Master Data Jabatan)
Daftar jabatan struktural yang ada di sekolah (Contoh: WAKASEK KURIKULUM, PEMBINA OSIS).

#### 4. Tabel `structural_assignments` (Pivot Karir)
Mencatat sejarah karir seorang Guru.
- `guru_id` (FK ke users).
- `jabatan_id` (FK ke jabatans).
- `academic_year_id`: *Track record* berdasarkan tahun ajaran (Tahun lalu Wakasek, tahun ini Guru biasa).

#### 5. Otoritas Tambahan: Wali Kelas
Wali kelas **tidak dibuatkan tabel/kolom profil khusus**, melainkan dihubungkan langsung dari tabel `classes` -> `wali_kelas_id` (FK ke `users`). Ini menjamin 1 Kelas hanya bisa dipegang oleh 1 Guru dalam 1 Tahun Ajaran, menghindari kerancuan data.

---

### D. Sistem Gamifikasi (Poin Universal)

#### Tabel `user_point_balances`
Karena Siswa memiliki "Poin Kedisiplinan" dan Guru memiliki "Poin KPI", sistem disatukan agar *engine* kalkulasinya efisien.
- `user_id` (FK).
- `point_type`: Membedakan jenis celengan poin (Contoh: KEDISIPLINAN, KPI_PERFORMANCE).
- `total_points` (Integer): Jumlah saldo poin saat ini.

---

## 🔑 Aturan Emas Pengembangan (Modul 1)
1. **Tidak Boleh Hapus Permanen:** Apapun alasannya, record di tabel `users` tidak boleh di-*query* `DELETE`. Selalu gunakan metode `destroy()` dari Laravel Eloquent agar fitur *SoftDelete* terpicu.
2. **Pengecekan Akses (Gate):** Di level *Backend* (API/Controller), pengecekan hak akses tidak boleh mengecek *Role* (Contoh Salah: `if(role == 'GURU')`). Pengecekan **wajib** menggunakan *Permissions* (Contoh Benar: `if($user->can('create-jurnal'))`). Ini menjamin skalabilitas jika jabatan baru bermunculan.
