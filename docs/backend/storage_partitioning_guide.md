# 📦 Blueprint Arsitektur Partisi Storage (Anise Storage Partitioning Standard)
*Lokasi: `docs/backend/storage_partitioning_guide.md`*  
*Versi: 1.0 (Oktober 2026)*

Dokumen ini adalah standar resmi dan baku untuk pengelolaan penyimpanan berkas unggahan (*file upload*) di aplikasi **Anise**. Seluruh modul yang memiliki fitur upload/download berkas **WAJIB** tunduk pada hierarki dan aturan partisi ini agar performa server tetap optimal, data mudah di-backup, dan tidak terjadi penumpukan ribuan file secara datar (*flat directory flood*).

---

## 🧭 1. Peta Master Partisi Direktori (`storage/app/public/`)

```text
storage/app/public/
│
├── 📂 tasks/                                          # 📚 1. MATERI / SOAL DARI GURU
│   └── 📂 {TAHUN_AJARAN}/                             # Contoh: 2026-2027
│       └── 📂 {KODE_KELAS}/                           # Contoh: XII-RPL-1
│           └── 📂 {KODE_MAPEL}/                       # Contoh: PWPB
│               └── 📂 task_{ID_TUGAS}/                # Contoh: task_a1b2c3d4
│                   └── materi_{timestamp}_{name}.pdf
│
├── 📂 submissions/                                    # 🎓 2. JAWABAN TUGAS DARI SISWA
│   └── 📂 {TAHUN_AJARAN}/                             # Contoh: 2026-2027
│       └── 📂 {KODE_KELAS}/                           # Contoh: XII-RPL-1
│           └── 📂 {KODE_MAPEL}/                       # Contoh: PWPB
│               └── 📂 task_{ID_TUGAS}/                # Contoh: task_a1b2c3d4
│                   └── 📂 {NIS}_{NAMA_SISWA}/         # Contoh: 102938_angga-maulana
│                       └── ans_{nis}_{timestamp}.pdf
│
├── 📂 leaves/                                         # 🏥 3. SURAT IZIN / BUKTI DOKTER
│   ├── 📂 siswa/
│   │   └── 📂 {TAHUN}/                                # Contoh: 2026
│   │       └── 📂 {BULAN}/                            # Contoh: 10
│   │           └── 📂 {KODE_KELAS}/                   # Contoh: XII-RPL-1
│   │               └── 📂 {NIS}_{NAMA_SISWA}/         # Contoh: 102938_angga
│   │                   └── surat_{timestamp}.jpg
│   └── 📂 pegawai/
│       └── 📂 {TAHUN}/
│           └── 📂 {BULAN}/
│               └── 📂 {NIP}_{NAMA_GURU}/              # Contoh: 19850101_budi
│                   └── surat_{timestamp}.pdf
│
├── 📂 reports/                                        # 🛡️ 4. PENGADUAN, DISIPLIN & HELPDESK
│   ├── 📂 pengaduan/                                  # Bukti aduan siswa (Bullying / Sarpras)
│   │   └── 📂 {TAHUN}/{BULAN}/
│   │       └── 📂 item_{REPORT_ID}/
│   │           └── bukti_{timestamp}.jpg
│   ├── 📂 disiplin/                                   # Foto bukti pelanggaran tata tertib
│   │   └── 📂 {TAHUN}/{BULAN}/
│   │       └── 📂 item_{DISIPLIN_ID}/
│   │           └── bukti_{timestamp}.jpg
│   └── 📂 helpdesk/                                   # Screenshot kendala error sistem
│       └── 📂 {TAHUN}/{BULAN}/
│           └── 📂 item_{TICKET_ID}/
│               └── bukti_{timestamp}.png
│
├── 📂 user_files/                                     # 📁 5. BERKAS PRIBADI / PORTOFOLIO
│   └── 📂 {ROLE}/                                     # siswa / guru
│       └── 📂 {NIS_ATAU_NIP}_{NAMA}/
│           ├── 📂 sertifikat/
│           │   └── doc_{timestamp}.pdf
│           └── 📂 dokumen/
│               └── doc_{timestamp}.pdf
│
└── 📂 avatars/                                        # 👤 6. FOTO PROFIL PENGGUNA
    ├── 📂 siswa/
    │   └── 📂 {NIS}_{NAMA}/
    │       └── avatar.webp                            # Timpa berkas lama jika ganti foto
    ├── 📂 guru/
    │   └── 📂 {NIP}_{NAMA}/
    │       └── avatar.webp
    └── 📂 default/
        └── default_avatar.png
```

---

## 🛠️ 2. Standar Pemanggilan di Kode Backend (`FileStorageService`)

Jangan melakukan *hardcode* path di controller. Selalu gunakan helper `App\Services\FileStorageService`:

```php
use App\Services\FileStorageService;

// 1. Simpan Pengumpulan Tugas Siswa
$path = FileStorageService::storeTaskSubmission($request->file('attachment'), $task, $user);
$attachmentUrl = '/storage/' . $path;

// 2. Simpan Lampiran Materi Guru
$path = FileStorageService::storeTaskAttachment($request->file('attachment'), $task);
$attachmentUrl = '/storage/' . $path;

// 3. Simpan Surat Izin Sakit
$path = FileStorageService::storeLeaveAttachment($request->file('attachment'), $user);

// 4. Simpan Bukti Pengaduan / Disiplin / Helpdesk
$path = FileStorageService::storeReportAttachment($request->file('attachment'), 'pengaduan', $report->id);

// 5. Simpan Portofolio / Berkas Pengguna
$path = FileStorageService::storeUserFile($request->file('file'), $user, 'sertifikat');
```

---

## 🔒 3. Sanitasi & Integritas Nama Berkas
1. **Dilarang Menyimpan Nama Asli Mentahan:** Nama asli dari file pengguna (contoh: `Tugas (1) @ #.pdf`) dibersihkan dengan `Str::slug` atau disimpan di kolom database `attachment_name` / `file_name`.
2. **Penamaan Fisik:** Menggunakan format unik berbasis timestamp dan random hash singkat untuk menghindari tabrakan berkas:  
   `ans_{nis}_{timestamp}_{hash}.{ext}` atau `materi_{timestamp}_{slug}.{ext}`.
3. **Penyimpanan URL:** Path yang disimpan di database dan dikirim ke Flutter selalu diawali `/storage/...` yang tersambung ke symlink web publik.
