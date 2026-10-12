# 💊 Spesifikasi Komponen: `PillButton`
**Kategori:** Sistem Tombol (Button Family)  
**Target:** Aksi Formulir, Login, Submit, Daftarkan Wajah, Logout  
**File Kode:** `lib/core/widgets/pill_button.dart` (atau `anise_button.dart`)

---

## 🎯 1. Deskripsi & Tujuan
`PillButton` adalah tombol aksi utama (*Primary Action Button*) yang berbentuk kapsul memanjang (*Pill Shape*). Tombol ini digunakan untuk keputusan penting pengguna: Simpan data, Kirim formulir, Masuk ke sistem, atau Konfirmasi persetujuan.

---

## 📐 2. Anatomi & Pengukuran Dimensi (Sizing & Ratio)
```text
┌──────────────────────────────────────────────────────────────┐  ▲
│                  [★]   KIRIM LAPORAN                         │  │ Tinggi: 52px (fluid)
│            (Ikon Opsional)   (Teks Bold Tengah)              │  │ Radius: 26px (50% Full Pill)
└──────────────────────────────────────────────────────────────┘  ▼
```

1. **Dimensi Baku:**
   - **Tinggi:** `52.h(context)` (ergonomis untuk sentuhan jempol / *Touch Target Standard 48-52px*).
   - **Lebar:** `double.infinity` (memenuhi wadah) atau lebar kustom proporsional.
   - **Tingkat Kelengkungan (Border Radius):** **`26.w(context)`** (atau 50% dari tinggi tombol, menghasilkan bentuk kapsul utuh/pill murni). Alternatif: `16.w` untuk rounded modern.
2. **Hierarki Varian:**
   - **Primary:** Latar blok `AppColors.primary`, teks `AppColors.onPrimary` (Putih).
   - **Secondary:** Latar blok `AppColors.secondary` (Mint), teks `AppColors.onSecondary` (Hitam).
   - **Danger:** Latar blok `AppColors.error` (Merah), teks putih (Logout, Batalkan, Hapus).
   - **Outline:** Latar transparan, garis tepi `BorderSide(color: AppColors.primary, width: 1.5)`.
3. **State Loading Terintegrasi:**
   - Ketika `isLoading: true`, teks otomatis disembunyikan dan digantikan oleh `CircularProgressIndicator` putih berukuran `20.w` tanpa merubah ukuran tombol.

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Default | Keterangan |
| :--- | :--- | :---: | :--- |
| `text` | `String` | Wajib | Label teks pada tombol ("Simpan", "Login"). |
| `onPressed` | `VoidCallback?` | Wajib | Handler aksi (jika null, tombol disabled). |
| `variant` | `PillButtonVariant` | `primary` | Pilihan gaya: `primary`, `secondary`, `danger`, `outline`. |
| `isLoading` | `bool` | `false` | Kondisi sedang memproses request server. |
| `icon` | `IconData?` | `null` | Ikon pelengkap di sebelah kiri teks. |
| `width` | `double?` | `null` | Lebar kustom (default: `double.infinity`). |
