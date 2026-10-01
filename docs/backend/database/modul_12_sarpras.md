# Dokumentasi Database: Modul 12 (Sarana Prasarana & Inventaris)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 02 Oktober 2026

Modul ini adalah pusat pencatatan seluruh aset mati milik sekolah, baik yang berupa bangunan fisik maupun barang lepasan. Secara UI, modul ini dirancang untuk dipisah menjadi 2 halaman utama agar *user* (Wakasek Sarpras/Staf TU) tidak kewalahan saat melakukan pencarian data.

---

## 🗄️ 1. Detail Struktur Tabel

Sistem memecah entitas "Sarpras" menjadi 3 tabel terpisah yang saling berelasi:

### A. Tabel `facilities` (Daftar Fasilitas / Bangunan)
Berisi daftar ruangan, bangunan, atau area lapangan. Entitas di tabel ini adalah tempat di mana barang-barang inventaris akan diletakkan.
- `id` (UUID).
- `name` (String): Nama fasilitas (Misal: *Lab Komputer 1*, *Lapangan Basket*, *Kelas 12 IPA*).
- `facility_type` (String): Mengelompokkan jenis fasilitas (`CLASSROOM`, `LAB`, `FIELD`, `TOILET`, `BUILDING`).
- `capacity` (Integer, Nullable): Daya tampung maksimal ruangan.
- `description` (Text, Nullable).

### B. Tabel `inventory_categories` (Kategori Barang)
Agar barang-barang mudah disaring (*filter*) saat direkapitulasi.
- `id` (UUID).
- `name` (String): Misal: *Elektronik*, *Mebel/Furnitur*, *Alat Olahraga*, *Alat Kebersihan*.
- `description` (Text, Nullable).

### C. Tabel `inventory_items` (Buku Induk Inventaris / Barang)
Tabel ini khusus mencatat benda-benda atau aset bergerak milik sekolah.
- `id` (UUID).
- `facility_id` (FK ke `facilities`, Nullable): Menandakan lokasi barang saat ini (Barang ini lagi ditaruh di ruangan mana?).
- `category_id` (FK ke `inventory_categories`, Nullable).
- `item_code` (String, *Unique*): Nomor Seri atau Barcode dari barang tersebut (Misal: `INV-26-001`).
- `name` (String): Nama spesifik barang (Misal: *Proyektor Epson X-11*, *Meja Guru Jati*).
- `quantity` (Integer): Jumlah stok barang.
- `condition` (String): Status kelayakan barang (`GOOD`, `FAIR`, `BROKEN`).
- `purchase_date` (Date, Nullable): Tanggal pembelian (Berfungsi jika ke depan sistem ingin mengembangkan fitur kalkulasi depresiasi/penyusutan aset).

---

## 🚦 2. Catatan Arsitektur UI/UX (Pemisahan Halaman)

Mengingat volume data inventaris bisa mencapai ribuan *item*, *Frontend* **WAJIB** memisahkan Modul 12 menjadi 2 sub-menu/halaman utama:

### 1. Halaman "Fasilitas"
- Halaman ini hanya menampilkan data dari tabel `facilities` (Daftar Ruangan).
- **Integrasi dengan Modul 8 (Helpdesk):** Di halaman ini, *Frontend* wajib menyediakan satu *Tab/Sub-menu* tambahan yang bertugas menarik data dari API `complaints` (Modul 8) dengan filter khusus `category = FASILITAS`. 
- **Tujuan:** Agar Wakasek Sarpras bisa melihat daftar aduan kerusakan (seperti genteng bocor atau AC mati) langsung dari menu Fasilitas miliknya tanpa harus membuka *dashboard* Kesiswaan.

### 2. Halaman "Inventaris"
- Halaman ini didedikasikan murni untuk CRUD tabel `inventory_items`.
- Fitur pencarian dan filter (berdasarkan Ruangan `facility_id` atau Kategori `category_id`) harus dibuat sekomprehensif mungkin di halaman ini.
