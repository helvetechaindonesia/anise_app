## 📍 Modul 2: Presensi (Kehadiran)
*Prefix:* `/api/attendance`
- `GET /`: Riwayat absen *user* login (Bisa difilter per bulan).
- `POST /check-in`: Tap masuk (menyertakan kordinat GPS & Foto Selfie).
- `POST /check-out`: Tap pulang.
- `GET /report/class/{class_id}`: Laporan rekap presensi kelas (Khusus Wali Kelas).

> Catatan: Dokumentasi ini dihasilkan dari blueprint endpoint.md. Tambahkan detail request/response secara spesifik di sini saat API mulai dikembangkan.
