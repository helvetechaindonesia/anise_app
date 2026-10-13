# 🎨 Spesifikasi Komponen: `ScheduleShareModal`
**Kategori:** Dialog & Modul Bagikan Media (Modal, Native Share & Image Generation)  
**Target:** Share Sheet Berbagi Jadwal/Catatan Pembelajaran  
**File Kode:** `lib/features/jadwal/widgets/schedule_share_modal.dart`  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`ScheduleShareModal` adalah modul *share sheet* interaktif yang mengubah ringkasan agenda pembelajaran menjadi **kartu grafis Instagram-Story Style** berkualitas tinggi (`PNG 3x pixel ratio`) atau **teks terformat rapi**, siap dibagikan ke WhatsApp, Instagram, Telegram, dan aplikasi sosial lainnya.

---

## 📐 2. Visual Card Preview (Instagram Card Style)
```text
┌─────────────────────────────────────────────────────────┐
│ 🏫 [Logo SMK]   SIPENA                      [ 07:30 - 09:00 ] │
│                 Senin, 13 Okt 2026                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Matematika Wajib                                        │
│ 👨‍🏫 Budi Pratama, S.Pd.                                  │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 📓 Ringkasan Materi                                 │ │
│ │ Matriks Ordo 3x3 dan Penerapan Determinan...        │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ #JadwalBelajar #Sipena                       sipena.app │
└─────────────────────────────────────────────────────────┘
┌───────────────────────────┐ ┌───────────────────────────┐
│   📸 Bagikan Gambar        │ │   💬 Bagikan Teks         │
└───────────────────────────┘ └───────────────────────────┘
```

---

## 🎨 3. Spesifikasi Desain Kartu (Graphic Tokens)
1. **Gradien Latar Belakang Kartu:**
   - Dark Navy Gradient: Linear Gradient dari `#0F172A` (Slate Navy Pekat) ke `#1E293B`.
   - **Border Radius:** `20.w(context)`.
   - **Border:** `1px`, `Colors.white(alpha: 0.12)`.
   - **Box Shadow:** `BoxShadow(color: Colors.black(alpha: 0.25), blurRadius: 16, offset: Offset(0, 8))`.

2. **Logo & Branding Header:**
   - **Logo Sekolah:** Logo resmi SMK pekat (`assets/images/logo-smk.png`) dalam lingkaran putih `34.w(context)` dengan bayangan lembut.
   - **Nama Aplikasi:** Teks **`SIPENA`** dengan `FontWeight.w900`, `letterSpacing: 1.4`.
   - **Tanggal:** Menampilkan tanggal KBM dengan font putih semi-transparan `alpha: 0.6`.
   - **Chip Jam:** Pill badge kanan atas berlatar `AppColors.secondary(alpha: 0.2)` dan border `1px`.

3. **Watermark Bawah:**
   - Kiri: `#JadwalBelajar #Sipena` (`alpha: 0.45`).
   - Kanan: `sipena.app` (`AppColors.secondary`).

---

## 🔘 4. Standarisasi Tombol Aksi (Action Buttons)
Kedua tombol diletakkan berdampingan secara simetris **(Proporsi Seimbang 1:1)** menggunakan `Expanded`:
1. **Tombol "Bagikan Gambar" (`ElevatedButton`):**
   - **Latar:** `AppColors.primary` (Hijau Utama).
   - **Teks & Ikon:** Putih, ikon Phosphor `image`.
   - **Fungsi:** Mengambil screenshot widget kartu via `RenderRepaintBoundary.toImage(pixelRatio: 3.0)`, menyimpan ke file sementara, lalu memicu native OS share dialog dengan lampiran gambar PNG + caption ringkas.
2. **Tombol "Bagikan Teks" (`OutlinedButton`):**
   - **Border:** `BorderSide(color: AppColors.outlineVariant, width: 1.2)`.
   - **Teks & Ikon:** `AppColors.onSurface`, ikon Phosphor `chatTeardropText`.
   - **Fungsi:** Menyusun ringkasan teks terstruktur dengan batas maksimal karakter (agar tidak terpotong atau error saat di-share ke aplikasi chat).

---

## ⚙️ 5. Cara Pemanggilan
```dart
ScheduleShareModal.show(
  context: context,
  subjectName: 'Matematika Wajib',
  teacherName: 'Budi Pratama, S.Pd.',
  timeRange: '07:30 - 09:00',
  description: 'Catatan materi matriks determinan.',
  dateText: 'Senin, 13 Oktober 2026',
);
```
