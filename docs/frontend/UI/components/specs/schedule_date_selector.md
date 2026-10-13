# 🗓️ Spesifikasi Komponen: `DateSelector` (Filter Tanggal Jadwal)
**Kategori:** Navigasi & Filter Waktu (Date Picker, Carousel Selector, & Active Filter Banner)  
**Target:** Layar Jadwal Siswa (`JadwalScreen`)  
**File Kode:** `lib/features/jadwal/screens/jadwal_screen.dart` (`_buildDateSelector`)  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
Komponen navigasi tanggal yang menyediakan dua mode akses:
1. **Carousel 14 Hari (Quick Navigation):** Menampilkan 3 hari sebelumnya, hari ini, dan 10 hari ke depan untuk akses harian instan.
2. **Pilih Tanggal Bebas (Date Picker):** Mengakses agenda lampau atau masa depan di luar jangkauan 14 hari dengan dialog kalender standar.

---

## 📐 2. Anatomi Item Tanggal (Carousel Item)
```text
┌─────────────────┐  ▲
│      SEN        │  │ 74px (.h)
│       13        │  │ Lebar: 56px (.w)
│  ─────────────  │  │ (Garis bawah khusus Hari Ini)
└─────────────────┘  ▼
```

### Aturan Visual Item:
1. **Item Biasa (Tidak Aktif):**
   - Latar: `AppColors.surface`.
   - Border: `1px`, `AppColors.outlineVariant`.
   - Teks: Nama hari `onSurfaceVariant`, angka tanggal `onSurface` (`w600`).
2. **Item Terpilih (Active State):**
   - Latar: `AppColors.primaryContainer`.
   - Border: `1.5px`, `AppColors.primary`.
   - Glow Shadow: `BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 8, offset: Offset(0, 3))`.
   - Teks: `onPrimaryContainer` (`FontWeight.w800`).
   - **Catatan Standarisasi:** *Tidak menggunakan titik bulat di bawahnya (clean minimalis).*
3. **Penanda Hari Ini (Today Indicator):**
   - Garis horizontal aksen bawah (`width: 20.w`, `height: 3.h`, `BorderRadius: 2.w`) berwarna `AppColors.secondary` (atau `onPrimaryContainer` jika sedang dipilih).

---

## 🏷️ 3. Banner Filter Tanggal Aktif (Custom Date State)
Ketika tanggal dipilih melalui tombol kalender "Pilih Tanggal":
- Item carousel berganti menjadi banner bar dengan:
  - Ikon kalender sukses (`calendarCheck`) warna secondary.
  - Teks: `"FILTER TANGGAL AKTIF"` + Tanggal terformat (Contoh: `"Senin, 13 Oktober 2026"`).
  - Tombol **`Reset`** di kanan untuk mengembalikan ke tanggal hari ini secara instan.
