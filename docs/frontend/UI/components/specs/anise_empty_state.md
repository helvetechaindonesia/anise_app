# 📭 Spesifikasi Komponen: `AniseEmptyState`
**Kategori:** Tampilan Status Kosong (Empty State / Zero-Data Display)  
**Target:** Seluruh Layar Daftar saat Data Kosong atau Hasil Pencarian Nihil  
**File Kode:** `lib/core/widgets/anise_empty_state.dart`  
*Terakhir Diperbarui: 15 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`AniseEmptyState` adalah komponen standar antarmuka untuk menampilkan kondisi di mana suatu daftar data tidak memiliki konten (*zero-data state*), baik karena belum ada entri yang ditambahkan ke sistem maupun karena hasil pencarian kata kunci (*search query*) tidak menemukan hasil yang cocok.

Komponen ini dirancang untuk menggantikan teks polos (`Text('Tidak ada data')`) dengan tampilan visual yang terstandarisasi, bersahabat, dan konsisten di seluruh aplikasi:
- Menggunakan ikon nampan kosong baku (`PhosphorIcons.tray bold`) di dalam lingkaran bergradasi lembut.
- Format judul baku: *"Belum Ada Data [Nama Kategori]"*.
- Deskripsi pendukung yang informatif dan ramah konteks.

---

## 📐 2. Anatomi & Struktur Visual
```text
┌──────────────────────────────────────────────────────────────┐
│                            [ 📥 ]                            │
│                 Badge Lingkaran Ikon (76x76)                 │
│               (AppColors.primary 8% opacity)                 │
│                                                              │
│                   Belum Ada Data Pengguna                    │
│               (titleMedium, w700 Bold pekat)                 │
│                                                              │
│      Daftar pengguna dengan role ini belum ditambahkan       │
│               ke dalam sistem sekolah.                       │
│            (bodyMedium, onSurface 60% opacity)               │
└──────────────────────────────────────────────────────────────┘
```

1. **Badge Ikon (Icon Badge):**
   - Diameter: `76.w(context)` berbentuk lingkaran sempurna (`BoxShape.circle`).
   - Latar Belakang: `AppColors.primary.withValues(alpha: 0.08)`.
   - Ikon Baku: `PhosphorIcons.tray(PhosphorIconsStyle.bold)`, ukuran `38.w(context)`, warna `AppColors.primary (65% alpha)`.
2. **Judul Utama (Primary Title):**
   - Format standar: *"Belum Ada Data X"*.
   - Tipografi: `AppTextStyles.titleMedium(context, color: AppColors.onBackground)` dengan berat `FontWeight.w700`.
3. **Deskripsi Tambahan (Subtitle / Context Info):**
   - Tipografi: `AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))`.
   - Mengubah kalimat secara adaptif: jika mode pencarian, menyebutkan kata kunci pencarian; jika mode data baru, memberi instruksi pengisian.

---

## ⚙️ 3. Parameter Properti (Props)

| Parameter | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `title` | `String` | Ya | Keterangan judul utama (contoh: *"Belum Ada Data Siswa"*). |
| `subtitle` | `String?` | Opsional | Keterangan detail penjelasan atau instruksi. |
| `icon` | `IconData?` | Opsional | Ikon kustom jika ingin mengganti ikon baku `standardIcon`. |
| `padding` | `EdgeInsetsGeometry?` | Opsional | Jarak luar wadah (default: horizontal `32.w`, vertikal `40.h`). |

---

## 💻 4. Blueprint Contoh Pemakaian

### Contoh 1: Penerapan pada Manajemen User saat Hasil Pencarian Kosong
```dart
if (filteredUsers.isEmpty) {
  return AniseEmptyState(
    title: 'Belum Ada Data ${_formatRoleName(_selectedFilter ?? 'User')}',
    subtitle: query.isNotEmpty
        ? 'Tidak ada pengguna yang cocok dengan kata kunci "$query".'
        : 'Daftar pengguna dengan role ini belum ditambahkan ke sistem sekolah.',
  );
}
```

### Contoh 2: Penerapan pada Manajemen Sekolah (Kelas / Jabatan Kosong)
```dart
if (items.isEmpty) {
  return AniseEmptyState(
    title: 'Belum Ada Data $category',
    subtitle: 'Data master untuk $category belum diinput atau disinkronkan.',
  );
}
```
