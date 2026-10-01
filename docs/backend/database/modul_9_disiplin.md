# Dokumentasi Database: Modul 9 (Penegakan Disiplin Siswa)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul 9 dikhususkan sebagai sentra penegakan hukum dan kedisiplinan siswa. Modul ini terisolasi dari sistem Helpdesk (Modul 8) dan BK, meskipun data akhirnya akan mengalir ke BK.

---

## 🏗️ 1. Filosofi Arsitektur (Sistem Penyatuan & 1-Pintu)

Pada awal perancangan, terdapat 2 tabel terpisah (`laporan_telat_siswa` dan `disiplin_reports`) dengan alur birokrasi yang panjang (ACC berjenjang sampai 4 tingkat). Di MVP 1.A, struktur ini **dilebur dan disederhanakan**:

1. **Sistem ACC 1 Pintu:** Laporan pelanggaran hanya butuh di-ACC 1 kali oleh **Guru Wali**. Setelah ditekan ACC, data langsung berstatus `APPROVED` (Valid). Wali Kelas, Guru BK, Kesiswaan, dan Kepala Sekolah hanya bertindak sebagai **Penerima Tembusan (Read-Only)**.
2. **Peleburan Tabel:** Semua jenis pelanggaran (Telat, Bolos, Seragam, Kenakalan) disatukan ke dalam satu tabel master `discipline_reports`.

---

## 🗄️ 2. Detail Struktur Tabel

### Tabel `discipline_reports` (Master Pelanggaran)
Tabel sentral untuk mencatat seluruh daftar dosa kedisiplinan siswa.

- `id` (UUID).
- `student_id` (FK ke `users`): Tersangka / Siswa yang melanggar.
- `reporter_id` (FK ke `users`): Pelapor (Guru / Tendik / Satpam). **Siswa dilarang keras melaporkan di menu ini.**
- `category` (String): Terdiri dari `TERLAMBAT`, `KENAKALAN`, `SERAGAM`, `BOLOS`.
- `point_rule_id` (FK ke `point_rules`, Nullable): Jembatan penghubung ke Modul Poin. Berfungsi untuk mendeteksi "Aturan/Pasal" apa yang dilanggar sehingga sistem bisa otomatis memotong poin siswa saat di-ACC.
- `description` (Text): Alasan telat atau deskripsi kronologi kenakalan.
- `attachment_url` (String, Nullable): Wajib disediakan *Frontend* untuk melampirkan bukti foto (Misal: Foto barang sitaan, foto siswa rambut gondrong).
- `violation_time` (Timestamp): Waktu presisi kejadian (Sangat krusial untuk mencatat jam berapa anak telat masuk gerbang).
- `status` (String): `PENDING`, `APPROVED` (Valid), `REJECTED`.
- `approved_by` (FK ke `users`, Nullable): Menyimpan jejak digital (*audit trail*) siapa Guru Wali yang berani memvalidasi pelanggaran tersebut.

---

## 🚦 3. Catatan Penting Untuk Frontend (UI/UX) & Controller

Ada 2 tantangan logika bisnis yang sangat kompleks di Modul 9 ini yang wajib ditangani di level *Controller* & UI:

### A. Solusi "Peran Ganda" (Kantong UI Terpisah)
Seorang Guru X bisa menjabat sebagai **Guru Wali** (hak memvalidasi) sekaligus **Wali Kelas/BK** (hak menerima tembusan). Agar UI Guru X tidak rancu, Frontend **WAJIB** membuat 2 *tab* atau kantong terpisah:
- **Kantong Validasi:** Menampilkan `discipline_reports` dengan status `PENDING` (Khusus untuk Guru Wali).
- **Kantong Riwayat/Tembusan:** Menampilkan laporan berstatus `APPROVED` (Khusus untuk tampilan Wali Kelas / BK / Kesiswaan).

### B. "Magic Merge" (Khusus Kategori BOLOS)
Untuk mencegah data ganda (siswa dipotong poinnya 2x untuk 1 kesalahan bolos yang sama):
- Jika Guru A melaporkan Siswa B `BOLOS` di Modul 9...
- **DAN** di waktu/jam pelajaran yang sama, Guru C (lewat Jurnal Modul 4) juga men-centang absen Siswa B sebagai `BOLOS/ALFA`...
- Maka saat Guru Wali menekan tombol `APPROVED`, *Backend* harus secara otomatis mendeteksi kecocokan waktu ini dan melakukan *Merge* (Penyatuan data). Sehingga mutasi pemotongan poin (`points_change`) untuk siswa B tetap dihitung 1 kali saja.
