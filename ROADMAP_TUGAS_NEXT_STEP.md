# 🚀 ROADMAP EKSEKUSI TOTAL: ENTERPRISE FACE AI (INSIGHTFACE + ANTI-SPOOFING)

Dokumen ini adalah cetak biru perombakan total arsitektur presensi cam dan pendaftaran biometrik Sipena menggunakan **Microservice Python AI (InsightFace ArcFace 512-D + Silent-Face Anti-Spoofing)** di server VPS.

---

## 🏗️ ARSITEKTUR SISTEM ENTERPRISE

```
[ FRONTEND FLUTTER ] 
  ├── BiometricRegistrationScreen: Auto-Capture foto selfie resolusi tinggi (JPEG).
  └── PresensiCameraScreen: Frame lingkaran, anti-peyang, auto-capture foto selfie + GPS.
              ⬇ (Multipart Foto Asli)
[ BACKEND LARAVEL (PHP 8.3) ] 
  ├── Menerima multipart foto & koordinat GPS (Geofence).
  └── Menghubungi Python Face AI Service via HTTP Internal (127.0.0.1:5000).
              ⬇ (Forward Image Buffer)
[ PYTHON FACE AI ENGINE (Port 5000) ]
  ├── 1. Anti-Spoofing Check: Mendeteksi apakah ini manusia 3D hidup vs KTP/kertas/layar HP.
  ├── 2. ArcFace Embedding: Menghasilkan 512-Dimensional Deep Vector unik.
  └── 3. Cosine Similarity Matching: Membandingkan vektor selfie vs vektor terdaftar (Akurasi 99.8%).
```

---

## 🎯 DAFTAR TARGET & STEP EKSEKUSI

### STEP 1: Siapkan Python Face AI Service di VPS (Port 5000)
- [x] Siapkan kode `face-engine/main.py` (FastAPI + InsightFace buffalo_s 512-D + Anti-Spoofing & Liveness).
- [x] Siapkan `face-engine/requirements.txt`, `face-engine/sipena-face-ai.service`, dan auto-installer `face-engine/deploy.sh`.
- [ ] Jalankan `./deploy.sh` di VPS (`31.97.222.13`) untuk aktivasi microservice di background port 5000.

---

### STEP 2: Rombak Backend Laravel (`AttendanceController` & `JournalController`)
- [x] Buat helper service [FaceAiService.php](file:///f:/projek/anise_app/backend/app/Services/FaceAiService.php) untuk komunikasi internal ke `http://127.0.0.1:5000`.
- [x] **Method `registerBiometric`:**
  - Menerima file foto selfie `face_image` dari user.
  - Memanggil `FaceAiService::extractEmbedding()` (512-D vector).
  - Menyimpan embedding asli ke `users.face_embedding` & foto ke `storage/app/public/biometrics/`.
- [x] **Method `submitPresensiCam` (Presensi Harian & Jurnal):**
  - Menerima file `face_image` snapshot asli dari kamera.
  - Memanggil `FaceAiService::verifyFace($photo, $user->face_embedding)` (threshold similarity standard 0.55 - 0.65).
  - Menolak otomatis jika foto buram/layar HP/KTP atau wajah orang lain.

---

### STEP 3: Rombak Frontend Flutter (Super Bersih & Seamless)
- [x] Di [biometric_registration_screen.dart](file:///f:/projek/anise_app/frontend/lib/features/profile/screens/biometric_registration_screen.dart):
  - Frame lingkaran sempurna & anti-peyang.
  - Auto-capture resolusi tinggi setelah verifikasi ekspresi/liveness.
  - Mengirim multipart file `face_image` ke backend.
- [x] Di [presensi_camera_screen.dart](file:///f:/projek/anise_app/frontend/lib/features/presensi/screens/presensi_camera_screen.dart):
  - Frame lingkaran sempurna, anti-peyang, banner status floating.
  - Auto-capture saat wajah stabil $\rightarrow$ Kirim file snapshot asli `face_image` + GPS.
  - Tangani pesan error presisi dari backend.

---

### STEP 4: Pengujian Menyeluruh
- [ ] Test KTP $\rightarrow$ Terbukti ditolak oleh Anti-Spoofing.
- [ ] Test Wajah Orang Lain (Ibu/Teman) $\rightarrow$ Terbukti ditolak oleh ArcFace (similarity rendah).
- [ ] Test Wajah Asli Pemilik Akun $\rightarrow$ Berhasil lolos presensi dalam < 1 detik.
