# 🔲 Spesifikasi Komponen: `MenuIconButton`
**Kategori:** Sistem Tombol (Button Family)  
**Target:** Grid Layanan Cepat (Home Siswa, Guru, BK, TU)  
**File Kode:** `lib/core/widgets/menu_icon_button.dart`

*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`MenuIconButton` adalah tombol kotak berlekuk halus (*squircle rounded rectangle*) baku yang digunakan sebagai gerbang aksi cepat pada grid dashboard Layanan Cepat (Siswa, Guru, BK, TU). 

Tombol ini menggabungkan wadah ikon simetris 1:1 di atas, efek sentuhan riak lembut (*InkWell*), dan label deskripsi di bawah yang mendukung teks hingga 2 baris tanpa risiko overflow.

---

## 📐 2. Anatomi & Pengukuran Dimensi (Sizing & Ratio)
```text
      ┌───────────┐  ▲
      │           │  │ 56px (fluid .w)
      │    [★]    │  │ Box Rounded: 20px (~35% dari ukuran)
      │           │  │ Latar: AppColors.primaryContainer (Deep Teal)
      └───────────┘  ▼
           8px (Jarak Spacing fluid .h)
      [ Dua Baris ]   AppTextStyles.labelSmall (maxLines: 2)
       [ Label ]      Rata Tengah + Ellipsis
```

1. **Kotak Wadah Ikon (Squircle Container):**
   - **Dimensi:** `56.w(context)` x `56.w(context)`.
   - **Tingkat Kelengkungan (Border Radius):** **`20.w(context)`** (sekitar **35.7%** dari panjang sisi kotak). Memberikan nuansa modern dan empuk.
   - **Warna Latar:** Blok solid pekat `AppColors.primaryContainer` (Deep Teal).
   - **Bayangan Halus:** `BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.2), blurRadius: 10, offset: Offset(0, 4))`.
2. **Ikon di Tengah:**
   - Ukuran: `24.w(context)`.
   - Warna: `AppColors.onPrimaryContainer` (Putih murni).
3. **Label Teks di Bawah:**
   - Jarak dari kotak: `8.h(context)`.
   - Tipografi: `AppTextStyles.labelSmall`, rata tengah (`textAlign: TextAlign.center`), warna `AppColors.onSurface`.
   - Batas Baris: `maxLines: 2`, `overflow: TextOverflow.ellipsis` (menghindari teks panjang terpotong kaku).
4. **Standar Penataan Grid (Grid Specification):**
   - Kolom: `crossAxisCount: 4`.
   - Rasio Aspek Sel: **`childAspectRatio: 0.72`** (proporsi baku di seluruh role).
   - Jarak Antar Sel: `crossAxisSpacing: 8.w(context)`, `mainAxisSpacing: 16.h(context)`.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `icon` | `IconData` | Ya | Ikon Phosphor penanda fitur (misal: kalender, tugas). |
| `label` | `String` | Ya | Nama fitur singkat (contoh: "Presensi", "Manajemen Sekolah"). |
| `onTap` | `VoidCallback` | Ya | Aksi ketika tombol ditekan (buka halaman/modal). |
| `backgroundColor` | `Color?` | Opsional | Default ke `AppColors.primaryContainer`. |
| `iconColor` | `Color?` | Opsional | Default ke `AppColors.onPrimaryContainer`. |
| `maxLines` | `int` | Opsional | Jumlah baris maksimal teks label (default: `2`). |

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
