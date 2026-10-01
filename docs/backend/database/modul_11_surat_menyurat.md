# Dokumentasi Database: Modul 11 (Administrasi Surat Menyurat TU)

**Status:** ON HOLD (Tahap Observasi & Pengembangan)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul ini direncanakan untuk menangani sistem kearsipan Surat Masuk, Surat Keluar, Sistem Disposisi Kepala Sekolah, dan Penomoran Surat Otomatis. Namun, karena tingginya kompleksitas birokrasi dan variasi aturan format surat di tiap instansi, **MODUL INI DITANGGUHKAN SEMENTARA**.

---

> [!WARNING]
> ## 🛑 STATUS: UNDER DEVELOPMENT (ON HOLD) 🛑
> Pembuatan tabel *database* (`incoming_letters`, `outgoing_letters`, `letter_categories`) **TIDAK DILAKUKAN** pada tahap MVP 1.A ini. Kami masih menunggu hasil observasi data riil (sampel format surat, alur penomoran dinas, dan hierarki disposisi) dari pihak sekolah.

---

## 🚧 Instruksi Keras Untuk Tim UI/UX (Frontend)

Mengingat *database* dan API untuk Modul 11 belum akan dibangun, *Frontend* **WAJIB** melakukan penyesuaian *Interface* di *dashboard* Tata Usaha:

1. **Menu Tetap Ada, Tapi Dikunci:** 
   Menu "Surat Menyurat", "Surat Masuk", dan "Surat Keluar" di *sidebar* Tata Usaha **tetap dimunculkan** agar *user* tahu fitur ini akan ada.
2. **Halaman *Under Construction*:** 
   Ketika menu tersebut di-klik, jangan mengarahkan *user* ke tabel kosong/ *error*. Alihkan *user* ke sebuah halaman ilustrasi (misal: gambar orang sedang membangun/memperbaiki server) dengan tulisan tebal: 
   **"Fitur Sedang Dalam Tahap Pengembangan (Coming Soon)."**
3. **Sembunyikan Tombol Aksi:** 
   Pastikan tidak ada tombol "Tambah Surat" atau "Kirim Disposisi" yang aktif atau bisa di-klik di area manapun yang berkaitan dengan modul ini.

Segala pengembangan lanjutan untuk Modul 11 ini akan dilanjutkan setelah fase riset kebutuhan Tata Usaha selesai dilakukan.
