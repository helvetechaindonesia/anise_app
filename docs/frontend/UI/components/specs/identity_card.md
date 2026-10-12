# 🪪 Spesifikasi Komponen: `IdentityCard` (3D Digital ID Card)
**Kategori:** Cards & Identitas Digital  
**Target:** Dashboard Utama Seluruh Role (Siswa, Guru, BK, Staf TU)  
**File Kode:** `lib/features/home/widgets/identity_card_3d_widget.dart` & `guru_identity_card_3d_widget.dart`

---

## 🎯 1. Deskripsi & Filosofi Desain
`IdentityCard` adalah kartu identitas digital interaktif dengan efek rotasi sensor gyroscope/gesture 3D. 

### 💡 Keputusan Refactor & Polish (Bebas AI-Slop):
1. **Pembersihan Pill Badges:**
   - **Sebelum:** Informasi NISN/NIP dan Kelas/Status dibungkus kontainer kapsul warna-warni berlapis.
   - **Sesudah:** Pill badges **DIHAPUS**. Menggunakan tipografi langsung (*Plain Typography Hierarchy*) dengan warna putih kontras lembut (`onPrimary.withValues(alpha: 0.8)`). Desain menjadi lebih otentik layaknya kartu fisik profesional (bukan template generik).
2. **Penggantian Pattern Background (Square ➔ Circle):**
   - **Sebelum:** Elemen geometris kotak-kotak miring kaku.
   - **Sesudah:** Elemen lingkaran abstrak halus (*Concentric Rings / Circle Blobs*) dengan opacity 5-8% untuk memberikan kesan fluid, modern, dan futuristik.

---

## 📐 2. Anatomi & Struktur Visual
```text
┌──────────────────────────────────────────────────────────────┐
│  [Logo Sekolah] SMA NEGERI 1 PEUNARON         [Logo Kemdikbud]│
│                                                              │
│  [ Avatar ]  NAMA LENGKAP PENGGUNA                           │
│  (64x64 px)  NISN / NIP (Teks Polos Bersih)                  │
│              Kelas / Jabatan (Teks Polos Bersih)             │
│                                                              │
│  [ Background Pattern: Soft Circle Rings, Bebas Kotak Kaku ] │
└──────────────────────────────────────────────────────────────┘
```

---

## ⚙️ 3. Parameter Properti (Props)
| Nama Properti | Tipe Data | Wajib? | Keterangan |
| :--- | :--- | :---: | :--- |
| `user` | `UserModel?` | Ya | Objek data pengguna saat ini. |
| `isInteractive3D` | `bool` | Opsional | Mengaktifkan respon sensor gyro/tilt sentuhan (default: `true`). |
| `cardColor` | `Color?` | Opsional | Gradien blok warna kartu (default: Deep Teal `AppColors.primary`). |
