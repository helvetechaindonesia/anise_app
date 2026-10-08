# Dokumentasi Database & API: Modul 21 (Developer Mode)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 08 Oktober 2026

Modul ini adalah "Panel Rahasia" yang hanya dapat diakses oleh tim *Engineering/Developer* (atau Kepala Yayasan/Admin Level Tertinggi). Tujuannya adalah untuk menelusuri *bug*, memperbaiki *state* aplikasi, dan melihat performa sistem secara langsung tanpa perlu masuk melalui akses *server* (SSH/CPanel).

---

## 🗄️ 1. Struktur Database
Modul 21 bersifat *Tooling* sehingga tidak memerlukan penyimpanan persisten jangka panjang. Modul ini murni memanfaatkan **Sistem *Role*** dari Modul 1. 
- Hanya `users` yang memiliki *Role* berstatus `SUPER_ADMIN` yang dapat mengakses fitur ini di Frontend.

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
