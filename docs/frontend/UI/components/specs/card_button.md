# 🗃️ Spesifikasi Komponen: `CardButton`
**Kategori:** Sistem Tombol (Button Family) & Cards  
**Target:** Card Jadwal Siswa/Guru, Card Kelas, Item Interaktif Berblok Primary  
**File Kode:** `lib/core/widgets/card_button.dart`

---

## 🎯 1. Deskripsi & Tujuan
`CardButton` adalah perpaduan antara **kontainer kartu informasi** dengan **tombol yang dapat diklik**. Berbeda dengan kartu biasa yang pasif, `CardButton` memiliki latar warna blok tegas (`AppColors.primaryContainer`), sudut melengkung berkarakter, serta memberikan feedback sentuhan (*InkWell Ripple Effect*) saat ditekan.

Komponen ini dirancang untuk menggantikan tombol navigasi lama yang kaku (seperti tombol jadwal terpisah pada siswa).

---

## 📐 2. Anatomi & Pengukuran Dimensi (Sizing & Ratio)
```text
┌──────────────────────────────────────────────────────────────┐  ▲
│  [ 👥 32 Siswa ]                             [ 🕒 07:30 ]    │  │
│  (Badge Rounded 12px)                        (Waktu KBM)     │  │
│                                                              │  │ Radius: 24px
│  XII MIPA 1                                                  │  │ (~16-20% kelengkungan)
│  Matematika Wajib                            [ ➔ Panah/Caret]│  │ Latar: Blok Primary
└──────────────────────────────────────────────────────────────┘  ▼
```

1. **Wadah Kartu (Card Shell):**
   - **Tingkat Kelengkungan (Border Radius):** **`24.w(context)`** (sekitar **16% - 20%** dari dimensi kartu). Memberikan kontur yang sangat modern dan ergonomis.
   - **Warna Latar:** Blok solid `AppColors.primaryContainer` (Deep Teal).
   - **Efek Sentuhan:** Dibungkus `Material` transparan + `InkWell` dengan splash color `AppColors.secondary.withValues(alpha: 0.1)`.
2. **Tata Letak Konten:**
   - **Bagian Atas:** Ruang untuk badge status / jumlah peserta didik (radius `12.w`).
   - **Bagian Tengah & Bawah:** Judul utama (Nama Kelas / Nama Agenda) dengan `AppTextStyles.titleMedium` putih, serta nama mapel/keterangan dengan `AppTextStyles.labelMedium`.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `title` | `String` | Ya | Teks utama (misal: nama kelas atau agenda). |
| `subtitle` | `String?` | Opsional | Keterangan tambahan (misal: nama mapel atau jam). |
| `badgeText` | `String?` | Opsional | Teks pada lencana kecil di bagian atas. |
| `badgeIcon` | `IconData?` | Opsional | Ikon pada lencana (misal: ikon siswa atau jam). |
| `onTap` | `VoidCallback` | Ya | Alur navigasi saat kartu diklik. |
| `width` | `double?` | Opsional | Lebar kartu (bisa fix untuk horizontal list atau fill). |
| `customChild` | `Widget?` | Opsional | Jika butuh isi konten custom di dalam card. |

---

## 💻 4. Blueprint Contoh Pemakaian
```dart
CardButton(
  title: 'XII MIPA 1',
  subtitle: 'Matematika Wajib',
  badgeText: '32 Siswa',
  badgeIcon: PhosphorIcons.student(PhosphorIconsStyle.fill),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalGuruDetailScreen(...)));
  },
)
```
