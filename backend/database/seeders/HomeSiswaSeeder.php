<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Role;
use App\Models\GuruProfile;
use App\Models\SiswaProfile;
use App\Models\SchoolClass;
use App\Models\ClassStudent;
use App\Models\Subject;
use App\Models\Schedule;
use App\Models\Journal;
use App\Models\JournalTask;
use App\Models\AcademicYear;
use App\Models\Major;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class HomeSiswaSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Dapatkan atau Buat Tahun Ajaran Aktif
        $academicYear = AcademicYear::firstOrCreate(
            ['name' => '2026/2027'],
            [
                'semester' => 'GANJIL',
                'is_active' => true,
                'start_date' => '2026-07-15',
                'end_date' => '2026-12-20',
            ]
        );

        // 2. Dapatkan atau Buat Jurusan MIPA
        $major = Major::firstOrCreate(
            ['code' => 'MIPA'],
            ['name' => 'Matematika dan Ilmu Pengetahuan Alam']
        );

        // 3. Pastikan Role GURU & SISWA Tersedia
        $roleGuru = Role::firstOrCreate(['name' => 'GURU'], ['is_guru_wali' => true]);
        $roleSiswa = Role::firstOrCreate(['name' => 'SISWA']);

        // 4. Cari atau Buat Siswa Andi Wijaya
        $siswa = User::where('email', 'siswa@sipena.sch.id')->first();
        if (!$siswa) {
            $siswa = User::create([
                'id' => (string) Str::uuid(),
                'full_name' => 'Andi Wijaya',
                'username' => 'siswa1',
                'email' => 'siswa@sipena.sch.id',
                'phone' => '087794274408',
                'password_hash' => Hash::make('siswa123'),
                'role_id' => $roleSiswa->id,
                'is_active' => true,
                'gender' => 'L',
            ]);

            SiswaProfile::create([
                'user_id' => $siswa->id,
                'nisn' => '0012345678',
                'nis' => '1001',
                'academic_year_id' => $academicYear->id,
            ]);
        }

        // 5. Cari atau Buat Kelas Siswa (X RPL 1 / XII MIPA 1)
        $classStudent = ClassStudent::where('student_id', $siswa->id)->where('status', 'ACTIVE')->first();
        if ($classStudent) {
            $schoolClass = SchoolClass::find($classStudent->class_id);
        } else {
            $schoolClass = SchoolClass::firstOrCreate(
                ['name' => 'X RPL 1', 'academic_year_id' => $academicYear->id],
                [
                    'grade_level' => 10,
                    'major_id' => $major->id,
                ]
            );

            ClassStudent::create([
                'class_id' => $schoolClass->id,
                'student_id' => $siswa->id,
                'status' => 'ACTIVE',
            ]);
        }

        // 6. Daftar 7 Guru Pengajar Asli SMA N 1 Peunaron
        $guruDataList = [
            [
                'name' => 'Budi Santoso, S.Kom.',
                'email' => 'guru@sipena.sch.id',
                'nip' => '198001012010011001',
                'gender' => 'L',
                'subject_code' => 'PBO',
                'subject_name' => 'Pemrograman Berorientasi Objek & Web',
                'day' => 1, // Senin
                'time' => '07:30 - 09:30',
                'task' => [
                    'title' => 'Implementasi State Management Riverpod pada Modul Presensi',
                    'desc' => 'Kerjakan integrasi Riverpod state notifier dan lakukan pengujian sinkronisasi data presensi siswa secara berkala. Kumpulkan tautan repository Git atau berkas project.',
                    'due' => now()->addDay()->setTime(23, 59, 0),
                ]
            ],
            [
                'name' => 'Dra. Siti Aminah, M.Pd.',
                'email' => 'siti.aminah@sipena.sch.id',
                'nip' => '197505121999032001',
                'gender' => 'P',
                'subject_code' => 'MAT-WAJIB',
                'subject_name' => 'Matematika Wajib',
                'day' => 2, // Selasa
                'time' => '08:00 - 10:00',
                'task' => [
                    'title' => 'Latihan Soal Matriks dan Transformasi Geometri (Bab 3)',
                    'desc' => 'Kerjakan soal latihan nomor 1 sampai 10 pada buku paket halaman 84-86. Tulis tangan di buku catatan dan unggah foto hasil pekerjaan Anda.',
                    'due' => now()->addDays(3)->setTime(17, 0, 0),
                ]
            ],
            [
                'name' => 'Ahmad Fauzi, S.Pd.',
                'email' => 'ahmad.fauzi@sipena.sch.id',
                'nip' => '198803152015021003',
                'gender' => 'L',
                'subject_code' => 'BINDO',
                'subject_name' => 'Bahasa Indonesia',
                'day' => 3, // Rabu
                'time' => '10:15 - 12:15',
                'task' => [
                    'title' => 'Penyusunan Teks Artikel Ilmiah Populer & Kaidah Kebahasaan',
                    'desc' => 'Buat draft artikel ilmiah populer minimal 600 kata dengan tema pendidikan digital di era revolusi industri 4.0 dengan memperhatikan tanda baca EYD V.',
                    'due' => now()->addDays(4)->setTime(21, 0, 0),
                ]
            ],
            [
                'name' => 'Sarah Jenkins, M.Ed.',
                'email' => 'sarah.jenkins@sipena.sch.id',
                'nip' => '198607212012042002',
                'gender' => 'P',
                'subject_code' => 'BING',
                'subject_name' => 'Bahasa Inggris',
                'day' => 4, // Kamis
                'time' => '07:30 - 09:30',
                'task' => [
                    'title' => 'Technical Essay: AI Adoption in High School Education',
                    'desc' => 'Write a comprehensive 500-word argumentative essay discussing the advantages and challenges of AI integration in classroom learning.',
                    'due' => now()->addDays(6)->setTime(12, 0, 0),
                ]
            ],
            [
                'name' => 'Drs. Hendra Gunawan',
                'email' => 'hendra.gunawan@sipena.sch.id',
                'nip' => '197211041998021001',
                'gender' => 'L',
                'subject_code' => 'FIS-TERAPAN',
                'subject_name' => 'Fisika Terapan & Gelombang',
                'day' => 5, // Jumat
                'time' => '08:00 - 09:30',
                'task' => [
                    'title' => 'Analisis Hukum Newton dan Gelombang Elektromagnetik',
                    'desc' => 'Selesaikan lembar kerja praktikum modul 4 terkait penerapan hukum Faraday dan sifat gelombang transversal pada sistem telekomunikasi nirkabel.',
                    'due' => now()->addDays(8)->setTime(23, 59, 0),
                ]
            ],
            [
                'name' => 'Nurul Hidayati, S.Si.',
                'email' => 'nurul.hidayati@sipena.sch.id',
                'nip' => '199009182018012004',
                'gender' => 'P',
                'subject_code' => 'BASIS-DATA',
                'subject_name' => 'Basis Data Relasional & Cloud',
                'day' => 1, // Senin
                'time' => '10:00 - 12:00',
                'task' => [
                    'title' => 'Normalisasi Skema Relasional Database PostgreSQL (3NF)',
                    'desc' => 'Rancang Entity Relationship Diagram (ERD) dan skrip DDL normalisasi tabel 1NF hingga 3NF untuk aplikasi inventaris sekolah.',
                    'due' => now()->addDays(5)->setTime(20, 0, 0),
                ]
            ],
            [
                'name' => 'Rudi Hermawan, S.Pd.',
                'email' => 'rudi.hermawan@sipena.sch.id',
                'nip' => '198402282011011002',
                'gender' => 'L',
                'subject_code' => 'PPKN',
                'subject_name' => 'Pendidikan Pancasila & Kewarganegaraan',
                'day' => 3, // Rabu
                'time' => '07:30 - 09:00',
                'task' => null // Tidak ada tugas pending (hanya jadwal & profil)
            ],
        ];

        foreach ($guruDataList as $gData) {
            // 7A. Buat atau Temukan Akun User Guru
            $guruUser = User::where('email', $gData['email'])->first();
            if (!$guruUser) {
                $guruUser = User::create([
                    'id' => (string) Str::uuid(),
                    'full_name' => $gData['name'],
                    'username' => strtolower(str_replace([' ', '.', ','], '', explode(' ', $gData['name'])[0])) . rand(10, 99),
                    'email' => $gData['email'],
                    'password_hash' => Hash::make('guru123'),
                    'role_id' => $roleGuru->id,
                    'is_active' => true,
                    'gender' => $gData['gender'],
                ]);
            } else {
                $guruUser->update([
                    'full_name' => $gData['name'],
                    'role_id' => $roleGuru->id,
                    'is_active' => true,
                ]);
            }

            // 7B. Buat Guru Profile
            GuruProfile::updateOrCreate(
                ['user_id' => $guruUser->id],
                [
                    'nip_nuptk' => $gData['nip'],
                    'employment_status' => 'PNS',
                ]
            );

            // 7C. Buat atau Temukan Mata Pelajaran
            $subject = Subject::firstOrCreate(
                ['code' => $gData['subject_code']],
                ['name' => $gData['subject_name']]
            );

            $times = explode('-', $gData['time'] ?? '07:30 - 09:30');
            $startTime = trim($times[0]) . (strlen(trim($times[0])) === 5 ? ':00' : '');
            $endTime = trim($times[1] ?? '09:30') . (strlen(trim($times[1] ?? '09:30')) === 5 ? ':00' : '');

            // 7D. Buat Jadwal Pelajaran (Schedule) untuk Kelas Siswa
            $schedule = Schedule::firstOrCreate(
                [
                    'class_id' => $schoolClass->id,
                    'subject_id' => $subject->id,
                    'academic_year_id' => $academicYear->id,
                ],
                [
                    'teacher_id' => $guruUser->id,
                    'day_of_week' => $gData['day'],
                    'start_time' => $startTime,
                    'end_time' => $endTime,
                ]
            );

            // Selaraskan Guru pengampu di Schedule
            $schedule->update([
                'teacher_id' => $guruUser->id,
                'day_of_week' => $gData['day'],
                'start_time' => $startTime,
                'end_time' => $endTime,
            ]);

            // 7E. Buat Jurnal Mengajar Guru jika ada tugas
            if (!empty($gData['task'])) {
                $journal = Journal::firstOrCreate(
                    [
                        'schedule_id' => $schedule->id,
                        'topic_material' => 'Bab: ' . $gData['task']['title'],
                    ],
                    [
                        'teacher_id' => $guruUser->id,
                        'class_id' => $schoolClass->id,
                        'subject_id' => $subject->id,
                        'teaching_date' => now()->toDateString(),
                    ]
                );

                // 7F. Buat Tugas Jurnal (JournalTask)
                JournalTask::firstOrCreate(
                    [
                        'journal_id' => $journal->id,
                        'title' => $gData['task']['title'],
                    ],
                    [
                        'description' => $gData['task']['desc'],
                        'due_date' => $gData['task']['due'],
                    ]
                );
            }
        }

        // 8. Seeding Data Presensi Asli Andi Wijaya (Oktober 2026)
        $waliKelas = User::where('email', 'guru@sipena.sch.id')->first();
        $budiId = $waliKelas ? $waliKelas->id : null;

        $attendanceDates = [
            ['date' => '2026-10-01', 'time' => '06:45:12', 'status' => 'MASUK'],
            ['date' => '2026-10-02', 'time' => '06:40:05', 'status' => 'MASUK'],
            ['date' => '2026-10-05', 'time' => '06:50:22', 'status' => 'MASUK'],
            ['date' => '2026-10-06', 'time' => '07:28:44', 'status' => 'TERLAMBAT'],
            ['date' => '2026-10-07', 'time' => '06:48:19', 'status' => 'MASUK'],
            ['date' => '2026-10-08', 'time' => '06:52:30', 'status' => 'MASUK'],
            ['date' => '2026-10-12', 'time' => '06:43:10', 'status' => 'MASUK'],
            ['date' => '2026-10-13', 'time' => '06:50:00', 'status' => 'MASUK'],
        ];

        foreach ($attendanceDates as $att) {
            \Illuminate\Support\Facades\DB::table('attendances')->updateOrInsert(
                [
                    'user_id' => $siswa->id,
                    'tanggal' => $att['date'],
                ],
                [
                    'id' => (string) Str::uuid(),
                    'jam_masuk' => $att['date'] . ' ' . $att['time'],
                    'status' => $att['status'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }

        // Catat Laporan Tilang Telat untuk 6 Oktober 2026
        if ($budiId) {
            if (\Illuminate\Support\Facades\Schema::hasTable('discipline_reports')) {
                \Illuminate\Support\Facades\DB::table('discipline_reports')->updateOrInsert(
                    [
                        'student_id' => $siswa->id,
                        'violation_time' => '2026-10-06 07:28:44',
                    ],
                    [
                        'id' => (string) Str::uuid(),
                        'reporter_id' => $budiId,
                        'category' => 'TERLAMBAT',
                        'description' => 'Ban motor bocor di jalan raya Peunaron',
                        'status' => 'APPROVED',
                        'approved_by' => $budiId,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]
                );
            }
        }

        // Catat Surat Izin Sakit untuk 9 Oktober 2026
        if (\Illuminate\Support\Facades\Schema::hasTable('student_leaves')) {
            \Illuminate\Support\Facades\DB::table('student_leaves')->updateOrInsert(
                [
                    'student_id' => $siswa->id,
                    'start_date' => '2026-10-09',
                ],
                [
                    'id' => (string) Str::uuid(),
                    'type' => 'SAKIT',
                    'reason' => 'Demam tinggi dan istirahat dokter klinik Peunaron',
                    'end_date' => '2026-10-09',
                    'status' => 'APPROVED',
                    'approved_by' => $budiId,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}
