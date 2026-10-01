# Dokumentasi Database: Modul 3 (Perizinan & Dispensasi)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 01 Oktober 2026

Dokumen ini membedah struktur *database* untuk Modul 3 yang berfokus pada sistem pengajuan perizinan ketidakhadiran (Cuti, Sakit, Izin, Dispensasi) untuk seluruh warga sekolah. Modul ini dirancang dengan fitur "Anti-Bolos" menggunakan verifikasi biometrik dan koordinat GPS.

---

## 🏗️ 1. Filosofi Sistem Perizinan (Anti-Bolos)

Untuk mencegah penyalahgunaan fitur izin (seperti siswa memalsukan surat sakit padahal sedang nongkrong, atau guru mengaku sakit padahal liburan), sistem perizinan Anise dilengkapi dengan 3 lapis validasi:
1. **Bukti Fisik:** *Upload* dokumen (Surat Dokter, Surat Tugas, Undangan).
2. **Verifikasi Biometrik (Wajah):** Saat mengajukan form, sistem *frontend* akan memaksa kamera terbuka untuk memindai wajah asli (bukan dari galeri).
3. **Verifikasi Geofencing (Lokasi Asli):** Koordinat GPS ditarik secara paksa saat *submit* form pengajuan, sehingga *Approver* (Wali Kelas/Kepala Sekolah) bisa melihat posisi asli pengaju di peta.

*Catatan: Verifikasi biometrik dan GPS diabaikan khusus untuk kategori 'DISPENSASI' (misal siswa dijemput orang tua secara mendadak di sekolah).*

---

## 🗄️ 2. Detail Struktur Tabel

Sistem perizinan dipisah menjadi 2 tabel agar jenis izin (Enum Type) lebih rapi dan spesifik sesuai target (Siswa vs Guru).

### A. Perizinan Siswa

#### Tabel `student_leaves`
Digunakan oleh siswa untuk meminta izin tidak masuk (Sakit/Izin) atau izin keluar di tengah KBM (Dispensasi).
- `id` (UUID).
- `student_id` (FK ke users).
- `type` (String): Terdiri dari `IZIN`, `SAKIT`, atau `DISPENSASI`.
- `reason` (Text): Alasan pengajuan.
- `start_date` & `end_date` (Date): Rentang waktu izin. Jika hanya 1 hari, tanggalnya disamakan.
- `attachment_path` (String, Nullable): *Link URL* ke foto bukti surat izin / surat dokter.
- `status` (String): Siklus *approval* (`PENDING`, `APPROVED`, `REJECTED`).
- `approved_by` (FK ke users): Menyimpan jejak siapa yang menyetujui izin ini (Bisa Wali Kelas, Guru BK, atau Kesiswaan).
- **[Sistem Anti-Bolos]**
  - `face_snapshot_url` (Text, Nullable): *Link URL* foto *selfie* wajib saat menekan tombol "Ajukan Izin".
  - `latitude` & `longitude` (Decimal, Nullable): Titik koordinat GPS *live* dari *smartphone* siswa.

---

### B. Perizinan Pegawai / Tendik

#### Tabel `employee_leaves`
Digunakan oleh seluruh staf pendidik dan tenaga kependidikan. Memiliki struktur identik dengan siswa, namun dengan tipe izin yang disesuaikan untuk kebutuhan instansi/pegawai.
- `id` (UUID).
- `employee_id` (FK ke users).
- `type` (String): Terdiri dari `SAKIT`, `CUTI`, `DINAS_LUAR`, atau `IZIN`.
- `reason` (Text): Alasan pengajuan.
- `start_date` & `end_date` (Date): Rentang waktu izin.
- `attachment_path` (String, Nullable): Dokumen lampiran (Misal: Surat Tugas dari Yayasan / Dinas Pendidikan).
- `status` (String): Siklus *approval* (`PENDING`, `APPROVED`, `REJECTED`).
- `approved_by` (FK ke users): Menyimpan jejak *Approver* (Bisa Kepala Sekolah atau Waka Kurikulum).
- **[Sistem Anti-Bolos]**
  - `face_snapshot_url` (Text, Nullable): Sama seperti siswa.
  - `latitude` & `longitude` (Decimal, Nullable): Sama seperti siswa.

---

## 🔑 Aturan Emas Pengembangan (Modul 3)
1. **Trigger Integrasi Modul 2:** Saat sebuah *record* perizinan (baik di tabel siswa maupun pegawai) berubah status menjadi `APPROVED`, sistem (melalui *Observer/Event Listener* di Laravel) **wajib** memperbarui status pada tabel `attendances` (Modul 2) di rentang tanggal tersebut menjadi status izin/sakit yang sesuai. 
2. **Fleksibilitas Approver:** Kolom `approved_by` sengaja didesain dinamis. Logic siapa yang berhak meng-*approve* dikelola melalui *Gate / Permissions* (Modul 1), bukan dibatasi *hardcode* di *database*.
