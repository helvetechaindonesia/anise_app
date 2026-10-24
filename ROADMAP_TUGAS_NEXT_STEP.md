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
- [ ] Buat folder `/www/wwwroot/31.97.222.13/face-engine` di VPS.
- [ ] Install library AI: `fastapi`, `uvicorn`, `insightface`, `onnxruntime`, `opencv-python-headless`.
- [ ] Buat service `main.py` dengan dua endpoint:
  - `POST /extract-face`: Menguji liveness anti-spoofing + mengembalikan 512-D embedding.
  - `POST /verify-face`: Membandingkan dua gambar wajah secara langsung (similarity score).
- [ ] Jalankan dengan systemd service / PM2: `sipena-face-ai`.

---

### STEP 2: Rombak Backend Laravel (`AttendanceController` & `JournalController`)
- [ ] Buat helper service `FaceAiService.php` untuk komunikasi internal ke `http://127.0.0.1:5000`.
- [ ] **Method `registerBiometric`:**
  - Terima file foto selfie `face_image` dari user.
  - Panggil Face AI Engine untuk verifikasi anti-spoofing & ekstrak 512-D embedding.
  - Simpan embedding asli ke `users.face_embedding` dan simpan foto ke `storage/app/public/biometrics/`.
- [ ] **Method `submitPresensiCam` (Presensi Harian & Jurnal):**
  - Validasi Geofence GPS.
  - Kirim foto selfie presensi ke Face AI Engine untuk di-matching dengan `users.face_embedding`.
  - Jika spoofing (KTP/layar) $\rightarrow$ Tolak HTTP 400: *"Foto tidak valid! Gunakan wajah asli."*
  - Jika similarity < 0.65 (Wajah orang lain/ibu/teman) $\rightarrow$ Tolak HTTP 400: *"Wajah tidak cocok dengan pemilik akun!"*.
  - Jika cocok $\ge 0.65$ $\rightarrow$ Presensi sah!

---

### STEP 3: Rombak Frontend Flutter (Super Bersih & Seamless)
- [ ] Hapus kalkulasi koordinat manual di `Face3dMeshAnalyzer.dart`.
- [ ] Di `BiometricRegistrationScreen.dart`:
  - Gunakan frame lingkaran sempurna, anti-peyang.
  - Saat wajah terdeteksi stabil di tengah lingkaran $\rightarrow$ Auto-jepret $\rightarrow$ Kirim file foto via FormData ke `/attendance/biometric/register`.
- [ ] Di `PresensiCameraScreen.dart`:
  - Gunakan frame lingkaran sempurna, banner status melayang.
  - Auto-jepret saat wajah stabil $\rightarrow$ Kirim file foto + GPS via FormData ke `/attendance/check-in-cam` atau `/journals/{id}/check-in-cam`.
  - Tangani pesan error presisi dari backend.

---

### STEP 4: Pengujian Menyeluruh
- [ ] Test KTP $\rightarrow$ Terbukti ditolak oleh Anti-Spoofing.
- [ ] Test Wajah Orang Lain (Ibu/Teman) $\rightarrow$ Terbukti ditolak oleh ArcFace (similarity rendah).
- [ ] Test Wajah Asli Pemilik Akun $\rightarrow$ Berhasil lolos presensi dalam < 1 detik.
