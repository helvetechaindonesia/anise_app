# 📑 Spesifikasi Komponen: `ScheduleCard` & `ScheduleCardComponents`
**Kategori:** Kartu Interaksi & Feed Pembelajaran (Feed, Engagement, & Academic Journal)  
**Target:** Layar Jadwal & Catatan Kelas Siswa (`JadwalScreen`)  
**File Kode:**
- `lib/features/jadwal/widgets/schedule_card.dart`
- `lib/features/jadwal/widgets/schedule_card_components.dart`  
*Terakhir Diperbarui: 13 Oktober 2026*

---

## 🎯 1. Deskripsi & Tujuan
`ScheduleCard` adalah kartu vertikal terstandarisasi untuk agenda akademik, jurnal pembelajaran harian, dan interaksi kelas (media sosial bergaya edukasi). Komponen ini menampilkan informasi guru pengajar, jam pembelajaran, catatan materi, lampiran tugas, penilaian bintang interaktif (reviews), serta 4 tombol aksi terintegrasi (Komentar, Bagikan Instagram-Card, Suka/Like, dan Simpan/Bookmark).

---

## 📐 2. Anatomi & Visual Layout
```text
┌────────────────────────────────────────────────────────┐
│ [Avatar 44px]  Nama Guru Pengajar            [STATUS]  │ ◄── Header Bar
│                Waktu Terbit (Muted)         (Live/End) │
├────────────────────────────────────────────────────────┤
│ 📖 Mata Pelajaran (Bold Title)                          │
│ ⏰ 07:30 - 09:00                                       │
│                                                        │
│ Catatan materi pembelajaran yang disampaikan guru...   │
│                                                        │
│ [📁 Lampiran_Tugas.pdf                [Unduh]]         │ (Jika ada task/file)
│                                                        │
│ ⭐ ⭐ ⭐ ⭐ ⭐ (Rating Pembelajaran Siswa)             │ (Khusus status selesai)
├────────────────────────────────────────────────────────┤
│ 💬 12       📤 Bagikan        ❤️ 45         🔖 Simpan   │ ◄── Footer Action Bar
└────────────────────────────────────────────────────────┘
```

---

## 🎨 3. Spesifikasi Visual & Design Tokens
1. **Container Luar (Wadah Kartu):**
   - **Border Radius:** `16.w(context)`.
   - **Latar Belakang:** `AppColors.surface`.
   - **Border:**
     - Status Normal: `1px`, `AppColors.outlineVariant`.
     - Status Live: `1.5px`, `AppColors.secondary`.
   - **Shadow:**
     - Normal: `BoxShadow(color: onBackground.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 4))`.
     - Live: `BoxShadow(color: secondary.withValues(alpha: 0.12), blurRadius: 10, offset: Offset(0, 4))`.
   - **Padding:** Horizontal `16.w(context)`, Vertikal `16.h(context)`.

2. **Header Bar:**
   - **Avatar Guru:** Lingkaran `44.w(context)` dengan latar `AppColors.primaryContainer` dan ikon/gambar profil.
   - **Nama Guru:** `AppTextStyles.titleMedium(context)`, `FontWeight.w700`, teks terpotong rapi dengan `TextOverflow.ellipsis`.
   - **Waktu Unggah:** `AppTextStyles.labelSmall(context)`, warna `onSurface(alpha: 0.5)`.
   - **Chip Status (Pojok Kanan Atas):**
     - **Live:** Warna latar `AppColors.error(alpha: 0.1)`, border merah `AppColors.error`, dot merah + teks `"Live"` dengan animasi kedip halus (*pulse blinking*).
     - **Akan Datang:** Warna latar `AppColors.surfaceVariant`, teks `"Akan Datang"`.
     - **Selesai:** Warna latar `AppColors.surfaceVariant(alpha: 0.6)`, teks `"Selesai"`.

3. **Kotak Lampiran File (`FileAttachmentWidget`):**
   - **Latar:** `AppColors.backgroundLight`.
   - **Sudut:** `12.w(context)`.
   - **Ikon Kiri:** Icon PDF merah squircle.
   - **Aksi Kanan:** Icon unduh sirkular.

4. **Footer Action Bar (Interaksi):**
   - **Tata Letak:** `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)`.
   - **1. Komentar:** Icon Phosphor `chatTeardrop` + badge hitungan komentar.
   - **2. Bagikan:** Icon Phosphor `shareNetwork` + label `"Bagikan"`. Membuka `ScheduleShareModal`.
   - **3. Suka (Like):** Icon Phosphor `heart` (terisi merah saat disukai) + hitungan realtime.
   - **4. Simpan (Bookmark):** Icon Phosphor `bookmarkSimple` (terisi warna secondary saat tersimpan).

---

## ⚙️ 4. Parameter Properti (`ScheduleCard`)
| Properti | Tipe | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `journalId` | `String?` | Opsional | ID unik jurnal untuk membedakan materi terbit dengan template jadwal mingguan (`sched_*`). |
| `status` | `ScheduleStatus` | Ya | `live`, `upcoming`, atau `selesai`. |
| `timeRange` | `String` | Ya | Rentang waktu KBM (contoh: `"07:30 - 09:00"`). |
| `uploadTime` | `String` | Ya | Waktu rilis (contoh: `"10 Menit yang lalu"` atau `"Jadwal Rutin"`). |
| `subjectName` | `String` | Ya | Nama mata pelajaran. |
| `teacherName` | `String` | Ya | Nama lengkap guru pengampu. |
| `teacherImage` | `String?` | Opsional | URL foto profil guru. |
| `teacherRole` | `String` | Ya | Peran guru (default: `"Guru Pengajar"`). |
| `description` | `String` | Ya | Catatan materi atau instruksi pembelajaran. |
| `hasFileAttachment`| `bool` | Opsional | `true` jika memiliki lampiran file. |
| `fileName` | `String?` | Opsional | Nama dokumen file lampiran. |
| `likes` | `int` | Ya | Jumlah total suka saat ini. |
| `isLiked` | `bool` | Opsional | Status like oleh user login. |
| `isSaved` | `bool` | Opsional | Status simpan bookmark oleh user login. |
| `comments` | `int` | Ya | Jumlah komentar. |
| `initialRating` | `int` | Opsional | Rata-rata bintang (1-5). |
| `hasRated` | `bool` | Opsional | Penanda apakah user sudah memberikan bintang. |
| `onRatingChanged` | `ValueChanged<int>?`| Opsional | Callback saat siswa mengirim rating bintang. |
| `onLikeToggled` | `VoidCallback?` | Opsional | Callback toggle like. |
| `onSaveToggled` | `VoidCallback?` | Opsional | Callback toggle simpan koleksi. |
| `onFetchComments` | `Function?` | Opsional | Future loader daftar komentar. |
| `onCommentSubmitted`| `Function?` | Opsional | Future submit komentar baru. |
| `onDeleteComment` | `Function?` | Opsional | Future hapus komentar. |

---

## 💬 5. Standarisasi Modal Komentar (Bottom Sheet)
1. **Identitas Pengguna:**
   - Komentar milik user sendiri otomatis berlabel **`Saya`** dilengkapi badge pill **`Anda`** (`AppColors.primaryContainer`).
   - Komentar siswa lain menampilkan nama lengkap asli (`full_name`) sesuai database.
2. **Moderasi:**
   - Ikon tempat sampah (*delete*) hanya tampil pada komentar milik siswa itu sendiri atau guru pemilik mata pelajaran.
3. **Validasi:**
   - Siswa dibatasi maksimal 1 komentar per sesi materi pembelajaran untuk menjaga ketertiban diskusi.
