# ↔️ Spesifikasi Komponen: `AniseSlidableTile`
**Kategori:** Aksi Baris Interaktif Geser (Interactive Slidable Action Pane)  
**Target:** Item Baris Daftar CRUD (Manajemen User, Manajemen Sekolah, dsb.)  
**File Kode:** `lib/core/widgets/anise_slidable_tile.dart`  
*Terakhir Diperbarui: 15 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`AniseSlidableTile` adalah komponen pembungkus (*wrapper widget*) terstandarisasi untuk memberikan kemampuan geser (*swipe action*) pada baris data daftar aplikasi Anise. Komponen ini membungkus pustaka `flutter_slidable` dengan desain token yang telah dikunci rapi, menggantikan puluhan baris kode `Slidable` manual yang berulang di layar seperti `tu_master_user_screen.dart` dan `tu_manajemen_sekolah_screen.dart`.

Fitur & Keunggulan Utama:
- **Kalkulasi Lebar Rasio Otomatis (`extentRatio`):** Secara pintar menyesuaikan proporsi geseran berdasarkan jumlah tombol aksi yang aktif (3 aksi = `0.65`, 2 aksi = `0.45`, 1 aksi = `0.25`).
- **Gaya Visual & Ikon Terstandarisasi:** Menggunakan ikon baku *Phosphor Icons Fill*, tipografi label seragam, dan palet warna status terverifikasi (`AppColors.warning` untuk Edit, `AppColors.menuPastelBlue` untuk Freeze/Status Akun, dan `AppColors.error` untuk Hapus).
- **Radius Sudut Adaptif:** Mengaplikasikan lengkungan sudut `12.w(context)` secara dinamis pada tepi tombol pertama dan terakhir agar selaras dengan lekukan `ItemListTile`.
- **Dukungan State Akun Beku (*Frozen State*):** Mendukung pergantian label dan ikon cerdas antara *"Freeze"* dan *"Aktifkan"* sesuai status `isFrozen`.

---

## 📐 2. Anatomi & Struktur Visual
```text
┌──────────────────────────────────────────────┬─────────┬─────────┬─────────┐
│ [👤]  Ahmad Zaky                   [Aktif]   │ [✏️]    │ [❄️]    │ [🗑️]    │
│       ahmad@dev.com                          │  Edit   │ Freeze  │  Hapus  │
│       Siswa - Kelas X-A                      │ Warning │ Pastel  │  Error  │
│                                              │         │  Blue   │         │
└──────────────────────────────────────────────┴─────────┴─────────┴─────────┘
◄──── Baris Item Utama (child: ItemListTile) ──►◄─── Aksi Tersembunyi ─────►
                                                (Muncul saat digeser ke kiri)
```

1. **Wadah Utama (Child Widget):**
   - Komponen anak yang dibungkus, umumnya berupa `ItemListTile`.
   - Jika semua callback aksi bernilai `null`, komponen akan mengembalikan `child` murni tanpa *overhead* gesture.
2. **Aksi Edit (Pencil Simple Fill):**
   - Latar: `AppColors.warning` (Kuning Amber).
   - Ikon: `PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill)` warna putih.
   - Label Bawaan: *"Edit"*.
   - Radius: Sisi kiri melengkung `12.w(context)` jika menjadi tombol terluar kiri.
3. **Aksi Freeze / Status Akun (Snowflake Fill):**
   - Latar: `AppColors.menuPastelBlue` (Biru Dingin Pastel).
   - Ikon: `PhosphorIcons.snowflake(PhosphorIconsStyle.fill)` warna putih.
   - Label Bawaan: Bersifat dinamis; menampilkan *"Aktifkan"* jika `isFrozen == true`, dan *"Freeze"* jika `isFrozen == false`.
4. **Aksi Hapus (Trash Fill):**
   - Latar: `AppColors.error` (Merah Bahaya).
   - Ikon: `PhosphorIcons.trash(PhosphorIconsStyle.fill)` warna putih.
   - Label Bawaan: *"Hapus"*.
   - Radius: Sisi kanan melengkung `12.w(context)`.

---

## ⚙️ 3. Parameter Properti (Props)

| Parameter | Tipe Data | Wajib? | Nilai Bawaan | Keterangan |
| :--- | :--- | :---: | :---: | :--- |
| `child` | `Widget` | **Ya** | - | Widget item data utama yang dibungkus (biasanya `ItemListTile`). |
| `onEdit` | `VoidCallback?` | Opsional | `null` | Aksi saat tombol Edit ditekan. Jika `null`, tombol Edit tidak muncul. |
| `onFreeze` | `VoidCallback?` | Opsional | `null` | Aksi saat tombol Freeze ditekan (khusus manajemen akun pengguna). |
| `onDelete` | `VoidCallback?` | Opsional | `null` | Aksi saat tombol Hapus ditekan. Jika `null`, tombol Hapus tidak muncul. |
| `isFrozen` | `bool` | Opsional | `false` | Status kebekuan akun untuk menentukan label tombol Freeze. |
| `editLabel` | `String` | Opsional | `'Edit'` | Kustomisasi teks label tombol edit. |
| `deleteLabel` | `String` | Opsional | `'Hapus'` | Kustomisasi teks label tombol hapus. |
| `freezeLabel` | `String?` | Opsional | `null` | Kustomisasi eksplisit label tombol freeze. |

---

## 💻 4. Blueprint Contoh Pemakaian

### Contoh 1: Penerapan Penuh (3 Aksi) pada Manajemen Pengguna (`tu_master_user_screen.dart`)
```dart
AniseSlidableTile(
  isFrozen: user.isFrozen,
  onEdit: () => _openEditUserModal(user),
  onFreeze: () => _toggleFreezeUser(user),
  onDelete: () => _confirmDeleteUser(user),
  child: ItemListTile(
    avatarIcon: _getRoleIcon(user.role),
    title: user.name,
    subtitle: user.email,
    detailInfo: '${user.role.toUpperCase()} • ${user.className ?? "-"}',
    customStatusBadge: _buildStatusBadge(user.isFrozen),
  ),
)
```

### Contoh 2: Penerapan 2 Aksi (Edit & Hapus) pada Manajemen Sekolah (`tu_manajemen_sekolah_screen.dart`)
```dart
AniseSlidableTile(
  onEdit: () => _openFormModal(item: item),
  onDelete: () => _confirmDeleteItem(item),
  child: ItemListTile(
    avatarIcon: _currentCategory.icon,
    title: item.name,
    subtitle: item.code,
    detailInfo: item.description,
  ),
)
```

---

## 🚫 5. Larangan & Pedoman Anti-Pattern
1. **Dilarang Menulis Blok `ActionPane` dan `SlidableAction` Manual:** Gunakan selalu `AniseSlidableTile` agar warna tombol, ikon Phosphor, dan rasio geser tetap selaras di semua modul aplikasi.
2. **Dilarang Menghardcode Lebar Rasio (`extentRatio`):** Perhitungan rasio telah dihitung secara presisi di dalam komponen agar tombol tidak terpotong atau terlalu renggang.
3. **Wajib Memasang Konfirmasi Dialog pada `onDelete`:** Aksi hapus yang dipicu dari swipe WAJIB menampilkan dialog konfirmasi `AniseFeedbackDialog` sebelum data dieksekusi ke backend.
