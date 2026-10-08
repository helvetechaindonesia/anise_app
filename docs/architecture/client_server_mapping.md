# ⚖️ Client-Server Hybrid Mapping (Blueprint 1k)

**Status:** Finalized Blueprint (Fase 1k)

Dokumen ini memetakan arsitektur *Hybrid* yang bertumpu pada **efisiensi beban kerja**, **kecepatan pemrosesan**, tanpa melupakan **pondasi *stack*** dan **pembatasan hak akses**.

---

## 1. 🏗️ Pemetaan Stack Teknologi
- **Server Side (Dapur):** Laravel (REST API) + MySQL. Berperan murni sebagai *API Provider* tanpa merender UI (Blade ditiadakan).
- **Client Side (Meja Tamu):** Flutter + Riverpod (State Management). Berperan murni mengkonsumsi JSON dan me-render UI lintas platform.

---

## 2. ⚡ Pemetaan Beban Kerja (Hybrid Efficiency)
Konsep utamanya adalah: **"Beban berat dipikul Server, Kelincahan dieksekusi Client."**

### 🍳 Dieksekusi di Server Side (Heavy Lifting):
- **Komputasi Berat & Aggregasi:** Perhitungan total nilai (*Assessment*), kalkulasi KPI Guru, atau rekapitulasi poin pelanggaran siswa bulanan.
- **File Generation:** Pembuatan laporan PDF, *Export/Import* file Excel (Daftar Siswa/Guru), karena *library* server (seperti *Maatwebsite Excel*) jauh lebih cepat dan tidak membebani RAM HP *user*.
- **Background Jobs & Cron:** Mengirim notifikasi otomatis jam 7 pagi, *cleanup* data basi, jadwal otomatis (*Scheduler*).
- **Validasi Inti (Security):** Memastikan input ke *database* selalu bersih dan lolos verifikasi bisnis (tidak peduli mau di-*bypass* lewat *Client* sekalipun).

### 📱 Dieksekusi di Client Side (Agility & UX):
- **Sorting & Filtering Instan:** Jika data (misal list 50 Siswa) sudah di-*fetch* dan masuk ke *Riverpod State*, maka proses *search* atau urut abjad **HARUS** dilakukan di *Client*. Haram memanggil ulang (menembak) *Server* hanya untuk *search text*.
- **Pre-Validation:** Mengecek apakah kolom *email* pakai tanda `@` atau cek minimal karakter *password* sebelum tombol *Submit* ditekan (mengurangi buang-buang HTTP Request ke *Server*).
- **State Caching:** Menyimpan JSON piring dari Waiter ke memori sementara (Riverpod), sehingga kalau user pindah halaman dan balik lagi, data langsung tampil tanpa *loading*.
- **Micro-Animations:** Transisi *route*, *snackbars*, *loading shimmers* di-*handle* 100% oleh Flutter.

---

## 3. 🔐 Pemetaan Pembagian Hak Akses (RBAC)
Sistem ini menggunakan gerbang ganda (*Dual Gatekeeper*):

### 🛡️ Gerbang Server Side (The Middleware)
Satpam mutlak. Mengecek JWT Token dan hak akses *Role* setiap kali Waiter dipanggil.
- **Superadmin:** Bebas masuk semua 7 Divisi.
- **Guru:** Hanya diizinkan mengakses *endpoint* Divisi KBM (Jurnal, Nilai) dan Kesiswaan (Absen).
- Jika ada *Siswa* mencoba *nembak* *endpoint* `/api/kpis` secara *brute-force*, *Middleware* langsung menolak (403 Forbidden).

### 🚪 Gerbang Client Side (The Interceptor & State)
Penjaga Estetika.
- *Client* mengecek *Role* pengguna dari *userProvider*.
- Jika *user* adalah Siswa, tombol "Input Nilai" akan disembunyikan (*hidden*) dari UI sejak awal.
- Jika JWT Token kedaluwarsa, *Interceptor* (Dio/Http) akan otomatis menangkap *error 401*, dan langsung melempar user kembali ke halaman *Login* tanpa aplikasi *crash*.
