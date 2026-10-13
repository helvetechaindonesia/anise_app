# 📅 Spesifikasi Komponen: `AniseScheduleCard`
**Kategori:** Kartu & Tampilan Data (Cards & Data Display)  
**Target:** Horisontal Schedule/Class Carousel (Home Siswa, Home Guru)  
**File Kode:** `lib/core/widgets/anise_schedule_card.dart`  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`AniseScheduleCard` adalah komponen kartu geser horizontal (*carousel card*) standar untuk menampilkan jadwal kelas, mata pelajaran, dan pengajar. Kartu ini mengusung estetika warna blok pekat (**Deep Teal** `AppColors.primaryContainer`) yang seragam di layar Siswa maupun Guru, menggantikan tampilan lama kartu putih generik.

---

## 📐 2. Anatomi & Pengukuran Dimensi (Sizing & Ratio)
```text
┌──────────────────────────────────────┐  ▲
│  [ Avatar Guru / Icon Profil ]       │  │ 145px (fluid .h)
│  (44x44 px + Online Dot)             │  │ Lebar: 150px (.w)
│                                      │  │ Latar: AppColors.primaryContainer
│  (Spacer)                            │  │ Sudut Lengkung: 24px (.w)
│                                      │  │
│  Mata Pelajaran (Bold White)         │  │ Tipografi Kontras Tinggi
│  Nama Guru Pengampu (75% White)      │  │
└──────────────────────────────────────┘  ▼
```

1. **Kotak Wadah Kartu (Solid Block Container):**
   - **Dimensi:** `150.w(context)` x `145.h(context)`.
   - **Tingkat Kelengkungan (Border Radius):** **`24.w(context)`**.
   - **Warna Latar:** Blok solid pekat `AppColors.primaryContainer` (Deep Teal).
   - **Bayangan Halus:** `BoxShadow(color: primaryContainer.withValues(alpha: 0.15), blurRadius: 12, offset: Offset(0, 4))`.
2. **Elemen Atas (`topWidget`):**
   - Untuk Siswa: Avatar profil guru squircle (`44.w` x `44.w`) dengan dot hijau aktif di sudut. Bebas dari pill badge generik.
   - Untuk Guru: Badge counter jumlah siswa (`Icon(student) + '32 Siswa'`).
3. **Elemen Bawah (Teks & Hirarki):**
   - **Judul Utama (`title`):** Nama Mata Pelajaran / Kelas, teks tebal `AppTextStyles.titleMedium`, warna `AppColors.onPrimaryContainer`.
   - **Subjudul (`subtitle`):** Nama Guru Pengampu / Jam KBM, teks `AppTextStyles.labelSmall`, warna `AppColors.onPrimaryContainer.withValues(alpha: 0.75)`.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `title` | `String` | Ya | Judul utama kartu (contoh: "Pemrograman Web", "X RPL 1"). |
| `subtitle` | `String` | Ya | Keterangan sekunder (contoh: "Budi Santoso, S.Kom.", "Ruang Lab 2"). |
| `topWidget` | `Widget?` | Opsional | Widget bagian atas kartu (misal: Avatar Guru atau Counter Badge). |
| `onTap` | `VoidCallback?` | Opsional | Aksi ketika kartu diklik (membuka jadwal detail / silabus). |
| `backgroundColor` | `Color?` | Opsional | Default ke `AppColors.primaryContainer`. |
| `width` | `double?` | Opsional | Default ke `150.w(context)`. |
| `height` | `double?` | Opsional | Default ke `145.h(context)`. |

---

## 💻 4. Contoh Penggunaan
```dart
AniseScheduleCard(
  title: 'Pemrograman Web',
  subtitle: 'Budi Santoso, S.Kom.',
  topWidget: AvatarSquircle(icon: PhosphorIcons.user(PhosphorIconsStyle.fill)),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => JadwalDetailScreen()));
  },
)
```
