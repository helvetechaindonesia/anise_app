# Dokumentasi Database: Modul 7 (G-7 KAIH / Pembiasaan & Karakter)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul ini berevolusi dari sekadar "Pembiasaan Siswa" menjadi **G-7 KAIH** (Kegiatan Agama, Ibadah, dan Harian), yang berlaku untuk **SELURUH USER** (Siswa, Guru, Staff, hingga Kepala Sekolah). 

> [!NOTE]
> Modul ini menganut prinsip **"Dosa Tanggung Sendiri"**. Tidak ada lagi sistem verifikasi/ACC yang merepotkan dari atasan/guru. Apa yang dicentang oleh *user*, itulah yang tersimpan di *database*.

---

## 🏗️ 1. Filosofi Extend Ibadah Khusus Muslim

Berdasarkan *request* klien, terdapat fitur *Extend Ibadah* (Pemantauan ibadah harian seperti Sholat 5 Waktu & Baca Qur'an). Agar fitur ini cerdas dan tidak memaksa *user* non-muslim:
- **Tabel `users`** telah disuntikkan kolom `religion` (Agama).
- Jika `religion == 'ISLAM'`, maka *Frontend* akan memunculkan menu "Extend Ibadah Khusus" yang datanya tersimpan sangat hemat di tabel `user_prayer_logs`.
- Jika bukan Islam, maka *user* hanya akan mengakses menu pembiasaan umum (seperti Gotong Royong, dll) yang tersimpan di tabel `user_habit_logs`.

---

## 🗄️ 2. Detail Struktur Tabel (KAIH)

Tabel di Modul 7 ini sangat ramping dan dioptimalkan untuk menampung jutaan baris data tanpa membuat *server down*.

### A. Master Data
#### 1. Tabel `habits` (Katalog Kegiatan Umum)
Menyimpan daftar kegiatan pembiasaan (berlaku untuk semua agama).
- `id` (UUID).
- `code` (String): Kode kegiatan (Misal: HB-001).
- `title` (String): Nama kegiatan (Misal: "Membersihkan Kelas", "Senam Pagi").
- `category` (String): Kategori (Misal: Kedisiplinan, Sosial, Kesehatan).

---

### B. Pencatatan Harian (Logs)
#### 2. Tabel `user_habit_logs` (Log Pembiasaan Umum)
Tabel ini digunakan jika *user* melakukan kegiatan dari tabel `habits`.
- `id` (UUID).
- `user_id` (FK ke users): Siapa yang melakukan.
- `habit_id` (FK ke habits): Kegiatan apa yang dilakukan.
- `logged_date` (Date): Tanggal pelaksanaan.
- `attachment_url` (String, Nullable): Opsional jika user ingin melampirkan foto kegiatan.
- `notes` (Text, Nullable): Jurnal singkat kegiatan.

#### 3. Tabel `user_prayer_logs` (Log Ibadah Khusus Muslim - Extend)
Ini adalah tabel mahakarya penghemat *database*. Daripada membuat 6 baris data per hari per *user*, tabel ini meringkas semuanya menjadi **1 baris saja per hari per user**.
- `id` (UUID).
- `user_id` (FK ke users).
- `logged_date` (Date): Tanggal ibadah.
- `is_subuh`, `is_dhuhur`, `is_asar`, `is_maghrib`, `is_isya`, `is_quran` (Boolean): Bernilai `true` jika dikerjakan, `false` jika bolong.
- **Batasan (*Constraint*):** Terdapat aturan `unique` ganda pada kolom `user_id` dan `logged_date`, yang memastikan 1 user tidak bisa memiliki 2 baris data di hari yang sama.

---

## 👁️ 3. Mekanisme Pemantauan Berjenjang (Tanpa Hardcode)

Walaupun tidak ada fitur Verifikasi/ACC, aplikasi tetap membutuhkan fitur *Dashboard Pemantauan* untuk melihat tingkat keshalehan/kedisiplinan *user*. Fitur ini **TIDAK MENGGUNAKAN TABEL BARU**, melainkan murni memanfaatkan *query* ke RBAC (Modul 1):

1. **Pemantauan Siswa:** Dilakukan oleh Guru Wali. API cukup melakukan *join* ke tabel `guru_wali_students` untuk mencari siapa saja murid dari guru yang sedang *login*.
2. **Pemantauan Tenaga Pendidik (Guru & Staff):** Dilakukan oleh Kepala Sekolah. API cukup memfilter data log milik *user* yang memiliki *role* GURU atau STAFF.
3. **Pemantauan Kepala Sekolah:** Kepala sekolah memantau dirinya sendiri (*Self-Reflection*).
