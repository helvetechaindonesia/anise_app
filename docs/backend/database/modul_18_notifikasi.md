# Dokumentasi Database & API: Modul 18 (Sistem Notifikasi)

**Status:** Finalized (MVP 1.A) - Mapping Skenario
**Terakhir Diperbarui:** 08 Oktober 2026

Modul 18 berfungsi sebagai "Kantor Pos Pusat" yang menerima pemicu (*trigger*) dari modul-modul lain untuk didistribusikan kepada *user* dalam bentuk **Notifikasi Dalam Aplikasi (Lonceng/In-App)** maupun **Push Notification (FCM)**.

---

## 🗄️ 1. Struktur Tabel Dasar

Tabel ini sudah dibuat sejak awal pengembangan dan dirancang seringan mungkin.

**Tabel `notifications`**
- `id` (UUID)
- `user_id` (FK ke `users`): Target penerima notifikasi.
- `title` (String): Judul notifikasi.
- `message` (Text): Isi pesan notifikasi.
- `is_read` (Boolean): *Default false*. (Menjadi *true* ketika user membuka/mengklik notifikasi).
- `timestamps`: Waktu notifikasi masuk.

*(Catatan: Penambahan kolom cerdas seperti `action_type` atau `reference_id` untuk navigasi klik ditunda terlebih dahulu dan akan dikembangkan pada fase optimasi UI/UX).*

---

## 🗺️ 2. Peta Distribusi Notifikasi (Rules of Trigger)

Berikut adalah daftar skenario baku kapan notifikasi harus ditembakkan oleh sistem kepada pengguna yang bersangkutan:

### A. Target: SISWA (Murid)
1. **Tugas / Jurnal Baru (Modul 4 & 5):** Guru merilis Tugas baru atau Jurnal baru di kelasnya. 
2. **Hukuman Kedisiplinan (Modul 9):** Laporan pelanggaran yang melibatkan siswa tersebut telah di-ACC (disetujui) oleh Guru BK.
3. **Hasil Penilaian (Modul 6):** Guru telah selesai menginput agenda penilaian / mengunggah nilai akhir.
4. **Pengumuman (Modul 16):** Tata Usaha mem- *blast* pengumuman yang mencakup siswa sebagai target audiens.

### B. Target: WALI KELAS & GURU MAPEL
1. **Wali Kelas (Modul 3):** Ada siswa di kelas asuhannya yang mengajukan izin / sakit / dispensasi.
2. **Guru Mapel (Modul 3):** Pengajuan izin siswa telah di-ACC, sehingga Guru Mapel yang sedang mengajar di jam tersebut mendapatkan notifikasi agar tidak bingung mencari siswa atau memberinya status Alpa.
3. **Guru Mapel (Modul 5):** *(Opsional)* Siswa mengumpulkan tugas melewati batas waktu (*late submission*).

### C. Target: GURU / TENDIK UMUM
1. **Engagement Jurnal (Modul 4):** Ada *user* lain yang memberikan *like* atau *comment* (ulasan) pada Jurnal Mengajar yang ia terbitkan.
2. **Izin Tendik (Modul 3):** Pengajuan cuti / izin / dispensasi yang ia ajukan telah disetujui (di-ACC) oleh Kepala Sekolah.
3. **Raport Kinerja / KPI (Modul 17A):** Kepala Sekolah menerbitkan / mem-*publish* raport evaluasi kinerjanya di akhir semester.
4. **Helpdesk (Modul 8):** Laporan kerusakan fasilitas atau tiket komplain yang ia buat telah ditanggapi oleh Sarpras/TU.

### D. Target: GURU BK
1. **Laporan Disiplin Baru (Modul 9):** Ada guru / satpam yang menangkap basah siswa melanggar dan men- *submit* laporannya. Guru BK mendapat notifikasi untuk segera melakukan tindak lanjut / ACC.

### E. Target: KEPALA SEKOLAH
1. **Pengajuan Izin Tendik (Modul 3):** Ada Guru atau Tenaga Kependidikan yang mengajukan cuti / izin tidak masuk. Kepala sekolah mendapat notifikasi untuk menekan tombol *Approve/Reject*.

### F. Target: TATA USAHA / SARPRAS
1. **Keluhan Fasilitas (Modul 8):** Ada tiket Helpdesk / komplain masuk dari pihak guru terkait kerusakan fasilitas sekolah (Modul 12).
