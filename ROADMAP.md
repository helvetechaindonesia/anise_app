# 🗺️ Anise App - Engineering Roadmap & Todo
**Versi Target:** MVP 1.A (Efisiensi, Skalabilitas, dan Stabilitas)
**Mulai Dikerjakan:** Kamis, 01/10/2026

Dokumen ini adalah kompas utama pengembangan dan refaktor aplikasi Anise agar efisien, tangguh, dan berskala tinggi (Enterprise-ready). Tujuan utama iterasi ini adalah menyelesaikan **MVP 1.A** sebelum beralih ke penambahan fitur raksasa lainnya.

---

## 🥇 Fase 1: Scrapping Database dan Pemetaan Pemrosesan Data
*Fokus: Memastikan seluruh data dan jalur komunikasi (API/State) lengkap, efisien, dan memiliki standar yang baku.*

- [x] **1a.** Menambahkan seluruh database yang belum tersedia.
- [x] **1b.** Menambahkan seluruh endpoint (dan/atau menyimpan beberapa endpoint yang untuk next plan) yang belum tersedia.
- [ ] **1c.** Menambahkan seluruh *Repositories* (Helper pembantu/Tukang ngambil bahan).
- [ ] **1d.** Menambahkan seluruh *Services* (Chef / Logika Bisnis).
- [ ] **1e.** Menambahkan seluruh *Resources* (Tukang Plating / DTO / Platter).
- [ ] **1f.** Menambahkan seluruh *Unit Tests* (QC / Quality Control).
- [ ] **1g.** Menambahkan seluruh state (frontend) yang belum tersedia.
- [ ] **1h.** Merapihkan dan memindah-mindahkan seluruh pemetaan database berdasarkan efisiensi dan skalabilitas (membuat framework database), serta memberinya nama yang jelas & terstandarisasi.
- [ ] **1i.** Merapihkan dan memindah-mindahkan seluruh pemetaan API endpoint dan state berdasarkan efisiensi dan skalabilitas, serta memberinya nama yang jelas & terstandarisasi.

---

## 🥈 Fase 2: Refactor Internal (Kerangka dan Rangkaian)
*Fokus: Membangun arsitektur file dan folder yang rapi agar pengembangan fitur ke depan tidak berantakan.*

- [ ] **2a.** Membuat dasar kerangka pemetaan folder dan file berdasarkan efisiensi dan skalabilitas.
- [ ] **2b.** Me-refactor seluruh file berdasarkan fungsi dan ekosistem berdasarkan efisiensi dan skalabilitas.
- [ ] **2c.** Menghapus seluruh folder, file, dan cache yang tidak digunakan.
- [ ] **2d.** Memindahkan dan merapihkan seluruh file sesuai kerangka yang telah dibuat.

---

## 🥉 Fase 3: Standarisasi dan Pembuatan Panduan UI
*Fokus: Kosmetik, Design System, dan Performa Layar.*

- [ ] **3a.** *(Akan dibahas dan didetailkan nanti setelah Fase 1 & 2 selesai)* 🤫

---

## 📌 Catatan Penting (Golden Rules)
- **Dokumentasi Kerangka Produksi:** Setiap kali kita membuat atau merombak kerangka (*framework* folder/arsitektur), **WAJIB** ada file fondasi panduan (dokumentasi penuh) yang menyertainya. Pola-pola produksi harus dituliskan secara jelas agar programmer/tim yang baru masuk bisa langsung paham tanpa tersesat.
- **Ritme Git Push:** Proses `git push` (lempar kode ke GitHub) HANYA dilakukan setiap kali satu sub-poin selesai (misal: selesai 1a, baru push). Ini bertujuan agar log GitHub tetap rapi, punya *checkpoint* yang jelas, dan tidak *spamming* push untuk perubahan kecil.

---

## 🗂️ Daftar Pemetaan Modul (Fase 1)
Berikut adalah daftar modul yang dibedah dalam Fase 1 (Scrapping Database):
- **Kuartal 1:** Modul 1 (User & Auth), Modul 2 (Presensi), Modul 3 (Perizinan).
- **Kuartal 2:** Modul 4 (Jurnal), Modul 5 (Tugas), Modul 6 (Raport).
- **Kuartal 3:** Modul 7 (Gerakan 7 KAIH), Modul 8 (Helpdesk/Pengaduan), Modul 9 (Disiplin).
- **Kuartal 4:** Modul 10 (BK), Modul 11 (Surat Menyurat), Modul 12 (Sarpras).
- **Kuartal 5:** Modul 13 (Kurikulum), Modul 14 (User UI/UX), Modul 15 (Manajemen Sekolah).
- **Kuartal 6:** Modul 16 (Humas), Modul 17A (KPI Tendik), Modul 17B (Poin Siswa)*, Modul 18 (Notifikasi).
- **Kuartal 7:** Modul 19 (Privacy & Legal), Modul 20 (Bantuan & Keamanan), Modul 21 (Dev Mode).

*\*Catatan Modul 17B: Data dan tabelnya akan diisi/disusun sambil jalan saat masuk fase API.*

