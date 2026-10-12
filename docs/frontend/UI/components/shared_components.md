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
| **`SectionActionLink`** | Menu extend ringkas satu baris ("Semua >") di sebelah kanan judul seksi. | [specs/section_action_link.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/section_action_link.md) |
| **`IdentityCard`** | Kartu identitas digital 3D (pola lingkaran lembut, bersih tanpa pill badges kaku). | [specs/identity_card.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/identity_card.md) |

---

## 🃏 3. Kartu & Tampilan Data (Cards & Data Display)

| Komponen | Peran & Letak | Tautan Dokumen Detail |
| :--- | :--- | :--- |
| **`CardInfo`** | Kartu ringkasan statistik & metrik performa (Hadir, Poin, Rekap). | [specs/card_info.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/card_info.md) |
| **`ItemListTile`** | Baris kartu daftar data vertikal (riwayat absen, surat masuk, daftar siswa). | [specs/item_list_tile.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/item_list_tile.md) |
| **`StateFeedback`** | Tampilan status saat data kosong (*Empty State*) atau internet error (*Retry View*). | [specs/state_feedback.md](file:///f:/projek/anise_app/docs/frontend/UI/components/specs/state_feedback.md) |

---

## 📌 Aturan Penggunaan Komponen
1. **Single Source of Truth:** Semua widget diimplementasikan di `lib/core/widgets/`.
2. **Strict Design Tokens:** Dilarang memberi warna di luar `AppColors` dan dilarang ukuran font di luar `AppTextStyles`.
3. **Fluid Layout:** Semua dimensi margin, padding, dan radius wajib menggunakan extension `.w(context)` dan `.h(context)`.
