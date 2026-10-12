# 📱 Spesifikasi Komponen: `MainHeader`
**Kategori:** Header & Navigation  
**Target:** Seluruh Tab Dashboard Utama (Siswa, Guru, BK, Staf TU)  
**File Kode:** `lib/core/widgets/main_header.dart`

---

## 🎯 1. Deskripsi & Tujuan
`MainHeader` adalah payung identitas visual teratas pada layar dashboard utama aplikasi Anise. Berbeda dengan sub-page header, `MainHeader` tidak memiliki tombol back, melainkan menampilkan identitas sekolah, nama entitas, dan akses cepat ke notifikasi.

---

## 📐 2. Anatomi & Struktur Visual
```text
┌──────────────────────────────────────────────────────────────┐
│  [Logo Sekolah]  SMA NEGERI 1 PEUNARON        [ 🔔 Icon ]   │
│  (36x36 px)      Sistem Informasi Akademik     (Badge Unread)│
└──────────────────────────────────────────────────────────────┘
```

1. **Sisi Kiri (Branding Cluster):**
   - **Logo Sekolah / Anise:** Container logo dengan rasio 1:1 (`36x36.w`), sudut tumpul halus (`radius 10px`).
   - **Teks Nama Sekolah (H1):** `AppTextStyles.titleMedium` dengan `fontWeight: FontWeight.w700`, warna `AppColors.onBackground`.
   - **Teks Keterangan / Subtitle:** `AppTextStyles.labelSmall` dengan warna `AppColors.onSurfaceVariant` (misal: "Sistem Informasi Akademik & Kesiswaan").
2. **Sisi Kanan (Action Cluster):**
   - **Notification Button:** Tombol ikon lonceng (`PhosphorIcons.bell(PhosphorIconsStyle.bold)`).
   - **Unread Badge:** Titik merah bulat (`radius 4px`, warna `AppColors.error`) jika terdapat pesan yang belum dibaca.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `schoolName` | `String` | Ya | Nama resmi sekolah (default: "SMA Negeri 1 Peunaron"). |
| `subtitle` | `String?` | Opsional | Keterangan singkat di bawah nama sekolah. |
| `logoPath` | `String?` | Opsional | Path asset logo sekolah / icon app. |
| `hasUnreadNotification`| `bool` | Opsional | Menampilkan titik merah di atas ikon lonceng. |
| `onNotificationPressed`| `VoidCallback?` | Ya | Alur navigasi saat tombol lonceng diklik. |

---

## 💻 4. Blueprint Contoh Pemakaian
```dart
MainHeader(
  schoolName: 'SMA Negeri 1 Peunaron',
  subtitle: 'Sistem Informasi Akademik',
  hasUnreadNotification: true,
  onNotificationPressed: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
  },
)
```
