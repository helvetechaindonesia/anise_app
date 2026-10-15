# 🔘 Spesifikasi Komponen: `CustomExpandableFab`
**Kategori:** Tombol Aksi Mengambang (Floating Action Button / Speed Dial)  
**Target:** Modul Manajemen Data Sekolah & Pengguna (Tata Usaha)  
**File Kode:** `lib/features/tata_usaha/widgets/custom_expandable_fab.dart`  
*Terakhir Diperbarui: 15 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`CustomExpandableFab` adalah tombol tindakan mengambang terstandarisasi untuk modul manajemen data Tata Usaha (seperti **Manajemen User** dan **Manajemen Sekolah**). 

Komponen ini memecah aksi pembuatan data menjadi dua jalur:
1. **Tambah Data Manual (`onAddPressed`):** Membuka form dialog atau halaman input perorangan.
2. **Upload Berkas Excel (`onUploadPressed`):** Memicu pemilihan berkas `.xlsx` / `.xls` untuk pengisian data massal (*One-Door Import*).

Dengan sistem menu yang dapat mengembang (*expandable speed-dial*), pengguna disuguhkan antarmuka yang bersih saat sedang menelusuri data, namun tetap memiliki akses instan ke seluruh opsi pengisian data tanpa tombol yang berjejal.

---

## 📐 2. Anatomi & Struktur Visual
```text
                     ┌────────────────────────────────┐
                     │ [➕] Tambah Data Manual         │ (Sub-Button 1)
                     └────────────────────────────────┘
                                      ▲
                     ┌────────────────────────────────┐
                     │ [📊] Upload Excel              │ (Sub-Button 2)
                     └────────────────────────────────┘
                                      ▲
┌─────────────────────────────────────────────────────┐
│ [📤 Sunting Data]  ◀─── Animasi Rotasi / Switcher ──┤ (Main FAB Button)
│ (Menjadi [❌ Tutup] saat terbuka)                   │
└─────────────────────────────────────────────────────┘
```

1. **Tombol Utama (Main Trigger):**
   - Format: `FloatingActionButton.extended` dengan sudut membulat `borderRadius: 16`.
   - Warna Latar: `AppColors.primary`, teks & ikon `AppColors.onPrimary`.
   - Ikon & Label Default (Tertutup): Ikon `PhosphorIcons.upload` + Label *"Sunting Data"*.
   - Ikon & Label Terbuka: Ikon `PhosphorIcons.x` + Label *"Tutup"*.
   - Transisi: `AnimatedSwitcher` dengan `RotationTransition` + `FadeTransition` berdurasi `200ms`.
2. **Sub-Menu Melayang (Floating Action Items):**
   - Mengembang vertikal dari bawah ke atas menggunakan `SizeTransition` dengan kurva `Curves.easeOutBack` (durasi `250ms`).
   - Setiap sub-item memiliki wujud pil kapsul (`borderRadius: 16`), elevasi halus (`blurRadius: 8, offset: (0, 4)`), dan warna `AppColors.primary`.
   - Jarak antar sub-tombol: `12.h(context)`.

---

## ⚙️ 3. Parameter Properti (Props)

| Parameter | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `onUploadPressed` | `VoidCallback` | Ya | Callback ketika tombol *"Upload Excel"* ditekan. |
| `onAddPressed` | `VoidCallback` | Ya | Callback ketika tombol *"Tambah Data"* ditekan. |

---

## 💻 4. Blueprint Contoh Pemakaian

```dart
Scaffold(
  appBar: ...,
  body: ...,
  floatingActionButton: CustomExpandableFab(
    onUploadPressed: () {
      // Buka bottom sheet pemilihan tipe upload Excel
      _showUploadChoices(context);
    },
    onAddPressed: () {
      // Buka modal / navigasi ke form tambah data baru
      _openAddDataForm(context);
    },
  ),
);
```
