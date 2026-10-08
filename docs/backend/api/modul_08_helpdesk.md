## 🛠️ Modul 8: Helpdesk & Pengaduan
*Prefix:* `/api/helpdesk`
- `GET /`: Daftar tiket komplain milik *user*.
- `POST /`: Membuat laporan (Misal: "Proyektor Kelas X Rusak").
- `GET /all`: Daftar semua tiket (Khusus Sarpras/TU).
- `PUT /{id}/respond`: Sarpras memberikan tanggapan / mengubah status tiket (*Progress/Done*).

> Catatan: Dokumentasi ini dihasilkan dari blueprint endpoint.md. Tambahkan detail request/response secara spesifik di sini saat API mulai dikembangkan.
