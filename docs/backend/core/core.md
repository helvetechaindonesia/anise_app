# 👑 Blueprint The Core (Manajer Dapur & SOP Master)

**Status:** Open Hiring (Draft Blueprint)
**Lokasi Aktual Nanti:** `app/Core/`

Sesuai kerangka *Layered Architecture by Clean Conditions*, dokumen ini adalah cetak biru untuk **The Core**.
Merekalah para Jenderal/Manajer Dapur. Jika ada perubahan SOP massal (misalnya format *error handling*, format *response*, atau cara *query* ke database), cukup ubah di sini, dan ratusan karyawan di bawahnya akan otomatis tunduk.

Berikut adalah jajaran dewan direksi (The Core) yang mengatur tiap divisi:

- **`BaseRepository`** -> General Manager untuk divisi Helper. Mengatur SOP standar *query*, *caching*, dan *error handling database*.
- **`BaseService`** -> General Manager untuk divisi Chef. Mengatur SOP standar pengolahan logika bisnis, *throw exception*, dan *logging*.
- **`BaseResource`** -> General Manager untuk divisi Platter. Mengatur SOP standar bentuk piring JSON, pagination, dan *meta data*.
- **`BaseController`** -> General Manager untuk divisi Waiter (API). Mengatur SOP cara merespon tamu (200 OK, 404 Not Found, 500 Error).

---

## 📜 3 ATURAN EMAS (SOP ABSOLUT) DAPUR HELVETECHA
SOP ini **HARAM** dilanggar oleh seluruh karyawan dapur:

1. **Waiters (Controllers) DILARANG KERAS** menyajikan piring (Response JSON) selain dari hasil *plating* piring **"Resources"** yang telah lolos QC **"Tests"**. (Waiters tidak boleh membuat format JSON sendiri).
2. **Helpers (Repositories) DILARANG KERAS ikut masak!** (Tidak boleh ada logika bisnis, *if/else* rumit, atau manipulasi data di dalam Repository. Helper murni hanya kurir pembawa bahan baku dari Database/Rak).
3. **Chefs (Services) DILARANG KERAS ngambil bahan baku sendiri!** (Tidak boleh ada *query* ke *database*, *Eloquent ORM*, atau koneksi ke rak penyimpanan di dalam Service. Chef harus menyuruh Helper untuk mengambilkannya).
