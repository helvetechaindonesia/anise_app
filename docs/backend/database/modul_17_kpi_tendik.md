# Dokumentasi Database & API: Modul 17 (Penilaian Kinerja / KPI Tendik)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 06 Oktober 2026

Modul 17 untuk Tendik (Tenaga Pendidik / Guru) telah direfaktor total. Sistem "Poin/Skor Angka" dihapus seutuhnya untuk menghindari ambiguitas dan menyesuaikan standar resmi pemerintah (E-Kinerja PMM). Sistem diganti menjadi penilaian murni *Subjektif (Kualitatif)* yang berbasiskan data laporan sistem.

---

## 🏗️ 1. Struktur Database Baru

Menghapus tabel lama (`kpi_indicators` & `teacher_kpi_period_summaries`), dan digantikan dengan 1 tabel utama:

### Tabel `teacher_evaluations` (Raport Kinerja Resmi)
Menyimpan hasil ketukan palu (keputusan) Kepala Sekolah setiap 1 semester.

- `id` (UUID)
- `teacher_id` (UUID): Guru yang dinilai.
- `evaluator_id` (UUID): Kepala Sekolah yang menilai.
- `academic_year_id` (UUID): Parameter Waktu (Mewakili 1 Semester).
- `praktik_kinerja` (Enum): `DI_BAWAH_EKSPEKTASI`, `SESUAI_EKSPEKTASI`, `DI_ATAS_EKSPEKTASI`.
- `perilaku_kerja` (Enum): Sama dengan atas.
- `predikat_kinerja` (Enum): `SANGAT_KURANG`, `KURANG`, `CUKUP`, `BAIK`, `SANGAT_BAIK`.
- `notes` (Text): Catatan / pembinaan / pesan sponsor dari Kepala Sekolah.
- `is_published` (Boolean): 
  - `false`: Status "Draft". Kepsek baru menekan tombol **"Simpan"**. Guru belum bisa melihatnya.
  - `true`: Status "Resmi". Kepsek menekan tombol **"Kirim Penilaian"**. Raport ini permanen dan dikirim ke *dashboard* guru.

*Constraint:* `Unique(teacher_id, academic_year_id)` -> 1 guru hanya punya 1 raport dalam 1 semester (Ganjil/Genap).

---

## 📱 2. Rencana Hak Akses & UI/UX

### A. Untuk *User* Guru (Akses *Read-Only* ke Diri Sendiri)
Guru tidak lagi melihat "Angka Poin KPI". Menu di- *rename* menjadi **"Analisa Penilaian Sistem"**. Di dalamnya terdapat 2 Tab:

1. **Tab 1: Riwayat Analisa (Harian)**
   - *Logic API:* *Backend* tidak mengambil data dari Modul 17, melainkan melakukan *Query Join* secara dinamis ke Modul 2 (Presensi) dan Modul 4 (Jurnal).
   - *Contoh Output:* Menampilkan *feed* kapan saja guru lupa absen, kapan lupa mengisi jurnal, dan *Rating Review* yang masuk dari siswa hari ini.
2. **Tab 2: Raport Penilaian Resmi (Per Semester)**
   - Mengambil data dari tabel `teacher_evaluations` yang `is_published = true`.

### B. Untuk *User* Kepala Sekolah (Menu Eksklusif: "Penilaian Tendik")
- Menampilkan daftar guru yang belum/sudah dinilai di semester berjalan.
- **Tampilan *Split-Screen* Saat Menilai:**
  - *Sebelah Kiri (Bahan Pertimbangan):* Menarik rangkuman "Riwayat Analisa Harian" milik guru tersebut (Rata-rata *Rating* siswa, persentase telat/absen, persentase jurnal kosong).
  - *Sebelah Kanan (Form Penilaian):* Form radio button *Praktik Kinerja*, *Perilaku Kerja*, dan Kolom Catatan. Serta 2 tombol: "Simpan" (Draft) & "Kirim" (Publish).

---

## 🕸️ 3. Ketergantungan (Cross-Module Dependencies)
- **Modul 2 & 4:** Data mentah "Bahan Pertimbangan Kepsek" ditarik langsung (*on the fly*) secara periodik dari rekam jejak jurnal dan presensi guru di semester tersebut.
- **Modul 13 (Kurikulum):** Filter waktu menggunakan `academic_year_id` sebagai batasan pembagian 1 semester.
