# 📋 ROADMAP & CHECKLIST FINAL QUALITY CONTROL (QC) ANISE / SIPENA APP

Dokumen ini adalah panduan dan daftar checklist Quality Control (QC) menyeluruh untuk memastikan seluruh fitur aplikasi berjalan 100% sempurna sebelum rilis/go-live.

---

## ✅ PROGRESS SELESAI (SUDAH DI-QC & FIXED)
- [x] **Presensi Harian Siswa & Tenaga Pendidik** (Geofence, Realtime Virtual Time, Kalkulasi KWK, TAM, TAP, Pulang Awal).
- [x] **Perijinan (Sakit, Izin, Dispensasi)**:
  - Validasi batas jam 16:01 & anti-tanggal lampau.
  - Validasi jam keluar dispensasi tidak boleh sebelum waktu saat ini.
  - Fitur unduh lampiran surat resmi dengan standarisasi penamaan berkas & notifikasi.
  - Alur approval Wali Kelas & Kepala Sekolah.
  - Tombol *"Siswa Telah Kembali"* & sinkronisasi insight card `Kembali (K)`.
- [x] **Jurnal Mengajar & KBM**:
  - Peringatan H-24 Jam penerbitan jurnal ke WhatsApp via Self-Hosted Baileys Gateway.
  - Notifikasi KBM Dimulai & Peringatan Toleransi 20 Menit Terlambat.
  - Filter tanggal akademik per item lancar.
  - Edit Isi Jurnal KBM (layout rapi jam di bawah kelas + auto-fill form data sebelumnya).
  - Rating bintang materi jurnal (khusus akun siswa, terproteksi tabel `journal_reviews`).

---

## 🚀 AGENDA QC BERIKUTNYA (NEXT STEP QC)

### 1. 🤝 Modul Bimbingan Konseling & Guru Wali (BK / Mentor)
- [ ] Pengajuan sesi bimbingan / konsultasi oleh siswa.
- [ ] Verifikasi jadwal bimbingan oleh Guru BK / Guru Wali.
- [ ] Pencatatan hasil bimbingan & rekap pembinaan siswa.
- [ ] Integrasi notifikasi in-app & WhatsApp saat jadwal bimbingan terbit.

### 2. 🔐 Fitur Reset Password
- [ ] Request token / OTP lupa kata sandi via WhatsApp Gateway.
- [ ] Validasi batas waktu kadaluwarsa token & anti-brute force limiter.
- [ ] Input kata sandi baru & hashing enkripsi `bcrypt`.
- [ ] Auto redirect ke halaman login dengan feedback sukses.

### 3. 👤 Fitur Edit Profile
- [ ] Pembaruan biodata profil (nama, nomor telepon/WhatsApp, alamat).
- [ ] Upload & kompresi foto profil avatar (storage symlink sync).
- [ ] Pendaftaran ulang biometrik wajah (Face Registration 512-D InsightFace).
- [ ] Validasi keamanan perubahan data krusial (NISN/NIP terkunci).

### 4. 🌟 Modul G7-KAIH (Gerakan 7 Karakter Anak Indonesia Hebat)
- [ ] Pembiasaan harian 7 karakter (Ibadah, Gemar Belajar, Disiplin, dsb).
- [ ] Pengisian checklist / jurnal pembiasaan oleh siswa.
- [ ] Validasi & apresiasi pembiasaan oleh Guru Wali / Wali Kelas.
- [ ] Rekapitulasi progres mingguan/bulanan karakter siswa.

### 5. 🎯 Modul Poin & KPI (Disiplin, Prestasi & Kinerja)
- [ ] Pencatatan poin pelanggaran siswa & sanksi otomatis.
- [ ] Pencatatan poin prestasi & reward siswa.
- [ ] Sinkronisasi KPI kedisiplinan guru & staf pendidik (keterlambatan, kehadiran KBM).
- [ ] Leaderboard / Rekap dashboard Kepala Sekolah.

### 6. 📢 Modul Lapor & Complaint (Sarpras & Kesiswaan)
- [ ] Pengajuan laporan kerusakan fasilitas sarana prasarana (Sarpras).
- [ ] Pengajuan laporan aduan kesiswaan / perundungan / saran sekolah.
- [ ] Upload bukti foto kerusakan/kejadian.
- [ ] Disposisi & tindak lanjut petugas Sarpras / Kesiswaan hingga status *Resolved*.
- [ ] Notifikasi progres aduan kembali ke pelapor.

---

> **Catatan Teknis VPS**:
> - Virtual Time Travel: `php artisan server:travel "YYYY-MM-DD HH:mm:ss"` (reset: `php artisan server:travel reset`).
> - Background WA Gateway: `pm2 status` (monitoring proses `anise-wa`).
