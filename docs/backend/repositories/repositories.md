# 🗃️ Blueprint Repositories (Helper Dapur)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `app/Repositories/`

Dokumen ini adalah cetak biru untuk seluruh tim *Helper* (Repositories) yang bertugas mengambil bahan mentah dari rak (Database) untuk diserahkan ke sang *Chef* (Services). 

---

## 🔐 Modul 1 & 14: Auth & Manajemen User
- **`UserRepository`**
  - `findByEmailOrNik($identifier)` -> Mengambil data *user* untuk *login*.
  - `createUser($data)` -> Simpan *user* baru.
  - `updateDeviceToken($userId, $token)` -> Update FCM Token.
  - `searchSiswa($keyword)` -> Mencari data spesifik siswa.
- **`RoleRepository`**
  - `assignRole($userId, $roleId)` -> Ganti jabatan.

## 📍 Modul 2 & 3: Presensi & Perizinan
- **`AttendanceRepository`**
  - `getHistoryByUser($userId, $month)` -> Ambil riwayat absen.
  - `storeCheckIn($data)` -> Simpan tap masuk.
  - `storeCheckOut($data)` -> Simpan tap pulang.
  - `getDailyReportByClass($classId, $date)` -> Rekap per kelas.
- **`LeaveRepository`**
  - `createLeaveRequest($data)` -> Simpan surat izin/sakit.
  - `getPendingApprovals($reviewerId)` -> Daftar izin butuh ACC.
  - `updateStatus($leaveId, $status)` -> ACC/Tolak izin.

## 📓 Modul 4, 5, 6, & 13: Akademik (Jurnal, PR, Ujian, Kurikulum)
- **`JournalRepository`**
  - `createJournal($data)` -> Simpan jurnal guru.
  - `getJournalByClass($classId)` -> Riwayat jurnal per kelas.
- **`AssignmentRepository`**
  - `createTask($data)` -> Simpan rilis PR baru.
  - `submitAnswer($data)` -> Simpan upload jawaban siswa.
  - `gradeAnswer($submissionId, $score)` -> Simpan nilai.
- **`AssessmentRepository`**
  - `createAgenda($data)` -> Bikin agenda UTS/UAS.
  - `bulkInsertScores($agendaId, $scores)` -> Upload nilai massal.
- **`CurriculumRepository`**
  - `getAllClasses()` -> Ambil daftar kelas.
  - `getAllSubjects()` -> Ambil daftar mapel.
  - `getSchedulesByTeacher($teacherId)` -> Jadwal ngajar guru.

## 🕌 Modul 7, 9, 10, & 17B: Kesiswaan (G7 KAIH, Disiplin, BK, Poin)
- **`HabitRepository`**
  - `logActivity($data)` -> Simpan laporan sholat/sedekah.
  - `getLeaderboard($limit)` -> Ambil *ranking* klasemen.
- **`DisciplineRepository`**
  - `storeReport($data)` -> Simpan lapor siswa nakal.
  - `processReport($reportId, $action)` -> Tindak lanjut BK.
- **`CounselingRepository`**
  - `bookSession($data)` -> Booking jadwal curhat.
  - `addSecretNotes($sessionId, $notes)` -> Simpan cacatan rahasia BK.
- **`PointRepository`**
  - `getStudentBalance($studentId)` -> Sisa poin dompet.
  - `addTransaction($data)` -> Potong/Tambah histori poin.

## 🪑 Modul 8, 11, 12, 15, 16, & 17A: Manajemen & Fasilitas
- **`HelpdeskRepository`**
  - `createTicket($data)` -> Simpan laporan kerusakan.
  - `updateTicketStatus($ticketId, $status)` -> Ubah status (Done).
- **`InventoryRepository`**
  - `getAllItems()` -> Katalog sarpras.
  - `storeLoan($data)` -> Pinjam proyektor/bola.
  - `returnItem($loanId)` -> Balikin barang.
- **`LetterRepository`**
  - `getIncomingLetters()` / `storeOutgoingLetter($data)` -> Arsip surat.
- **`AnnouncementRepository`**
  - `broadcastAnnouncement($data)` -> Rilis pengumuman.
- **`KpiRepository`**
  - `storeEvaluation($data)` -> Kepsek nilai guru.

## ⚙️ Modul 18, 19, 20, 21: Sistem Core
- **`NotificationRepository`**
  - `getUnread($userId)` -> Daftar notif lonceng.
  - `markAsRead($notificationId)` -> Centang biru.
- **`SystemLogRepository`**
  - `storeSecurityLog($userId, $ip, $device)` -> Lapor login sukses.
- **`SchoolSettingRepository`**
  - `getGeofenceConfig()` -> Ambil koordinat GPS sekolah.
  - `updateConfig($key, $value)` -> Update pengaturan global.
