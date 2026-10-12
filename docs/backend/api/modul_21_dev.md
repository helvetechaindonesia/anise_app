## 👨‍💻 Modul 21: Developer Mode & Info
*Prefix:* `/api/dev`
- `GET /contact`: *(Publik)* Mengambil informasi kontak resmi developer (Nama, Email, WhatsApp Phone, WhatsApp Direct Link).
- `GET /logs`: *(Middleware: Super Admin)* *Streaming/Read* file `laravel.log`.
- `POST /cache/clear`: *(Middleware: Super Admin)* *Bypass command* Artisan *optimize*.
- `POST /impersonate/{user_id}`: *(Middleware: Super Admin)* Meretas masuk (*Login*) sebagai *user* lain untuk *debugging*.

### Detail: `GET /api/dev/contact`
*Akses:* Publik (Dapat diakses tanpa token untuk Helpdesk sebelum login)

**Contoh Response Sukses (200 OK):**
```json
{
  "status": "success",
  "message": "Kontak developer berhasil diambil",
  "data": {
    "name": "Helvetecha Group",
    "email": "Helvetechaindonesia@gmail.com",
    "phone": "081931315944",
    "whatsapp_phone": "6281931315944",
    "whatsapp_url": "https://wa.me/6281931315944?text=Halo%20Tim%20Developer%20Helvetecha%2C%20saya%20butuh%20bantuan%20terkait%20aplikasi%20Anise."
  }
}
```
