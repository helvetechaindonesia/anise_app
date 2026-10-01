# Panduan Pengaktifan Sistem (Anise App)

Berikut adalah langkah-langkah untuk menjalankan aplikasi Anise secara lokal untuk proses *development* dan *testing*:

## 1. Menyalakan Database (Laragon atau Docker)
Jika menggunakan Laragon:
- Buka aplikasi **Laragon** di komputer Anda.
- Klik tombol **Start All** untuk menyalakan Apache dan MySQL.
- Pastikan MySQL berjalan di port `3306`.

Jika menggunakan Docker:
- Pastikan *service* database di docker-compose sudah berjalan (misal: `docker-compose up -d db`).

## 2. Menjalankan Backend (Laravel)
### Opsi A: Tanpa Docker (Langsung)
Buka terminal baru, arahkan ke folder `backend`, lalu jalankan *server* Laravel pada port `8001`:
```bash
cd f:/projek/anise_app/backend
php artisan serve --port=8001 --host=0.0.0.0
```

### Opsi B: Menggunakan Docker (Saat Ini)
Jika menjalankan *backend* via Docker (`anise_app_backend`):
```bash
docker-compose up -d backend
```
*(Catatan: Port 8001 digunakan karena port 8000 mungkin sedang dipakai untuk keperluan lain).*

## 3. Menjalankan Frontend (Flutter Web / Android)
Buka terminal baru lainnya, arahkan ke folder `frontend`, lalu jalankan aplikasi Flutter:
```bash
cd f:/projek/anise_app/frontend
# Untuk Web/Chrome:
flutter run -d chrome
# Untuk HP Android / Emulator:
flutter run -d <ID_DEVICE_ATAU_IP>
```

---
## ⚠️ Troubleshooting (PENTING)

### Masalah: "Network Error" atau Loading Terus-menerus di HP/Emulator
**Penyebab:** 
Server lokal bawaan PHP (`php artisan serve` atau `php -S`) bersifat **single-threaded** (hanya bisa menangani 1 koneksi/request dalam satu waktu). 
Terkadang, aplikasi Flutter mengirimkan beberapa permintaan API sekaligus (bersamaan), atau ada koneksi yang menggantung (*hang*). Akibatnya, server PHP "macet" menunggu koneksi pertama selesai, dan menolak/membuat koneksi lainnya mengalami *timeout (Network Error)*.

**Solusi & Cara Mengatasi:**
1. **Restart Server Backend**:
   - Jika pakai Docker: jalankan perintah `docker restart anise_app_backend` di terminal.
   - Jika pakai terminal biasa: tekan `Ctrl + C` pada terminal tempat `php artisan serve` berjalan, lalu jalankan lagi perintahnya.
2. **Ubah Koneksi ke PHP-FPM / Nginx (Opsional, untuk jangka panjang)**:
   Karena sifat *single-threaded* dari `php artisan serve`, sangat disarankan menggunakan web server beneran (seperti Nginx + PHP-FPM di Docker atau Apache di Laragon) jika aplikasi Flutter sudah mulai berat dan melakukan banyak *request* API paralel.
3. **Cek IP Address**:
   Pastikan IP Address di `api_constants.dart` (contoh `http://192.168.1.7:8001/api`) sama persis dengan IP komputer kamu (cek pakai perintah `ipconfig`).

---
**Catatan Tambahan:**
- Jika ada perubahan pada struktur *database* atau butuh me-reset *dummy data*, jalankan perintah ini di terminal `backend` (atau di dalam container docker):
  ```bash
  php artisan migrate:fresh --seed
  ```