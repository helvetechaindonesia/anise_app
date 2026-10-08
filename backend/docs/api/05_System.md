# Dokumentasi API - Grup 5: Sistem, Notifikasi & Keamanan

## 🔔 Modul 18: Notifikasi
**Base URL:** `/api/notifications`
**Controller:** `NotificationController` (Boilerplate)

*Fitur belum diimplementasikan.*
- Mengambil *feed* notifikasi *in-app* (simbol lonceng).
- `PUT /{id}/read` untuk menandai satu notifikasi terbaca.
- `PUT /read-all` untuk menandai semua terbaca (Sapu bersih).

---

## ⚖️ Modul 19: Privacy & Legal
**Base URL:** `/api/legal`
**Controller:** `LegalController` (Boilerplate)

*Fitur belum diimplementasikan.*
- Melayani dokumen teks panjang statis via API (`/api/legal/tos`, `/api/legal/privacy_policy`).
- `POST /consent` untuk mencatat *timestamp* saat *user* menyetujui versi legal yang terbaru (wajib untuk aplikasi iOS/Android standar publik).

---

## 🛟 Modul 20: Bantuan & Keamanan
**Base URL:** `/api/support`
**Controller:** `SupportController` (Boilerplate)

*Fitur belum diimplementasikan.*
- `GET /faqs` : Daftar pertanyaan umum.
- `GET /security-logs` : Catatan aktivitas login (IP Address, Device, Waktu) untuk transparansi keamanan *user*.

---

## 👨‍💻 Modul 21: Developer Mode
**Base URL:** `/api/dev`
**Controller:** `DevController` (Boilerplate)

*Fitur belum diimplementasikan (Hanya diakses Super Admin).*
- `GET /logs` : Membaca isi file `storage/logs/laravel.log` langsung dari UI aplikasi tanpa harus buka SSH.
- `POST /cache/clear` : Eksekusi `php artisan optimize:clear` via API.
- `POST /impersonate/{user_id}` : Paksa *login* sebagai *user* lain untuk keperluan *debugging* atau investigasi error di pihak pengguna.
