# 🔗 Spesifikasi Komponen: `SectionActionLink` (Menu Extend "Semua >")
**Kategori:** Navigation & Links  
**Target:** Header Seksi Daftar di Dashboard (Tugas Mendatang, Jurnal Mengajar, Bimbingan BK, Pantau Tugas)  
**File Kode:** `lib/core/widgets/section_action_link.dart`

---

## 🎯 1. Deskripsi & Tujuan
`SectionActionLink` (sebelumnya disebut Menu Extend / "Lihat Semua") adalah tombol navigasi ringkas satu baris yang diletakkan sejajar di sisi kanan judul seksi (*Section Header*). 

### 💡 Keputusan Refactor & Polish:
- **Sebelum:** Teks boros ruang dua baris `'Lihat\nSemua'` yang membuat tinggi seksi tidak seimbang.
- **Sesudah:** Disederhanakan menjadi **satu baris ramping**: kata **`"Semua"`** diikuti ikon caret kanan **`>`** (`PhosphorIcons.caretRight bold`).

---

## 📐 2. Anatomi & Pengukuran Dimensi
```text
┌──────────────────────────────────────────────────────────────┐
│  Tugas Mendatang                                   Semua  >  │
│  (Judul Seksi Kiri)                              (Satu Baris)│
└──────────────────────────────────────────────────────────────┘
```

1. **Tata Letak:**
   - Baris horizontal rapat (`Row mainAxisSize: min`).
   - Teks: `"Semua"` menggunakan `AppTextStyles.labelMedium(context, color: AppColors.onBackground)`.
   - Jarak: `4.w(context)`.
   - Ikon: `PhosphorIcons.caretRight(PhosphorIconsStyle.bold)` ukuran `14.w(context)` s/d `16.w(context)`.
2. **Efek Interaksi:**
   - Dibungkus `InkWell` / `GestureDetector` dengan padding sentuh minimum `8.w(context)` agar tetap mudah disentuh jari.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Default | Keterangan |
| :--- | :--- | :---: | :--- |
| `text` | `String` | `'Semua'` | Label tautan (bisa diubah jika perlu konteks lain). |
| `onTap` | `VoidCallback` | Wajib | Alur navigasi saat tautan ditekan. |
| `color` | `Color?` | `AppColors.onBackground` | Warna teks dan ikon panah. |

---

## 💻 4. Blueprint Contoh Pemakaian
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Tugas Mendatang', style: AppTextStyles.titleMedium(context)),
    SectionActionLink(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TugasScreen()));
      },
    ),
  ],
)
```
