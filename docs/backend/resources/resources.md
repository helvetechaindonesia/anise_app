# 🍽️ Blueprint Resources (Tim Platter / Penata Hidangan)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `app/Http/Resources/`

Sesuai kerangka *Layered Architecture by Clean Conditions*, dokumen ini adalah cetak biru untuk seluruh tim **Resources (Platter)**.
Tugas utama Platter adalah mengambil masakan mentah (Data/Koleksi) yang baru selesai dimasak oleh *Chef* (Services), lalu menatanya ke dalam piring cantik (Format JSON yang baku) sebelum disajikan oleh *Waiter* (API) ke tamu (Frontend).

Sesuai arahan, jumlah dan jabatan tim Platter ini **DIBUAT SAMA PERSIS 1:1** dengan tim QC (Unit Tests) agar inspeksi makanan sangat ketat dan sejajar. Karena mereka mem-plating bahan baku, strukturnya juga mengikuti 7 Divisi Entitas (mirip Helper).

Berikut adalah daftar Tukang Plating (Resources) yang dibutuhkan:

---

## 👥 Divisi Data Induk & Kepegawaian (HRD)
- **`UserResource`** -> Tukang *plating* data profil user (sembunyikan password dll).
- **`RoleResource`** -> Tukang *plating* data hak akses.
- **`SchoolProfileResource`** -> Tukang *plating* data konfigurasi dan logo sekolah.

## 🗓️ Divisi Master Akademik & Kurikulum
- **`ClassroomResource`** -> Tukang *plating* data Rombel/Kelas.
- **`SubjectResource`** -> Tukang *plating* data Mata Pelajaran.
- **`ScheduleResource`** -> Tukang *plating* data Jadwal Pelajaran.
- **`AcademicYearResource`** -> Tukang *plating* data Semester Aktif.

## 📓 Divisi Kegiatan Belajar Mengajar (KBM)
- **`JournalResource`** -> Tukang *plating* laporan Jurnal Mengajar.
- **`AssignmentResource`** -> Tukang *plating* data PR dan detail jawaban siswa.
- **`AssessmentResource`** -> Tukang *plating* data nilai Ujian dan Raport.

## 👮‍♂️ Divisi Kesiswaan, Disiplin & Ibadah
- **`AttendanceResource`** -> Tukang *plating* histori Absen (jam masuk, status telat).
- **`LeaveResource`** -> Tukang *plating* data pengajuan Izin/Sakit.
- **`HabitResource`** -> Tukang *plating* data rutinitas Ibadah (G7 KAIH).
- **`DisciplineResource`** -> Tukang *plating* data laporan pelanggaran tata tertib.
- **`PointResource`** -> Tukang *plating* histori mutasi Dompet Poin.

## 🛋️ Divisi Bimbingan Konseling (BK)
- **`CounselingResource`** -> Tukang *plating* jadwal BK (pastikan catatan rahasia di-*filter* sesuai *role* tamu).

## 🪑 Divisi Logistik, Humas & Umum
- **`HelpdeskResource`** -> Tukang *plating* data tiket komplain fasilitas.
- **`InventoryResource`** -> Tukang *plating* katalog barang dan status peminjaman.
- **`LetterResource`** -> Tukang *plating* data arsip surat masuk/keluar.
- **`AnnouncementResource`** -> Tukang *plating* data pengumuman sekolah.

## ⚙️ Divisi Sistem, Keamanan & Laporan
- **`NotificationResource`** -> Tukang *plating* list notifikasi lonceng.
- **`SecurityLogResource`** -> Tukang *plating* histori *login* (IP & Device).
- **`KpiResource`** -> Tukang *plating* raport KPI performa Guru.
- **`LegalResource`** -> Tukang *plating* dokumen Terms of Service.
