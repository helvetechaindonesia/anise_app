## 💌 Modul 3: Perizinan & Dispensasi
*Prefix:* `/api/leaves`
- `GET /`: Daftar pengajuan izin milik *user* login.
- `POST /`: Mengajukan izin/sakit/cuti (Upload surat dokter).
- `GET /approvals`: Daftar izin bawahan yang butuh di-ACC (Khusus Kepsek/Piket).
- `PUT /{id}/approve`: Menyetujui izin.
- `PUT /{id}/reject`: Menolak izin.

> Catatan: Dokumentasi ini dihasilkan dari blueprint endpoint.md. Tambahkan detail request/response secara spesifik di sini saat API mulai dikembangkan.
