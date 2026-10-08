# 🕵️ Laporan Audit API (Code vs Blueprint)

**Tanggal:** 08 Oktober 2026
**Tujuan:** Membandingkan `routes/api.php` aktual dengan *blueprint* `endpoint.md` (Fase 1b).

---

## 🛑 1. Apa yang ADA di Blueprint, tapi BELUM ADA di Kode (`routes/api.php`)?
Banyak modul dari Kuartal menengah hingga akhir yang *database*-nya sudah siap, tapi API-nya belum pernah kita buat sama sekali:
1. **Modul 6 (Penilaian & Raport):** `/api/assessments` kosong total.
2. **Modul 8 (Helpdesk):** Belum ada *endpoint* khusus, mungkin dulu idenya numpang di `/users/reports`.
3. **Modul 11 (Surat Menyurat):** `/api/letters` kosong total.
4. **Modul 12 (Sarpras):** `/api/inventory` kosong total.
5. **Modul 16 (Humas):** `/api/announcements` kosong total.
6. **Modul 17A & 17B (KPI & Poin):** Belum ada API-nya.
7. **Modul 18 (Notifikasi):** Belum ada API-nya.
8. **Modul 19, 20, 21:** (Privacy, FAQ, Dev Mode) semuanya belum ada.

---

## ⚠️ 2. Apa yang ADA di Kode (`routes/api.php`), tapi BERANTAKAN / Beda dari Blueprint?
Ini adalah utang teknis (*Tech Debt*) yang paling parah dan menjadi target utama **Fase 2 (Refactor Internal)**:

1. **Jalur Master Data "Gado-Gado" (`/master/*`):**
   - Di *blueprint*, data harusnya dipisah rapi (Misal jadwal ke `/api/curriculum`, user ke `/api/users`). 
   - Tapi di *code*, semuanya numpuk di `MasterDataController` dengan rute `/master/kelas`, `/master/mapel`, `/master/users`, dll. Ini bikin file *controller* jadi bengkak dan susah di- *maintain*.
2. **Rute Numpang di `/users/*`:**
   - Izin/cuti ditaruh di `/users/leaves` (Harusnya di `/api/leaves`).
   - Disiplin ditaruh di `/users/disiplin-reports` (Harusnya di `/api/discipline`).
3. **Rute Fitur Spesifik (Tidak Ada di Blueprint):**
   - **Parser Excel (`/parse/*`):** Rute ini sangat banyak di kode untuk upload Excel, tapi tidak dimasukkan di *blueprint*. (Perlu kita sepakati apakah rute parser ini dipertahankan, atau digabung ke rute POST biasa).
   - **Upload File (`/auth/files/upload`):** Ada rute untuk upload file secara general, tapi ditaruh di dalam *group* `/auth`. Ini salah kamar.
   - **G7 KAIH:** Di kode pakai *prefix* `/habits`, tapi di *blueprint* direncakan pakai `/api/g7kaih`.

---

## 🎯 3. Kesimpulan & Rekomendasi
*Routing* di `routes/api.php` saat ini masih mencerminkan pola "Asal Jalan Dulu" (*Quick & Dirty*). Hal ini sangat wajar di awal *development*.

**Tindakan Lanjutan (Fase 2):**
Sesuai *Roadmap*, di **Fase 2b dan 2d** nanti, kita wajib membongkar `routes/api.php` ini dan memotong-motong `MasterDataController` menjadi belasan *Controller* kecil sesuai dengan cetak biru di `endpoint.md` agar memenuhi standar skala *Enterprise*.
