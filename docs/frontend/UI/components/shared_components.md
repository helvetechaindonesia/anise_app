# 🧩 Blueprint Komponen Bersama (Shared Components Blueprint)
**Katalog Komponen Baku Antarmuka Aplikasi Anise**  
*Terakhir Diperbarui: 12 Oktober 2026*

Dokumen ini adalah **peta induk (blueprint)** seluruh komponen antarmuka Anise. Setiap komponen memiliki dokumentasi spesifikasi teknis mendalam yang terpisah di folder `specs/`.

---

## 🏛️ 1. Header & Navigation (Kepala & Jalur Akses)

| Komponen | Peran & Letak | Tautan Dokumen Detail |
| :--- | :--- | :--- |
| **`MainHeader`** | Header utama pada Tab Dashboard: Logo + Nama Sekolah + Keterangan + Notifikasi. | [specs/main_header.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/main_header.md) |
| **`SubHeader`** | Header sub-halaman: Ikon Back/Close di pojok kiri + Judul rata tengah + Aksi kanan. | [specs/sub_header.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/sub_header.md) |
| **`MenuTab`** | Bottom Navigation Bar: Tab navigasi bawah (+ Tombol Presensi Cam khusus non-siswa). | [specs/menu_tab.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/menu_tab.md) |

---

## 🔘 2. Sistem Tombol (Button Family)

| Komponen | Bentuk & Karakter Visual | Tautan Dokumen Detail |
| :--- | :--- | :--- |
| **`MenuIconButton`** | Rounded Rectangle `56x56` (radius 20px / ~35%), warna blok primary + label teks. | [specs/menu_icon_button.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/menu_icon_button.md) |
| **`PillButton`** | Tombol kapsul (tinggi 52px, radius 16-26px) untuk aksi Save, Kirim, Login, Wajah. | [specs/pill_button.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/pill_button.md) |
| **`CardButton`** | Kartu interaktif yang dapat diklik (radius 24px), warna blok primary + ripple effect. | [specs/card_button.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/card_button.md) |
| **`CustomExpandableFab`** | Tombol aksi mengambang expandable speed-dial untuk Unggah Excel & Tambah Data Manual. | [specs/custom_expandable_fab.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/custom_expandable_fab.md) |

---

## 🃏 3. Kartu & Tampilan Data (Cards & Data Display)

| Komponen | Peran & Letak | Tautan Dokumen Detail |
| :--- | :--- | :--- |
| **`CardInfo`** | Kartu ringkasan statistik & metrik performa (Hadir, Poin, Rekap). | [specs/card_info.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/card_info.md) |
| **`ItemListTile`** | Baris kartu daftar data vertikal baku (Tugas, Manajemen User, Manajemen Sekolah, Presensi). | [specs/item_list_tile.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/item_list_tile.md) |
| **`AniseEmptyState`** | Tampilan status baku saat data kosong (*Zero-Data State*) atau hasil pencarian nihil. | [specs/anise_empty_state.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/anise_empty_state.md) |

---

## 📢 4. Modal & Dialog Umpan Balik (Modals & Feedback)

| Komponen | Peran & Letak | Tautan Dokumen Detail |
| :--- | :--- | :--- |
| **`AniseFeedbackDialog`** | Standarisasi dialog pop-up respon sistem: Sukses, Error, Berkas Ditolak, Konfirmasi Hapus, & Pemutusan Sesi. | [specs/anise_feedback_dialog.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/anise_feedback_dialog.md) |

---

## 📌 Aturan Penggunaan Komponen
1. **Single Source of Truth:** Semua widget terstandarisasi diletakkan di `lib/core/widgets/` (atau direktori widget modul terkait).
2. **Strict Design Tokens:** Dilarang memberi warna di luar `AppColors` dan dilarang ukuran font di luar `AppTextStyles`.
3. **Fluid Layout:** Semua dimensi margin, padding, dan radius wajib menggunakan extension `.w(context)` dan `.h(context)`.
4. **Header Cleanliness Policy:** Ikon notifikasi (lonceng) DILARANG ditaruh pada sub-header halaman turunan; hanya eksklusif di Header Dashboard Utama (`MainHeader`).
