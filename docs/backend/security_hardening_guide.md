# 🛡️ Panduan & Blueprint Keamanan Sistem (Anti-Brute Force, Anti-DDoS, & Hardening VPS)

Dokumen ini adalah hasil **Scrapping & Audit Keamanan** menyeluruh untuk aplikasi **Anise** guna melindungi sistem dari serangan siber (Brute-Force, DDoS Layer 7, Flooding WhatsApp, dan eksploitasi API).

---

## 🧭 1. Peta Ancaman (Threat Modeling)

| Jenis Serangan | Target | Dampak Jika Bocor | Status Proteksi |
| :--- | :--- | :--- | :---: |
| **Brute Force Password** | `POST /api/auth/login` | Akun guru/siswa/admin dijebol | ✅ **TERLINDUNGI** (Throttle: 5x / menit) |
| **WhatsApp Flooding / Spam** | `POST /api/auth/forgot-password` | Bot WA kehabisan kuota / spam nomor orang | ✅ **TERLINDUNGI** (Throttle: 3x / 5 menit) |
| **HTTP Flood (DDoS Layer 7)** | Seluruh API Port 80/443 | Server VPS down (CPU & RAM 100%) | ⚙️ **Konfigurasi Nginx & Cloudflare** |
| **Slowloris (Koneksi Lambat)** | Nginx Worker | Nginx kehabisan slot koneksi | ⚙️ **Konfigurasi Nginx Timeout** |
| **SQL Injection & XSS** | Input Data Query | Data sekolah bocor / dirusak | ✅ **TERLINDUNGI** (Laravel PDO Binding) |

---

## 🔒 2. Lapis 1: Keamanan Aplikasi (Laravel Backend)

Pembaruan yang sudah langsung diaktifkan di kode backend:

### A. Rate Limiting Kustom (`AppServiceProvider.php`)
1. **Endpoint Login (`throttle:login`):**
   - Maksimal **5 percobaan gagal per 1 menit** per kombinasi `IP Address + Email`.
   - Jika melebihi batas, server mengembalikan status **`HTTP 429 Too Many Requests`**:
     ```json
     {
       "status": "error",
       "message": "Terlalu banyak percobaan login gagal. Demi keamanan, silakan coba lagi dalam 1 menit."
     }
     ```
2. **Endpoint Lupa Sandi (`throttle:forgot-password`):**
   - Maksimal **3 permintaan per 5 menit** per `IP Address + Email`.
   - Mencegah oknum membombardir nomor HP siswa/guru dengan pesan WhatsApp.
3. **Global API Throttling (`throttle:api`):**
   - Maksimal 120 request per menit per user/IP.

### B. Security Audit Logging (`security_audit_logs`)
Setiap kali ada upaya login dengan password yang salah, sistem otomatis mencatat:
- `user_id` pemilik akun yang disasar
- `event_type`: `FAILED_LOGIN_ATTEMPT`
- `ip_address`: Alamat IP penyerang
- `user_agent`: Jenis browser / perangkat yang digunakan
- `metadata`: Timestamp ISO8601 dan email terkait

---

## 🌐 3. Lapis 2: Keamanan Web Server (Nginx VPS)

Untuk menahan serangan DoS / Flooding sebelum menyentuh PHP-FPM, terapkan konfigurasi berikut pada file konfigurasi Nginx website Anda di VPS (`/etc/nginx/nginx.conf` atau konfigurasi vhost domain):

```nginx
# 1. Batasi Rate Request (Anti-DDoS Layer 7)
# Mengizinkan maksimal 20 request per detik per IP
limit_req_zone $binary_remote_addr zone=anise_api_limit:10m rate=20r/s;

# 2. Batasi Koneksi Bersamaan per IP (Anti-Slowloris)
limit_conn_zone $binary_remote_addr zone=anise_conn_limit:10m;

server {
    listen 443 ssl http2;
    server_name api.helvetecha.tech;

    # Terapkan rate limit dengan burst 10
    limit_req zone=anise_api_limit burst=10 nodelay;
    limit_conn anise_conn_limit 15;

    # Timeout agresif agar penyerang lambat langsung diputus
    client_body_timeout 10s;
    client_header_timeout 10s;
    keepalive_timeout 30s;
    send_timeout 10s;

    # Security Headers Standar Industri
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # ... konfigurasi root dan proxy php-fpm ...
}
```

---

## 🛡️ 4. Lapis 3: Keamanan Edge Network (Cloudflare Free Anti-DDoS)

Metode terbaik untuk melindungi VPS dari serangan DDoS berskala besar (Volumetric Attack gigabit) adalah menggunakan **Cloudflare** di domain `helvetecha.tech`:

1. **Aktifkan Proxy (Awan Oranye):**
   - Di DNS Cloudflare, set record `A` untuk `api.helvetecha.tech` dengan status **Proxied**.
   - **Efek:** IP asli VPS (`31.97.222.13`) disembunyikan sepenuhnya dari publik. Penyerang yang melakukan ping/DDoS hanya akan memukul server raksasa Cloudflare, bukan VPS Anda.
2. **Aktifkan Fitur Keamanan Cloudflare:**
   - **Security > Settings > Security Level:** Set ke `Medium` atau `High`.
   - **Bot Fight Mode:** Aktifkan (otomatis memblokir bot scanning/scraping berbahaya).
   - **Under Attack Mode:** Siap dinyalakan kapan saja jika server sedang menerima serangan masif.

---

## 🧱 5. Lapis 4: Firewall OS VPS (UFW & Fail2ban)

1. **UFW (Uncomplicated Firewall):**
   Pastikan hanya port esensial yang terbuka ke publik:
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```
   *(Port 3001 WhatsApp Gateway sudah ditutup dari publik dan hanya berkomunikasi via internal `127.0.0.1`)*.

2. **Pasang Fail2ban (Auto-Ban IP Penyerang):**
   ```bash
   sudo apt install -y fail2ban
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```
   *Fail2ban akan otomatis memblokir IP apa pun di firewall Linux yang melakukan kegagalan login berulang atau request scanning anomali.*
