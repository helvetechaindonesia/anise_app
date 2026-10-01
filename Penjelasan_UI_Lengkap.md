# Dokumentasi User Interface (UI) Sistem Anise

Dokumen ini menjelaskan rancangan antar-muka (*User Interface*) dari aplikasi Anise secara menyeluruh. Aplikasi ini dibangun sebagai PWA (Progressive Web App) dengan pendekatan *Mobile-First Design*, sehingga tampilannya dirancang menyerupai aplikasi *native* di *smartphone* dengan pengalaman pengguna (UX) yang sangat mulus dan modern.

---

## 1. Layar Selamat Datang & Autentikasi (Splash Screen & Login)
- **Splash Screen:** Saat aplikasi dibuka, pengguna akan disambut dengan animasi *fade-in* logo Anise yang berkesan premium.
- **Halaman Login:** Desain minimalis dan bersih. Terdapat *form* untuk memasukkan Username dan Password. Tombol login didesain menonjol (dengan efek *hover/tap*). Jika terjadi kesalahan login, akan muncul notifikasi *toast* (pesan melayang kecil) berwarna merah tanpa mengganggu struktur halaman.

## 2. Beranda (Home / Dashboard Utama)
Halaman ini adalah pusat kontrol utama pengguna. Beranda disesuaikan secara otomatis berdasarkan *role* (Siswa atau Guru).
- **Header & Greeting:** Menyapa pengguna dengan nama panggilan mereka secara personal, beserta informasi waktu (tanggal hari ini).
- **Kartu Identitas Digital (Digital Card):** Ini adalah elemen paling *eye-catching* di halaman depan. Kartu melayang berlapis *glassmorphism* (kaca transparan) yang menampilkan Nama, NIS/NIP, Jurusan/Sekolah, dan yang paling penting: **Status Kehadiran Hari Ini** (contoh: Indikator hijau bertuliskan "Hadir" atau abu-abu "Belum Presensi").
- **Menu Cepat (Quick Menu Grid):** Berisi ikon-ikon berjejer rapi (seperti tata letak aplikasi *GoJek* atau *Grab*) untuk mengakses fitur utama:
  - Tombol **Presensi** (Sangat menonjol untuk memancing klik pertama kali)
  - Tombol **Jurnal/Tugas**
  - Tombol **Riwayat Absen**
  - Tombol **Pembiasaan / Habit**
- **Asisten AI (Anise Chatbot):** Di bagian bawah halaman, terdapat area obrolan pintar. Pengguna bisa mengetik pertanyaan santai seperti *"Jadwal gue hari ini apa aja?"* dan sistem (AI) akan menjawabnya langsung di layar tersebut layaknya *chatting*.

## 3. Layar Presensi Wajah (Face Recognition Camera)
Halaman ini berupa *Modal* / *Overlay* yang menutupi seluruh layar (*full-screen*).
- **Live Camera Feed:** Menampilkan tangkapan kamera depan secara *real-time*.
- **Indikator Pemindaian:** Di sekeliling bingkai kamera terdapat garis animasi berputar yang menandakan AI sedang mencari titik wajah (pola geometri wajah).
- **Status Text:** Tulisan di bawah kamera yang berubah-ubah secara dinamis (contoh: *"Mencari lokasi GPS..."* -> *"Arahkan wajah Anda ke kamera"* -> *"Memproses kecocokan..."*).
- **Layar Sukses:** Begitu wajah cocok, garis animasi berubah hijau, muncul ikon centang tebal, dan *snapshot* foto akan menampilkan koordinat GPS (*watermark*) di pojokannya sebelum layar otomatis tertutup.

## 4. Halaman Jurnal & Jadwal (Khusus Guru)
Antar-muka produktivitas harian untuk guru mengajar.
- **Kartu Jadwal Mengajar:** Menampilkan daftar kelas yang harus dimasuki hari ini beserta jam dan mata pelajarannya.
- **Formulir Jurnal (Form Input):** Jika satu kartu jadwal diklik, akan terbuka halaman pengisian. Terdapat kolom teks yang luas untuk mengisi **Topik Materi** dan **Catatan Khusus**.
- **Panel Penugasan (Tugas Sidebar):** Di dalam form jurnal, guru bisa mencentang kotak *"Beri Tugas Siswa"*. Jika dicentang, akan meluncur menu tambahan untuk mengatur batas waktu (*deadline*) tugas dan tombol unggah dokumen (*upload* lampiran).

## 5. Halaman Riwayat & Statistik Presensi
Halaman khusus untuk melihat rekam jejak kedisiplinan.
- **Papan Statistik (Dashboard Mini):** Di bagian paling atas terdapat kotak-kotak ringkasan visual berupa angka (Contoh: Total Hadir: 20, Izin: 2, Alpa: 0).
- **Daftar Jejak Waktu (Timeline List):** Di bawahnya terdapat daftar panjang yang bisa di-*scroll*. Setiap baris menampilkan tanggal, jam masuk, dan logo kecil penanda status (Hijau untuk Tepat Waktu, Kuning untuk Terlambat). 

## 6. Halaman Pembiasaan (Habit Tracker)
Antar-muka gaya *gamifikasi* untuk melatih kedisiplinan siswa.
- **Pilihan Kartu Habit:** Menampilkan kotak-kotak kegiatan positif (contoh: Sholat Dhuha, Buang Sampah, Literasi Baca).
- **Sistem Upload Bukti:** Jika satu kartu dipilih, akan membuka fitur kamera bagi siswa untuk berfoto (*selfie* dengan latar belakang kegiatan). Setelah di-*submit*, kartu tersebut akan berubah warna menjadi kuning (Status: *Pending/Menunggu Validasi Guru*).

## 7. Navigasi Bawah (Bottom Navigation Bar)
Karena dirancang mirip aplikasi HP (PWA), terdapat *bar* statis di bagian paling bawah layar yang selalu menempel.
- Berisi ikon standar: **Home (Beranda)**, **Tugas/Jurnal**, **Notifikasi**, dan **Profil**.
- Perpindahan antar *tab* dibuat sangat responsif tanpa perlu memuat ulang (*reload*) halaman.

---
*Catatan: Keseluruhan warna dominan UI menggunakan palet warna khusus Anise (paduan warna gelap elegan, putih bersih untuk keterbacaan, dan warna aksen/highlght terang untuk tombol-tombol krusial (Call to Action).*
