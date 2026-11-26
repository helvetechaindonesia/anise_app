<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ComprehensiveDatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Mengisi semua tabel yang masih kosong dengan data realistis,
     * sambil MEMPERTAHANKAN tabel `roles` dan `developers`.
     */
    public function run(): void
    {
        // 1. Ambil Data Acuan Inti (Siswa, Guru, Mapel, Kelas, dsb)
        $siswa = DB::table('users')->where('email', 'siswa@sipena.sch.id')->first()
            ?? DB::table('users')->where('role_id', DB::table('roles')->where('name', 'SISWA')->value('id'))->first();

        $guru = DB::table('users')->where('role_id', DB::table('roles')->where('name', 'GURU')->value('id'))->first()
            ?? DB::table('users')->first();

        $guruBk = DB::table('users')->where('role_id', DB::table('roles')->where('name', 'GURU_BK')->value('id'))->first()
            ?? $guru;

        $tu = DB::table('users')->where('username', 'tu_dev')->first()
            ?? $guru;

        $academicYear = DB::table('academic_years')->where('is_active', true)->first()
            ?? DB::table('academic_years')->first();

        $class = DB::table('classes')->first();
        $subject = DB::table('subjects')->first();
        $journal = DB::table('journals')->first();
        $journalTask = DB::table('journal_tasks')->first();

        $userId = $siswa ? $siswa->id : ($guru ? $guru->id : (string) Str::uuid());
        $guruId = $guru ? $guru->id : $userId;
        $guruBkId = $guruBk ? $guruBk->id : $guruId;
        $classId = $class ? $class->id : 1;
        $subjectId = $subject ? $subject->id : 1;
        $academicYearId = $academicYear ? $academicYear->id : 1;

        // ==========================================
        // 2. G7-KAIH: HABITS & VERIFIKASI & LOG
        // ==========================================
        $defaultHabits = [
            ['code' => 'HBT01', 'title' => 'Bangun Pagi', 'category' => 'KEDISIPLINAN', 'description' => 'Bangun sebelum subuh atau pukul 05:00 WIB'],
            ['code' => 'HBT02', 'title' => 'Beribadah Tepat Waktu', 'category' => 'IBADAH', 'description' => 'Melaksanakan salat/doa tepat waktu'],
            ['code' => 'HBT03', 'title' => 'Berolahraga Teratur', 'category' => 'KESEHATAN', 'description' => 'Melakukan pemanasan, jalan santai atau lari'],
            ['code' => 'HBT04', 'title' => 'Makan Sehat & Bergizi', 'category' => 'KESEHATAN', 'description' => 'Konsumsi sayur, buah dan air mineral cukup'],
            ['code' => 'HBT05', 'title' => 'Gemar Membaca & Belajar', 'category' => 'AKADEMIK', 'description' => 'Membaca buku atau mengulang materi min 30 menit'],
            ['code' => 'HBT06', 'title' => 'Bermasyarakat & Peduli', 'category' => 'SOSIAL', 'description' => 'Membantu orang tua, rekan, atau kerja bakti'],
            ['code' => 'HBT07', 'title' => 'Tidur Tepat Waktu', 'category' => 'KEDISIPLINAN', 'description' => 'Istirahat malam sebelum pukul 22:00 WIB'],
        ];

        foreach ($defaultHabits as $h) {
            DB::table('habits')->updateOrInsert(
                ['code' => $h['code']],
                [
                    'title' => $h['title'],
                    'category' => $h['category'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }

        $habit1 = DB::table('habits')->first();
        if ($habit1 && DB::table('user_habit_logs')->count() === 0) {
            DB::table('user_habit_logs')->insert([
                [
                    'user_id' => $userId,
                    'habit_id' => $habit1->id,
                    'date' => now()->toDateString(),
                    'is_completed' => true,
                    'notes' => 'Alhamdulillah bangun jam 04:30 WIB tepat waktu.',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }

        if (DB::table('user_prayer_logs')->count() === 0) {
            DB::table('user_prayer_logs')->insert([
                [
                    'user_id' => $userId,
                    'date' => now()->toDateString(),
                    'subuh' => true,
                    'dzuhur' => true,
                    'ashar' => true,
                    'maghrib' => true,
                    'isya' => true,
                    'dhuha' => true,
                    'tahajud' => false,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            ]);
        }

        // ==========================================
        // 3. BIMBINGAN KONSELING (BK) & GURU WALI
        // ==========================================
        if (DB::table('guru_wali_students')->count() === 0 && $guruId && $userId) {
            DB::table('guru_wali_students')->insert([
                'guru_id' => $guruId,
                'student_id' => $userId,
                'academic_year_id' => $academicYearId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if (DB::table('guru_bk_classes')->count() === 0 && $guruBkId) {
            DB::table('guru_bk_classes')->insert([
                'guru_id' => $guruBkId,
                'class_id' => $classId,
                'academic_year_id' => $academicYearId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if (DB::table('counseling_requests')->count() === 0 && $userId && $guruBkId) {
            $reqId = DB::table('counseling_requests')->insertGetId([
                'student_id' => $userId,
                'counselor_id' => $guruBkId,
                'title' => 'Konsultasi Perencanaan Studi & Penjurusan Kuliah',
                'description' => 'Ingin berkonsultasi mengenai pemilihan prodi saintek vs teknik.',
                'status' => 'APPROVED',
                'scheduled_at' => now()->addDays(2)->setTime(10, 0, 0),
                'session_notes' => 'Siswa memiliki potensi kuat di bidang komputasi dan matematika.',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('counseling_comments')->insert([
                'counseling_request_id' => $reqId,
                'user_id' => $guruBkId,
                'comment' => 'Bagus sekali Andi, silakan datang ke ruang BK hari lusa jam 10 ya.',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('counseling_likes')->insert([
                'counseling_request_id' => $reqId,
                'user_id' => $userId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // ==========================================
        // 4. PENILAIAN, TUGAS, & ULASAN JURNAL
        // ==========================================
        if (DB::table('assessments')->count() === 0) {
            $assessmentId = DB::table('assessments')->insertGetId([
                'class_id' => $classId,
                'subject_id' => $subjectId,
                'teacher_id' => $guruId,
                'academic_year_id' => $academicYearId,
                'title' => 'Sumatif Akhir Bab 1: Persamaan Linier & Matriks',
                'type' => 'SUMATIF',
                'max_score' => 100,
                'weight' => 20,
                'date' => now()->subDays(3)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('assessment_grades')->insert([
                'assessment_id' => $assessmentId,
                'student_id' => $userId,
                'score' => 92.50,
                'notes' => 'Penguasaan konsep matriks sangat baik.',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if ($journal && DB::table('journal_reviews')->count() === 0) {
            DB::table('journal_reviews')->insert([
                'journal_id' => $journal->id,
                'student_id' => $userId,
                'rating' => 5,
                'review_text' => 'Penyampaian materi sangat interaktif dan mudah dipahami.',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if ($journal && DB::table('journal_comments')->count() === 0) {
            DB::table('journal_comments')->insert([
                'journal_id' => $journal->id,
                'user_id' => $userId,
                'comment' => 'Pak, untuk slide halaman 15 rumus determinannya sangat membantu, terima kasih!',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if ($journal && DB::table('journal_interactions')->count() === 0) {
            DB::table('journal_interactions')->insert([
                'journal_id' => $journal->id,
                'user_id' => $userId,
                'type' => 'LIKE',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if ($journal && DB::table('journal_student_records')->count() === 0) {
            DB::table('journal_student_records')->insert([
                'journal_id' => $journal->id,
                'student_id' => $userId,
                'status' => 'HADIR',
                'notes' => 'Siswa sangat aktif bertanya saat sesi diskusi.',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if ($journalTask && DB::table('journal_task_attachments')->count() === 0) {
            DB::table('journal_task_attachments')->insert([
                'journal_task_id' => $journalTask->id,
                'file_name' => 'Lembar_Kerja_Matematika_01.pdf',
                'file_path' => 'tasks/attachments/sample_task.pdf',
                'file_size' => 1024500,
                'file_type' => 'application/pdf',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if ($journalTask && DB::table('student_task_submissions')->count() === 0) {
            $subId = DB::table('student_task_submissions')->insertGetId([
                'journal_task_id' => $journalTask->id,
                'student_id' => $userId,
                'submitted_at' => now()->subDay(),
                'file_path' => 'submissions/andi_tugas_01.pdf',
                'notes' => 'Sudah selesai dikerjakan sesuai petunjuk soal.',
                'status' => 'SUBMITTED',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('student_task_grades')->insert([
                'task_submission_id' => $subId,
                'graded_by' => $guruId,
                'score' => 95.00,
                'feedback' => 'Pengerjaan runtut dan sistematis. Pertahankan!',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if ($journalTask && DB::table('task_late_submission_requests')->count() === 0) {
            DB::table('task_late_submission_requests')->insert([
                'task_id' => $journalTask->id,
                'student_id' => $userId,
                'reason' => 'Mengikuti perlombaan olimpiade sains mewakili sekolah.',
                'status' => 'APPROVED',
                'approved_by' => $guruId,
                'extension_until' => now()->addDays(2),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // ==========================================
        // 5. POIN, TATA TERTIB & DISIPLIN
        // ==========================================
        $defaultPointRules = [
            ['code' => 'PLG01', 'title' => 'Terlambat Masuk Sekolah (< 15 menit)', 'type' => 'PELANGGARAN', 'points' => 5],
            ['code' => 'PLG02', 'title' => 'Seragam Tidak Lengkap / Atribut Hilang', 'type' => 'PELANGGARAN', 'points' => 10],
            ['code' => 'PLG03', 'title' => 'Meninggalkan Kelas Tanpa Izin Guru', 'type' => 'PELANGGARAN', 'points' => 15],
            ['code' => 'PRS01', 'title' => 'Juara 1 Lomba Tingkat Kota / Kabupaten', 'type' => 'PRESTASI', 'points' => 30],
            ['code' => 'PRS02', 'title' => 'Juara 1 Lomba Tingkat Provinsi', 'type' => 'PRESTASI', 'points' => 50],
            ['code' => 'PRS03', 'title' => 'Pengurus OSIS / MPK Aktif', 'type' => 'PRESTASI', 'points' => 20],
        ];

        foreach ($defaultPointRules as $pr) {
            DB::table('point_rules')->updateOrInsert(
                ['code' => $pr['code']],
                [
                    'title' => $pr['title'],
                    'type' => $pr['type'],
                    'points' => $pr['points'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }

        if (DB::table('user_point_balances')->count() === 0) {
            DB::table('user_point_balances')->insert([
                'user_id' => $userId,
                'total_reward_points' => 50,
                'total_violation_points' => 5,
                'current_balance' => 45,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $pr1 = DB::table('point_rules')->first();
        if ($pr1 && DB::table('student_point_logs')->count() === 0) {
            DB::table('student_point_logs')->insert([
                'student_id' => $userId,
                'rule_id' => $pr1->id,
                'recorded_by' => $guruId,
                'points' => $pr1->points,
                'type' => $pr1->type,
                'notes' => 'Catatan ketertiban berkala.',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if (DB::table('disiplin_reports')->count() === 0) {
            DB::table('disiplin_reports')->insert([
                'student_id' => $userId,
                'reporter_id' => $guruId,
                'incident_date' => now()->toDateString(),
                'category' => 'RINGAN',
                'description' => 'Terlambat mengikuti apel pagi karena kendala lalu lintas.',
                'action_taken' => 'Pembinaan lisan oleh wali kelas.',
                'status' => 'SELESAI',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // ==========================================
        // 6. SARPRAS, INVENTARIS & PENGADUAN (COMPLAINTS)
        // ==========================================
        if (DB::table('facilities')->count() === 0) {
            DB::table('facilities')->insert([
                ['code' => 'FAC-LAB-01', 'name' => 'Laboratorium Komputer & AI', 'location' => 'Gedung B Lt. 2', 'status' => 'BAIK', 'created_at' => now(), 'updated_at' => now()],
                ['code' => 'FAC-LAB-02', 'name' => 'Laboratorium Kimia & Fisika', 'location' => 'Gedung C Lt. 1', 'status' => 'BAIK', 'created_at' => now(), 'updated_at' => now()],
                ['code' => 'FAC-AULA', 'name' => 'Aula Serbaguna Graha Anise', 'location' => 'Gedung Utama', 'status' => 'BAIK', 'created_at' => now(), 'updated_at' => now()],
            ]);
        }

        if (DB::table('inventory_categories')->count() === 0) {
            DB::table('inventory_categories')->insert([
                ['name' => 'Elektronik & Multimedia', 'description' => 'Proyektor, PC, Speaker', 'created_at' => now(), 'updated_at' => now()],
                ['name' => 'Furnitur & Meubelair', 'description' => 'Meja, Kursi Siswa/Guru', 'created_at' => now(), 'updated_at' => now()],
                ['name' => 'Alat Olahraga', 'description' => 'Bola basket, Futsal, Raket', 'created_at' => now(), 'updated_at' => now()],
            ]);
        }

        $invCat = DB::table('inventory_categories')->first();
        if ($invCat && DB::table('inventory_items')->count() === 0) {
            DB::table('inventory_items')->insert([
                ['category_id' => $invCat->id, 'item_code' => 'ELK-PRJ-01', 'name' => 'Epson Laser Projector 4K', 'quantity' => 12, 'condition' => 'BAIK', 'created_at' => now(), 'updated_at' => now()],
                ['category_id' => $invCat->id, 'item_code' => 'ELK-SPK-02', 'name' => 'Wireless Portable PA Speaker', 'quantity' => 4, 'condition' => 'BAIK', 'created_at' => now(), 'updated_at' => now()],
            ]);
        }

        if (DB::table('complaints')->count() === 0) {
            DB::table('complaints')->insert([
                'user_id' => $userId,
                'category' => 'SARPRAS',
                'title' => 'AC Kelas X MIPA 1 Kurang Dingin',
                'description' => 'Hawa ruangan agak panas saat siang hari karena filter AC berdebu.',
                'status' => 'IN_PROGRESS',
                'is_anonymous' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // ==========================================
        // 7. KALENDER AKADEMIK & HARI LIBUR
        // ==========================================
        if (DB::table('academic_calendars')->count() === 0) {
            DB::table('academic_calendars')->insert([
                [
                    'academic_year_id' => $academicYearId,
                    'title' => 'Asesmen Tengah Semester (ATS) Ganjil',
                    'start_date' => '2026-09-21',
                    'end_date' => '2026-09-26',
                    'type' => 'UJIAN',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'academic_year_id' => $academicYearId,
                    'title' => 'Pekan Olahraga dan Seni (PORSENI)',
                    'start_date' => '2026-12-10',
                    'end_date' => '2026-12-15',
                    'type' => 'KEGIATAN',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }

        if (DB::table('holidays')->count() === 0) {
            DB::table('holidays')->insert([
                ['name' => 'Tahun Baru Masehi', 'start_date' => '2026-01-01', 'end_date' => '2026-01-01', 'description' => 'Hari Libur Nasional', 'created_at' => now(), 'updated_at' => now()],
                ['name' => 'Hari Kemerdekaan RI', 'start_date' => '2026-08-17', 'end_date' => '2026-08-17', 'description' => 'HUT Kemerdekaan Republik Indonesia Ke-81', 'created_at' => now(), 'updated_at' => now()],
                ['name' => 'Libur Semester Ganjil', 'start_date' => '2026-12-21', 'end_date' => '2027-01-02', 'description' => 'Libur Akhir Semester Ganjil', 'created_at' => now(), 'updated_at' => now()],
            ]);
        }

        // ==========================================
        // 8. PENGUMUMAN & HUBUNGAN MASYARAKAT (HUMAS)
        // ==========================================
        if (DB::table('announcements')->count() === 0) {
            $ancId = DB::table('announcements')->insertGetId([
                'title' => 'Pelaksanaan Pembelajaran Tatap Muka & Sosialisasi LMS Anise',
                'content' => 'Diberitahukan kepada seluruh dewan guru dan siswa bahwa pelaporan KBM dan presensi resmi menggunakan aplikasi Anise terhitung pekan ini.',
                'target_role' => 'ALL',
                'author_id' => $tu->id ?? $guruId,
                'published_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('announcement_reads')->insert([
                'announcement_id' => $ancId,
                'user_id' => $userId,
                'read_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // ==========================================
        // 9. CUTI & PERIZINAN PEGAWAI / GURU
        // ==========================================
        if (DB::table('employee_leaves')->count() === 0 && $guruId) {
            DB::table('employee_leaves')->insert([
                'user_id' => $guruId,
                'leave_type' => 'TAHUNAN',
                'start_date' => now()->addDays(10)->toDateString(),
                'end_date' => now()->addDays(11)->toDateString(),
                'reason' => 'Menghadiri wisuda keluarga di luar kota.',
                'status' => 'APPROVED',
                'approved_by' => $tu->id ?? $guruId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if (DB::table('leaves')->count() === 0 && $userId) {
            DB::table('leaves')->insert([
                'user_id' => $userId,
                'type' => 'SAKIT',
                'start_date' => now()->subDays(5)->toDateString(),
                'end_date' => now()->subDays(5)->toDateString(),
                'reason' => 'Demam dan flu (disertai surat keterangan dokter).',
                'status' => 'APPROVED',
                'approved_by' => $guruId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // ==========================================
        // 10. EVALUASI GURU & KPI
        // ==========================================
        if (DB::table('teacher_evaluations')->count() === 0 && $guruId) {
            DB::table('teacher_evaluations')->insert([
                'teacher_id' => $guruId,
                'evaluator_id' => $tu->id ?? $guruId,
                'period' => '2026/2027 Ganjil',
                'pedagogik_score' => 90.00,
                'kepribadian_score' => 92.50,
                'sosial_score' => 88.00,
                'profesional_score' => 91.00,
                'notes' => 'Kinerja mengajar dan interaksi dengan siswa sangat baik.',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // ==========================================
        // 11. FAQ, DOKUMEN LEGAL & AUDIT
        // ==========================================
        if (DB::table('faqs')->count() === 0) {
            DB::table('faqs')->insert([
                [
                    'question' => 'Bagaimana jika lupa presensi saat tiba di sekolah?',
                    'answer' => 'Silakan segera menghubungi guru piket atau bagian Tata Usaha untuk verifikasi manual sebelum jam kepulangan.',
                    'category' => 'PRESENSI',
                    'order' => 1,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'question' => 'Apakah tugas bisa dikumpulkan setelah batas tenggat waktu?',
                    'answer' => 'Pengumpulan terlambat memerlukan persetujuan izin keterlambatan dari guru pengampu mata pelajaran.',
                    'category' => 'AKADEMIK',
                    'order' => 2,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }

        if (DB::table('legal_documents')->count() === 0) {
            DB::table('legal_documents')->insert([
                [
                    'title' => 'Syarat & Ketentuan Layanan Aplikasi Anise',
                    'slug' => 'terms-of-service',
                    'content' => 'Ketentuan pemanfaatan sistem informasi akademik Anise / SIPENA...',
                    'version' => '1.0.0',
                    'is_active' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'title' => 'Kebijakan Privasi & Keamanan Data Siswa',
                    'slug' => 'privacy-policy',
                    'content' => 'Kami berkomitmen menjaga kerahasiaan data pribadi, biometrik, dan presensi...',
                    'version' => '1.0.0',
                    'is_active' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }

        if (DB::table('security_audit_logs')->count() === 0) {
            DB::table('security_audit_logs')->insert([
                [
                    'user_id' => $userId,
                    'ip_address' => '127.0.0.1',
                    'action' => 'LOGIN_SUCCESS',
                    'user_agent' => 'Anise Mobile App / Android 14',
                    'details' => json_encode(['method' => 'jwt_biometric']),
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }

        // ==========================================
        // 12. PERMISSIONS, STRUCTURAL & SUBJECT TEACHER
        // ==========================================
        if (DB::table('permissions')->count() === 0) {
            $permId = DB::table('permissions')->insertGetId([
                'name' => 'manage-journals',
                'display_name' => 'Kelola Jurnal Mengajar',
                'module' => 'KBM',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $guruRole = DB::table('roles')->where('name', 'GURU')->first();
            if ($guruRole) {
                DB::table('role_permissions')->insert([
                    'role_id' => $guruRole->id,
                    'permission_id' => $permId,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        if (DB::table('subject_teachers')->count() === 0 && $guruId) {
            DB::table('subject_teachers')->insert([
                'teacher_id' => $guruId,
                'subject_id' => $subjectId,
                'class_id' => $classId,
                'academic_year_id' => $academicYearId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        if (DB::table('presensi_logs')->count() === 0 && $userId) {
            DB::table('presensi_logs')->insert([
                'user_id' => $userId,
                'action' => 'CHECK_IN',
                'timestamp' => now()->setTime(6, 45, 0),
                'location_lat' => -6.200000,
                'location_lng' => 106.816666,
                'status' => 'VALID',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
