# 🌊 Blueprint Frontend State (Riverpod Providers)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `frontend/lib/providers/`

Dokumen ini adalah cetak biru untuk seluruh **Manajer Ruang Makan (Providers)** di aplikasi Flutter kita.
Karena kita menganut sekte **Riverpod**, *state management* kita akan mengandalkan `NotifierProvider` atau `AsyncNotifierProvider` untuk menampung data (makanan) yang baru saja diantarkan oleh Waiter (API) dari Dapur (Backend).

Sesuai arsitektur *Clean Conditions*, jumlah dan jabatan *Providers* ini **SAMA PERSIS 1:1** dengan tim Platter (Resources) di Backend. Hal ini untuk memastikan sinkronisasi data yang sempurna dari *database* hingga tampil ke layar HP *user*.

Berikut adalah daftar **Manajer Ruang Makan (Providers)** yang dibutuhkan:

---

## 👥 Divisi Data Induk & Kepegawaian (HRD)
- **`userProvider`** -> Manajer yang pegang data *state* profil *User*.
- **`roleProvider`** -> Manajer yang pegang data *state* daftar *Role*.
- **`schoolProfileProvider`** -> Manajer yang pegang data *state* logo & info sekolah.

## 🗓️ Divisi Master Akademik & Kurikulum
- **`classroomProvider`** -> Manajer yang pegang data *state* daftar *Classroom*.
- **`subjectProvider`** -> Manajer yang pegang data *state* daftar *Subject*.
- **`scheduleProvider`** -> Manajer yang pegang data *state* jadwal *Schedule*.
- **`academicYearProvider`** -> Manajer yang pegang data *state* tahun ajaran aktif.

## 📓 Divisi Kegiatan Belajar Mengajar (KBM)
- **`journalProvider`** -> Manajer yang pegang data *state* daftar *Journal*.
- **`assignmentProvider`** -> Manajer yang pegang data *state* daftar *Assignment*.
- **`assessmentProvider`** -> Manajer yang pegang data *state* daftar nilai *Assessment*.

## 👮‍♂️ Divisi Kesiswaan, Disiplin & Ibadah
- **`attendanceProvider`** -> Manajer yang pegang data *state* riwayat *Attendance*.
- **`leaveProvider`** -> Manajer yang pegang data *state* daftar pengajuan *Leave*.
- **`habitProvider`** -> Manajer yang pegang data *state* data *Habit* ibadah.
- **`disciplineProvider`** -> Manajer yang pegang data *state* kasus *Discipline*.
- **`pointProvider`** -> Manajer yang pegang data *state* saldo *Point*.

## 🛋️ Divisi Bimbingan Konseling (BK)
- **`counselingProvider`** -> Manajer yang pegang data *state* jadwal *Counseling*.

## 🪑 Divisi Logistik, Humas & Umum
- **`helpdeskProvider`** -> Manajer yang pegang data *state* tiket *Helpdesk*.
- **`inventoryProvider`** -> Manajer yang pegang data *state* katalog *Inventory*.
- **`letterProvider`** -> Manajer yang pegang data *state* arsip surat *Letter*.
- **`announcementProvider`** -> Manajer yang pegang data *state* *Announcement* terbaru.

## ⚙️ Divisi Sistem, Keamanan & Laporan
- **`notificationProvider`** -> Manajer yang pegang data *state* daftar *Notification*.
- **`securityLogProvider`** -> Manajer yang pegang data *state* histori *SecurityLog*.
- **`kpiProvider`** -> Manajer yang pegang data *state* raport *Kpi* guru.
- **`legalProvider`** -> Manajer yang pegang data *state* regulasi *Legal*.
