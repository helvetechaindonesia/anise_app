# 📄 Standarisasi 5 Tipe Halaman (Page Archetypes)
**Panduan Pola Layar untuk Seluruh Modul Aplikasi Anise**  
*Lokasi: `docs/frontend/UI/page_archetypes/page_archetypes.md`*

---

## 1. 🏠 Ruang Utama / Root Tab Screen
- **Fungsi:** Dashboard peran (Siswa, Guru, BK, TU) dan tab navigasi utama.
- **Karakteristik Wajib:**
  - `Scaffold` dengan `backgroundColor: AppColors.backgroundLight`.
  - Menggunakan `CustomScrollView` + `SliverAppBar`.
  - Punya Greeting Header & 3D Identity Card.
  - **DILARANG ada tombol Back**.
  - Punya `BottomNavigationBar`.

---

## 2. 📑 Ruang Cabang / Sub-Page Screen
- **Fungsi:** Halaman fitur turunan dari dashboard (misal: Daftar Jadwal, Manajemen Surat, Rekap Presensi).
- **Karakteristik Wajib:**
  - Menggunakan `AniseAppBar(title: '...', showBackButton: true)`.
  - Padding konten standar: `EdgeInsets.symmetric(horizontal: 24.w(context))`.
  - Berisi list data, filter chip, atau grid menu sekunder.

---

## 3. 🔍 Ruang Rincian / Detail Item Screen
- **Fungsi:** Melihat rincian satu data (misal: Detail Tugas, Detail Riwayat Absen, Detail Siswa).
- **Karakteristik Wajib:**
  - Menggunakan `AniseAppBar`.
  - Hero Card / Header kartu ringkasan status di bagian atas.
  - Seksi informasi dipisah menggunakan `Spacing.component(context)`.
  - Aksi utama (misal: "Kumpulkan Tugas", "Unduh Berkas") berada di sticky bottom atau FAB.

---

## 4. 📝 Ruang Formulir / Form Screen
- **Fungsi:** Input atau pengeditan data baru (misal: Input Tugas Guru, Ajukan Izin, Edit Profil).
- **Karakteristik Wajib:**
  - Menggunakan `AniseAppBar`.
  - Kontrol input menggunakan `AniseTextField` / dropdown standar.
  - Tombol Submit menggunakan `AniseButton(text: 'Simpan', variant: AniseButtonVariant.primary)`.
  - Form field dibungkus `SingleChildScrollView` dengan `keyboardDismissBehavior`.

---

## 5. 🪟 Bilik Geser / Modal BottomSheet
- **Fungsi:** Dialog aksi cepat, filter list, atau konfirmasi tanpa berpindah halaman.
- **Karakteristik Wajib:**
  - `showModalBottomSheet` dengan `shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))`.
  - Ada indikator garis pegangan kecil (*Handle Bar*) di paling atas.
  - Berisi konten ringkas dan tombol konfirmasi/batal.
