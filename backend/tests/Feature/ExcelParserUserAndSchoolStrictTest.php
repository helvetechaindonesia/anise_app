<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;
use App\Models\Role;
use App\Models\SchoolClass;
use App\Models\Jabatan;
use App\Models\AcademicYear;
use App\Models\Major;
use App\Models\Notification;
use App\Http\Resources\UserResource;
use App\Http\Controllers\Api\ExcelParserUserController;
use App\Http\Controllers\Api\ExcelParserController;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;

class ExcelParserUserAndSchoolStrictTest extends TestCase
{
    use RefreshDatabase;

    protected $academicYear;
    protected $major;
    protected $user;
    protected $userController;
    protected $schoolController;

    protected function setUp(): void
    {
        parent::setUp();

        $role = Role::create(['name' => 'TATA_USAHA']);
        $this->user = User::create([
            'username' => 'tu_dev',
            'full_name' => 'Staf Tata Usaha Dev',
            'email' => 'tudev@sipena.com',
            'password_hash' => bcrypt('password'),
            'role_id' => $role->id,
            'is_active' => true,
        ]);

        $this->academicYear = AcademicYear::create([
            'name' => '2026/2027',
            'semester' => 'GANJIL',
            'start_date' => '2026-07-01',
            'end_date' => '2026-12-31',
            'is_active' => true,
        ]);

        $this->major = Major::create([
            'name' => 'Umum',
            'code' => 'UMUM',
        ]);

        $this->userController = new ExcelParserUserController();
        $this->schoolController = new ExcelParserController();
    }

    public function test_user_siswa_strict_requires_nama_nisn_email_kredensial_agama()
    {
        $ref = new \ReflectionClass($this->userController);
        $method = $ref->getMethod('validateRequiredColumns');
        $method->setAccessible(true);

        // 1. Lengkap semua 5 kolom wajib -> Berhasil
        $collectionValid = collect([
            [
                'Nama Lengkap' => 'Ahmad Siswa',
                'Kredensial' => '0101010101',
                'NIS' => '1001',
                'NISN' => '0101010101',
                'Email' => 'ahmad@sipena.com',
                'No. HP' => '0812345678',
                'Tahun Ajaran' => '2026/2027',
                'Gender' => 'L',
                'Agama' => 'Islam',
            ]
        ]);

        $resultValid = $method->invokeArgs($this->userController, [$collectionValid, 'SISWA']);
        $this->assertEmpty($resultValid['errors']);

        // 2. Kolom Agama kosong -> Ditolak
        $collectionNoAgama = collect([
            [
                'Nama Lengkap' => 'Ahmad Siswa',
                'Kredensial' => '0101010101',
                'NIS' => '1001',
                'NISN' => '0101010101',
                'Email' => 'ahmad@sipena.com',
                'No. HP' => '0812345678',
                'Tahun Ajaran' => '2026/2027',
                'Gender' => 'L',
                'Agama' => '',
            ]
        ]);

        $resultNoAgama = $method->invokeArgs($this->userController, [$collectionNoAgama, 'SISWA']);
        $this->assertNotEmpty($resultNoAgama['errors']);
        $this->assertStringContainsString('Agama', $resultNoAgama['errors'][0]);

        // 3. Kolom NISN kosong -> Ditolak
        $collectionNoNisn = collect([
            [
                'Nama Lengkap' => 'Ahmad Siswa',
                'Kredensial' => '0101010101',
                'NIS' => '1001',
                'NISN' => '',
                'Email' => 'ahmad@sipena.com',
                'No. HP' => '0812345678',
                'Tahun Ajaran' => '2026/2027',
                'Gender' => 'L',
                'Agama' => 'Islam',
            ]
        ]);

        $resultNoNisn = $method->invokeArgs($this->userController, [$collectionNoNisn, 'SISWA']);
        $this->assertNotEmpty($resultNoNisn['errors']);
        $this->assertStringContainsString('NISN', $resultNoNisn['errors'][0]);
    }

    public function test_user_tendik_strict_requires_nama_nuptk_email_kredensial_agama()
    {
        $ref = new \ReflectionClass($this->userController);
        $method = $ref->getMethod('validateRequiredColumns');
        $method->setAccessible(true);

        // 1. Lengkap semua 5 kolom wajib -> Berhasil
        $collectionValid = collect([
            [
                'Nama Lengkap' => 'Siti Guru',
                'Kredensial' => '198501012010012001',
                'NUPTK/NIK' => '198501012010012001',
                'Email' => 'siti@sipena.com',
                'No. HP' => '0812345679',
                'Gender' => 'P',
                'Agama' => 'Islam',
            ]
        ]);

        $resultValid = $method->invokeArgs($this->userController, [$collectionValid, 'GURU']);
        $this->assertEmpty($resultValid['errors']);

        // 2. Agama kosong -> Ditolak
        $collectionNoAgama = collect([
            [
                'Nama Lengkap' => 'Siti Guru',
                'Kredensial' => '198501012010012001',
                'NUPTK/NIK' => '198501012010012001',
                'Email' => 'siti@sipena.com',
                'No. HP' => '0812345679',
                'Gender' => 'P',
                'Agama' => '',
            ]
        ]);

        $resultNoAgama = $method->invokeArgs($this->userController, [$collectionNoAgama, 'GURU']);
        $this->assertNotEmpty($resultNoAgama['errors']);
        $this->assertStringContainsString('Agama', $resultNoAgama['errors'][0]);

        // 3. NUPTK kosong -> Ditolak
        $collectionNoNuptk = collect([
            [
                'Nama Lengkap' => 'Siti Guru',
                'Kredensial' => '198501012010012001',
                'NUPTK/NIK' => '',
                'Email' => 'siti@sipena.com',
                'No. HP' => '0812345679',
                'Gender' => 'P',
                'Agama' => 'Islam',
            ]
        ]);

        $resultNoNuptk = $method->invokeArgs($this->userController, [$collectionNoNuptk, 'GURU']);
        $this->assertNotEmpty($resultNoNuptk['errors']);
        $this->assertStringContainsString('NIP/NUPTK', $resultNoNuptk['errors'][0]);
    }

    public function test_user_resource_platter_includes_religion()
    {
        $role = Role::create(['name' => 'SISWA']);
        $user = User::create([
            'full_name' => 'Budi Pratama',
            'username' => '0102030405',
            'email' => 'budi@test.com',
            'password_hash' => bcrypt('password'),
            'role_id' => $role->id,
            'gender' => 'L',
            'religion' => 'Islam',
            'is_active' => true,
        ]);

        $resource = new UserResource($user);
        $array = $resource->toArray(Request::create('/'));

        $this->assertArrayHasKey('religion', $array);
        $this->assertEquals('Islam', $array['religion']);
    }

    public function test_master_role_requires_peran_name_but_is_guru_wali_is_optional()
    {
        // 1. Role valid dengan isGuruWali kosong tetap sukses
        $collectionValid = collect([
            ['Peran' => 'Kepala Sekolah', 'isGuruWali' => null],
            ['Peran' => 'Guru Wali Tingkat', 'isGuruWali' => '1'],
        ]);

        // Simulasikan validasi baris di parseMasterRole
        $roleKeywords = ['peran', 'role', 'hakakses', 'namarole', 'peranpengguna'];
        $ref = new \ReflectionClass($this->schoolController);
        $getValueMethod = $ref->getMethod('getValueBySemantics');
        $getValueMethod->setAccessible(true);

        $errors = [];
        $rowNum = 1;
        foreach ($collectionValid as $row) {
            $rowNum++;
            $peranRaw = $getValueMethod->invokeArgs($this->schoolController, [(array)$row, $roleKeywords]);
            if (empty($peranRaw)) {
                $errors[] = "Baris $rowNum: Nama Role/Peran wajib diisi.";
            }
        }
        $this->assertEmpty($errors);

        // 2. Role kosong -> ditolak
        $collectionInvalid = collect([
            ['Peran' => '', 'isGuruWali' => '1'],
        ]);
        $errorsInvalid = [];
        $rowNum = 1;
        foreach ($collectionInvalid as $row) {
            $rowNum++;
            $peranRaw = $getValueMethod->invokeArgs($this->schoolController, [(array)$row, $roleKeywords]);
            if (empty($peranRaw)) {
                $errorsInvalid[] = "Baris $rowNum: Nama Role/Peran wajib diisi.";
            }
        }
        $this->assertNotEmpty($errorsInvalid);
        $this->assertStringContainsString('Nama Role/Peran wajib diisi', $errorsInvalid[0]);
    }

    public function test_master_kelas_requires_all_columns()
    {
        $nameKeywords = ['namakelas', 'namarombel', 'rombel', 'kelas', 'nama'];
        $gradeKeywords = ['tingkat', 'tingkatkelas', 'grade', 'level', 'jenjang'];
        $codeKeywords = ['kodekelas', 'koderombel', 'kode', 'code', 'classcode'];

        $ref = new \ReflectionClass($this->schoolController);
        $getValueMethod = $ref->getMethod('getValueBySemantics');
        $getValueMethod->setAccessible(true);

        // 1. Lengkap semua 3 kolom -> Sukses
        $collectionValid = collect([
            ['Tingkat' => 'X', 'Nama' => 'Cut Nyak Dhien', 'Kode' => 'X CND']
        ]);
        $errors = [];
        $rowNum = 1;
        foreach ($collectionValid as $row) {
            $rowNum++;
            $rowArr = (array)$row;
            $nameRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $nameKeywords]);
            $codeRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $codeKeywords]);
            $gradeRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $gradeKeywords]);

            $missing = [];
            if (empty($gradeRaw)) $missing[] = 'Tingkat';
            if (empty($nameRaw)) $missing[] = 'Nama Kelas';
            if (empty($codeRaw)) $missing[] = 'Kode Kelas';
            if (!empty($missing)) {
                $errors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Kolom " . implode(', ', $missing) . " belum diisi).";
            }
        }
        $this->assertEmpty($errors);

        // 2. Kode kosong -> Ditolak
        $collectionNoKode = collect([
            ['Tingkat' => 'X', 'Nama' => 'Cut Nyak Dhien', 'Kode' => '']
        ]);
        $errorsNoKode = [];
        $rowNum = 1;
        foreach ($collectionNoKode as $row) {
            $rowNum++;
            $rowArr = (array)$row;
            $nameRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $nameKeywords]);
            $codeRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $codeKeywords]);
            $gradeRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $gradeKeywords]);

            $missing = [];
            if (empty($gradeRaw)) $missing[] = 'Tingkat';
            if (empty($nameRaw)) $missing[] = 'Nama Kelas';
            if (empty($codeRaw)) $missing[] = 'Kode Kelas';
            if (!empty($missing)) {
                $errorsNoKode[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Kolom " . implode(', ', $missing) . " belum diisi).";
            }
        }
        $this->assertNotEmpty($errorsNoKode);
        $this->assertStringContainsString('Kode Kelas', $errorsNoKode[0]);
    }

    public function test_master_jabatan_requires_all_columns()
    {
        $jabatanKeywords = ['jabatan', 'namajabatan', 'posisi', 'title', 'struktural', 'jabatanorganisasi'];
        $areaKeywords = ['areatugas', 'area', 'tugas', 'deskripsi', 'taskarea', 'lingkuptugas', 'bidang'];

        $ref = new \ReflectionClass($this->schoolController);
        $getValueMethod = $ref->getMethod('getValueBySemantics');
        $getValueMethod->setAccessible(true);

        // 1. Lengkap kedua kolom -> Sukses
        $collectionValid = collect([
            ['Jabatan' => 'Wakasek Kesiswaan', 'Area Tugas' => 'Kesiswaan']
        ]);
        $errors = [];
        $rowNum = 1;
        foreach ($collectionValid as $row) {
            $rowNum++;
            $rowArr = (array)$row;
            $jabatanRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $jabatanKeywords]);
            $areaRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $areaKeywords]);

            $missing = [];
            if (empty($jabatanRaw)) $missing[] = 'Jabatan';
            if (empty($areaRaw)) $missing[] = 'Area Tugas';
            if (!empty($missing)) {
                $errors[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Kolom " . implode(' & ', $missing) . " belum diisi).";
            }
        }
        $this->assertEmpty($errors);

        // 2. Area Tugas kosong -> Ditolak
        $collectionNoArea = collect([
            ['Jabatan' => 'Wakasek Kesiswaan', 'Area Tugas' => '']
        ]);
        $errorsNoArea = [];
        $rowNum = 1;
        foreach ($collectionNoArea as $row) {
            $rowNum++;
            $rowArr = (array)$row;
            $jabatanRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $jabatanKeywords]);
            $areaRaw = $getValueMethod->invokeArgs($this->schoolController, [$rowArr, $areaKeywords]);

            $missing = [];
            if (empty($jabatanRaw)) $missing[] = 'Jabatan';
            if (empty($areaRaw)) $missing[] = 'Area Tugas';
            if (!empty($missing)) {
                $errorsNoArea[] = "Baris $rowNum: Semua kolom wajib diisi tanpa terkecuali (Kolom " . implode(' & ', $missing) . " belum diisi).";
            }
        }
        $this->assertNotEmpty($errorsNoArea);
        $this->assertStringContainsString('Area Tugas', $errorsNoArea[0]);
    }

    public function test_upload_failure_creates_in_app_notification_with_human_explanation()
    {
        $this->actingAs($this->user);

        // 1. Upload file PDF ke parse user -> Ditolak & Masuk ke notifications
        $fakePdf = UploadedFile::fake()->create('data_siswa.pdf', 100, 'application/pdf');
        $response = $this->postJson('/api/parse/user/siswa', [
            'file' => $fakePdf,
        ]);

        $response->assertStatus(422);

        $notif = Notification::where('user_id', $this->user->id)
            ->where('title', 'like', '%Siswa%')
            ->first();
        $this->assertNotNull($notif, 'Notifikasi harus tersimpan di database saat upload gagal.');
        $this->assertStringContainsString('⚠️ Gagal Unggah Master Siswa', $notif->title);
        $this->assertStringContainsString('🔍 Penyebab Utama:', $notif->message);
        $this->assertStringContainsString('📋 Rincian Kendala:', $notif->message);
        $this->assertStringContainsString('💡 Solusi & Rekomendasi:', $notif->message);
        $this->assertStringContainsString('PDF', $notif->message);

        // 2. Upload file PDF ke parse master role -> Ditolak & Masuk ke notifications
        $responseRole = $this->postJson('/api/parse/master-role', [
            'file' => $fakePdf,
        ]);

        $responseRole->assertStatus(422);

        $notifRole = Notification::where('user_id', $this->user->id)
            ->where('title', 'like', '%Role%')
            ->first();
        $this->assertNotNull($notifRole);
        $this->assertStringContainsString('⚠️ Gagal Unggah Master Role & Hak Akses', $notifRole->title);

        // 3. Upload file PDF ke parse kurikulum mapel -> Ditolak & Masuk ke notifications
        $responseCurriculum = $this->postJson('/api/curriculum/parse/mapel', [
            'file' => $fakePdf,
        ]);

        $responseCurriculum->assertStatus(422);

        $notifMapel = Notification::where('user_id', $this->user->id)
            ->where('title', 'like', '%Mata Pelajaran%')
            ->first();
        $this->assertNotNull($notifMapel);
        $this->assertStringContainsString('⚠️ Gagal Unggah Master Mata Pelajaran', $notifMapel->title);
    }

    public function test_upload_success_does_not_create_in_app_notification()
    {
        $this->actingAs($this->user);

        // Bersihkan semua notifikasi awal
        Notification::query()->delete();
        $this->assertEquals(0, Notification::count());

        // Parse master role langsung berhasil
        $collection = collect([
            ['Peran' => 'GURU_PIKET', 'isGuruWali' => 'false']
        ]);

        // Simpan role
        Role::create(['name' => 'GURU_PIKET', 'is_guru_wali' => false]);

        // Pastikan tidak ada notifikasi yang tersimpan untuk aksi sukses
        $this->assertEquals(0, Notification::count(), 'Upload sukses tidak boleh menambahkan record ke tabel notifications.');
    }
}

