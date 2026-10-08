# 👑 Profil The Core: BaseService

**Jabatan:** Dewan Direksi / General Manager
**Lokasi File:** `app/Core/BaseService.php`

## 📝 Deskripsi Tugas
General Manager tim Chef. Pegang SOP logika bisnis dan exception.
Semua kelas di bawah divisi ini WAJIB melakukan `extends` ke class ini. Jika ada perubahan SOP secara massal (misal penambahan fitur *logging* otomatis), ubah di sini!

## 📜 ATURAN EMAS DIVISI CHEF
**SOP ABSOLUT:** Chefs (Services) DILARANG KERAS ngambil bahan baku sendiri! Tidak boleh ada query ke database, Eloquent ORM, atau koneksi ke rak penyimpanan di dalam Service. Chef harus menyuruh Helper (Repository) untuk mengambilkannya.

## 🛠️ Daftar SOP Absolut (Methods)
- `__construct()` : Inisialisasi standar perusahaan.
- *(Tambahkan aturan SOP lain di sini...)*

---
> Catatan HRD: Profil ini digenerate otomatis. Jangan sembarangan mengubah file ini tanpa rapat dewan direksi karena akan berdampak ke seluruh sistem!
