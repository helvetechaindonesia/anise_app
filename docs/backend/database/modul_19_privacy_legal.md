# Dokumentasi Database & API: Modul 19 (Privacy & Legal)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 08 Oktober 2026

Modul ini bertanggung jawab untuk menyimpan dan melacak seluruh dokumen hukum yang mengikat pengguna aplikasi Anise (seperti Syarat & Ketentuan serta Kebijakan Privasi).

---

## 🗄️ 1. Struktur Database

Pendekatan *Key-Value* yang sebelumnya digunakan tidak cukup "serius" untuk dokumen berbadan hukum. Oleh karena itu, kita membuat tabel khusus yang mendukung **Versioning** (Pelacakan Versi).

### Tabel `legal_documents`
- `id` (UUID)
- `document_type` (Enum): `PRIVACY_POLICY`, `TERMS_OF_SERVICE`, `DATA_RETENTION_POLICY`.
- `version_number` (String): (Misal: `v1.0.0`, `v1.1.0`). Penting jika ada perubahan hukum, kita punya arsip versi lama.
- `content` (Text): Isi dokumen (Bisa *Markdown* atau HTML).
- `is_active` (Boolean): Menandakan dokumen ini adalah versi yang sedang berlaku.
- `published_by` (FK `users`): Admin/Pihak sekolah yang merilis dokumen.
- `published_at` (Timestamp)

---

## 🚀 2. Rencana API & Logic

1. **`GET /api/legal/{type}`**
   - API publik (Bisa diakses tanpa *Login*). *Endpoint* ini otomatis mencari baris data di mana `document_type` cocok dan `is_active = true`.
2. **Versioning Logic (Force Consent):**
   - Di iterasi berikutnya, jika Admin merilis versi baru (`v1.2.0`), sistem akan menandai versi lama menjadi `is_active = false`. 
   - Aplikasi akan mendeteksi perubahan versi ini dan memaksa *user* untuk menekan tombol **"Saya Setuju"** kembali saat mereka membuka aplikasi.
