# 🔲 Spesifikasi Komponen: `MenuIconButton`
**Kategori:** Sistem Tombol (Button Family)  
**Target:** Grid Layanan Cepat (Home Siswa, Guru, BK, TU)  
**File Kode:** `lib/core/widgets/menu_icon_button.dart`

---

## 🎯 1. Deskripsi & Tujuan
`MenuIconButton` adalah tombol kotak berlekuk halus (*squircle rounded rectangle*) yang digunakan sebagai gerbang aksi cepat pada dashboard. Tombol ini memiliki rasio simetris 1:1 untuk ikon, diikuti dengan label teks deskripsi di bagian bawahnya.

---

## 📐 2. Anatomi & Pengukuran Dimensi (Sizing & Ratio)
```text
      ┌───────────┐  ▲
      │           │  │ 56px (fluid .w)
      │    [★]    │  │ Box Rounded: 20px (~35% dari ukuran)
      │           │  │ Latar: AppColors.primaryContainer
      └───────────┘  ▼
           8px (Jarak Spacing)
        [ Label ]   AppTextStyles.labelSmall
```

1. **Kotak Wadah Ikon (Squircle Container):**
   - **Dimensi:** `56.w(context)` x `56.w(context)`.
   - **Tingkat Kelengkungan (Border Radius):** **`20.w(context)`** (sekitar **35.7%** dari panjang sisi kotak). Memberikan nuansa modern dan empuk.
   - **Warna Latar:** Blok solid `AppColors.primaryContainer` (Deep Teal).
   - **Bayangan Halus:** `BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.15), blurRadius: 10, offset: Offset(0, 4))`.
2. **Ikon di Tengah:**
   - Ukuran: `24.w(context)`.
   - Warna: `AppColors.onPrimaryContainer` (Putih murni).
3. **Label Teks di Bawah:**
   - Jarak dari kotak: `8.h(context)`.
   - Tipografi: `AppTextStyles.labelSmall`, rata tengah (`textAlign: TextAlign.center`), warna `AppColors.onSurface`.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `icon` | `IconData` | Ya | Ikon Phosphor penanda fitur (misal: kalender, tugas). |
| `label` | `String` | Ya | Nama fitur singkat (contoh: "Presensi", "Jadwal"). |
| `onTap` | `VoidCallback` | Ya | Aksi ketika tombol ditekan (buka halaman/modal). |
| `backgroundColor` | `Color?` | Opsional | Default ke `AppColors.primaryContainer`. |
| `iconColor` | `Color?` | Opsional | Default ke `AppColors.onPrimaryContainer`. |

---

## 💻 4. Blueprint Contoh Pemakaian
```dart
MenuIconButton(
  icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
  label: 'Presensi',
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen()));
  },
)
```
