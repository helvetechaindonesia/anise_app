# 📌 ROADMAP & CHECKLIST STANDARISASI FITUR TUGAS & PENILAIAN (ANISE APP)

> [!IMPORTANT]
> **PENGINGAT KERAS / PIN UTAMA UNTUK SESI BERIKUTNYA:**
> Dokumen ini adalah acuan resmi pekerjaan berikutnya. Jika user masuk kembali dan lupa callback atau bingung mau mulai dari mana, **Antigravity WAJIB mengingatkan checklist ini secara proaktif!**

---

## 📋 Daftar Rencana Pekerjaan (Next Step)

### 🔹 Poin A: Standarisasi Pop-Up Notifikasi
- [x] Ganti seluruh `ScaffoldMessenger` / snackbar biasa yang masih tersisa dengan **`AniseFeedbackDialog`** (sukses, konfirmasi, error) di seluruh alur:
  - [x] Saat buat tugas baru (Guru)
  - [x] Saat edit tugas (Guru)
  - [x] Saat hapus tugas (Guru)
  - [x] Saat kumpulkan / perbarui jawaban tugas (Siswa)
  - [x] Saat guru menyimpan nilai & feedback (Guru Penilaian)

---

### 🔹 Poin B: Halaman Tugas Siswa (ListTile UI)
- [x] Ubah komponen item tugas di tab Siswa (`TugasItemCard` / `AniseSiswaTaskCard`) menjadi bentuk **ListTile** yang bersih, modern, dan rapi sesuai estetika shared components:
  - [x] Leading / Icon Mapel & Status
  - [x] Title: Judul Tugas
  - [x] Subtitle: Mapel, Tenggat Waktu, Status Pengerjaan / Nilai
  - [x] Trailing: Indikator status / arrow

---

### 🔹 Poin C: Adjust Card Item Penugasan Guru
- [x] Evaluasi tatanan isi card item penugasan guru (`AniseGuruTaskCard`):
  - [x] Kerapian urutan: Mapel $\rightarrow$ Kelas $\rightarrow$ Jarak $\rightarrow$ Judul Tugas $\rightarrow$ Ringkasan Instruksi $\rightarrow$ Lampiran $\rightarrow$ Bar Progres Siswa $\rightarrow$ Tombol Penilaian.
  - [x] Pertegas kontras border menyala (glow) dan konsistensi tipografi.

---

### 🔹 Poin D: Penyesuaian Halaman Detail Tugas & Penilaian Guru
- [x] **Detail Tugas (Siswa / Umum):**
  - [x] Pindahkan **Nama Guru** tepat ke **bawah Mata Pelajaran** (tidak sejajar horizontal).
  - [x] Di section *"Jawaban Anda yang Terkirim"*: Keterangan waktu pengumpulan yang ada di sebelah tulisan *"Tugas Telah Dikumpulkan"* dipindahkan ke **bawahnya**.
  - [x] Tombol *"Unduh Kembali Berkas Terkirim"* diubah bentuk dan styling-nya persis seperti tampilan berkas di section *"Lampiran Tugas dari Guru"* (Card terstruktur dengan ikon dokumen, nama berkas, ukuran, dan tombol unduh di kanan).
- [x] **Halaman Penilaian Guru:**
  - [x] Pindahkan **Tenggat Waktu** tepat ke **bawah Mata Pelajaran**.
  - [x] Adjust tampilan **Item Card Siswa** di list penilaian agar lebih informatif dan rapi.
  - [x] Tombol unduh berkas jawaban siswa di halaman penilaian diubah bentuk styling-nya persis seperti tampilan berkas di section *"Lampiran Tugas dari Guru"*.

---

### 🔹 Poin E: Logic & Alur Baru "Permohonan Pengumpulan Tugas Terlewat"
Alur lengkap ketika batas waktu tugas sudah habis (`Terlewat`):

1. **Tombol Siswa Berubah:**
   - [x] Ketika tugas sudah terlewat, tombol submit tidak lagi *"Kumpulkan Tugas"*, melainkan berubah menjadi **`Permohonan Mengumpulkan`**.
2. **Form Permohonan Siswa:**
   - [x] Saat tombol dipencet, muncul dialog / bottomsheet form isian:
     - [x] Alasan keterlambatan / ucapan maaf / penjelasan kendala.
3. **Notifikasi ke Guru Penerbit Tugas:**
   - [x] Setelah siswa mengirim permohonan, server mengirim notifikasi in-app ke Guru yang menerbitkan tugas tersebut.
   - [x] Di kartu notifikasi / detail permohonan Guru & halaman penilaian, ada 2 opsi aksi:
     - [x] **Tolak**
     - [x] **Setujui**
4. **Form Nasihat Guru & Efek Aksi:**
   - [x] Ketika Guru menekan tombol (baik *Setujui* maupun *Tolak*):
     - [x] Muncul form popup untuk Guru memberikan **Pesan / Nasihat / Catatan**.
   - [x] **Jika Ditolak:**
     - [x] Tombol tugas di sisi siswa tetap dinonaktifkan (`Terlewat`).
     - [x] Siswa menerima notifikasi bahwa permohonan ditolak beserta pesan nasihat dari guru.
   - [x] **Jika Disetujui:**
     - [x] Tombol *"Kumpulkan Tugas"* di sisi siswa otomatis **AKTIF KEMBALI** dengan masa tenggang waktu khusus: **2 x 24 jam** sejak tombol disetujui guru!
     - [x] Siswa menerima notifikasi persetujuan beserta nasihat guru dan info batas waktu pengumpulan 2x24 jam.

---

### 🛠️ Kebutuhan Teknis Backend untuk Poin E
- [x] Tabel / Model: `TaskLateSubmissionRequest` (kolom: `journal_task_id`, `student_id`, `reason`, `status [PENDING, APPROVED, REJECTED]`, `teacher_note`, `extended_until`, `approved_at`).
- [x] Controller API:
  - [x] `POST /assignments/{taskId}/request-late`
  - [x] `GET /assignments/late-requests` (untuk Guru)
  - [x] `POST /assignments/late-requests/{id}/respond` (Setujui / Tolak + Nasihat + set `extended_until = now() + 48 hours`)
- [x] Modifikasi query `getTaskDetailForSiswa` & `getTasks` & `getTaskSubmissions` agar mengecek apakah ada permohonan aktif yang disetujui (`now() < extended_until`).

---
*Status: SELESAI SELURUHNYA (Commit siap di-pull di VPS)*
