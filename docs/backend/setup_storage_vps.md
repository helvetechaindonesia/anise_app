# 📦 Panduan Eksekusi Setup Storage & Permission (VPS aaPanel)

Panduan ini berisi kumpulan perintah satu kali jalan (*one-liner*) untuk menghubungkan storage publik Laravel (`storage:link`), mengatur permission folder agar upload file tidak error *Permission Denied*, serta membersihkan cache konfigurasi.

---

## 🚀 Perintah Sekali Jalan (Copy-Paste Langsung di Terminal VPS)

Buka **Terminal** di aaPanel atau via SSH (Putty / PowerShell SSH), lalu paste satu baris berikut:

```bash
cd /www/wwwroot/api.helvetecha.tech && \
php artisan storage:link && \
mkdir -p storage/app/public && \
mkdir -p storage/framework/{sessions,views,cache} && \
chown -R www:www storage bootstrap/cache public/storage && \
chmod -R 775 storage bootstrap/cache && \
php artisan config:clear && \
php artisan cache:clear && \
echo "✅ STORAGE SETUP BERHASIL!"
```

---

## 🔍 Apa Saja yang Dilakukan Perintah di Atas?
1. **`cd /www/wwwroot/api.helvetecha.tech`**: Masuk ke root direktori backend Laravel di VPS.
2. **`php artisan storage:link`**: Membuat symlink dari `public/storage` ke `storage/app/public` sehingga file upload bisa diakses via URL `https://api.helvetecha.tech/storage/...`.
3. **`mkdir -p ...`**: Memastikan semua sub-folder cache & upload sudah terbentuk.
4. **`chown -R www:www ...`**: Mengubah kepemilikan file ke user webserver Nginx/PHP (`www`) agar webserver punya hak tulis saat user mengunggah berkas/foto.
5. **`chmod -R 775 ...`**: Memberikan izin baca-tulis penuh pada folder storage dan cache.
6. **`php artisan config:clear && cache:clear`**: Me-refresh cache sistem Laravel agar membaca konfigurasi filesystem terbaru.

---

## 📌 Pengecekan Tambahan di File `.env` VPS
Buka menu **Website** > **api.helvetecha.tech** > **Files** (atau edit via terminal `nano .env`), pastikan dua baris ini sudah benar:

```dotenv
APP_URL=https://api.helvetecha.tech
FILESYSTEM_DISK=public
```

Setelah itu, fitur upload foto profil, lampiran tugas, surat perizinan, dan dokumen sekolah dijamin langsung aktif dan aman! 🎉
