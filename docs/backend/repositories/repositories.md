# 🗃️ Blueprint Repositories (Tim Helper Dapur)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `app/Repositories/`

Sesuai kerangka *Layered Architecture by Clean Conditions*, dokumen ini adalah cetak biru untuk seluruh tim **Helper (Repositories)**. 
Tugas mereka murni hanya berinteraksi dengan "Rak Bahan" (Database). Mereka tidak peduli fitur apa (Modul) yang memanggil mereka, mereka hanya peduli pada **Bahan Baku (Entitas)** yang mereka kelola.

Daftar Divisi Helper yang dibutuhkan:

---

## 👥 Divisi Data Induk & Kepegawaian (HRD)
*Tugas: Mengelola bahan baku terkait identitas manusia dan sekolah.*
- **`UserRepository`**
  - `findByEmailOrNik($identifier)` -> Cari identitas untuk validasi login.
  - `findById($id)` -> Cari profil detail.
  - `searchSiswa($keyword)` -> Pencarian nama siswa lintas modul.
  - `updateDeviceToken($userId, $token)` -> Update FCM token HP.
- **`RoleRepository`**
  - `getUserRoles($userId)` -> Cek akses/jabatan.
- **`SchoolProfileRepository`**
  - `getSettings()` -> Ambil koordinat Geofence, logo, dll.
  - `updateSettings($data)` -> Update profil sekolah.

## 🗓️ Divisi Master Akademik & Kurikulum
*Tugas: Mengelola bahan baku terstruktur yang statis per semester.*
- **`ClassroomRepository`**
  - `getAllClasses()` -> Ambil daftar rombel/kelas.
  - `getStudentsByClass($classId)` -> Ambil absen anak sekelas.
- **`SubjectRepository`**
  - `getAllSubjects()` -> Ambil daftar mapel.
- **`ScheduleRepository`**
  - `getSchedulesByTeacher($teacherId)` -> Bahan untuk Jurnal.
  - `getSchedulesByClass($classId)` -> Bahan jadwal murid.
- **`AcademicYearRepository`**
  - `getActiveYear()` -> Deteksi semester aktif saat ini.

## 📓 Divisi Kegiatan Belajar Mengajar (KBM)
*Tugas: Mengelola bahan baku operasional kelas harian.*
- **`JournalRepository`**
  - `storeJournal($data)` -> Simpan log ngajar guru.
  - `getHistoryByClass($classId)` -> Laporan jurnal per kelas.
- **`AssignmentRepository`**
  - `createTask($data)` -> Simpan PR.
  - `submitStudentAnswer($data)` -> Simpan jawaban siswa.
  - `gradeAnswer($id, $score)` -> Simpan nilai PR.
- **`AssessmentRepository`** (Ujian/Raport)
  - `createExamAgenda($data)` -> Bikin agenda UTS/UAS.
  - `bulkInsertScores($agendaId, $scores)` -> Upload nilai massal pakai Excel.

## 👮‍♂️ Divisi Kesiswaan, Disiplin & Ibadah
*Tugas: Mengelola bahan baku tingkah laku siswa.*
- **`AttendanceRepository`**
  - `storeCheckIn($data)` / `storeCheckOut($data)` -> Catat absen.
  - `getMonthlyHistory($userId, $month)` -> Histori bulanan.
- **`LeaveRepository`**
  - `createRequest($data)` -> Surat izin/sakit.
  - `getPendingApprovals($reviewerId)` -> Ambil daftar antrian ACC.
- **`HabitRepository`** (G7 KAIH)
  - `logActivity($data)` -> Simpan rutinitas ibadah (Dhuha, dll).
  - `getLeaderboard()` -> Bahan untuk klasemen siswa ter-alim.
- **`DisciplineRepository`**
  - `storeViolationReport($data)` -> Simpan laporan pelanggaran.
- **`PointRepository`**
  - `getBalance($studentId)` -> Cek sisa dompet poin.
  - `addTransaction($data)` -> Mutasi potong/tambah poin.

## 🛋️ Divisi Bimbingan Konseling (BK)
*Tugas: Mengelola bahan baku rahasia psikologi siswa.*
- **`CounselingRepository`**
  - `createSessionRequest($data)` -> Booking jadwal curhat.
  - `updateNotes($sessionId, $notes)` -> Simpan catatan tertutup.
  - `getTeacherSchedule($teacherId)` -> Cek jadwal kosong Guru BK.

## 🪑 Divisi Logistik, Humas & Umum
*Tugas: Mengelola barang, surat, dan komunikasi sekolah.*
- **`InventoryRepository`**
  - `getAllItems()` -> Ambil katalog barang (Proyektor, dll).
  - `storeLoan($data)` / `returnItem($loanId)` -> Peminjaman.
- **`HelpdeskRepository`**
  - `createTicket($data)` -> Lapor fasilitas rusak (AC bocor, dll).
- **`LetterRepository`**
  - `getIncoming()` / `storeOutgoing($data)` -> Arsip surat TU.
- **`AnnouncementRepository`**
  - `createBroadcast($data)` -> Simpan pengumuman massa.

## ⚙️ Divisi Sistem, Keamanan & Laporan
*Tugas: Mengelola bahan baku teknis dan log sistem.*
- **`NotificationRepository`**
  - `getUnread($userId)` -> Loncat notif.
  - `markAsRead($id)` -> Centang notif.
- **`SecurityLogRepository`**
  - `storeLoginAttempt($data)` -> Catat IP dan Device user untuk keamanan.
- **`KpiRepository`**
  - `storeEvaluation($data)` -> Raport evaluasi kinerja tendik.
- **`LegalRepository`**
  - `getLatestDocument($type)` -> Ambil TOS/Privacy Policy.
