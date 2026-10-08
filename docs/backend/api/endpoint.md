# 📡 Master Endpoint API (Fase 1b)

**Status:** Draf Awal (Scraping dari Arsitektur 21 Modul)
**Terakhir Diperbarui:** 08 Oktober 2026

Dokumen ini adalah cetak biru (blueprint) untuk seluruh RESTful API *Endpoint* aplikasi Anise. Setiap modul dipetakan *endpoint*-nya agar tim *Frontend* dan *Mobile* dapat bersiap merancang *State Management* (Vuex/Pinia/Bloc/Redux).

---

## 🔐 Modul 1: Autentikasi & RBAC
*Prefix:* `/api/auth`
- `POST /login`: Login menggunakan NIK/NISN/Email.
- `POST /logout`: Menghapus sesi JWT token aktif.
- `GET /me`: Mengambil profil *user* yang sedang login.
- `PUT /me/password`: Ubah password / reset PIN.
- `POST /device-token`: Mendaftarkan FCM Token dari HP *user* untuk Modul 18.

## 📍 Modul 2: Presensi (Kehadiran)
*Prefix:* `/api/attendance`
- `GET /`: Riwayat absen *user* login (Bisa difilter per bulan).
- `POST /check-in`: Tap masuk (menyertakan kordinat GPS & Foto Selfie).
- `POST /check-out`: Tap pulang.
- `GET /report/class/{class_id}`: Laporan rekap presensi kelas (Khusus Wali Kelas).

## 💌 Modul 3: Perizinan & Dispensasi
*Prefix:* `/api/leaves`
- `GET /`: Daftar pengajuan izin milik *user* login.
- `POST /`: Mengajukan izin/sakit/cuti (Upload surat dokter).
- `GET /approvals`: Daftar izin bawahan yang butuh di-ACC (Khusus Kepsek/Piket).
- `PUT /{id}/approve`: Menyetujui izin.
- `PUT /{id}/reject`: Menolak izin.

## 📓 Modul 4: Jurnal Mengajar
*Prefix:* `/api/journals`
- `GET /`: Daftar jurnal.
- `POST /`: Guru mengisi jurnal kelas setelah mengajar.
- `PUT /{id}`: Guru mengedit jurnal.
- `POST /{id}/reviews`: Siswa memberikan *rating* bintang pada jurnal guru.

## 📝 Modul 5: Penugasan (PR)
*Prefix:* `/api/assignments`
- `GET /`: Daftar PR untuk siswa, atau daftar PR yang dibuat oleh guru.
- `POST /`: Guru merilis tugas baru ke sebuah kelas.
- `POST /{id}/submit`: Siswa mengunggah jawaban (teks/file).
- `PUT /submissions/{sub_id}/grade`: Guru memberikan nilai pada jawaban siswa.

## 📊 Modul 6: Agenda Penilaian & Raport
*Prefix:* `/api/assessments`
- `GET /`: Daftar agenda ujian (UTS, UAS, Ulangan Harian).
- `POST /`: Guru membuat agenda penilaian.
- `POST /{id}/scores`: Guru mengunggah nilai murid-murid secara *bulk* (massal).

## 🕌 Modul 7: Gerakan 7 KAIH (Karakter)
*Prefix:* `/api/g7kaih`
- `GET /`: Daftar aktivitas ibadah harian.
- `POST /`: Siswa melapor kegiatan (misal: Sholat Dhuha, Sedekah).
- `GET /leaderboard`: Papan klasemen anak ter-alim wkwk.

## 🛠️ Modul 8: Helpdesk & Pengaduan
*Prefix:* `/api/helpdesk`
- `GET /`: Daftar tiket komplain milik *user*.
- `POST /`: Membuat laporan (Misal: "Proyektor Kelas X Rusak").
- `GET /all`: Daftar semua tiket (Khusus Sarpras/TU).
- `PUT /{id}/respond`: Sarpras memberikan tanggapan / mengubah status tiket (*Progress/Done*).

## 👮‍♂️ Modul 9: Kedisiplinan
*Prefix:* `/api/discipline`
- `GET /reports`: Riwayat laporan kedisiplinan.
- `POST /reports`: Guru/Satpam melaporkan murid yang melanggar.
- `PUT /reports/{id}/process`: Guru BK memproses / menindaklanjuti laporan.

## 🛋️ Modul 10: Bimbingan Konseling (BK)
*Prefix:* `/api/counseling`
- `GET /sessions`: Daftar jadwal *curhat* / konseling.
- `POST /sessions`: Siswa *booking* jadwal ke Guru BK.
- `PUT /{id}/notes`: Guru BK mencatat hasil pertemuan secara rahasia.

## 📨 Modul 11: Surat Menyurat
*Prefix:* `/api/letters`
- `GET /incoming`: Daftar surat masuk (Khusus TU).
- `GET /outgoing`: Daftar surat keluar.
- `POST /outgoing`: Membuat arsip surat keluar baru.

## 🪑 Modul 12: Sarpras (Inventaris)
*Prefix:* `/api/inventory`
- `GET /items`: Katalog barang sekolah.
- `GET /loans`: Riwayat peminjaman barang.
- `POST /loans`: Guru/Siswa mengajukan pinjam (Misal: Pinjam Bola Basket).
- `PUT /loans/{id}/return`: Mengembalikan barang.

## 🗓️ Modul 13: Kurikulum
*Prefix:* `/api/curriculum`
- `GET /schedules`: Jadwal pelajaran harian/mingguan.
- `GET /subjects`: Mata pelajaran.
- `GET /classes`: Daftar kelas dan rombel.

## 👥 Modul 14: Manajemen User & UI/UX
*Prefix:* `/api/users`
- `GET /`: List seluruh pengguna (Khusus TU/Admin).
- `POST /`: Tambah *user* baru.
- `PUT /{id}/roles`: Mengganti jabatan *user*.
- `PUT /preferences`: Menyimpan preferensi tema (Dark/Light mode).

## 🏫 Modul 15: Manajemen Sekolah
*Prefix:* `/api/school`
- `GET /settings`: Mengambil profil sekolah (Logo, Nama, Visi Misi).
- `PUT /settings`: Admin mengedit profil sekolah.
- `GET /academic-years`: Mengambil daftar tahun ajaran.

## 📢 Modul 16: Humas & Pengumuman
*Prefix:* `/api/announcements`
- `GET /`: Daftar pengumuman (Sesuai *role* target).
- `POST /`: Admin TU merilis pengumuman baru (beserta *push notif*).
- `PUT /{id}/read`: Menandai bahwa pengumuman sudah dibaca (*Read Receipt*).

## 📈 Modul 17A: KPI Tendik (Penilaian Guru)
*Prefix:* `/api/kpi`
- `GET /analysis`: Umpan/Feed riwayat analisa harian guru (Robot).
- `GET /reports`: Guru melihat raport KPI-nya sendiri per semester.
- `GET /evaluations`: Kepsek melihat daftar guru yang harus dinilai.
- `POST /evaluations`: Kepsek men-*submit* form penilaian (Draft/Publish).

## 💯 Modul 17B: Poin Kedisiplinan Siswa
*Prefix:* `/api/points`
- `GET /balance`: Melihat sisa saldo poin milik siswa (Dompet).
- `GET /rules`: Melihat daftar pasal pelanggaran (Katalog).
- `GET /history`: Melihat sejarah poin dipotong/ditambah.

## 🔔 Modul 18: Notifikasi
*Prefix:* `/api/notifications`
- `GET /`: Mengambil notifikasi *in-app* (lonceng).
- `PUT /{id}/read`: Menandai notif sudah diklik.
- `PUT /read-all`: Membaca semua notif sekaligus.

## ⚖️ Modul 19: Privacy & Legal
*Prefix:* `/api/legal`
- `GET /{document_type}`: Membaca teks Privacy Policy / TOS.
- `POST /consent`: *User* menyetujui versi legal yang baru.

## 🛟 Modul 20: Bantuan & Keamanan
*Prefix:* `/api/support`
- `GET /faqs`: Daftar FAQ bantuan mandiri.
- `GET /security-logs`: Riwayat login *user* login.

## 👨‍💻 Modul 21: Developer Mode
*Prefix:* `/api/dev` *(Middleware: Super Admin)*
- `GET /logs`: *Streaming/Read* file `laravel.log`.
- `POST /cache/clear`: *Bypass command* Artisan *optimize*.
- `POST /impersonate/{user_id}`: Meretas masuk (*Login*) sebagai *user* lain untuk *debugging*.
