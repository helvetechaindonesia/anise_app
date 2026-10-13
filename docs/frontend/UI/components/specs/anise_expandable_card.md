# 📂 Spesifikasi Komponen: `AniseExpandableCard`
**Kategori:** Kartu & Tampilan Data (Cards & Data Display)  
**Target:** Kartu Accordion Kolapsibel (Rekap Ketidakhadiran, Rincian Nilai, Detail Pembayaran)  
**File Kode:** `lib/core/widgets/anise_expandable_card.dart`  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`AniseExpandableCard` adalah komponen kartu akordeon (*collapsible accordion card*) yang mendukung pembukaan dan penutupan rincian konten secara teranimasi halus (*smooth cross-fade*). Dilengkapi rotasi ikon panah (*chevron rotation* 180°), header informatif (judul + subjudul + ikon), dan kontainer isi independen.

---

## 📐 2. Anatomi & Pengukuran Dimensi
```text
┌────────────────────────────────────────────────────────┐
│  [📅]  Rekap Ketidakhadiran                  [ v ]     │
│        Oktober 2026                                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Sakit: 1 Hari                                   │  │ (Konten Terbuka)
│  │  Izin: 0 Hari                                    │  │
│  │  Alpha: 0 Hari                                   │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```
1. **Wadah Luar Header:**
   - **Padding:** `horizontal: 16.w(context)`, `vertical: 14.h(context)`.
   - **Border Radius:** `16.w(context)`.
   - **Warna Latar:** Default `AppColors.primaryContainer` (Deep Teal).
   - **Warna Teks & Ikon:** `AppColors.onPrimaryContainer`.
2. **Animasi Perubahan Ukuran:**
   - Menggunakan `AnimatedCrossFade` dan `AnimationController` (durasi `250ms`, kurva `Curves.easeInOut`).
   - Ikon panah berputar dinamis menggunakan `RotationTransition`.
3. **Kontainer Isi (`child`):**
   - Padding internal `14.w(context)`.
   - Border radius internal `12.w(context)`.
   - Latar belakang default `AppColors.surface`.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `title` | `String` | Ya | Judul kartu header (contoh: "Rekap Ketidakhadiran"). |
| `subtitle` | `String?` | Opsional | Keterangan kecil di bawah judul (contoh: "Oktober 2026"). |
| `icon` | `IconData?` | Opsional | Ikon penjelas di sisi kiri judul. |
| `child` | `Widget` | Ya | Widget konten rincian yang muncul saat kartu terbuka. |
| `initiallyExpanded` | `bool` | Opsional | Default `false` (tertutup saat pertama kali dimuat). |
| `onExpansionChanged` | `ValueChanged<bool>?` | Opsional | Callback status buka/tutup. |
| `headerBgColor` | `Color?` | Opsional | Default `AppColors.primaryContainer`. |
| `contentBgColor` | `Color?` | Opsional | Default `AppColors.surface`. |
| `textColor` | `Color?` | Opsional | Default `AppColors.onPrimaryContainer`. |

---

## 💻 4. Contoh Penggunaan
```dart
AniseExpandableCard(
  title: 'Rekap Ketidakhadiran',
  subtitle: 'Oktober 2026',
  icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
  child: Column(
    children: [
      Text('Sakit: 1 Hari'),
      Text('Izin: 0 Hari'),
    ],
  ),
)
```
