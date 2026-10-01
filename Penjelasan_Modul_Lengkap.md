# Daftar Modul & Detail Fitur Sistem Anise

Dokumen ini memaparkan seluruh modul (fungsionalitas utama) yang terdapat di dalam ekosistem aplikasi pendidikan Anise, beserta rincian fitur super lengkap di dalam setiap modulnya.

---

## 1. Modul Autentikasi & Manajemen Akses
Modul dasar yang memastikan keamanan sistem dan memisahkan alur kerja pengguna berdasarkan perannya.

- **Role-Based Access Control (RBAC):** Sistem secara cerdas membedakan hak akses dan tampilan aplikasi secara otomatis saat pengguna *login*. (Contoh: Guru melihat menu Jurnal, Siswa melihat menu Pengumpulan Tugas).
- **Secure JWT Token Authentication:** Keamanan tingkat tinggi di mana setiap sesi *login* diberikan *token* terenkripsi yang memiliki batas waktu kedaluwarsa.
- **Auto-Hydration State:** Aplikasi mampu mengingat identitas pengguna (memori aplikasi tidak hilang) saat aplikasi dimuat ulang (Di-refresh), tanpa harus *login* berulang kali.

## 2. Modul Presensi Pintar (Smart Attendance)
Modul revolusioner untuk menggantikan sistem absensi manual (kertas/fingerprint) dengan AI.

- **Verifikasi Wajah Bertenaga AI (Face Recognition):** Memanfaatkan kecerdasan buatan untuk memindai geometri wajah pengguna secara *real-time* via kamera *smartphone*/laptop.
- **Validasi Geolocation (GPS):** Mencegah kecurangan (absen dari rumah) dengan cara mengunci koordinat GPS pengguna. Absen hanya valid jika dilakukan di radius area sekolah.
- **Anti-Spoofing:** AI dirancang untuk membedakan wajah asli dengan foto 2D atau topeng.
- **Riwayat Kehadiran (Timeline):** Menyajikan grafik mini dan jejak rekam presensi harian secara detail (jam masuk, status terlambat, izin, sakit) yang bisa dipantau langsung oleh pengguna.

## 3. Modul Manajemen KBM (Jurnal & Tugas)
Modul ini mendigitalkan seluruh interaksi di dalam kelas, menggantikan buku absen/jurnal kelas fisik.

- **Jadwal Dinamis Terintegrasi:** Guru cukup membuka aplikasi dan sistem langsung menyajikan kartu kelas yang harus diajar pada detik/jam tersebut.
- **Pencatatan Topik & Materi (Jurnal):** Guru dapat mengetik topik bahasan, mencatat siswa yang izin/alpha di jam pelajarannya, dan menyimpannya sebagai arsip sekolah.
- **Distribusi Tugas Instan:** Di dalam jurnal yang sama, guru bisa mencentang opsi "Beri Tugas", lalu melampirkan modul (PDF/Gambar), dan menetapkan *deadline*.
- **Portal Pengumpulan Tugas (Siswa):** Siswa akan menerima notifikasi, lalu bisa langsung mengerjakan dan mengunggah (upload) jawaban tugas mereka melalui aplikasi.
- **Sistem Penilaian (Grading):** Guru dapat mereviu tugas yang terkumpul, memberikan skor (0-100), dan menambahkan *feedback* catatan untuk siswa tersebut.

## 4. Modul Kedisiplinan & Sistem Poin
Modul yang membantu penegakan tata tertib sekolah secara transparan.

- **Database Regulasi Poin:** Master data yang memuat aturan penambahan poin (Prestasi) dan pengurangan poin (Pelanggaran Tata Tertib).
- **Pelaporan Pelanggaran Instan:** Guru mana pun (terutama Guru BK/Wali Kelas) dapat memotret kejadian pelanggaran, memilih nama siswa, dan sistem otomatis memotong poin kedisiplinan siswa tersebut.
- **Peringatan Otomatis (Notifikasi):** Jika poin kedisiplinan siswa menyentuh batas rawan (misal: tinggal 20 poin), sistem otomatis mengirimkan peringatan (SP) digital ke siswa dan memicu sistem untuk menghubungi Wali Kelas.

## 5. Modul Pembiasaan Karakter (Habit Tracker)
Modul unik bergaya *gamifikasi* untuk memantau dan melatih rutinitas positif siswa.

- **Daftar Kebiasaan Positif:** Menampilkan target harian/mingguan (Contoh: Sholat Dhuha berjamaah, Buang sampah pada tempatnya, Literasi baca buku 15 menit).
- **Upload Bukti Aksi (Selfie):** Siswa mengambil aksi nyata dengan memotret diri mereka sedang melakukan kegiatan tersebut sebagai bukti lapor.
- **Audit & Validasi (Anti Curang):** Bukti foto tidak otomatis dinilai valid. Guru (Agama/Wali Kelas) harus mengecek foto tersebut di panel mereka dan menekan tombol *Approve* (Terima) atau *Reject* (Tolak jika foto terindikasi palsu/tidak relevan).

## 6. Modul Evaluasi Kinerja (KPI Guru)
Modul otomatisasi di belakang layar (*backend engine*) khusus untuk pihak Yayasan atau Kepala Sekolah.

- **Sistem Penilaian Anonim:** Di akhir jam pelajaran, siswa bisa memberikan bintang (Rating 1-5) terhadap cara mengajar guru hari itu. Data ini bersifat anonim (guru tidak tahu siapa yang memberi nilai jelek).
- **Kalkulasi Metrik Kombinasi:** *Engine* sistem secara terus-menerus memantau persentase absen guru, kedisiplinan mengisi jurnal kelas, dan rata-rata rating dari siswa.
- **Rapor Kinerja Bulanan (Auto-Generate):** Di akhir bulan, sistem otomatis merilis laporan (Rapor KPI) setiap guru. Ini memudahkan Kepala Sekolah untuk memberikan apresiasi/bonus atau teguran tanpa repot menghitung manual.

## 7. Modul Asisten Virtual (Anise AI Chatbot)
Asisten pintar yang tertanam langsung di aplikasi untuk melayani pengguna 24/7.

- **Informasi Cepat Tanggap:** Siswa bisa bertanya santai di *chat* (Contoh: *"Hari ini mapel apa aja?"* atau *"Ada PR nggak hari ini?"*), dan AI akan membaca database jadwal/tugas lalu membalas dengan bahasa natural.
- **Pengingat Presensi:** AI akan menyapa dan mengingatkan pengguna secara proaktif jika sistem mendeteksi mereka belum melakukan presensi masuk di pagi hari.

## 8. Modul Administrasi Guru & Laporan Ekstra
Modul pendukung (*Support*) untuk menjaga ekosistem komunikasi sekolah.

- **Bank Administrasi Digital:** Area khusus bagi guru untuk mengunggah dan menyimpan perangkat ajar (RPP, Modul Ajar, Silabus) agar tersentralisasi di *server* sekolah.
- **Kotak Lapor Anonim (Whistleblower):** Siswa dapat melapor secara rahasia jika fasilitas sekolah rusak parah, atau jika terjadi kasus *bullying* tanpa takut identitasnya bocor ke siswa lain. Laporan langsung masuk ke meja Kepala Sekolah/BK.
