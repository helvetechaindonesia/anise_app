# 🧭 Spesifikasi Komponen: `MenuTab`
**Kategori:** Header & Navigation  
**Target:** Navigasi Utama Aplikasi Anise  
**File Kode:** `lib/core/widgets/menu_tab.dart`

---

## 🎯 1. Deskripsi & Tujuan
`MenuTab` adalah bilah navigasi bawah (*Bottom Navigation Bar*) yang menghubungkan modul-modul utama. 

Komponen ini memiliki **dua varian adaptif peran**:
1. **Peran Siswa:** 4 Tab navigasi standar (*Home, Jadwal, Poin, Profil*).
2. **Peran Non-Siswa (Guru / BK / Staf TU):** Terdapat tombol aksi melayang/sentral khusus: **Presensi Cam Action Button** untuk pemindaian presensi harian secara cepat.

---

## 📐 2. Anatomi & Struktur Visual
```text
[ Varian Siswa ]
┌──────────────────────────────────────────────────────────────┐
│    🏠 Home        📅 Jadwal        ⭐ Poin        👤 Profil   │
└──────────────────────────────────────────────────────────────┘

[ Varian Non-Siswa ]
┌──────────────────────────────────────────────────────────────┐
│   🏠 Home     📅 Jadwal    [ 📷 CAM ]    📋 Agenda   👤 Profil│
└──────────────────────────────────────────────────────────────┘
```

1. **Wadah Navigasi:**
   - Latar belakang: `AppColors.surface` dengan shadow lembut ke atas (`offset: Offset(0, -4)`).
   - Border radius atas: `BorderRadius.vertical(top: Radius.circular(24.w))`.
2. **Tab Item Biasa:**
   - Ikon aktif: `PhosphorIconsStyle.fill`, warna `AppColors.primary`.
   - Ikon tidak aktif: `PhosphorIconsStyle.regular`, warna `AppColors.onSurfaceVariant`.
   - Label teks: `AppTextStyles.labelSmall` fluid.
3. **Tombol Presensi Cam (Khusus Non-Siswa):**
   - Lingkaran mengapung di tengah (`width: 52.w`, `height: 52.w`).
   - Latar belakang: `AppColors.primary` dengan ikon kamera putih.
   - Efek glow/shadow lembut berwarna teal.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `currentIndex` | `int` | Ya | Index tab yang sedang aktif. |
| `onTap` | `ValueChanged<int>` | Ya | Handler saat salah satu tab disentuh. |
| `showPresensiCam` | `bool` | Opsional | Aktifkan jika user adalah Guru/BK/Staf TU. |
| `onPresensiCamPressed` | `VoidCallback?` | Opsional | Membuka scanner/kamera presensi langsung. |
| `items` | `List<MenuTabItem>` | Ya | Kumpulan icon dan label untuk tiap tab. |
