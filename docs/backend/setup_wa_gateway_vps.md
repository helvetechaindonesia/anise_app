# 🚀 Panduan Setup Self-Hosted WhatsApp Gateway di VPS (Baileys)

Dokumen ini berisi panduan untuk mengaktifkan **WhatsApp Gateway Mandiri** (*Self-Hosted*) menggunakan Node.js dan Baileys (`@whiskeysockets/baileys`).

---

## 💡 Mengapa Bikin Sendiri di VPS?
1. **100% Gratis Selamanya:** Tidak perlu bayar langganan bulanan ke vendor pihak ketiga (Fonnte, Wablas, dll).
2. **Unlimited Pesan:** Tidak ada batasan kuota pesan per hari.
3. **Super Ringan:** Menggunakan Baileys murni (WebSocket) tanpa Chrome/Chromium, hanya memakan RAM **~50MB** di VPS.
4. **Session Persisten:** Sekali scan QR di HP ("Perangkat Tertaut"), nomor WhatsApp akan tetap login selamanya bahkan jika VPS di-restart.

---

## 🛠️ Langkah 1: Persiapan di VPS

Pastikan Node.js (v18 ke atas) dan PM2 sudah terpasang di VPS:
```bash
# Cek versi node & npm
node -v
npm -v

# Install PM2 jika belum ada
npm install -g pm2
```

---

## 📦 Langkah 2: Install Dependensi & Jalankan Service

Di VPS Anda, masuk ke direktori proyek Anise:
```bash
cd /path/to/anise_app/wa-gateway

# 1. Install dependensi
npm install

# 2. Buat file .env dari template
cp .env.example .env

# 3. Jalankan service menggunakan PM2 (agar jalan terus di background)
pm2 start server.js --name "anise-wa-gateway"

# 4. Simpan state PM2 agar otomatis jalan saat VPS reboot
pm2 save
pm2 startup
```

---

## 📲 Langkah 3: Scan QR Code (Tautkan Perangkat)

1. Buka browser di laptop atau HP Anda:
   ```text
   http://IP_VPS_ANDA:3001/scan
   ```
   *(Pastikan port 3001 sudah diizinkan di firewall VPS / UFW: `sudo ufw allow 3001`)*

2. Buka aplikasi WhatsApp di HP Anda:
   * Buka **Setelan (Settings)** > **Perangkat Tertaut (Linked Devices)**.
   * Pilih **Tautkan Perangkat (Link a Device)**.
   * Arahkan kamera HP ke QR Code yang muncul di layar browser.

3. Begitu selesai di-scan, halaman web akan menampilkan:
   ```text
   ✅ WhatsApp Terhubung!
   Nomor Bot: 628xxxxxxxx
   ```

---

## ⚙️ Langkah 4: Hubungkan ke Laravel Backend

Buka file `.env` di folder `backend/`:
```env
WA_GATEWAY_URL=http://127.0.0.1:3001/send-message
WA_GATEWAY_KEY=anise_secret_gateway_key_2026
```

Lalu jalankan pembersihan cache konfigurasi Laravel:
```bash
php artisan config:clear
```

---

## 🧪 Langkah 5: Uji Coba

1. Buka aplikasi Anise di HP atau browser.
2. Di halaman login, pilih **Lupa Sandi?**.
3. Masukkan email siswa: `siswa@sipena.sch.id`.
4. Tekan tombol **"Kirim Kata Sandi ke WhatsApp"**.
5. Server VPS akan otomatis mengirimkan pesan WhatsApp ke nomor `087794274408` dalam hitungan detik!

---

## 🔍 Perintah Berguna untuk Maintenance
```bash
# Cek log WhatsApp Gateway secara realtime
pm2 logs anise-wa-gateway

# Restart service
pm2 restart anise-wa-gateway

# Hentikan service
pm2 stop anise-wa-gateway
```
