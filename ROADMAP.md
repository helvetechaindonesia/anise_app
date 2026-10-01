# 🗺️ Anise App - Engineering Roadmap & Todo
**Versi Target:** MVP 1.A (Efisiensi, Skalabilitas, dan Stabilitas)
**Mulai Dikerjakan:** Kamis, 01/10/2026

Dokumen ini adalah kompas utama pengembangan dan refaktor aplikasi Anise agar efisien, tangguh, dan berskala tinggi (Enterprise-ready). Tujuan utama iterasi ini adalah menyelesaikan **MVP 1.A** sebelum beralih ke penambahan fitur raksasa lainnya.

---

## 🥇 Fase 1: Scrapping Database dan Pemetaan Pemrosesan Data
*Fokus: Memastikan seluruh data dan jalur komunikasi (API/State) lengkap, efisien, dan memiliki standar yang baku.*

- [ ] **1a.** Menambahkan seluruh database yang belum tersedia.
- [ ] **1b.** Menambahkan seluruh endpoint (dan/atau menyimpan beberapa endpoint yang untuk next plan) yang belum tersedia.
- [ ] **1c.** Menambahkan seluruh state (frontend) yang belum tersedia.
- [ ] **1d.** Merapihkan dan memindah-mindahkan seluruh pemetaan database berdasarkan efisiensi dan skalabilitas (membuat framework database), serta memberinya nama yang jelas & terstandarisasi.
- [ ] **1e.** Merapihkan dan memindah-mindahkan seluruh pemetaan API endpoint dan state berdasarkan efisiensi dan skalabilitas, serta memberinya nama yang jelas & terstandarisasi.

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

