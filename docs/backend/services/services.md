# 👨‍🍳 Blueprint Services (Tim Chef / Logika Bisnis)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `app/Services/`

Sesuai kerangka *Layered Architecture by Clean Conditions*, dokumen ini adalah cetak biru untuk seluruh tim **Chef (Services)**. 
Tugas utama Chef adalah meracik logika bisnis aplikasi. Waiter (API Controller) bertugas mengambil pesanan dari *user*, lalu memberikannya ke Chef. Chef kemudian menyuruh para Helper (Repositories) untuk mengambil bahan dari rak (Database), memasaknya, dan menyuruh *Platter* untuk menatanya sebelum diberikan kembali ke Waiter.

Berikut adalah daftar Chef (Services) yang dibutuhkan berdasarkan Modul:

---

## 🔐 Modul 1 & 14: Auth & Manajemen User
- **`AuthService`** (Modul 1)
  - **Tugas:** Ngurusin validasi login, *hashing* password, dan *generate* JWT Token.
  - **Helper yang diandalkan:** `UserRepository`, `RoleRepository`.
- **`UserService`** (Modul 14)
  - **Tugas:** Logika CRUD user, validasi import Excel dari *Frontend*.
  - **Helper yang diandalkan:** `UserRepository`, `RoleRepository`.

## 📍 Modul 2 & 3: Presensi & Perizinan
- **`AttendanceService`** (Modul 2)
  - **Tugas:** Kalkulasi rumus Haversine (Geofence), deteksi status keterlambatan berdasarkan jam server.
  - **Helper yang diandalkan:** `AttendanceRepository`, `SchoolProfileRepository` (buat ambil koordinat pusat sekolah).
- **`LeaveService`** (Modul 3)
  - **Tugas:** Validasi upload surat dokter dan alur persetujuan (ACC/Tolak) berjenjang.
  - **Helper yang diandalkan:** `LeaveRepository`.

## 📓 Modul 4, 5, 6, & 13: Akademik (Jurnal, PR, Ujian, Kurikulum)
- **`CurriculumService`** (Modul 13)
  - **Tugas:** Logika penempatan jadwal, pencegahan bentrok kelas.
  - **Helper yang diandalkan:** `ClassroomRepository`, `SubjectRepository`, `ScheduleRepository`, `AcademicYearRepository`.
- **`JournalService`** (Modul 4)
  - **Tugas:** Validasi apakah guru benar-benar punya jadwal ngajar di hari itu sebelum bisa mengisi jurnal.
  - **Helper yang diandalkan:** `JournalRepository`, `ScheduleRepository`.
- **`AssignmentService`** (Modul 5)
  - **Tugas:** Distribusi tugas ke anak sekelas dan logika *grading* (kalkulasi nilai PR).
  - **Helper yang diandalkan:** `AssignmentRepository`.
- **`AssessmentService`** (Modul 6)
  - **Tugas:** Kalkulasi raport, bobot nilai UTS/UAS, dan validasi *bulk insert* nilai Excel.
  - **Helper yang diandalkan:** `AssessmentRepository`, `ClassroomRepository`.

## 🕌 Modul 7, 9, 10, & 17B: Kesiswaan (G7 KAIH, Disiplin, BK, Poin)
- **`HabitService`** (Modul 7)
  - **Tugas:** Logika poin ibadah (misal dhuha dapat 10 poin) dan filter harian.
  - **Helper yang diandalkan:** `HabitRepository`.
- **`DisciplineService`** (Modul 9)
  - **Tugas:** Otomatis potong poin (Modul 17B) setiap kali ada laporan pelanggaran yang di-ACC.
  - **Helper yang diandalkan:** `DisciplineRepository`, `PointRepository`.
- **`CounselingService`** (Modul 10)
  - **Tugas:** Validasi *booking* BK agar tidak bentrok, enkripsi *secret notes* konseling.
  - **Helper yang diandalkan:** `CounselingRepository`.
- **`PointService`** (Modul 17B)
  - **Tugas:** Logika saldo mutasi (Dompet Poin) untuk mencegah minus.
  - **Helper yang diandalkan:** `PointRepository`.

## 🪑 Modul 8, 11, 12, 15, 16, & 17A: Manajemen & Fasilitas
- **`HelpdeskService`** (Modul 8)
  - **Tugas:** Logika *ticketing* komplain, notifikasi ke sarpras.
  - **Helper yang diandalkan:** `HelpdeskRepository`.
- **`InventoryService`** (Modul 12)
  - **Tugas:** Cek *stock* barang sebelum dipinjam.
  - **Helper yang diandalkan:** `InventoryRepository`.
- **`LetterService`** (Modul 11)
  - **Tugas:** Penomoran surat keluar secara otomatis.
  - **Helper yang diandalkan:** `LetterRepository`.
- **`AnnouncementService`** (Modul 16)
  - **Tugas:** *Blast Push Notification* ke FCM token terpilih saat pengumuman dirilis.
  - **Helper yang diandalkan:** `AnnouncementRepository`, `UserRepository` (ambil FCM token).
- **`KpiService`** (Modul 17A)
  - **Tugas:** Kalkulasi skor otomatis KPI guru berdasarkan persentase absen dan jurnal.
  - **Helper yang diandalkan:** `KpiRepository`, `AttendanceRepository`, `JournalRepository`.
- **`SchoolProfileService`** (Modul 15)
  - **Tugas:** Logika caching logo sekolah dan info statis.
  - **Helper yang diandalkan:** `SchoolProfileRepository`.

## ⚙️ Modul 18, 19, 20, 21: Sistem Core
- **`NotificationService`** (Modul 18)
  - **Tugas:** *Broadcast realtime* (WebSocket / FCM).
  - **Helper yang diandalkan:** `NotificationRepository`.
- **`SupportService`** (Modul 20)
  - **Tugas:** Filter histori IP dan peringatan *login* mencurigakan.
  - **Helper yang diandalkan:** `SecurityLogRepository`.
- **`LegalService`** (Modul 19)
  - **Tugas:** *Versioning* dokumen legal dan audit validasi *consent*.
  - **Helper yang diandalkan:** `LegalRepository`.
- **`DevService`** (Modul 21)
  - **Tugas:** Baca *file log* sistem langsung dari memori, bypass impersonate.
  - **Helper yang diandalkan:** Tidak ada (Murni bypass internal logic).
