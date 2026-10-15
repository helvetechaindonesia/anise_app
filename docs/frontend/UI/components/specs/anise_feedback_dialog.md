# 📢 Spesifikasi Komponen: `AniseFeedbackDialog`
**Kategori:** Modal & Dialog Umpan Balik (Feedback & Overlay Modals)  
**Target:** Seluruh Respon Sistem (Berhasil, Gagal, Berkas Ditolak/Peringatan, Konfirmasi Aksi, Pemutusan Sesi)  
**File Kode:** `lib/core/widgets/anise_feedback_dialog.dart`  
*Terakhir Diperbarui: 15 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`AniseFeedbackDialog` adalah komponen modal dialog terstandarisasi untuk menggantikan penggunaan `SnackBar` liar dan `AlertDialog` manual di seluruh aplikasi Anise.

Komponen ini dirancang dengan estetika modern, ramah pengguna, dan berhirarki visual jelas:
1. **Pemusatan Informasi:** Setiap feedback disampaikan lewat kartu modal mengambang dengan elevasi elegan dan sudut membulat (`borderRadius: 20.w(context)`).
2. **Indikator Visual Tematik:** Badge lingkaran ikon di bagian atas yang berubah warna dan ikon sesuai jenis respon:
   - **Sukses (Success):** Hijau `AppColors.success` (`checkCircle`).
   - **Gagal / Error:** Merah `AppColors.error` (`xCircle`).
   - **Peringatan / Ditolak (Warning):** Kuning/Oranye `AppColors.warning` (`warningCircle`).
   - **Konfirmasi (Confirm):** Biru `AppColors.primary` (`question`) atau Merah `AppColors.error` (`trash` untuk aksi destruktif).
3. **Smart Action Button (Tombol Notifikasi Otomatis):** Jika pesan penolakan mengandung kata *"notifikasi"*, dialog secara cerdas menyediakan tombol sekunder **"Buka Notif"** yang langsung membuka layar `NotificationScreen`.
4. **Proteksi Sesi Mutlak (`showSessionExpired`):** Untuk skenario akun dibekukan (*freeze*), kredensial diedit, atau akun dihapus, modal menggunakan `PopScope(canPop: false)` dan `barrierDismissible: false` dengan satu tombol aksi tunggal (`[Log Out]` atau `[Login]`). Pengguna tidak dapat menutup modal lewat gestur *back* maupun klik latar.

---

## 📐 2. Anatomi & Struktur Visual

### A. Tipe Standar (Satu / Dua Tombol)
```text
┌──────────────────────────────────────────────────────────────┐
│                      [ (✓) / (X) / (!) ]                     │
│                Badge Lingkaran Ikon (56x56)                  │
│                                                              │
│                      Judul Feedback                          │
│               (titleMedium, w700 Bold pekat)                 │
│                                                              │
│                   Deskripsi Pesan Lengkap                    │
│            (bodyMedium, onSurface 85% opacity)               │
│                                                              │
│  ┌─────────────────────────────┬──────────────────────────┐  │
│  │   [Tombol Batal / Tutup]    │ [Tombol Utama / Aksi]    │  │
│  │   (OutlinedButton)          │ (ElevatedButton)         │  │
│  └─────────────────────────────┴──────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### B. Tipe Pemutusan Sesi (`showSessionExpired`)
```text
┌──────────────────────────────────────────────────────────────┐
│                           [ (X) ]                            │
│                 Badge Lingkaran Merah Error                  │
│                                                              │
│                   Akun Dibekukan / Dihapus                   │
│                                                              │
│          Deskripsi alasan pemutusan sesi oleh Admin          │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │           [ Log Out ]  /  [ Login ] (Wajib)            │  │
│  │     (Satu Tombol Tunggal - Tidak Dapat Diabaikan)      │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## ⚙️ 3. Parameter Properti & Method Statis

### A. Method Statis Pembantu (Helper Methods)

| Method | Kegunaan | Ciri Khusus |
| :--- | :--- | :--- |
| `showSuccess(context, ...)` | Menampilkan dialog berhasil operasi. | Warna hijau `AppColors.success`, tombol tunggal "Tutup" (atau kustom). |
| `showError(context, ...)` | Menampilkan dialog error/kesalahan sistem. | Warna merah `AppColors.error`, deteksi otomatis tombol "Buka Notif". |
| `showWarning(context, ...)` | Menampilkan dialog berkas ditolak / validasi. | Warna oranye `AppColors.warning`, aksi ganda (Tutup + Buka Notif). |
| `showConfirm(context, ...)` | Konfirmasi tindakan penting (misal hapus/freeze).| Mengembalikan `Future<bool?>` (`true` jika konfirmasi disetujui). |
| `showSessionExpired(context, ...)` | Pemutusan sesi user aktif secara paksa. | `PopScope(canPop: false)`, `barrierDismissible: false`, 1 tombol aksi. |

### B. Parameter Props Widget

| Parameter | Tipe Data | Default | Keterangan |
| :--- | :--- | :---: | :--- |
| `type` | `AniseFeedbackType` | Wajib | `success`, `error`, `warning`, `confirm`. |
| `title` | `String` | Wajib | Judul besar dialog. |
| `message` | `String` | Wajib | Isi pesan penjelasan rinci. |
| `confirmText` | `String` | `'Tutup'` | Teks tombol utama kanan. |
| `cancelText` | `String?` | `null` | Teks tombol batal kiri (jika ada). |
| `onConfirm` | `VoidCallback?` | `null` | Callback eksekusi tombol utama. |
| `onCancel` | `VoidCallback?` | `null` | Callback eksekusi tombol batal. |
| `customActionText` | `String?` | `null` | Label kustom tombol aksi (misal: "Buka Notif"). |
| `onCustomAction` | `VoidCallback?` | `null` | Callback tombol aksi kustom. |
| `isDestructive` | `bool` | `false` | Jika `true`, tombol konfirmasi berwarna merah `AppColors.error`. |

---

## 💻 4. Blueprint Contoh Pemakaian

### Contoh 1: Notifikasi Berkas Ditolak (Excel Parser)
```dart
AniseFeedbackDialog.showWarning(
  context,
  title: 'Berkas Ditolak',
  message: 'Berkas Excel tidak valid. Silakan cek detail kesalahan di halaman notifikasi.',
  // Jika pesan mengandung kata 'notifikasi', tombol "Buka Notif" otomatis muncul
);
```

### Contoh 2: Konfirmasi Hapus Data Master (Kelas / User)
```dart
final bool? confirmed = await AniseFeedbackDialog.showConfirm(
  context,
  title: 'Hapus Pengguna?',
  message: 'Apakah Anda yakin ingin menghapus user "Andi Wijaya"? Data yang dihapus tidak dapat dipulihkan.',
  confirmText: 'Ya, Hapus',
  cancelText: 'Batal',
  isDestructive: true,
);

if (confirmed == true) {
  // Jalankan API delete
}
```

### Contoh 3: Pemutusan Sesi Akun Dibekukan (Freeze)
```dart
AniseFeedbackDialog.showSessionExpired(
  context,
  title: 'Akun Dibekukan',
  message: 'Akun Anda sedang dibekukan (freeze) oleh Administrator. Silakan hubungi Tata Usaha.',
  buttonText: 'Log Out',
  onAction: () async {
    await SharedPrefs.clearToken();
    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  },
);
```
