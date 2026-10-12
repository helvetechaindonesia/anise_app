# 🧱 Spesifikasi Elemen 01: Foundation (Pondasi)
**Helvetecha UI Framework - Elemen 1**  
*Modul Target: Seluruh 21 Modul Anise (Cross-Module Standard)*  
*Lokasi Dokumen: `docs/frontend/UI/01_foundation/spec_foundation.md`*

---

## 🔍 1. Hasil Scrapping Lapangan di Seluruh Modul
Dari hasil penyisiran menyeluruh pada `lib/features/`:

### A. Temuan Positif
- Mayoritas screen sudah menggunakan token semantik `AppColors.primary`, `AppColors.onBackground`, `AppColors.backgroundLight`.
- Sudah ada abstraksi fluid `ResponsiveSpacing` (`.w(context)`, `.h(context)`, `.sp(context)`).

### B. Temuan Retak / Inkonsistensi Lapangan (Wajib Distandarisasi)
1. **Warna Hardcoded `Colors.red`, `Colors.white`, `Colors.white70`:**
   - Ditemukan di pesan error, snackbar, dan tombol aksi (misal `guru_tugas_screen.dart:256`, `tu_geofence_settings_screen.dart:159`, `biometric_registration_screen.dart:156`).
   - *Solusi:* Semua teks putih di atas tombol primary wajib memakai `AppColors.onPrimary`, error wajib memakai `AppColors.error`.
2. **Penggunaan `TextStyle(...)` Manual:**
   - Masih ada baris kode yang memakai `const TextStyle(color: Colors.white, fontSize: 16)` daripada `AppTextStyles.titleMedium(context, color: AppColors.onPrimary)`.
   - Hal ini membuat ukuran teks tidak fluid dan tidak merespons perubahan tema atau ukuran layar.
3. **Penyimpangan Spacing Statis (`SizedBox(height: 20)`):**
   - Di beberapa widget masih ditemukan `SizedBox(height: 10)` mentah tanpa extension `.h(context)` atau helper `Spacing.item(context)`.

---

## 📐 2. Definisi Spesifikasi Baku Elemen 01 (Foundation)

Fondasi terdiri dari 3 pilar tak terpisahkan:

```text
┌────────────────────────────────────────────────────────┐
│             ELEMEN 01: FOUNDATION (PONDASI)            │
├────────────────────────┬───────────────────────────────┤
│ 1. Color Palette       │ AppColors (Semantic Tokens)   │
│ 2. Typography System   │ AppTextStyles (Google Fonts)  │
│ 3. Responsive Spacing  │ Spacing & ResponsiveSpacing   │
└────────────────────────┴───────────────────────────────┘
```

### 2.1 Color Palette (`AppColors`)
| Token | Nilai Hex | Peruntukan Baku |
| :--- | :--- | :--- |
| `primary` | `#1C3F4A` | Warna dominan brand (Deep Teal), tombol utama, navbar aktif. |
| `onPrimary` | `#FFFFFF` | Teks & icon di atas bidang `primary`. |
| `secondary` | `#87D0C5` | Aksen sekunder (Mint/Teal cerah), bintang rating, chip aktif. |
| `onSecondary` | `#000000` | Teks di atas bidang `secondary`. |
| `backgroundLight` | `#F9FAFB` | Latar belakang seluruh layar (Scaffold background). |
| `onBackground` | `#1C3F4A` | Teks judul/utama yang berdiri di atas background. |
| `surface` | `#FFFFFF` | Latar belakang kartu/kontainer (Card surface). |
| `onSurface` | `#1C3F4A` | Teks utama di dalam kartu/kontainer. |
| `surfaceVariant` | `#F0F4F5` | Latar belakang section sekunder/field input. |
| `onSurfaceVariant` | `#B3B3B3` | Teks keterangan, subtitle, hint placeholder. |
| `error` | `#E53935` | Status gagal, badge terlambat, tombol hapus/batal. |
| `success` | `#87D0C5` | Status hadir tepat waktu, checklist selesai. |
| `warning` | `#FFA726` | Status pending, peringatan dispensasi. |
| `info` | `#29B6F6` | Status pengumuman, bimbingan terjadwal. |

### 2.2 Typography System (`AppTextStyles`)
Menggunakan font `Inter` / `Google Sans` dengan skala responsif:
| Token Method | Ukuran (sp) | Weight | Penggunaan |
| :--- | :---: | :---: | :--- |
| `displayLarge` | 32 | Bold (700) | Banner greeting angka besar. |
| `headlineLarge` | 24 | Bold (700) | Nama siswa/guru di header ("Halo, Ahmad!"). |
| `headlineMedium` | 20 | SemiBold (600) | Judul seksi utama di dashboard. |
| `titleMedium` | 16 | SemiBold (600) | Judul kartu, judul tugas, nama mata pelajaran. |
| `bodyMedium` | 14 | Regular (400) | Paragraf penjelasan, keterangan tugas, deskripsi. |
| `bodySmall` | 12 | Regular (400) | Keterangan tambahan, catatan kaki kartu. |
| `labelMedium` | 12 | Medium (500) | Label tombol aksi, badge status. |
| `labelSmall` | 10 | Regular (400) | Timestamp waktu, kategori kecil. |

### 2.3 Responsive & Spacing System (`Spacing`)
- `Spacing.item(context)` ➔ 12px fluid (jarak antar elemen di dalam kartu).
- `Spacing.component(context)` ➔ 16px fluid (jarak antar kartu/seksi).
- `Spacing.custom(context, N)` ➔ N px fluid.
- Horizontal padding standar layar ➔ `24.w(context)`.

---

## 📋 3. Checklist SOP Standarisasi (Foundation)
- [x] Dilarang menggunakan `Colors.red`, `Colors.white`, `Colors.black` langsung di kode modul (Semua sudah direfactor ke `AppColors.error`, `AppColors.onPrimary`, dll).
- [x] Dilarang menggunakan `TextStyle(...)` langsung tanpa `AppTextStyles` (Semua sudah direfactor ke `AppTextStyles`).
- [x] Dilarang menggunakan `SizedBox(height: 20)` tanpa `.h(context)` (Semua sudah menggunakan fluid Spacing).
- [x] Semua file spesifikasi foundation tersimpan rapi di `docs/frontend/UI/01_foundation/`.
