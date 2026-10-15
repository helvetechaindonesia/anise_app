<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;
use App\Models\Role;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\SubjectTeacher;
use App\Models\Jabatan;
use App\Models\AcademicYear;
use App\Models\SchoolHoliday;
use App\Models\AcademicCalendar;
use App\Http\Controllers\Api\ExcelParserKurikulumController;

class ExcelParserKurikulumStrictTest extends TestCase
{
    use RefreshDatabase;

    protected $academicYear;
    protected $role;
    protected $controller;

    protected function setUp(): void
    {
        parent::setUp();

        $this->role = Role::create(['name' => 'GURU']);

        $this->academicYear = AcademicYear::create([
            'name' => '2026/2027',
            'semester' => 'GANJIL',
            'start_date' => '2026-07-01',
            'end_date' => '2026-12-31',
            'is_active' => true,
        ]);

        $this->controller = new ExcelParserKurikulumController();
    }

    private function makeUser($username, $fullName)
    {
        return User::create([
            'username' => $username,
            'full_name' => $fullName,
            'email' => $username . '@example.com',
            'password_hash' => bcrypt('secret'),
            'role_id' => $this->role->id,
            'is_active' => true,
        ]);
    }

    public function test_penugasan_requires_tendik_and_jabatan_but_area_is_optional()
    {
        $guru = $this->makeUser('19900101', 'Budi Santoso');

        $jabatan = Jabatan::create([
            'name' => 'Wakasek Kurikulum',
        ]);

        $ref = new \ReflectionClass($this->controller);
        $method = $ref->getMethod('parsePenugasan');
        $method->setAccessible(true);

        // Case 1: Area kosong tetap berhasil
        $rowsValid = collect([
            ['MASTER PENUGASAN TENDIK & GURU', '', ''], // Header banner
            ['Nama Tendik', 'Tugas Tambahan', 'Area Penugasan'], // Header kolom
            ['Budi Santoso', 'Wakasek Kurikulum', ''], // Data valid tanpa area
        ]);

        $errors = $method->invokeArgs($this->controller, [$rowsValid, $this->academicYear]);
        $this->assertEmpty($errors);

        // Case 2: Nama Tendik kosong -> tolak
        $rowsInvalid = collect([
            ['MASTER PENUGASAN TENDIK & GURU', '', ''],
            ['Nama Tendik', 'Tugas Tambahan', 'Area Penugasan'],
            ['', 'Wakasek Kurikulum', 'Kurikulum'],
        ]);
        $errorsInvalid = $method->invokeArgs($this->controller, [$rowsInvalid, $this->academicYear]);
        $this->assertNotEmpty($errorsInvalid);
        $this->assertStringContainsString('Nama Tendik dan Tugas Tambahan wajib diisi', $errorsInvalid[0]);
    }

    public function test_mapel_strict_validation_and_subject_teacher_cross_check_with_jurnal()
    {
        $teacher = $this->makeUser('198205232008032003', 'Frita Kartika Batubara');

        $class = SchoolClass::create([
            'academic_year_id' => $this->academicYear->id,
            'grade_level' => '10',
            'name' => 'Cut Nyak Dhien',
        ]);

        $ref = new \ReflectionClass($this->controller);
        $methodMapel = $ref->getMethod('parseMapel');
        $methodMapel->setAccessible(true);

        // Upload Master Mapel
        $mapelRows = collect([
            ['Nama Mata Pelajaran', 'Kode Mapel', 'Tingkat', 'Nama Kelas', 'Nama Tendik(pengampu)', 'NUPTK/NIP'],
            ['Bahasa Indonesia', 'BIN', 'X', 'Cut Nyak Dhien', 'Frita Kartika Batubara', '198205232008032003'],
        ]);

        $errorsMapel = $methodMapel->invokeArgs($this->controller, [$mapelRows, $this->academicYear]);
        $this->assertEmpty($errorsMapel);

        $this->assertDatabaseHas('subjects', ['code' => 'BIN']);
        $this->assertDatabaseHas('subject_teachers', [
            'class_id' => $class->id,
            'teacher_id' => $teacher->id,
        ]);

        // Jurnal Mengajar Check
        $methodJurnal = $ref->getMethod('parseJurnalMengajar');
        $methodJurnal->setAccessible(true);

        // 1. KEG tanpa tendik diperbolehkan
        $jurnalKeg = collect([
            ['Hari', 'Jam ke-', 'Jam Mulai', 'Jam Selesai', 'Tingkat', 'Nama Kelas', 'Kode Mapel', 'Nama Mata Pelajaran', 'Nama Tendik(pengampu)', 'NUPTK/NIP'],
            ['Senin', 1, '07:30', '08:15', 'X', 'Cut Nyak Dhien', 'KEG', 'Upacara Bendera', '', '-'],
        ]);
        $errorsKeg = $methodJurnal->invokeArgs($this->controller, [$jurnalKeg, $this->academicYear]);
        $this->assertEmpty($errorsKeg);

        // 2. Non-KEG dengan pengampu yang cocok dengan Master Mapel berhasil
        $jurnalValid = collect([
            ['Hari', 'Jam ke-', 'Jam Mulai', 'Jam Selesai', 'Tingkat', 'Nama Kelas', 'Kode Mapel', 'Nama Mata Pelajaran', 'Nama Tendik(pengampu)', 'NUPTK/NIP'],
            ['Senin', 2, '08:15', '09:00', 'X', 'Cut Nyak Dhien', 'BIN', 'Bahasa Indonesia', 'Frita Kartika Batubara', '198205232008032003'],
        ]);
        $errorsValid = $methodJurnal->invokeArgs($this->controller, [$jurnalValid, $this->academicYear]);
        $this->assertEmpty($errorsValid);

        // 3. Non-KEG dengan guru yang tidak terdaftar di Master Mapel kelas tersebut -> DITOLAK
        $otherTeacher = $this->makeUser('1999999999', 'Guru Lain');
        $jurnalMismatch = collect([
            ['Hari', 'Jam ke-', 'Jam Mulai', 'Jam Selesai', 'Tingkat', 'Nama Kelas', 'Kode Mapel', 'Nama Mata Pelajaran', 'Nama Tendik(pengampu)', 'NUPTK/NIP'],
            ['Senin', 3, '09:00', '09:45', 'X', 'Cut Nyak Dhien', 'BIN', 'Bahasa Indonesia', 'Guru Lain', '1999999999'],
        ]);
        $errorsMismatch = $methodJurnal->invokeArgs($this->controller, [$jurnalMismatch, $this->academicYear]);
        $this->assertNotEmpty($errorsMismatch);
        $this->assertStringContainsString('tidak terdaftar sebagai pengampu mapel', $errorsMismatch[0]);
    }

    public function test_wali_kelas_strict_validation()
    {
        $teacher = $this->makeUser('199504132024212022', 'Yeni Setianingsih');

        $class = SchoolClass::create([
            'academic_year_id' => $this->academicYear->id,
            'grade_level' => '10',
            'name' => 'Cut Nyak Dhien',
        ]);

        $ref = new \ReflectionClass($this->controller);
        $method = $ref->getMethod('parseWaliKelas');
        $method->setAccessible(true);

        // Valid
        $rowsValid = collect([
            ['Tingkat', 'Nama Kelas', 'Nama Wali Kelas', 'NUPTK/NIP Wali Kelas'],
            ['X', 'Cut Nyak Dhien', 'Yeni Setianingsih', '199504132024212022'],
        ]);
        $errors = $method->invokeArgs($this->controller, [$rowsValid]);
        $this->assertEmpty($errors);

        $class->refresh();
        $this->assertEquals($teacher->id, $class->wali_kelas_id);

        // Nama beda dengan DB -> Ditolak
        $rowsTypo = collect([
            ['Tingkat', 'Nama Kelas', 'Nama Wali Kelas', 'NUPTK/NIP Wali Kelas'],
            ['X', 'Cut Nyak Dhien', 'Yeni Typo', '199504132024212022'],
        ]);
        $errorsTypo = $method->invokeArgs($this->controller, [$rowsTypo]);
        $this->assertNotEmpty($errorsTypo);
        $this->assertStringContainsString('tidak cocok dengan data terdaftar', $errorsTypo[0]);
    }

    public function test_guru_wali_strict_validation()
    {
        $student = $this->makeUser('0103655074', 'Aisyatul Madina');
        $guruWali = $this->makeUser('19800101', 'Sutrisno');

        $class = SchoolClass::create([
            'academic_year_id' => $this->academicYear->id,
            'grade_level' => '10',
            'name' => 'Cut Nyak Dhien',
        ]);

        $ref = new \ReflectionClass($this->controller);
        $method = $ref->getMethod('parseGuruWali');
        $method->setAccessible(true);

        // Valid
        $rowsValid = collect([
            ['MASTER PENEMPATAN KELAS SISWA', 'col2', 'col3', 'col4', 'col5'],
            ['Nama Lengkap', 'NISN', 'Tingkat Kelas', 'Nama Kelas', 'Guru Wali'],
            ['Aisyatul Madina', '0103655074', 'X', 'Cut Nyak Dhien', 'Sutrisno'],
        ]);
        $errors = $method->invokeArgs($this->controller, [$rowsValid, $this->academicYear]);
        $this->assertEmpty($errors);

        $this->assertDatabaseHas('class_students', [
            'student_id' => $student->id,
            'class_id' => $class->id,
        ]);
        $this->assertDatabaseHas('guru_wali_students', [
            'student_id' => $student->id,
            'guru_id' => $guruWali->id,
        ]);

        // NISN salah -> Ditolak
        $rowsInvalidNisn = collect([
            ['Nama Lengkap', 'NISN', 'Tingkat Kelas', 'Nama Kelas', 'Guru Wali'],
            ['Aisyatul Madina', '9999999999', 'X', 'Cut Nyak Dhien', 'Sutrisno'],
        ]);
        $errorsNisn = $method->invokeArgs($this->controller, [$rowsInvalidNisn, $this->academicYear]);
        $this->assertNotEmpty($errorsNisn);
        $this->assertStringContainsString('tidak ditemukan di Master User', $errorsNisn[0]);
    }

    public function test_hari_libur_and_kalender_strict_validation()
    {
        $ref = new \ReflectionClass($this->controller);

        // Hari Libur
        $methodLibur = $ref->getMethod('parseHariLibur');
        $methodLibur->setAccessible(true);

        $liburValid = collect([
            ['Waktu (DD/MM/YYYY)', 'Keterangan'],
            ['25/12/2026', 'Hari Raya Natal'],
        ]);
        $errorsLibur = $methodLibur->invokeArgs($this->controller, [$liburValid, $this->academicYear]);
        $this->assertEmpty($errorsLibur);
        $this->assertDatabaseHas('holidays', ['name' => 'Hari Raya Natal']);

        $liburKosong = collect([
            ['Waktu (DD/MM/YYYY)', 'Keterangan'],
            ['25/12/2026', ''],
        ]);
        $errorsLiburKosong = $methodLibur->invokeArgs($this->controller, [$liburKosong, $this->academicYear]);
        $this->assertNotEmpty($errorsLiburKosong);

        // Kalender Akademik
        $methodKalender = $ref->getMethod('parseKalenderAkademik');
        $methodKalender->setAccessible(true);

        $kalenderValid = collect([
            ['Nama', 'Jenis', 'Mulai (DD/MM/YYYY)', 'Selesai (DD/MM/YYYY)', 'Tingkat'],
            ['Penilaian Akhir Semester', 'asesmen', '01/12/2026', '12/12/2026', 'X + XI + XII'],
        ]);
        $errorsKalender = $methodKalender->invokeArgs($this->controller, [$kalenderValid, $this->academicYear]);
        $this->assertEmpty($errorsKalender);
        $this->assertDatabaseHas('academic_calendars', ['name' => 'Penilaian Akhir Semester', 'type' => 'ASESMEN']);
    }
}
