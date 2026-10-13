# 📊 Spesifikasi Komponen: `CardInfo`
**Kategori:** Kartu & Tampilan Data (Cards & Data Display)  
**Target:** Kartu Ringkasan Metrik / Statistik (Presensi, Poin, Tugas, Habit)  
**File Kode:** `lib/core/widgets/card_info.dart`  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`CardInfo` adalah komponen kartu statistik kompak untuk menampilkan metrik kunci (seperti *Hadir Penuh*, *Terlambat*, *Poin Pelanggaran*, *Tugas Selesai*). Komponen ini memadukan kontainer ikon berwarna dengan teks judul dan angka statistik tebal, menjaga keterbacaan tinggi (*high scannability*) di berbagai dashboard aplikasi.

---

## 📐 2. Anatomi & Pengukuran Dimensi
```text
┌──────────────────────────────────────┐
│  ┌──────┐   Hadir Penuh              │
│  │ [✓]  │   18 Hari                  │
│  └──────┘                            │
└──────────────────────────────────────┘
```
1. **Wadah Luar (Container):**
   - **Padding:** `12.w(context)`.
   - **Border Radius:** `16.w(context)`.
   - **Warna Latar:** `AppColors.surface`.
   - **Bayangan:** `BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))`.
2. **Kontainer Ikon:**
   - **Dimensi:** `42.w(context)` x `42.w(context)`.
   - **Border Radius:** `12.w(context)`.
   - **Warna Latar:** Dinamis sesuai konteks (`AppColors.primary` untuk hadir, `AppColors.error` untuk terlambat).
3. **Tipografi & Hirarki:**
   - **Judul (`title`):** `AppTextStyles.labelSmall`, warna `AppColors.onSurface.withValues(alpha: 0.7)` atau kustom.
   - **Angka Nilai (`value`):** `AppTextStyles.titleLarge` tebal (`FontWeight.w700`).
   - **Satuan (`unit`):** `AppTextStyles.labelSmall`, diletakkan sejajar bawah (*bottom-aligned*) di samping nilai.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `title` | `String` | Ya | Label kartu (contoh: "Hadir Penuh", "Terlambat", "Poin Siswa"). |
| `value` | `String` | Ya | Nilai metrik (contoh: "18", "2", "95"). |
| `unit` | `String?` | Opsional | Satuan teks di samping nilai (contoh: "Hari", "Poin", "Tugas"). |
| `icon` | `IconData` | Ya | Ikon Phosphor penjelas metrik. |
| `iconBgColor` | `Color?` | Opsional | Warna latar kotak ikon (default `AppColors.primary`). |
| `iconColor` | `Color?` | Opsional | Warna ikon (default `AppColors.onPrimary`). |
| `titleColor` | `Color?` | Opsional | Warna teks judul. |
| `valueColor` | `Color?` | Opsional | Warna angka metrik. |
| `onTap` | `VoidCallback?` | Opsional | Callback interaksi ketika kartu ditekan. |

---

## 💻 4. Contoh Penggunaan
```dart
CardInfo(
  title: 'Hadir Penuh',
  value: '18',
  unit: 'Hari',
  icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
  iconBgColor: AppColors.primary,
  iconColor: AppColors.onPrimary,
)
```
