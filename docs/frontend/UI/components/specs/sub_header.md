# 📑 Spesifikasi Komponen: `SubHeader`
**Kategori:** Header & Navigation  
**Target:** Seluruh Halaman Turunan (Sub-Page, Detail Screen, Form Input)  
**File Kode:** `lib/core/widgets/sub_header.dart` (atau `anise_app_bar.dart`)

---

## 🎯 1. Deskripsi & Tujuan
`SubHeader` adalah bar navigasi standar yang muncul saat pengguna berpindah dari tab utama menuju halaman yang lebih dalam. Fokus utamanya adalah memberi navigasi kembali (*Back / Close*) serta menampilkan konteks nama halaman secara tegas di tengah (*Center Title*).

---

## 📐 2. Anatomi & Struktur Visual
```text
┌──────────────────────────────────────────────────────────────┐
│  [ < / X ]                  JUDUL HALAMAN          [ Aksi ]  │
│  (CaretLeft/Close)          (Center Title)         (Opsional)│
└──────────────────────────────────────────────────────────────┘
```

1. **Sisi Kiri (Leading Action):**
   - Ikon panah kembali (`PhosphorIcons.caretLeft bold`) atau ikon silang tutup (`PhosphorIcons.x bold`).
   - Ukuran ikon: `24.w(context)`, warna `AppColors.onBackground`.
2. **Bagian Tengah (Title):**
   - Rata tengah (`centerTitle: true`).
   - Tipografi: `AppTextStyles.titleMedium` dengan `fontWeight: FontWeight.w700`.
3. **Sisi Kanan (Trailing Actions - Opsional):**
   - Mendukung ikon aksi tambahan (misal: tombol filter, tombol opsi tiga titik, tombol download berkas).

> [!IMPORTANT]
> **Kebijakan Baku Ikon Notifikasi (Notification Bell Rule):**  
> Ikon lonceng notifikasi **DILARANG** dipasang pada `actions` di SubHeader maupun `AppBar` halaman turunan (seperti *Manajemen User*, *Manajemen Sekolah*, dsb.). Ikon lonceng notifikasi **hanya eksklusif** ditempatkan pada Header Dashboard Utama (`MainHeader`). Hal ini menjaga header sub-layar tetap bersih, terfokus pada tugas, dan mencegah duplikasi navigasi notifikasi.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Default | Keterangan |
| :--- | :--- | :---: | :--- |
| `title` | `String` | Wajib | Nama halaman / konteks fitur yang sedang dibuka. |
| `isCloseIcon` | `bool` | `false` | Jika `true`, mengganti caret panah dengan tanda silang (X). |
| `onBackPressed` | `VoidCallback?` | `Navigator.pop` | Callback ketika tombol kembali diklik. |
| `actions` | `List<Widget>?` | `null` | Kumpulan widget aksi di sisi kanan. |
| `bottom` | `PreferredSizeWidget?`| `null` | Tambahan TabBar / SearchBar di bawah header. |

---

## 💻 4. Blueprint Contoh Pemakaian
```dart
Scaffold(
  appBar: SubHeader(
    title: 'Rekap Presensi Siswa',
    onBackPressed: () => Navigator.pop(context),
    actions: [
      IconButton(
        icon: Icon(PhosphorIcons.funnel(PhosphorIconsStyle.bold)),
        onPressed: () => openFilterSheet(),
      )
    ],
  ),
  body: ...
)
```
