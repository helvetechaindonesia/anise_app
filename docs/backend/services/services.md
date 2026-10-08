# 👨‍🍳 Blueprint Services (Tim Chef / Logika Bisnis)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `app/Services/`

Sesuai kerangka *Layered Architecture by Clean Conditions*, dokumen ini adalah cetak biru untuk seluruh tim **Chef (Services)**. 
Chef (Services) dikelompokkan berdasarkan **Jabatan / Divisi Domain**, sama persis seperti Helper (Repositories). Mereka bertanggung jawab mengelola logika bisnis untuk divisinya dengan menyuruh Helper mengambil bahan.

Berikut adalah daftar Chef (Services) yang dibutuhkan:

---

## 👥 Divisi Data Induk & Kepegawaian (HRD)
- **`AuthService`**
  - **Tugas:** Ngurusin validasi login, *hashing* password, dan *generate* JWT Token.
  - **Helper:** `UserRepository`, `RoleRepository`.
- **`UserService`**
  - **Tugas:** Logika CRUD user, validasi import Excel dari *Frontend*.
  - **Helper:** `UserRepository`, `RoleRepository`.
- **`SchoolProfileService`**
  - **Tugas:** Logika caching logo sekolah dan info statis.
  - **Helper:** `SchoolProfileRepository`.

## 🗓️ Divisi Master Akademik & Kurikulum
- **`CurriculumService`**
  - **Tugas:** Logika penempatan jadwal, pencegahan bentrok kelas.
  - **Helper:** `ClassroomRepository`, `SubjectRepository`, `ScheduleRepository`, `AcademicYearRepository`.

## 📓 Divisi Kegiatan Belajar Mengajar (KBM)
- **`JournalService`**
  - **Tugas:** Validasi jadwal ngajar di hari H sebelum bisa mengisi jurnal.
  - **Helper:** `JournalRepository`, `ScheduleRepository`.
- **`AssignmentService`**
  - **Tugas:** Distribusi tugas ke anak sekelas dan logika kalkulasi nilai PR.
  - **Helper:** `AssignmentRepository`.
- **`AssessmentService`**
  - **Tugas:** Kalkulasi raport, bobot nilai UTS/UAS, dan validasi *bulk insert* nilai Excel.
  - **Helper:** `AssessmentRepository`, `ClassroomRepository`.

## 👮‍♂️ Divisi Kesiswaan, Disiplin & Ibadah
- **`AttendanceService`**
  - **Tugas:** Kalkulasi rumus Haversine (Geofence), deteksi status keterlambatan berdasarkan jam server.
  - **Helper:** `AttendanceRepository`, `SchoolProfileRepository`.
- **`LeaveService`**
  - **Tugas:** Validasi upload surat dokter dan alur persetujuan (ACC/Tolak) berjenjang.
  - **Helper:** `LeaveRepository`.
- **`HabitService`**
  - **Tugas:** Logika poin ibadah (dhuha dll) dan filter harian.
  - **Helper:** `HabitRepository`.
- **`DisciplineService`**
  - **Tugas:** Otomatis potong poin setiap kali ada laporan pelanggaran yang di-ACC.
  - **Helper:** `DisciplineRepository`, `PointRepository`.
- **`PointService`**
  - **Tugas:** Logika saldo mutasi (Dompet Poin) untuk mencegah minus.
  - **Helper:** `PointRepository`.

## 🛋️ Divisi Bimbingan Konseling (BK)
- **`CounselingService`**
  - **Tugas:** Validasi *booking* BK agar tidak bentrok, enkripsi *secret notes*.
  - **Helper:** `CounselingRepository`.

## 🪑 Divisi Logistik, Humas & Umum
- **`HelpdeskService`**
  - **Tugas:** Logika *ticketing* komplain, notifikasi ke sarpras.
  - **Helper:** `HelpdeskRepository`.
- **`InventoryService`**
  - **Tugas:** Cek *stock* barang sebelum dipinjam.
  - **Helper:** `InventoryRepository`.
- **`LetterService`**
  - **Tugas:** Penomoran surat keluar otomatis.
  - **Helper:** `LetterRepository`.
- **`AnnouncementService`**
  - **Tugas:** *Blast Push Notification* ke FCM token saat pengumuman dirilis.
  - **Helper:** `AnnouncementRepository`, `UserRepository`.

## ⚙️ Divisi Sistem, Keamanan & Laporan
- **`NotificationService`**
  - **Tugas:** *Broadcast realtime* (WebSocket / FCM).
  - **Helper:** `NotificationRepository`.
- **`SupportService`**
  - **Tugas:** Filter histori IP dan peringatan *login* mencurigakan.
  - **Helper:** `SecurityLogRepository`.
- **`KpiService`**
  - **Tugas:** Kalkulasi skor otomatis KPI guru berdasarkan persentase absen dan jurnal.
  - **Helper:** `KpiRepository`, `AttendanceRepository`, `JournalRepository`.
- **`LegalService`**
  - **Tugas:** *Versioning* dokumen legal dan audit *consent*.
  - **Helper:** `LegalRepository`.
- **`DevService`**
  - **Tugas:** Baca *file log* sistem, bypass impersonate.
  - **Helper:** Tidak ada (Murni bypass internal logic).
