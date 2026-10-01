# Dokumentasi Database: Modul 8 (Pengaduan & Helpdesk Kesiswaan)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul 8 difokuskan secara eksklusif sebagai sistem **Helpdesk / Pengaduan** (*Ticketing System*) untuk menampung aspirasi, laporan fasilitas, dan kasus khusus (seperti *bullying*) dari seluruh pengguna aplikasi.

> [!NOTE]
> Modul ini murni bersifat **Bottom-Up** (Laporan dari bawah ke atas) dan diproses langsung oleh petinggi terkait (Wakasek). Modul ini sama sekali terpisah dari alur "Penegakan Disiplin Anak" (Modul BK/Telat Gerbang) yang sifatnya berjenjang dan mempengaruhi Poin Siswa.

---

## 🏗️ 1. Filosofi Pemisahan Helpdesk vs Penegakan Hukum

Pada iterasi sebelumnya, terdapat kerancuan antara "Melaporkan Fasilitas Rusak" dengan "Melaporkan Anak Nakal". Untuk menjaga integritas sistem:
- Laporan yang butuh **Tindak Lanjut Cepat / Aspirasi** masuk ke Modul 8 (Tabel `complaints`).
- Laporan yang butuh **Investigasi / Hukuman** masuk ke Modul Kedisiplinan (Tabel `disiplin_reports` atau `laporan_telat_siswa`).

---

## 🗄️ 2. Detail Struktur Tabel Utama

### Tabel `complaints` (Pusat Pengaduan)
Tabel ini merupakan hasil *refactor* dari tabel `student_reports` versi lama. Dibuat jauh lebih universal agar bisa menampung laporan dari Siswa, Guru, maupun Tendik.

- `id` (UUID).
- `user_id` (FK ke `users`): Siapa yang membuat laporan (Siswa, Guru, Satpam, dll).
- `category` (String): Menggunakan *keyword* spesifik (`FASILITAS`, `BULLYING`, `ASPIRASI`).
- `title` (String): Judul singkat laporan.
- `description` (Text): Kronologi lengkap atau detail usulan.
- `attachment_url` (String, Nullable): Wajib disediakan *Frontend* untuk melampirkan bukti foto (Misal: Foto bangku rusak, *screenshot chat bullying*).
- `status` (String): Status penanganan tiket (`PENDING`, `ON_PROGRESS`, `RESOLVED`, `REJECTED`).
- `response_note` (Text, Nullable): Pesan tanggapan resmi dari pihak sekolah yang menangani tiket tersebut.

---

## 🚦 3. Arsitektur Distribusi Laporan (Untuk Backend & Frontend)

Kolom `category` pada tabel `complaints` memegang peranan vital untuk mendistribusikan (*routing*) laporan ke dasbor yang tepat:

1. **Kategori `FASILITAS`:**
   *Query* data ini wajib diarahkan ke **Dashboard Wakasek Sarana & Prasarana (Sarpras)**. *(Catatan: Halaman ini berbeda dengan halaman Inventaris Barang).*
2. **Kategori `BULLYING` & `ASPIRASI`:**
   *Query* data ini diarahkan langsung ke **Dashboard Wakasek Kesiswaan**.

Tanggapan (`response_note`) dan perubahan `status` hanya boleh dilakukan oleh *user* yang memiliki *Role/Permission* yang berwenang di masing-masing *dashboard* tersebut.
