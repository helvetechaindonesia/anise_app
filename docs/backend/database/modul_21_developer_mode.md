# Dokumentasi Database & API: Modul 21 (Developer Mode)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 08 Oktober 2026

Modul ini adalah "Panel Rahasia" yang hanya dapat diakses oleh tim *Engineering/Developer* (atau Kepala Yayasan/Admin Level Tertinggi). Tujuannya adalah untuk menelusuri *bug*, memperbaiki *state* aplikasi, dan melihat performa sistem secara langsung tanpa perlu masuk melalui akses *server* (SSH/CPanel).

---

## 🗄️ 1. Struktur Database
Modul 21 mengelola panel *Engineering/Developer* serta informasi kontak resmi pengembang aplikasi Anise.

### Tabel: `developers`
Menyimpan identitas entitas developer/vendor pengembang aplikasi untuk kebutuhan kontak helpdesk, direct WhatsApp, dan pelaporan sistem.

| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `UUID` (Primary Key) | Pengenal unik developer |
| `name` | `VARCHAR(255)` | Nama tim/perusahaan pengembang (cth: "Helvetecha Group") |
| `email` | `VARCHAR(255)` | Email resmi pengembang (cth: "Helvetechaindonesia@gmail.com") |
| `phone` | `VARCHAR(50)` | Nomor kontak / WhatsApp pengembang (cth: "081931315944") |
| `created_at` / `updated_at` | `TIMESTAMP` | Waktu pencatatan & pembaruan data |

> **Data Awal (Seeded Record):**
> - **Nama:** Helvetecha Group
> - **Email:** Helvetechaindonesia@gmail.com
> - **Phone:** 081931315944 (WhatsApp URL: `https://wa.me/6281931315944`)

---

## 🚀 2. Fitur & Rencana API

### A. Fitur *Log Viewer*
- **`GET /api/dev/logs`**
- *Backend* tidak melakukan *Query Database*, melainkan membaca file fisik `storage/logs/laravel.log`. 
- Sangat berguna ketika terjadi masalah (*Error 500*) di HP pengguna, *developer* cukup menekan 1 tombol di aplikasi untuk melihat letak *error* (*stack trace*)-nya.

### B. Fitur *Clear Cache / Optimize*
- **`POST /api/dev/cache/clear`**
- Sebuah tombol ajaib di aplikasi yang jika ditekan akan menjalankan perintah *Terminal* internal: `php artisan optimize:clear` atau `php artisan cache:clear`.
- Berguna saat ada pembaruan Jadwal Pelajaran (Modul 13) namun masih menyangkut (*nyangkut*) di HP sebagian guru.

### C. Fitur *Impersonate User* (Nyamar)
- **`POST /api/dev/impersonate/{user_id}`**
- Memungkinkan *Developer* login sebagai murid "Budi" (tanpa perlu tahu *password*-nya Budi) untuk mengecek apakah tampilan HP Budi mengalami *bug* atau tidak.
- API ini akan men- *generate* JWT *Token* sementara untuk *Session* Budi. Saat selesai nge- *debug*, *Developer* bisa kembali ke *Session* Adminnya semula.
