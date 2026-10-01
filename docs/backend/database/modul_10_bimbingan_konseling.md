# Dokumentasi Database: Modul 10 (Bimbingan Konseling / BK)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul ini adalah pusat penanganan psikologis, bimbingan karir, dan tindak lanjut hukuman disiplin siswa. Modul ini terintegrasi erat dengan Master Kelas (Penempatan Guru BK) dan Modul 4 (Jurnal KBM).

---

## 🗄️ 1. Detail Struktur Tabel Utama

### A. Tabel Relasi Guru BK
#### Tabel `guru_bk_classes` (Dari Modul 1)
Memetakan 1 Guru BK memegang kelas mana saja.
- `guru_bk_id` (FK ke `users`).
- `class_id` (FK ke `classes`).
> [!NOTE]
> **Catatan untuk Modul Kurikulum (Import Excel):** Saat membaca file `.xlsx` untuk *Master Penempatan Kelas*, sistem *Backend* harus diprogram untuk membaca kolom **"Guru BK"** dan langsung mem- *populate* data ke tabel `guru_bk_classes` ini.

### B. Tabel Transaksi Sesi BK
#### Tabel `counseling_requests`
Menampung jadwal pertemuan antara Guru BK dan Siswa.
- `id` (UUID).
- `student_id` (FK ke `users`): Siswa yang dikonseling.
- `guru_bk_id` (FK ke `users`, Nullable): Guru BK yang menangani.
- `initiator` (String): Menandakan siapa yang membuat jadwal.
  - `STUDENT`: Siswa mengajukan curhat/bimbingan mandiri lewat HP.
  - `GURU_BK`: Panggilan paksa/razia dari Guru BK karena poin siswa kritis.
- `topic` (String): Topik konseling (Misal: *Karir*, *Keluarga*, *Kenakalan*).
- `schedule_date` & `schedule_time`: Jadwal pertemuan di ruang BK.
- `description` (Text): Alasan pemanggilan atau detail keluhan awal siswa.
- `status` (String): `PENDING`, `APPROVED` (Jadwal *fix*), `REJECTED`, `COMPLETED` (Sudah selesai).
- `counseling_result` (Text, Nullable): Notulensi atau kesimpulan hasil bimbingan yang diketik oleh Guru BK setelah status berubah menjadi `COMPLETED`.

> [!IMPORTANT]
> **Catatan UI/UX untuk Frontend:**
> - UI Dasbor Guru BK wajib menampilkan Riwayat/Log lengkap bimbingan tiap siswa.
> - UI "Ajukan Bimbingan" di HP Siswa juga wajib menampilkan riwayat bimbingan yang pernah mereka ikuti beserta statusnya.

---

## 🚦 2. Fitur "Sosialisasi Kelas" (Hijacking Jurnal KBM)

Bagaimana jika Guru BK ingin masuk ke sebuah kelas untuk melakukan Sosialisasi (Misal: Bimbingan Karir Kelas 12), padahal Guru BK tidak punya jam mengajar spesifik di master jadwal KBM?

**Solusinya: BUKAN MEMBUAT TABEL BARU.**
Kita menggunakan teknik *"Classroom Hijacking"* atau pembajakan jadwal yang secara arsitektur sama persis dengan fitur **Guru Inval/Pengganti** di Modul 4 (Jurnal).

**Alur Kerja & Desain API (Sistem Input Sosialisasi):**
1. **Intai Jadwal:** Guru BK memilih Tingkat dan Kelas. API *Backend* (`GET /api/schedules?class_id=XYZ&date=...`) akan membalas daftar jadwal mapel asli di kelas tersebut pada hari H.
2. **Pilih Target:** Guru BK memilih salah satu slot mapel (Misal: Pelajaran IPS milik Pak A di jam ke-3).
3. **Eksekusi Bajak:** Saat Guru BK menekan "Simpan Jurnal", *Frontend* menembak `POST /api/journals` dengan payload:
   ```json
   {
       "schedule_id": "<UUID Jadwal IPS Pak A>",
       "class_id": "<UUID Kelas>",
       "subject_id": "<UUID Mapel IPS>",
       "teaching_date": "2026-10-05",
       "topic_material": "Bimbingan Karir / Sosialisasi",
       "is_bk_sosialisasi": true
   }
   ```
4. **Sihir Controller:** *Backend* menyimpan data tersebut ke tabel `journals`. `teacher_id` akan otomatis diisi dengan ID Guru BK yang sedang login `Auth::id()`, BUKAN ID Pak A.
5. **Dampak Otomatis:** Karena jadwal IPS Pak A sudah memiliki data di tabel `journals` (walaupun diisi BK), maka di layar dasbor Pak A status kelasnya akan berubah menjadi `COMPLETED / DIAMBIL ALIH BK`. Sistem tidak akan meneror Pak A untuk mengisi absen KBM tersebut.
