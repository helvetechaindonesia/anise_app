# 📋 Spesifikasi Komponen: `ItemListTile`
**Kategori:** Kartu & Tampilan Data (Cards & Data Display)  
**Target:** Baris Daftar Vertikal Baku (Tugas, Riwayat Presensi, Pengumuman, Surat Masuk)  
**File Kode:** `lib/core/widgets/item_list_tile.dart`  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`ItemListTile` adalah komponen standar antarmuka untuk baris data daftar vertikal (mengadopsi **Standar Model B: Minimal Flat Tile with Divider**). 

Komponen ini dirancang untuk menggantikan desain kartu kotak terisolasi (*heavy boxed cards*) dengan tampilan yang lebih bersih, modern, dan bernafas lega:
- Menggunakan pendekatan datar (*flat*) tanpa border container tebal di sekelilingnya.
- Memiliki garis pemisah (*divider*) tipis semi-transparan otomatis di bagian bawah.
- Mendukung hierarki informasi lengkap: **Kategori** (Mapel), **Subkategori** (Guru/Pengampu), **Judul Utama**, **Metadata Waktu/Tenggat**, serta **Status & Tombol Aksi (Trailing)**.

---

## 📐 2. Anatomi & Pengukuran Dimensi (Sizing & Ratio)
```text
┌──────────────────────────────────────────────────────────────┐
│  Kategori / Mata Pelajaran (labelSmall, w400)                │
│  Subkategori / Pengampu (labelSmall, opacity 0.7)            │
│                                                              │
│  Judul Utama / Nama Tugas (titleMedium, w700 Bold)           │
│                                                              │
│  [📅 Metadata Icon] Waktu / Tenggat (labelMedium, w400)      │
│                                                              │
│  [⏳ Status Icon] Status Pengerjaan         [ Trailing / Aksi]│
│                                                              │
│  [🛡️ Bottom Widget / Validator Pill Badge]                   │
├──────────────────────────────────────────────────────────────┤
│  ────────────────── Divider Halus ─────────────────────────  │
└──────────────────────────────────────────────────────────────┘
```

1. **Wadah Sentuh (Touch Target & Padding):**
   - **Padding Default:** Horizontal `4.w(context)`, Vertikal `14.h(context)`.
   - **Feedback Sentuhan:** Dibungkus `InkWell` dengan border radius `12.w(context)`.
2. **Hierarki Tipografi & Warna:**
   - **Kategori:** `AppTextStyles.labelSmall`, warna `AppColors.onBackground`, berat `w400`.
   - **Subkategori:** `AppTextStyles.labelSmall`, warna `AppColors.onBackground.withValues(alpha: 0.7)`.
   - **Judul Utama:** `AppTextStyles.titleMedium`, warna `AppColors.onBackground`, berat `w700` (Bold pekat).
   - **Metadata Baris:** Ikon ukuran `14.w(context)` berdampingan dengan `AppTextStyles.labelMedium`.
   - **Status & Trailing:** Status warna kontekstual (misal `AppColors.error` untuk belum dikerjakan / terlambat) dengan trailing opsional di kanan.
   - **Bottom Widget:** Widget tambahan yang diletakkan tepat di bawah status (misal: badge validator yang tidak ditumpuk di kanan).
3. **Pemisah (Divider / Separator):**
   - **Bentuk:** Wadah `Container` garis tegas dengan ujung membulat halus (`borderRadius: 1.w(context)`).
   - **Ketebalan Baku (Thickness):** **`2.0.h(context)`** (cukup tebal dan tegas, tidak samar/nyaru di layar beresolusi tinggi).
   - **Warna Kontras Baku:** **`AppColors.onBackground.withValues(alpha: 0.18)`** (harmonis dengan tema Deep Teal, tegas membatasi item tanpa mengganggu teks).
   - **Padding Spacing:** Horizontal `4.w(context)`, Vertikal `2.h(context)`.
   - Dapat dinonaktifkan dengan `showDivider: false` (misal untuk item paling akhir).

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `title` | `String` | Ya | Judul utama dokumen, tugas, atau riwayat. |
| `category` | `String?` | Opsional | Label kategori tingkat atas (contoh: Nama Mata Pelajaran). |
| `subcategory` | `String?` | Opsional | Keterangan sub-kategori (contoh: Nama Guru Pengampu). |
| `metadataText` | `String?` | Opsional | Teks waktu/jadwal/tenggat (contoh: "Tenggat: Besok, 23:59 WIB"). |
| `metadataIcon` | `IconData?` | Opsional | Ikon di samping metadata waktu (contoh: `PhosphorIcons.calendarBlank`). |
| `statusText` | `String?` | Opsional | Label status dokumen/pengerjaan (contoh: "Belum Dikerjakan"). |
| `statusIcon` | `IconData?` | Opsional | Ikon indikator status (contoh: `PhosphorIcons.clock`). |
| `statusColor` | `Color?` | Opsional | Warna teks & ikon status (default `AppColors.onBackground`). |
| `trailing` | `Widget?` | Opsional | Komponen aksi tambahan di pojok kanan bawah. |
| `bottomWidget` | `Widget?` | Opsional | Komponen tambahan yang diletakkan tepat di bawah baris status (contoh: Pill Badge Validator). |
| `onTap` | `VoidCallback?` | Opsional | Fungsi callback saat item baris ditekan. |
| `showDivider` | `bool` | Opsional | Menampilkan garis batas di bawah item (default: `true`). |
| `dividerThickness` | `double?` | Opsional | Ketebalan garis pembatas (default: `2.0.h(context)`). |
| `dividerColor` | `Color?` | Opsional | Warna garis pembatas (default: `AppColors.onBackground (18% alpha)`). |
| `padding` | `EdgeInsetsGeometry?` | Opsional | Override padding kustom jika dibutuhkan. |

---

## 💻 4. Blueprint Contoh Pemakaian

### Contoh 1: Penerapan pada Tugas Item Siswa
```dart
ItemListTile(
  category: 'Matematika Wajib',
  subcategory: 'Drs. Hendro Wibowo',
  title: 'Latihan Soal Matriks Bab 3',
  metadataIcon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
  metadataText: 'Batas Pengumpulan: Besok, 23:59 WIB',
  statusIcon: PhosphorIcons.clock(PhosphorIconsStyle.fill),
  statusText: 'Belum Dikerjakan',
  statusColor: AppColors.error,
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailTugasScreen()));
  },
)
```

### Contoh 2: Penerapan pada Riwayat Presensi / Dokumen
```dart
ItemListTile(
  category: 'Izin Sakit',
  title: 'Surat Keterangan Dokter dari RSUD',
  metadataIcon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
  metadataText: 'Diajukan: 12 Okt 2026, 08:00 WIB',
  statusText: 'Disetujui',
  statusColor: AppColors.primary,
  showDivider: true,
  onTap: () {
    // Navigasi ke preview surat
  },
)
```
