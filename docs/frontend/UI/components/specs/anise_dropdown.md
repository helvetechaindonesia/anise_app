# 🔽 Spesifikasi Komponen: `AniseDropdown`
**Kategori:** Form & Filter Selector  
**Target:** Seluruh Filter Dropdown Aplikasi (Presensi, Tugas, Jadwal, Penilaian, BK, Tata Usaha)  
**File Kode:** `lib/core/widgets/anise_dropdown.dart`  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`AniseDropdown<T>` adalah komponen pemilih menu jatuh (*dropdown selector*) standar di seluruh aplikasi Anise. Komponen ini menggantikan pembuatan manual `Container + BoxDecoration + DropdownButtonHideUnderline` yang sebelumnya tersebar dan tidak seragam. `AniseDropdown` menjamin konsistensi sudut lengkung (`16.w`), warna outline terstandar, ikon chevron Phosphor, dan perataan teks baku.

---

## 📐 2. Anatomi & Pengukuran Dimensi
```text
┌────────────────────────────────────────────────────────┐
│  Bulan: Oktober                              [ v ]     │
└────────────────────────────────────────────────────────┘
```
1. **Wadah Luar (Container):**
   - **Padding:** `horizontal: 16.w(context)`, `vertical: 4.h(context)`.
   - **Border Radius:** `16.w(context)`.
   - **Border:** `Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.8))`.
   - **Warna Latar:** `AppColors.surface`.
   - **Bayangan Halus:** `BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))`.
2. **Ikon Panah Kanan:**
   - Ikon: `PhosphorIcons.caretDown(PhosphorIconsStyle.bold)`.
   - Ukuran: `16.w(context)`.
   - Warna: `AppColors.onSurfaceVariant`.
3. **Tipografi Item:**
   - Menggunakan `AppTextStyles.labelMedium(context, color: AppColors.onSurface)`.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `value` | `T?` | Ya | Nilai yang sedang terpilih saat ini. |
| `items` | `List<DropdownMenuItem<T>>` | Ya | Daftar pilihan item dropdown. |
| `onChanged` | `ValueChanged<T?>?` | Ya | Callback ketika item baru dipilih. |
| `hintText` | `String?` | Opsional | Teks petunjuk saat nilai belum dipilih. |
| `isExpanded` | `bool` | Opsional | Default `true` (mengisi penuh lebar kolom induk). |
| `backgroundColor` | `Color?` | Opsional | Default `AppColors.surface`. |
| `borderColor` | `Color?` | Opsional | Default `AppColors.outlineVariant.withValues(alpha: 0.8)`. |
| `borderRadius` | `BorderRadius?` | Opsional | Default `BorderRadius.circular(16.w(context))`. |

---

## 💻 4. Contoh Penggunaan
```dart
AniseDropdown<String>(
  value: selectedMonth,
  onChanged: (newValue) => ref.read(selectedMonthProvider.notifier).state = newValue!,
  items: months.map((m) => DropdownMenuItem(
    value: m,
    child: Text('Bulan: $m'),
  )).toList(),
)
```
