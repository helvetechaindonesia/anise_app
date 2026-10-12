# 🏛️ Fondasi & Kerangka Arsitektur Anise (Fase 2a)
**Dokumen Standar Pengembangan & Refaktor Sistem (Backend & Frontend)**  
*Terakhir Diperbarui: 12 Oktober 2026*

---

## 🎯 1. Filosofi & Tujuan Arsitektur
Arsitektur Anise dirancang untuk memenuhi kriteria **Enterprise-Grade**:
1. **Separation of Concerns (SoC):** Setiap komponen hanya bertanggung jawab atas satu peran spesifik.
2. **High Cohesion & Low Coupling:** Modul memiliki ketergantungan minimal dengan modul lain, sehingga perubahan di satu modul tidak merusak modul lainnya.
3. **Scalability:** Mudah menampung 21 modul tanpa membuat struktur folder menjadi sesak atau membingungkan.
4. **Developer Experience (DX):** Onboarding engineer baru menjadi cepat karena pola file terprediksi (*predictable patterns*).

---

## 🐘 2. Standar Arsitektur Backend (Laravel)

### 2.1 Alur Aliran Data (Data Flow Pipeline)
Setiap permintaan (request) wajib melalui urutan terstruktur berikut:

```text
HTTP Request
     │
     ▼
[ Route ] (routes/api.php)
     │
     ▼
[ Controller ] (Http/Controllers/*Controller.php) ───► Tangani validasi request & HTTP status
     │
     ▼
[ Service ] (Services/*Service.php) ──────────────► Tangani Business Logic / Aturan Sekolah
     │
     ▼
[ Repository ] (Repositories/*Repository.php) ────► Tangani Query Database / Eloquent ORM
     │
     ▼
[ Model ] (Models/*.php) ─────────────────────────► Entitas Database & Relasi Tabel
     │
     ▼
[ Resource / DTO ] (Http/Resources/*Resource.php) ► Format plating data JSON respon ke Client
     │
     ▼
HTTP Response (Standard JSON Format)
```

> **Aturan Emas Backend:**
> - Controller **DILARANG KERAS** memanggil Eloquent Model secara langsung. Controller hanya boleh memanggil Service.
> - Service **DILARANG KERAS** menulis raw query SQL atau manipulasi database langsung. Service memanggil Repository.
> - Repository **HANYA** bertugas mengambil, menyimpan, mengupdate, atau menghapus data model.

### 2.2 Format Standar JSON Response API
Semua endpoint API wajib mengembalikan format seragam:

```json
{
  "success": true,
  "message": "Data presensi berhasil diambil",
  "data": { ... },
  "meta": {
    "page": 1,
    "total": 100
  }
}
```
Untuk respon error:
```json
{
  "success": false,
  "message": "Token tidak valid atau telah kadaluarsa",
  "errors": null
}
```

### 2.3 Standar Penamaan File & Konvensi Backend
| Komponen | Penamaan File | Contoh | Lokasi |
| :--- | :--- | :--- | :--- |
| **Model** | PascalCase (Tunggal) | `Attendance.php` | `app/Models/` |
| **Controller** | PascalCase + Controller | `AttendanceController.php` | `app/Http/Controllers/` |
| **Service** | PascalCase + Service | `AttendanceService.php` | `app/Services/` |
| **Repository** | PascalCase + Repository | `AttendanceRepository.php` | `app/Repositories/` |
| **Resource (DTO)** | PascalCase + Resource | `AttendanceResource.php` | `app/Http/Resources/` |
| **Base SOP** | `Base{Komponen}.php` | `BaseService.php` | `app/Core/` |

---

## 📱 3. Standar Arsitektur Frontend (Flutter)

### 3.1 Pola Feature-First Architecture
Frontend menggunakan pendekatan terisolasi berbasis fitur (`features/*`). Setiap fitur memiliki batasan yang jelas:

```text
frontend/lib/
├── core/
│   ├── constants/       # API URLs, Asset paths, String keys
│   ├── network/         # Dio Client, Interceptors, SSL Adapters
│   ├── theme/           # Color palette, Typography, Dark mode
│   └── utils/           # Date formatters, Validators, Helpers
│
└── features/
    └── [nama_fitur]/
        ├── screens/     # UI Layar Utama (Scaffold, AppBar)
        ├── widgets/     # UI Komponen khusus fitur (Card item, Modal)
        └── providers/   # State Management (ChangeNotifier/Riverpod)
```

### 3.2 Standar Penamaan File & Konvensi Frontend
| Tipe | Penamaan File | Contoh | Lokasi |
| :--- | :--- | :--- | :--- |
| **Screen / Page** | snake_case + `_screen.dart` | `presensi_screen.dart` | `features/[fitur]/screens/` |
| **Widget** | snake_case + `_widget.dart` | `presensi_card_widget.dart`| `features/[fitur]/widgets/` |
| **Provider/State**| snake_case + `_provider.dart`| `presensi_provider.dart` | `features/[fitur]/providers/` |
| **Model Data** | snake_case + `_model.dart` | `presensi_model.dart` | `features/[fitur]/models/` atau `core/models/` |

---

## 🧹 4. Kerangka Pembersihan Direktori & Sanitasi Proyek (Fase 2c & 2d)

### 4.1 Relokasi File Non-Source Code
- Semua file spreadsheet sumber (`*.xlsx`, `*.csv`) dipindahkan ke direktori `master-file/`.
- File arsip patch sementara (`*.zip`, folder `temp_*`, folder `scratch*`) yang sudah selesai digunakan dihapus untuk menjaga kebersihan repositori.

### 4.2 Struktur Root Bersih yang Ditargetkan
```text
anise_app/
├── backend/            # Source code Laravel
├── frontend/           # Source code Flutter
├── docs/               # Dokumentasi sistem, arsitektur & panduan teknis
│   ├── architecture/   # Guidelines & ERD
│   ├── backend/        # Dokumentasi API
│   └── frontend/       # Dokumentasi UI/UX
├── master-file/        # File master data asli (Excel/CSV)
├── README.md           # Ikhtisar Proyek
└── ROADMAP.md          # Peta jalan pengembangan
```

---

## 🚀 5. Checklist Verifikasi Implementasi
- [x] Dokumen fondasi arsitektur dibuat (`docs/architecture/foundation_guidelines.md`).
- [ ] Refactor struktur backend & frontend sesuai standar yang ditentukan.
- [ ] Bersihkan file sampah dan arsip sementara dari root workspace.
- [ ] Verifikasi semua endpoint dan UI berjalan normal setelah refactor.
