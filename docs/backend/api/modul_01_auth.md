## 🔐 Modul 1: Autentikasi & RBAC
*Prefix:* `/api/auth`
- `POST /login`: Login menggunakan NIK/NISN/Email.
- `POST /logout`: Menghapus sesi JWT token aktif.
- `GET /me`: Mengambil profil *user* yang sedang login.
- `PUT /me/password`: Ubah password / reset PIN.
- `POST /device-token`: Mendaftarkan FCM Token dari HP *user* untuk Modul 18.

> Catatan: Dokumentasi ini dihasilkan dari blueprint endpoint.md. Tambahkan detail request/response secara spesifik di sini saat API mulai dikembangkan.
