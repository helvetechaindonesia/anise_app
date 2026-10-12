# User Flow Keseluruhan (Master Flowchart)

Dokumen ini berisi *Master Flowchart* (Alur Besar) yang menggabungkan seluruh fitur aplikasi Anise dalam satu pandangan helikopter (*helicopter view*). Diagram ini sangat berguna untuk menjelaskan *big picture* dari sistem kepada calon investor atau dewan guru.

```mermaid
flowchart TD
    %% Mulai
    Start(["Buka Aplikasi Anise"]) --> CekLogin{"Sudah Login?"}
    CekLogin -->|Belum| Login["Input Kredensial"]
    Login --> Validasi{"Validasi Backend"}
    Validasi -->|Gagal| Login
    Validasi -->|Sukses| Routing

    CekLogin -->|Sudah| Routing{"Cek Role User"}

    %% Cabang Siswa
    Routing -->|Role: SISWA| DashboardSiswa(("Dashboard Siswa"))
    
    DashboardSiswa --> S1["Fitur: Presensi Pagi"]
    S1 --> S1A{"Cek Wajah & GPS"}
    S1A -->|Cocok| S1B["Status: HADIR"]
    S1A -->|Gagal| S1C["Status: ABSEN / GAGAL"]
    
    DashboardSiswa --> S2["Fitur: Cek Jadwal & Notifikasi"]
    S2 --> S2A["Terima Notif Tugas Baru"]
    S2A --> S2B["Kerjakan Tugas"]
    S2B --> S2C["Upload & Kumpulkan"]
    
    DashboardSiswa --> S3["Fitur: Jurnal & Ulasan"]
    S3 --> S3A["Beri Rating Pengajaran Guru"]
    
    DashboardSiswa --> S4["Fitur: Habit Tracker"]
    S4 --> S4A["Lapor Kegiatan Positif & Upload Foto"]
    S4A --> S4B["Tunggu Validasi Guru"]
    
    DashboardSiswa --> S5["Fitur: Lapor Fasilitas / Bullying"]
    S5 --> S5A["Kirim Laporan via Sistem"]

    %% Cabang Guru
    Routing -->|Role: GURU| DashboardGuru(("Dashboard Guru"))
    
    DashboardGuru --> G1["Fitur: Jadwal Mengajar"]
    G1 --> G1A["Buka Kelas Sesuai Jam"]
    G1A --> G1B["Presensi Khusus Kelas"]
    G1B --> G1C["Isi Jurnal Mengajar"]
    G1C --> G1D{"Beri Tugas?"}
    G1D -->|Ya| G1E["Broadcast Tugas ke Siswa"]
    G1D -->|Tidak| G1F["Simpan Jurnal"]
    
    DashboardGuru --> G2["Fitur: Penilaian Tugas"]
    G2 --> G2A["Cek Tugas Terkumpul dari Siswa"]
    G2A --> G2B["Beri Nilai & Feedback"]
    
    DashboardGuru --> G3["Fitur: Kedisiplinan & Poin"]
    G3 --> G3A["Input Pelanggaran/Prestasi Siswa"]
    
    DashboardGuru --> G4["Fitur: Validasi Pembiasaan"]
    G4 --> G4A["Cek Laporan Sholat/Kegiatan Siswa"]
    G4A --> G4B{"Valid?"}
    G4B -->|Ya| G4C["Approve"]
    G4B -->|Tidak| G4D["Reject"]
    
    DashboardGuru --> G5["Fitur: Administrasi"]
    G5 --> G5A["Upload RPP / Modul Ajar"]

    %% Koneksi Interaksi Siswa & Guru
    S2C -.->|"Dikumpulkan ke"| G2A
    G1E -.->|"Notifikasi Tugas ke"| S2A
    G2B -.->|"Nilai Masuk ke"| DashboardSiswa
    S3A -.->|"Mempengaruhi"| KPI
    G3A -.->|"Memotong/Menambah Poin"| DashboardSiswa
    S4A -.->|"Diperiksa oleh"| G4A
    
    %% Engine Belakang Layar
    subgraph Backend_Engine ["Sistem Otomatis di Belakang Layar"]
        KPI(("Engine Penilaian KPI Guru"))
        KPI -->|"Input 1"| G1B
        KPI -->|"Input 2"| G1C
        KPI -->|"Input 3"| S3A
        KPI --> Rekap["Generate Raport Kinerja Bulanan Guru"]
    end
```

## Cara Membaca Master Flowchart
1. **Titik Awal (Start):** Semua dimulai dari pengecekan otentikasi. Sistem otomatis membelah jalur aplikasi berdasarkan peran (*role*).
2. **Dashboard Siswa (Kiri):** Memiliki ruang gerak mulai dari melakukan presensi dengan kamera, mengerjakan tugas yang dilempar guru, memberikan *rating* ke guru, hingga melapor kegiatan positif.
3. **Dashboard Guru (Kanan):** Berfokus pada pengelolaan KBM (Isi Jurnal, Beri Tugas), mengaudit perilaku siswa (memberi hukuman poin, menyetujui kegiatan positif), dan menyelesaikan administrasi mengajar.
4. **Garis Putus-Putus:** Merupakan titik persimpangan di mana aksi Guru akan langsung dirasakan oleh Siswa secara *real-time* (dan sebaliknya). Misalnya saat guru menekan tombol "Kirim Tugas", notifikasi seketika muncul di HP Siswa.
5. **Backend Engine (Bawah):** Mewakili sistem cerdas tak kasat mata yang terus-menerus memantau data (seperti rating siswa dan frekuensi absen guru) untuk mencetak rapor kinerja (KPI) bulanan bagi setiap guru.
