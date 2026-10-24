# 🚀 ROADMAP EKSEKUSI: 3D FACE BIOMETRIC & ANTI-SPOOFING KETAT (SIPENA)

Dokumen ini memuat spesifikasi arsitektur matematika dan langkah implementasi **Face Biometric 3D Depth & Landmark Multi-Variabel** untuk membasmi foto palsu (KTP/layar HP) dan memastikan pencocokan wajah 1-to-1 yang mutlak presisi (menolak wajah orang lain).

---

## 🔬 PILAR ALGORITMA BIOMETRIK 3D SIPENA

### 1. Uji Kedalaman 3D Real-Time (Anti-KTP / Kertas / Layar HP)
- [ ] Implementasi **Nose-to-Eye & Cheek Depth Variance ($\Delta Z$)**:
  - Mengukur diferensiasi elevasi sumbu kedalaman ($Z$) antara ujung hidung terhadap bidang mata dan pipi.
  - Objek 2D (Foto KTP/kertas cetak/layar HP) memiliki bidang datar ($\Delta Z \approx 0.00$) $\rightarrow$ Ditolak mutlak sebagai "Foto Palsu / Objek Datar".
  - Manusia asli 3D memiliki elevasi hidung nyata ($\Delta Z \ge \text{Threshold}$) $\rightarrow$ Lolos uji keaslian 3D.

### 2. Ekstraksi Landmark Geometri Wajah 5-Zona (Exclude Dahi)
- [x] **Zona Mata (Eye Aspect Ratio & Inter-Pupillary Distance):**
  - Mengukur rasio kelopak mata atas-bawah dan jarak antar pupil.
- [x] **Zona Hidung (Nose Bridge & Ala Cartilage Ratio):**
  - Mengukur rasio panjang tulang hidung terhadap lebar cuping hidung.
- [x] **Zona Pipi (Zygomatic Arch Curvature):**
  - Mengukur kelengkungan dan jarak tulang pipi kiri ke kanan.
- [x] **Zona Mulut & Bibir (Mouth Width & Lip Thickness Ratio):**
  - Mengukur rasio ketebalan bibir atas-bawah dan jarak sudut bibir (commissure).
- [x] **Zona Dagu & Rahang (Mandibular Jawline Angle):**
  - Mengukur sudut kemiringan rahang bawah ke titik pusat dagu.
- [x] **Exclude Dahi (Forehead Ignored):**
  - Titik kening/dahi diabaikan 100% agar ramah bagi guru gondrong, berhijab, atau berpeci.

### 3. Vektor Biometrik (128-D) & Pencocokan 1-to-1 (Anti-Muka Orang Lain)
- [x] Normalisasi fitur geometri 5-zona menjadi **Biometric Signature Vector**.
- [x] Perhitungan jarak kemiripan berbasis **Weighted Cosine Similarity & Normalized Euclidean Distance**:
  - Skor $\ge 80\%$ $\rightarrow$ Wajah pemilik akun sah diizinkan absen.
  - Skor $< 80\%$ (Ibu, teman, joki) $\rightarrow$ Ditolak: *"Wajah Anda tidak cocok dengan data biometrik terdaftar!"*.

---

## 🎯 DAFTAR TARGET & STEP PEKERJAAN

### STEP 1: Core Biometric 3D Analyzer
- [x] Buat file `lib/core/biometric/face_3d_mesh_analyzer.dart` di frontend.
- [x] Tulis fungsi kalkulasi:
  - `calculate3DDepthScore(Face face)`
  - `extract5ZoneBiometricSignature(Face face)`
  - `compareBiometricSignatures(List<double> sigA, List<double> sigB)`

---

### STEP 2: Pendaftaran Biometrik Wajah (`BiometricRegistrationScreen`)
- [x] Integrasikan `Face3dMeshAnalyzer` saat pendaftaran.
- [x] Validasi bahwa objek yang didaftarkan adalah manusia 3D (bukan foto KTP).
- [x] Ekstrak Biometric Signature dan kirim ke backend (`/attendance/biometric/register`).
- [x] Simpan signature ke database user (`users.face_embedding`).

---

### STEP 3: Presensi Cam (Harian & Jurnal KBM)
- [x] Integrasikan `Face3dMeshAnalyzer` di `PresensiCameraScreen`.
- [x] Real-time verification flow:
  1. **Geofence Check:** Validasi radius sekolah via GPS.
  2. **3D Depth Check:** Tolak instan jika diarahkan ke foto KTP / layar HP (`isReal3dFace` check).
  3. **1-to-1 Biometric Matching:** Hitung kemiripan signature dengan `user.face_embedding`.
- [x] Status banner dinamis:
  - 🔴 *"Objek datar terdeteksi! Gunakan wajah manusia asli (Bukan Foto/KTP)"* (Anti-KTP).
  - 🔴 *"Wajah tidak cocok dengan biometrik terdaftar!"*.
  - 🟢 *"Presensi Berhasil!"*.
- [x] **AUTO JEPRET! 📸** begitu validasi 3D & liveness tembus.

---

### STEP 4: Backend Enforcement & Database Synchronization
- [x] Update `AttendanceController.php` dan `JournalController.php` untuk memvalidasi kemiripan signature 3D (threshold 75-80%).
- [x] Simpan snapshot foto riil absensi ke storage server.
- [ ] Pengujian di device langsung oleh user.
