# 🏗️ Helvetecha UI Architecture Framework: "To Building, Literally"
**Kitab Standar Konstruksi Antarmuka (Frontend Design System & Architecture)**  
*Edisi: Anise App | Versi 1.0 | 12 Oktober 2026*

---

## 🏛️ Filosofi: Dari Dapur ke Gedung Bertingkat
Jika backend disimulasikan sebagai **Dapur Restoran Bintang 5** (Manager/Core, Chef/Service, Tukang Belanja/Repo, Tukang Plating/Resource), maka frontend di Helvetecha disimulasikan sebagai **Konstruksi Bangunan Utuh (*To Building, Literally*)**.

Setiap piksel, widget, dan interaksi di layar memiliki padanan struktur fisik dalam sebuah gedung:

```text
                  ┌──────────────────────────────┐
                  │          7. ATAP             │  (AppBar / Header)
                  │  ┌────────────────────────┐  │
                  │  │     11. VENTILASI      │  │  (Status / Alert / Notif)
                  │  └────────────────────────┘  │
                  │                              │
                  │   ┌──────────────────────┐   │
 3. SCAFFOLDING   │   │      5. RUANGAN      │   │  (Page View / Screen)
 (Tiang Penyangga)│   │  ┌────────────────┐  │   │
                  │   │  │   4. TEMBOK    │  │   │  (Card / Container Box)
                  │   │  │ ┌────────────┐ │  │   │
                  │   │  │ │6.FURNITURE │ │  │   │  (Button, Field, Text)
                  │   │  │ └────────────┘ │  │   │
                  │   │  │  9. JENDELA   │ │  │   │  (Chart, Image, Viewport)
                  │   │  └────────────────┘  │   │
                  │   │                      │   │
                  │   │     10. PINTU        │   │  (Link, Nav Item, CTA)
                  │   └──────────────────────┘   │
                  │                              │
                  │   [12. TANGGA / ROUTING]     │  (Transitions / Steppers)
                  │   [ 8. LANTAI 2 / SUB-PAGE]  │  (Modal / Nested View)
                  │                              │
                  ├──────────────────────────────┤
                  │          2. LANTAI           │  (Canvas / Surface / Background)
                  └──────────────────────────────┘
                  ════════════════════════════════
                         1. FOUNDATION            (Tokens: Colors, Typo, Spacing)
                  ════════════════════════════════
```

---

## 📐 12 Elemen Konstruksi Bangunan (Definisi & Pemetaan Teknis)

### 1. 🧱 Foundation (Pondasi)
- **Definisi:** Fondasi tanah dan semen yang mendasari seluruh bangunan. Jika fondasi bergeser, seluruh bangunan retak.
- **Implementasi Teknis:**
  - Token Warna: `AppColors` (`core/constants/colors.dart`)
  - Token Tipografi: `AppTextStyles` (`core/theme/app_text_styles.dart`)
  - Token Dimensi & Matematika Responsif: `ResponsiveSpacing` & `Spacing` (`core/utils/responsive.dart`)
- **Aturan Emas:** **DILARANG KERAS** menggunakan nilai heksadesimal warna mentah atau ukuran font hardcoded di widget. Semua wajib merujuk ke Foundation.

### 2. 🪵 Lantai (Base Canvas / Surface)
- **Definisi:** Lantai dasar tempat penghuni berpijak. Memberikan rasa stabil dan alas bagi seluruh isi gedung.
- **Implementasi Teknis:**
  - `Scaffold.backgroundColor` (`AppColors.backgroundLight`)
  - Canvas latar belakang: `DecorativeBackground`
  - Area aman: `SafeArea`

### 3. 🏛️ Scaffolding / Tiang (Struktur Kerangka Utama)
- **Definisi:** Tiang beton bertulang dan bekisting yang membagi gravitasi dan beban vertikal/horizontal.
- **Implementasi Teknis:**
  - `Scaffold`, `CustomScrollView`, `SliverList`, `SliverGrid`
  - Struktur tata letak grid dan flex (`Column`, `Row`, `Expanded`, `Flex`)
  - Padding batas tepi layar global (`EdgeInsets.symmetric(horizontal: 24.w(context))`)

### 4. 🧱 Tembok (Container & Pembatas Zona)
- **Definisi:** Dinding pemisah antar ruangan atau bilik di dalam gedung agar barang tidak tumpah ruah.
- **Implementasi Teknis:**
  - `Card`, `Container` dengan batas jelas
  - Dekorasi: `borderRadius: BorderRadius.circular(20)` (Standar Anise)
  - Pembatas garis: `Divider`, `Border.all(color: AppColors.outline)`
  - Efek bayangan halus: `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))`

### 5. 🚪 Ruangan (Page Archetype / Screen Views)
- **Definisi:** Ruang fungsional utuh dengan fungsi tertentu (kamar tidur, ruang rapat, aula).
- **5 Standar Tipe Ruangan (Page Archetypes):**
  1. **Ruang Utama (Root / Tab Room):** Berisi Bottom Nav Bar, greeting, 3D card. *Tanpa tombol back.*
  2. **Ruang Cabang (Sub-Page Room):** Halaman menu fitur dari dashboard. Memiliki AppBar dengan tombol back.
  3. **Ruang Rincian (Detail Room):** Menampilkan detail data spesifik (Hero card, metadata, status).
  4. **Ruang Kerja/Aksi (Form / Action Room):** Ruangan input formulir dengan *Bottom Sticky CTA Button*.
  5. **Bilik Geser (Modal / BottomSheet Room):** Ruangan lipat yang muncul dari bawah untuk filter atau konfirmasi cepat.

### 6. 🛋️ Furniture (Interactive Components & Content)
- **Definisi:** Perabotan yang mengisi ruangan dan digunakan langsung oleh manusia.
- **Implementasi Teknis:**
  - Tombol: `ElevatedButton`, `OutlinedButton`, `IconButton`
  - Input: `AniseTextField`, `DropdownButtonFormField`, `Switch`
  - Teks Konten: `Text` dengan heading/body styles
  - Lencana: `StatusBadge`, `Chip`, `Tag`

### 7. 🏠 Atap (Header / App Bar)
- **Definisi:** Bagian paling atas yang memayungi seluruh isi ruangan dan melindungi dari cuaca.
- **Implementasi Teknis:**
  - `SliverAppBar` (collapsible header)
  - `AppBar` dengan Title, Back Icon, dan Action Icon (Notifikasi/Profile)
  - Banner Atap: Greeting Header & Identity Card 3D

### 8. 🏢 Lantai 2 (Sub-Page Overlay / Stack Layer - Opsional)
- **Definisi:** Lantai mezanin atau tingkat di atas lantai 1 untuk konteks yang lebih spesifik.
- **Implementasi Teknis:**
  - `ModalBottomSheet`
  - `Dialog` / `AlertDialog`
  - Floating Action Button overlay, contextual bottom sheet

### 9. 🪟 Jendela (Display Viewport / Media & Visual)
- **Definisi:** Kaca tembus pandang tempat mata bisa melihat dunia luar atau menyajikan visual.
- **Implementasi Teknis:**
  - Grafik & Chart: Garis rekapitulasi kehadiran, grafik poin
  - Gambar & Media: Avatar profile, QR Code viewport, image attachment preview
  - Card Carousel slider

### 10. 🚪 Pintu (Navigation & Access Points)
- **Definisi:** Lubang lintasan yang menghubungkan satu ruangan ke ruangan lain.
- **Implementasi Teknis:**
  - `BottomNavigationBar`
  - Navigasi `Navigator.pushNamed`, `context.go`
  - Tombol CTA utama (Call-To-Action) yang mengarahkan user ke alur selanjutnya
  - Tombol Back (`BackButton`, `PopScope`)

### 11. 💨 Ventilasi (Feedback & Dynamic Indicators)
- **Definisi:** Kisi-kisi udara tempat sirkulasi angin, pertukaran suhu, dan alarm asap.
- **Implementasi Teknis:**
  - Notifikasi kilat: `SnackBar`, `Toast`
  - Titik merah indikator belum dibaca: `Badge` / `Notification Dot`
  - Status koneksi offline/online banner
  - Shimmer / Skeleton loader saat data sedang di-fetch

### 12. 🪜 Tangga (Transition & Routing - Opsional)
- **Definisi:** Sarana gerak vertikal yang memuluskan perpindahan dari lantai 1 ke lantai 2.
- **Implementasi Teknis:**
  - Animasi transisi halaman (`PageRouteBuilder`, slide transition, fade)
  - `Stepper` (langkah 1, langkah 2, langkah 3 form)
  - `TabBar` / `TabBarView` slider horizontal antar sub-tab

---

## 🛠️ Rencana Aksi Pembuatan Shared Component Kit (Fase 3b)
Berdasarkan 12 elemen di atas, kita akan membangun pondasi folder `frontend/lib/core/building/`:
- `building/foundation/` ➔ Tokens (Colors, Typography, Spacing).
- `building/roof/` ➔ Atap bersama (Standard AppBars, Sliver Headers).
- `building/walls/` ➔ Tembok bersama (Standard Card Container, Section Box).
- `building/furniture/` ➔ Perabot bersama (Standard Buttons, Form Inputs, Badges).
- `building/doors/` ➔ Pintu bersama (Standard Bottom Nav, Action CTA).
- `building/ventilation/` ➔ Ventilasi bersama (Feedback Snackbars, Loading Skeletons, Error State).
