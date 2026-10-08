# Dokumentasi API - Grup 1: Autentikasi & Manajemen Pengguna

## 🔐 Modul 1: Autentikasi & RBAC
**Base URL:** `/api/auth`
**Controller:** `AuthController`

Modul ini mengelola sesi *login*, validasi JWT Token (Sanctum), dan pengambilan profil dasar pengguna.

### 1. Login
- **Endpoint:** `POST /login`
- **Body Request:**
  ```json
  {
    "email": "siswa@sekolah.com",
    "password": "password123"
  }
  ```
- **Response (200 OK):** Mengembalikan `access_token` dan detail dasar *user*.
- **Notes:** Endpoint ini akan menghapus token lama pada *device* sebelumnya (Single Device Login).

### 2. Dapatkan Profil Login
- **Endpoint:** `GET /me`
- **Header:** `Authorization: Bearer {token}`
- **Response (200 OK):** Mengembalikan relasi spesifik. Jika role `GURU`, akan mengembalikan `guruProfile`. Jika `SISWA`, akan mengembalikan `siswaProfile`.

### 3. Update Profil
- **Endpoint:** `PUT /profile`
- **Body Request:** Field dasar (nama, email, alamat).
- **Notes:** Khusus siswa, dapat mengubah nama wali (`parent_name`).

### 4. Logout
- **Endpoint:** `POST /logout`
- **Notes:** Menghapus token dari database (Membunuh sesi).


---

## 👥 Modul 14: Manajemen User & UI/UX
**Base URL:** `/api/users`
**Controller:** `UserController`

Dikhususkan untuk TU (Tata Usaha) dalam mengelola Master Data Pengguna, Role, Jabatan, dan File.

### 1. Ambil Semua User
- **Endpoint:** `GET /`
- **Query Params:** `?role=GURU` (Opsional untuk filter)
- **Middleware:** `role:TATA_USAHA`

### 2. Tambah User Baru
- **Endpoint:** `POST /`
- **Body Request:** `full_name`, `username`, `email`, `role_id`.
- **Notes:** Password secara *default* akan disamakan dengan `username` dan di-*hash*.

### 3. Parse/Import Excel
- **Endpoint:** `POST /parse/{type}`
- **Notes:** Menggunakan `ExcelParserUserController` (Untuk memproses file .xlsx).

### 4. Pencarian Global Siswa
- **Endpoint:** `GET /siswa/search`
- **Query Params:** `?q=nama_siswa`
- **Notes:** Dibutuhkan oleh fitur Jurnal/Penugasan saat guru ingin mencari siswa spesifik.
