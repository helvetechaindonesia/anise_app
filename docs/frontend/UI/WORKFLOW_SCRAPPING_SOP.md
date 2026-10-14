# 🔄 Alur Kerja Scrapping & Standarisasi UI-Backend (SOP Frontend Anise)
**Standar Kolaborasi Interaktif: User-Directed Deep Scrapping & Alignment**  
*Lokasi: `docs/frontend/UI/WORKFLOW_SCRAPPING_SOP.md`*  
*Terakhir Diperbarui: 14 Oktober 2026*

---

## 🎯 1. Filosofi & Esensi Alur Kerja
Alur kerja ini dirancang agar pengembangan frontend tidak lagi meraba-raba atau membuat asumsi sepihak. Setiap halaman disisir secara kolaboratif bersama User:
1. **User mengarahkan fokus halaman** (misal: "Home Siswa", "Tugas Screen", "Presensi Screen", dll).
2. **AI melakukan 4 lapis audit menyeluruh sekaligus:**
   - 🎨 **Audit UI & Standarisasi Komponen:** Cek kepatuhan elemen terhadap Design Tokens & Shared Component Kit.
   - 🔌 **Audit Integrasi API / Backend Lookup:** Cek apakah fitur sudah memanggil endpoint Laravel yang tepat.
   - 📦 **Audit Partisi Storage & Berkas:** (Jika ada upload/download berkas) Pastikan jalur penyimpanan mematuhi *Master Blueprint Storage* (`docs/backend/storage_partitioning_guide.md`), bukan menaruh file acak/flat.
   - 📝 **Audit Backend Notes & Gaps:** Tarik catatan teknis dari backend (jika ada controller/service yang belum terhubung atau butuh payload khusus).
3. **Penyajian Laporan Terstruktur** kepada User untuk disepakati sebelum dieksekusi.

---

## 📋 2. Template Laporan Audit Tiap Halaman (Format Baku)
Setiap kali User memberikan instruksi penelusuran (misal: *"Brok, scrapping halaman X"*), AI wajib menyajikan output dengan struktur 5 bagian berikut:

```markdown
### 📍 [Nama Halaman / Screen Target]

#### 1. 🗂️ Daftar Fitur yang Ditemukan di Halaman Ini
- Fitur A: [Penjelasan singkat & widget yang menangani]
- Fitur B: [Penjelasan singkat & widget yang menangani]

#### 2. 🎨 Aspek UI yang Perlu Distandarisasi
- Komponen X ➔ Belum memakai token/komponen baku (Rekomendasi: ganti ke `AniseCard` / `PillButton` / dll).
- Spacing & Layout ➔ Jarak vertikal tidak seragam / teks meluber.

#### 3. 🔌 Jalur Komunikasi Backend (API Endpoint Alignment)
| Fitur | Status Sambungan | Endpoint Backend Laravel | Service / Repository Backend |
| :--- | :---: | :--- | :--- |
| Fitur A | 🟢 Terhubung | `GET /api/v1/...` | `AttendanceService` |
| Fitur B | 🟡 Dummy Data | `POST /api/v1/...` | `AssignmentService` |
| Fitur C | 🔴 Belum Ada Endpoint | *(Perlu dibuatkan route / controller baru)* | - |

#### 4. 📦 Partisi Storage & Berkas (Jika Ada Fitur Unggah/Unduh Berkas)
- Tipe Berkas: [Lampiran / Jawaban Tugas / Bukti Surat / Avatar]
- Master Partisi Direktori: `storage/app/public/...` (Sesuai `storage_partitioning_guide.md`)
- Helper Penyimpanan: `FileStorageService::store...()`

#### 5. 📝 Catatan Teknis & Rekomendasi Eksekusi
- Payload khusus atau header authorization yang dibutuhkan.
- Rekomendasi perbaikan bertahap untuk disetujui User.
```

---

## 🚀 3. Siklus Eksekusi (The 4-Step Loop)
```text
[ 1. User Direct Halaman Target ]
              │
              ▼
[ 2. AI Deep Scrapping (UI + API + Storage + Backend Notes) ]
              │
              ▼
[ 3. Diskusi & Kesepakatan Bareng User ]
              │
              ▼
[ 4. Refactor & Sambungkan ke Backend ➔ Validasi & Commit ]
```
