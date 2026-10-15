# 🗓️ Dokumentasi API: Modul 13 (Kurikulum & Master Data)

**Prefix:** `/api/curriculum`  
**Middleware:** `auth:sanctum`, `check.session`, `role:TATA_USAHA`  
*Terakhir Diperbarui: 15 Oktober 2026*

---

## 🏛️ 1. Kelas & Wali Kelas (`/classes`)
* `GET /classes`: Mengambil seluruh daftar rombel/kelas beserta `waliKelas`, `major`, dan `academicYear`.
* `POST /classes`: Membuat kelas baru (nama, tingkat 10/11/12, major_id, academic_year_id).
* `PUT /classes/{id}`: Memperbarui nama/tingkat kelas.
* `PUT /classes/{id}/wali-kelas`: Menetapkan / mengubah guru wali kelas (`wali_kelas_id`).
* `DELETE /classes/{id}`: Menghapus kelas.

---

## 👥 2. Guru Wali & Siswa Asuh (`/guru-wali`)
* `GET /guru-wali`: Mengambil seluruh daftar pemetaan siswa asuh dengan guru wali / guru BK (`guru_wali_students`).
* `POST /guru-wali`: Menetapkan siswa asuh ke guru wali (`guru_id`, `student_id`, `academic_year_id`).
* `DELETE /guru-wali/{id}`: Menghapus penugasan guru wali pada siswa.

---

## 📚 3. Mata Pelajaran (`/subjects`)
* `GET /subjects`: Mengambil seluruh katalog mata pelajaran.
* `POST /subjects`: Menambahkan mata pelajaran baru (`name`, `code`).
* `PUT /subjects/{id}`: Memperbarui nama dan kode mapel.
* `DELETE /subjects/{id}`: Menghapus mata pelajaran.

---

## 📅 4. Jadwal KBM (`/schedules`)
* `GET /schedules`: Mengambil seluruh jadwal pelajaran mingguan terurut hari dan jam mulai.
* `POST /schedules`: Membuat jadwal baru (`class_id`, `subject_id`, `teacher_id`, `day_of_week`, `start_time`, `end_time`, `activity_name`).
* `PUT /schedules/{id}`: Memperbarui detail jadwal pelajaran.
* `DELETE /schedules/{id}`: Menghapus jadwal pelajaran.

---

## 💼 5. Penugasan Struktural (`/assignments`)
* `GET /assignments`: Mengambil daftar tugas tambahan guru (Wakasek, Pembina, dll).
* `POST /assignments`: Menetapkan tugas tambahan (`guru_id`, `jabatan_id`, `academic_year_id`).
* `DELETE /assignments/{id}`: Menghapus penugasan tambahan.

---

## 🗓️ 6. Kalender Akademik (`/academic-calendars`)
* `GET /academic-calendars`: Mengambil daftar agenda kalender pendidikan tahun ajaran (PTS, PAS, MPLS, Porseni).
  * *Query Params:* `?year=2026`
* `POST /academic-calendars`: Menambahkan agenda kalender (`name`, `start_date`, `end_date`, `is_holiday`, `academic_year_id`).
* `PUT /academic-calendars/{id}`: Memperbarui agenda kalender.
* `DELETE /academic-calendars/{id}`: Menghapus agenda kalender.

---

## 🏖️ 7. Hari Libur Nasional & Sekolah (`/holidays`)
* `GET /holidays`: Mengambil daftar hari libur sekolah dan nasional.
  * *Query Params:* `?year=2026`, `?type=NASIONAL`, `?is_active=true`
* `POST /holidays`: Menambahkan hari libur baru (`name`, `start_date`, `end_date`, `type`, `description`, `is_active`).
* `GET /holidays/{id}`: Detail hari libur.
* `PUT /holidays/{id}`: Memperbarui hari libur.
* `DELETE /holidays/{id}`: Menghapus hari libur.
* `GET /holidays-check?date=YYYY-MM-DD`: Mengecek apakah suatu tanggal adalah hari libur (rutin mingguan maupun kalender).

---

## 📥 8. Sinkronisasi Massal Excel (`/parse/{type}`)
* `POST /parse/{type}`: Mengunggah file Excel (`.xlsx`, `.xls`) dengan multipart form data `file`.
* *Tipe Valid:*
  1. `wali_kelas`: Sinkronisasi wali kelas dari sheet rombel.
  2. `guru_wali`: Sinkronisasi siswa asuh & kelas siswa.
  3. `penugasan`: Sinkronisasi jabatan & tugas tambahan pendidik.
  4. `mapel`: Sinkronisasi katalog mata pelajaran.
  5. `jurnal_mengajar`: Sinkronisasi jadwal KBM mingguan.
  6. `kalender_akademik`: Sinkronisasi agenda kalender pendidikan.
  7. `hari_libur`: Sinkronisasi hari libur nasional dan sekolah.
