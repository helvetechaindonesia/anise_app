# 🧩 Shared Component Kit (Anise App)
**Dokumentasi Komponen Baku Antarmuka (Lego Blocks)**  
*Lokasi: `frontend/lib/core/widgets/`*

---

## 1. 📱 `AniseAppBar`
App bar standar untuk semua Sub-Page di aplikasi Anise.
- **Lokasi File:** `lib/core/widgets/anise_app_bar.dart`
- **Fitur:**
  - Tombol back konsisten (`PhosphorIcons.caretLeft bold`).
  - Judul di tengah (*Center title*) dengan `AppTextStyles.titleMedium`.
  - Mendukung `actions` (icon kanan) dan `bottom` (TabBar / filter row).
- **Contoh Pemakaian:**
  ```dart
  Scaffold(
    appBar: AniseAppBar(
      title: 'Jadwal Mengajar',
      onBackPressed: () => Navigator.pop(context),
    ),
    body: ...
  )
  ```

---

## 2. 🔘 `AniseButton`
Tombol interaktif dengan 4 varian semantik & otomatis mengelola loading spinner.
- **Lokasi File:** `lib/core/widgets/anise_button.dart`
- **Varian:**
  - `AniseButtonVariant.primary` ➔ Latar Deep Teal (`AppColors.primary`), teks putih.
  - `AniseButtonVariant.secondary` ➔ Latar Mint/Teal (`AppColors.secondary`), teks hitam.
  - `AniseButtonVariant.danger` ➔ Latar Merah (`AppColors.error`), teks putih (hapus/batal/izin).
  - `AniseButtonVariant.outline` ➔ Border garis Deep Teal, latar transparan.
- **Fitur:**
  - `isLoading: true` ➔ Mengganti teks dengan spinner proporsional tanpa merusak dimensi tombol.
  - Mendukung icon di sebelah kiri teks.
- **Contoh Pemakaian:**
  ```dart
  AniseButton(
    text: 'Simpan Data',
    variant: AniseButtonVariant.primary,
    isLoading: isSubmitting,
    onPressed: () => submitData(),
  )
  ```

---

## 3. 🃏 `AniseCard`
Kontainer kartu standar untuk membalut informasi item, card menu, dan seksi konten.
- **Lokasi File:** `lib/core/widgets/anise_card.dart`
- **Fitur:**
  - Border radius fluid seragam (20px).
  - Bayangan halus (`BoxShadow`) tanpa efek kaku.
  - Border outline tipis yang elegan.
  - Dilengkapi efek sentuh Ripple (`InkWell`) saat `onTap` diberikan.
- **Contoh Pemakaian:**
  ```dart
  AniseCard(
    onTap: () => openDetail(),
    child: Column(
      children: [
        Text('Tugas Matematika', style: AppTextStyles.titleMedium(context)),
        Spacing.item(context),
        Text('Tenggat: Besok 23:59', style: AppTextStyles.bodySmall(context)),
      ],
    ),
  )
  ```

---

## 4. 📭 `AniseStateFeedback`
Komponen penanganan state kosong (*Empty State*) & error (*Error State*) dengan tombol aksi.
- **Lokasi File:** `lib/core/widgets/anise_state_feedback.dart`
- **Fitur:**
  - Lingkaran ikon pastel besar di tengah.
  - Judul tegas & deskripsi pembantu.
  - Tombol aksi opsional (misal: "Muat Ulang" atau "Buat Baru").
- **Contoh Pemakaian:**
  ```dart
  // Untuk data kosong
  AniseStateFeedback(
    title: 'Belum Ada Tugas',
    subtitle: 'Semua tugas sekolah Anda telah selesai dikerjakan.',
    icon: PhosphorIcons.checks(PhosphorIconsStyle.fill),
  )

  // Untuk error gagal koneksi
  AniseStateFeedback(
    title: 'Gagal Memuat Data',
    subtitle: error.toString(),
    isError: true,
    actionButtonText: 'Coba Lagi',
    onActionPressed: () => ref.refresh(provider),
  )
  ```

---

## 5. ✍️ `AniseTextField`
Input teks terstandar dengan label, prefix/suffix icon, dan validasi.
- **Lokasi File:** `lib/core/widgets/anise_text_field.dart`
