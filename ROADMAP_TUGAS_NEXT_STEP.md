# 📌 ROADMAP & CHECKLIST STANDARISASI FITUR TUGAS & PENILAIAN (ANISE APP)

> [!IMPORTANT]
> **PENGINGAT KERAS / PIN UTAMA UNTUK SESI BERIKUTNYA:**
> Dokumen ini adalah acuan resmi pekerjaan berikutnya. Jika user masuk kembali dan lupa callback atau bingung mau mulai dari mana, **Antigravity WAJIB mengingatkan checklist ini secara proaktif!**

---

## 📋 Daftar Rencana Pekerjaan (Next Step)

### 🔹 Poin A: Standarisasi Pop-Up Notifikasi
- [ ] Ganti seluruh `ScaffoldMessenger` / snackbar biasa yang masih tersisa dengan **`AniseFeedbackDialog`** (sukses, konfirmasi, error) di seluruh alur:
  - Saat buat tugas baru (Guru)
  - Saat edit tugas (Guru)
  - Saat hapus tugas (Guru)
  - Saat kumpulkan / perbarui jawaban tugas (Siswa)
  - Saat guru menyimpan nilai & feedback (Guru Penilaian)

---

### 🔹 Poin B: Halaman Tugas Siswa (ListTile UI)
- [ ] Ubah komponen item tugas di tab Siswa (`TugasItemCard` / `AniseSiswaTaskCard`) menjadi bentuk **ListTile** yang bersih, modern, dan rapi sesuai estetika shared components:
  - Leading / Icon Mapel & Status
  - Title: Judul Tugas
  - Subtitle: Mapel, Tenggat Waktu, Status Pengerjaan / Nilai
  - Trailing: Indikator status / arrow

---

### 🔹 Poin C: Adjust Card Item Penugasan Guru
- [ ] Evaluasi tatanan isi card item penugasan guru (`AniseGuruTaskCard`):
  - Kerapian urutan: Mapel $\rightarrow$ Kelas $\rightarrow$ Jarak $\rightarrow$ Judul Tugas $\rightarrow$ Ringkasan Instruksi $\rightarrow$ Lampiran $\rightarrow$ Bar Progres Siswa $\rightarrow$ Tombol Penilaian.
  - Pertegas kontras border menyala (glow) dan konsistensi tipografi.

---

### 🔹 Poin D: Penyesuaian Halaman Detail Tugas & Penilaian Guru
- [ ] **Detail Tugas (Siswa / Umum):**
  - [ ] Pindahkan **Nama Guru** tepat ke **bawah Mata Pelajaran** (tidak sejajar horizontal).
  - [ ] Di section *"Jawaban Anda yang Terkirim"*: Keterangan waktu pengumpulan yang ada di sebelah tulisan *"Tugas Telah Dikumpulkan"* dipindahkan ke **bawahnya**.
  - [ ] Tombol *"Unduh Kembali Berkas Terkirim"* diubah bentuk dan styling-nya persis seperti tampilan berkas di section *"Lampiran Tugas dari Guru"* (Card terstruktur dengan ikon dokumen, nama berkas, ukuran, dan tombol unduh di kanan).
- [ ] **Halaman Penilaian Guru:**
  - [ ] Pindahkan **Tenggat Waktu** tepat ke **bawah Mata Pelajaran**.
  - [ ] Adjust tampilan **Item Card Siswa** di list penilaian agar lebih informatif dan rapi.
  - [ ] Tombol unduh berkas jawaban siswa di halaman penilaian diubah bentuk styling-nya persis seperti tampilan berkas di section *"Lampiran Tugas dari Guru"*.

---

### 🔹 Poin E: Logic & Alur Baru "Permohonan Pengumpulan Tugas Terlewat"
Alur lengkap ketika batas waktu tugas sudah habis (`Terlewat`):

1. **Tombol Siswa Berubah:**
   - [ ] Ketika tugas sudah terlewat, tombol submit tidak lagi *"Kumpulkan Tugas"*, melainkan berubah menjadi **`Permohonan Mengumpulkan`**.
2. **Form Permohonan Siswa:**
   - [ ] Saat tombol dipencet, muncul dialog / bottomsheet form isian:
     - Alasan keterlambatan / ucapan maaf / penjelasan kendala.
3. **Notifikasi ke Guru Penerbit Tugas:**
   - [ ] Setelah siswa mengirim permohonan, server mengirim notifikasi in-app ke Guru yang menerbitkan tugas tersebut.
   - [ ] Di kartu notifikasi / detail permohonan Guru, ada 2 opsi aksi:
     - **Tolak**
     - **Setujui**
4. **Form Nasihat Guru & Efek Aksi:**
   - [ ] Ketika Guru menekan tombol (baik *Setujui* maupun *Tolak*):
     - Muncul form popup untuk Guru memberikan **Pesan / Nasihat / Catatan**.
   - [ ] **Jika Ditolak:**
     - Tombol tugas di sisi siswa tetap dinonaktifkan (`Terlewat`).
     - Siswa menerima notifikasi bahwa permohonan ditolak beserta pesan nasihat dari guru.
   - [ ] **Jika Disetujui:**
     - Tombol *"Kumpulkan Tugas"* di sisi siswa otomatis **AKTIF KEMBALI** dengan masa tenggang waktu khusus: **2 x 24 jam** sejak tombol disetujui guru!
     - Siswa menerima notifikasi persetujuan beserta nasihat guru dan info batas waktu pengumpulan 2x24 jam.

---

### 🛠️ Kebutuhan Teknis Backend untuk Poin E
- Tabel / Model: `TaskLateSubmissionRequest` (kolom: `journal_task_id`, `student_id`, `reason`, `status [PENDING, APPROVED, REJECTED]`, `teacher_note`, `extended_until`, `approved_at`).
- Controller API:
  - `POST /assignments/{taskId}/request-late-submission`
  - `GET /assignments/late-requests` (untuk Guru)
  - `POST /assignments/late-requests/{id}/respond` (Setujui / Tolak + Nasihat + set `extended_until = now() + 48 hours`)
- Modifikasi query `getTaskDetailForSiswa` & `getTasks` agar mengecek apakah ada permohonan aktif yang disetujui (`now() < extended_until`).

---
*Dibuat pada: 18 Oktober 2026 • Status: PINNED (Siap dieksekusi begitu coding dimulai)*
