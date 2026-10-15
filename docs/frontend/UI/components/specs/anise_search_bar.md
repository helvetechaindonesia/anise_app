# 🔍 Spesifikasi Komponen: `AniseSearchBar`
**Kategori:** Kontrol Input Pencarian (Interactive Search Bar)  
**Target:** Seluruh Layar Manajemen Data & Pencarian (Manajemen User, Manajemen Sekolah, dsb.)  
**File Kode:** `lib/core/widgets/anise_search_bar.dart`  
*Terakhir Diperbarui: 15 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`AniseSearchBar` adalah komponen bilah pencarian terstandarisasi untuk ekosistem aplikasi Anise. Komponen ini menggantikan implementasi widget pencarian yang sebelumnya dibuat secara *hardcoded* dan berulang di berbagai layar seperti *Manajemen Pengguna* (`tu_master_user_screen.dart`) dan *Manajemen Sekolah* (`tu_manajemen_sekolah_screen.dart`).

Komponen ini dirancang dengan standar UX & UI tinggi:
- **Pencarian Real-Time Dinamis:** Mendukung pemfilteran langsung melalui callback `onChanged`.
- **Aksi Hapus Cepat (Quick Clear Button):** Menampilkan tombol ikon silang (`xCircle`) secara reaktif hanya ketika kolom teks berisi karakter, yang langsung mengosongkan teks dan menyinkronkan filter ketika ditekan.
- **Konsistensi Visual Elegan:** Menggunakan elevated card dengan `AppColors.surface`, outline border subtil, dan bayangan lembut (*subtle elevation shadow*).
- **Desain Responsif Penuh:** Mengadaptasi ukuran padding, margin, ikon, dan radius sesuai layar menggunakan ekstensi `.w(context)` dan `.h(context)`.

---

## 📐 2. Anatomi & Struktur Visual
```text
┌────────────────────────────────────────────────────────────────────────┐
│ [ 🔍 ]   Cari nama pengguna atau email...                       [ ⓧ ]  │
│  Ikon                Kolom Teks (TextField)                   Tombol   │
│ Kaca Pembesar        bodyMedium (AppColors.onSurface)          Hapus   │
│ (20x20, 50% alpha)                                       (18x18, 40%)  │
└────────────────────────────────────────────────────────────────────────┘
```

1. **Wadah Utama (Container Card):**
   - Latar Belakang: `AppColors.surface`.
   - Radius Sudut: `16.w(context)`.
   - Garis Batas: Border tipis `AppColors.outline.withValues(alpha: 0.2)`.
   - Bayangan (BoxShadow): Warna `AppColors.black.withValues(alpha: 0.03)`, `blurRadius: 10`, `offset: const Offset(0, 4)`.
   - Padding Internal: Horizontal `16.w(context)`.
   - Padding Luar (Default): Horizontal `24.w(context)`, Vertikal `8.h(context)`.
2. **Ikon Kaca Pembesar (Leading Search Icon):**
   - Ikon: `PhosphorIcons.magnifyingGlass()`.
   - Ukuran: `20.w(context)`.
   - Warna: `AppColors.onSurface.withValues(alpha: 0.5)`.
   - Jarak ke Teks: `12.w(context)`.
3. **Kolom Masukan Teks (TextField):**
   - Gaya Teks Aktif: `AppTextStyles.bodyMedium(context, color: AppColors.onSurface)`.
   - Gaya Placeholder (Hint): `AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4))`.
   - Perilaku: `isDense: true`, `border: InputBorder.none`, padding vertikal `14.h(context)`.
4. **Tombol Hapus Cepat (Trailing Clear Button):**
   - Kondisi Tampil: Ditampilkan otomatis jika `controller.text.isNotEmpty`.
   - Ikon: `PhosphorIcons.xCircle(PhosphorIconsStyle.fill)`.
   - Ukuran: `18.w(context)`.
   - Warna: `AppColors.onSurface.withValues(alpha: 0.4)`.
   - Aksi: Mengosongkan controller via `controller.clear()` dan memanggil callback `onClear` atau `onChanged('')`.

---

## ⚙️ 3. Parameter Properti (Props)

| Parameter | Tipe Data | Wajib? | Nilai Bawaan | Keterangan |
| :--- | :--- | :---: | :---: | :--- |
| `controller` | `TextEditingController` | **Ya** | - | Controller pengelola teks input pencarian. |
| `hintText` | `String` | **Ya** | - | Teks petunjuk saat input masih kosong (placeholder). |
| `onChanged` | `ValueChanged<String>?` | Opsional | `null` | Callback yang dipicu setiap kali teks input berubah secara real-time. |
| `onClear` | `VoidCallback?` | Opsional | `null` | Callback kustom saat tombol clear ditekan. Jika kosong, akan otomatis memanggil `onChanged('')`. |
| `padding` | `EdgeInsetsGeometry?` | Opsional | `H: 24.w, V: 8.h` | Jarak luar wadah bilah pencarian jika ingin disesuaikan. |

---

## 💻 4. Blueprint Contoh Pemakaian

### Contoh 1: Penerapan pada Layar Manajemen Pengguna (`tu_master_user_screen.dart`)
```dart
AniseSearchBar(
  controller: _searchController,
  hintText: 'Cari nama atau email pengguna...',
  onChanged: (val) {
    setState(() {
      _searchQuery = val;
    });
  },
  onClear: () {
    setState(() {
      _searchQuery = '';
    });
  },
)
```

### Contoh 2: Penerapan pada Layar Manajemen Sekolah (`tu_manajemen_sekolah_screen.dart`)
```dart
AniseSearchBar(
  controller: _searchController,
  hintText: 'Cari nama ${_currentCategory.label.toLowerCase()}...',
  onChanged: (val) {
    setState(() {
      _searchQuery = val;
    });
  },
)
```

---

## 🚫 5. Larangan & Pedoman Anti-Pattern
1. **Dilarang Menulis Ulang `Container` Search Bar:** Selalu gunakan `AniseSearchBar` alih-alih membuat `TextField` kustom dengan `BoxDecoration` manual.
2. **Dilarang Menggunakan Warna Ad-Hoc:** Jangan pernah memberikan `Colors.grey` atau warna manual; `AniseSearchBar` telah mengunci penggunaan token `AppColors.surface`, `AppColors.outline`, dan `AppColors.onSurface`.
3. **Penyelarasan State Kosong:** Pastikan saat teks dihapus melalui tombol *clear*, daftar tampilan data langsung menyegarkan data ke daftar utuh (*all items*).
