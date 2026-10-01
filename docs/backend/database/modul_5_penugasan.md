# Dokumentasi Database: Modul 5 (Penugasan Harian & Evaluasi)

**Status:** Finalized (MVP 1.A)
**Terakhir Diperbarui:** 01 Oktober 2026

Modul 5 didesain untuk menangani **Micro-Assignments** (Tugas Harian) yang melekat secara langsung pada Jurnal KBM di Modul 4. 

*Catatan: Segala jenis ujian skala besar (seperti Ulangan Harian, UTS, dan UAS) telah dipisahkan dari modul ini dan akan dibahas pada Modul Agenda Penilaian.*

---

## 🏗️ 1. Filosofi Penugasan (Micro-Assignments)

Konsep penugasan harian di Anise sangat praktis:
1. Saat guru merilis Jurnal Harian (Modul 4) dan mencentang `has_task = True`, maka sebuah "Cangkang Tugas" akan terbentuk di Modul 5 ini.
2. Tugas tidak selalu berbentuk *file* dokumen rumit. Seringkali guru hanya memotret soal LKS/Papan Tulis, lalu menyuruh siswa mengerjakan dari foto tersebut. Oleh karena itu, *field* lampiran menggunakan `attachment_url` agar dapat menangani gambar maupun dokumen.
3. Siswa dapat mengumpulkan tugas dalam 2 opsi:
   - **Teks Langsung:** Mengetik jawaban/esai singkat di aplikasi (`answer_text`).
   - **Upload File/Foto:** Memotret hasil coretan di buku tulis (`attachment_url`).

---

## 🗄️ 2. Detail Struktur Tabel

Modul ini sangat padat dan ringkas, terdiri dari 4 tabel utama yang terhubung erat.

### A. Sisi Guru (Pembuat Tugas)

#### 1. Tabel `journal_tasks` (Instruksi Tugas)
Tempat guru mendeskripsikan soal atau instruksi yang harus dikerjakan siswa.
- `id` (UUID).
- `journal_id` (FK ke journals): Menyambungkan tugas dengan materi KBM hari itu.
- `title` (String): Judul tugas (Misal: "Tugas Hal. 14").
- `description` (Text, Nullable): Perintah/Instruksi rinci.
- `due_date` (Timestamp): Tenggat waktu pengumpulan (Misal: Hari ini jam 23:59).

#### 2. Tabel `journal_task_attachments` (Lampiran Soal)
Tempat menyimpan foto buram soal dari papan tulis 😂 atau *file* PDF.
- `id` (UUID).
- `journal_task_id` (FK ke journal_tasks).
- `attachment_name` (String): Nama *file/foto*.
- `attachment_url` (Text): Tautan fisik ke penyimpanan *cloud/local*.

---

### B. Sisi Siswa (Pengumpulan & Penilaian)

#### 3. Tabel `student_task_submissions` (Pengumpulan Jawaban)
Wadah penderitaan siswa (tempat ngumpulin PR).
- `id` (UUID).
- `journal_task_id` (FK ke journal_tasks): Tugas mana yang dikerjakan.
- `student_id` (FK ke users): Siapa yang mengumpulkan.
- `status` (Enum/String): `PENDING` atau `SUBMITTED`.
- `answer_text` (Text, Nullable): Jawaban tertulis jika siswa disuruh ngetik langsung.
- `attachment_url` (Text, Nullable): Foto hasil coretan buku tulis siswa.
- `submitted_at` (Timestamp): Waktu pasti siswa menekan tombol kumpul (Guna mencegah protes siswa yang ngaku udah ngumpulin tepat waktu wkwk).

#### 4. Tabel `student_task_grades` (Pemberian Nilai)
Hasil akhir jerih payah siswa.
- `id` (UUID).
- `submission_id` (FK ke student_task_submissions): Jawaban yang mana yang dinilai.
- `teacher_id` (FK ke users): Guru siapa yang mengoreksi.
- `score` (Decimal, 5,2): Nilai angka (Misal: 85.50).

---

## 🔑 Aturan Emas Pengembangan (Modul 5)
1. **Validasi Keterlambatan:** Di level *Backend*, wajib hukumnya mengecek `submitted_at` dengan `due_date` pada tabel `journal_tasks`. Jika telat, sistem boleh tetap menerima jawaban dengan status tambahan `LATE_SUBMITTED` atau dikunci sama sekali (tergantung *setting* guru).
2. **Fleksibilitas Pengumpulan:** API Pengumpulan Tugas tidak boleh me-*require* (mewajibkan) kedua *field* pengumpulan. Siswa boleh hanya mengisi `answer_text`, atau hanya mengunggah `attachment_url`, asalkan salah satu terisi.
