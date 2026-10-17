<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\AcademicYear;
use App\Models\SchoolClass;
use App\Models\Subject;
use App\Models\Schedule;
use App\Models\Journal;
use App\Models\JournalTask;
use App\Models\ClassStudent;
use App\Models\StudentTaskSubmission;
use App\Models\StudentTaskGrade;
use Carbon\Carbon;

class AssignmentTest extends TestCase
{
    use RefreshDatabase;

    protected $guru;
    protected $siswa;
    protected $class;
    protected $subject;
    protected $schedule;
    protected $journal;

    protected function setUp(): void
    {
        parent::setUp();

        $guruRole = Role::firstOrCreate(['name' => 'GURU']);
        $siswaRole = Role::firstOrCreate(['name' => 'SISWA']);

        $academicYear = AcademicYear::create([
            'name' => '2026/2027',
            'semester' => 'GANJIL',
            'start_date' => '2026-07-01',
            'end_date' => '2026-12-31',
            'is_active' => true,
        ]);

        $this->guru = User::create([
            'full_name' => 'Guru Pengajar',
            'username' => 'guru_pengajar',
            'email' => 'guru@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $guruRole->id,
            'is_active' => true,
        ]);

        $this->siswa = User::create([
            'full_name' => 'Siswa Pintar',
            'username' => 'siswa_pintar',
            'email' => 'siswa@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $siswaRole->id,
            'is_active' => true,
        ]);

        $this->class = SchoolClass::create([
            'name' => 'X RPL 1',
            'code' => '10-X-RPL-1',
            'grade_level' => 10,
            'academic_year_id' => $academicYear->id,
        ]);

        $this->subject = Subject::create([
            'name' => 'Matematika Terapan',
            'code' => 'MTK01',
        ]);

        ClassStudent::create([
            'class_id' => $this->class->id,
            'student_id' => $this->siswa->id,
            'status' => 'ACTIVE',
        ]);

        $this->schedule = Schedule::create([
            'teacher_id' => $this->guru->id,
            'class_id' => $this->class->id,
            'subject_id' => $this->subject->id,
            'academic_year_id' => $academicYear->id,
            'day_of_week' => 'Senin',
            'start_time' => '07:30:00',
            'end_time' => '09:30:00',
        ]);

        $this->journal = Journal::create([
            'schedule_id' => $this->schedule->id,
            'teacher_id' => $this->guru->id,
            'subject_id' => $this->subject->id,
            'class_id' => $this->class->id,
            'topic_material' => 'Trigonometri Dasar',
            'description' => 'Pembahasan sudut istimewa',
            'teaching_date' => Carbon::now()->toDateString(),
            'has_task' => true,
            'status' => 'Selesai',
        ]);
    }

    /**
     * Test 1: Jurnal dengan has_task = true yang belum punya JournalTask muncul sebagai cangkang tugas di GET /assignments
     */
    public function test_get_tasks_returns_cangkang_tugas_and_insights(): void
    {
        $response = $this->actingAs($this->guru)->getJson('/api/assignments');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ])
            ->assertJsonStructure([
                'status',
                'data',
                'categories' => ['pending', 'active', 'completed'],
                'insight' => ['pending_count', 'active_count', 'completed_count', 'total_count']
            ]);

        $this->assertEquals(1, $response->json('insight.pending_count'));
        $this->assertTrue($response->json('data.0.is_cangkang'));
    }

    /**
     * Test 2: Guru dapat membuat tugas baru dari jurnal
     */
    public function test_guru_can_create_task(): void
    {
        $dueDate = Carbon::now()->addDays(2)->toDateTimeString();

        $response = $this->actingAs($this->guru)->postJson('/api/assignments', [
            'journal_id' => $this->journal->id,
            'title' => 'Latihan Soal Sudut Istimewa',
            'description' => 'Kerjakan soal 1-5 di buku tulis',
            'due_date' => $dueDate,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Tugas berhasil dibuat dan dibagikan ke siswa.'
            ]);

        $this->assertDatabaseHas('journal_tasks', [
            'journal_id' => $this->journal->id,
            'title' => 'Latihan Soal Sudut Istimewa',
        ]);
    }

    /**
     * Test 3: Siswa dapat melihat tugas dan mengumpulkan jawaban
     */
    public function test_siswa_can_view_and_submit_task(): void
    {
        $task = JournalTask::create([
            'journal_id' => $this->journal->id,
            'title' => 'Tugas Aljabar Linear',
            'description' => 'Selesaikan sistem persamaan',
            'due_date' => Carbon::now()->addDays(3)->toDateTimeString(),
        ]);

        $viewResponse = $this->actingAs($this->siswa)->getJson('/api/assignments/siswa');
        $viewResponse->assertStatus(200)
            ->assertJson(['status' => 'success']);

        $submitResponse = $this->actingAs($this->siswa)->postJson('/api/assignments/submit', [
            'journal_task_id' => $task->id,
            'answer_text' => 'Jawaban x = 4, y = 2',
        ]);

        $submitResponse->assertStatus(200)
            ->assertJson(['status' => 'success']);

        $this->assertDatabaseHas('student_task_submissions', [
            'journal_task_id' => $task->id,
            'student_id' => $this->siswa->id,
            'status' => 'SUBMITTED',
            'answer_text' => 'Jawaban x = 4, y = 2',
        ]);
    }

    /**
     * Test 4: Guru dapat melihat submission siswa dan memberikan nilai serta feedback
     */
    public function test_guru_can_view_submissions_and_grade_student(): void
    {
        $task = JournalTask::create([
            'journal_id' => $this->journal->id,
            'title' => 'Tugas Geometri',
            'description' => 'Hitung volume bangun ruang',
            'due_date' => Carbon::now()->addDays(1)->toDateTimeString(),
        ]);

        $submission = StudentTaskSubmission::create([
            'journal_task_id' => $task->id,
            'student_id' => $this->siswa->id,
            'status' => 'SUBMITTED',
            'answer_text' => 'Volume = 120 cm3',
            'submitted_at' => Carbon::now(),
        ]);

        // Guru ambil submissions list
        $submissionsResponse = $this->actingAs($this->guru)->getJson("/api/assignments/{$task->id}/submissions");
        $submissionsResponse->assertStatus(200)
            ->assertJson(['status' => 'success'])
            ->assertJsonPath('data.task.title', 'Tugas Geometri');

        // Guru beri nilai (Grade Submission)
        $gradeResponse = $this->actingAs($this->guru)->postJson("/api/assignments/submissions/{$submission->id}/grade", [
            'score' => 95,
            'feedback' => 'Penjelasan langkah sangat detail dan rapi!',
        ]);

        $gradeResponse->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'submission_id' => $submission->id,
                    'score' => 95,
                    'feedback' => 'Penjelasan langkah sangat detail dan rapi!',
                ]
            ]);

        $this->assertDatabaseHas('student_task_grades', [
            'submission_id' => $submission->id,
            'teacher_id' => $this->guru->id,
            'score' => 95,
            'feedback' => 'Penjelasan langkah sangat detail dan rapi!',
        ]);

        $this->assertDatabaseHas('student_task_submissions', [
            'id' => $submission->id,
            'status' => 'GRADED',
        ]);
    }

    /**
     * Test 5: Guru penerbit menghapus tugas -> tugas dikembalikan ke cangkang (journal has_task = true)
     */
    public function test_delete_task_reverts_to_cangkang(): void
    {
        $task = JournalTask::create([
            'journal_id' => $this->journal->id,
            'title' => 'Tugas Aljabar Linear',
            'description' => 'Kerjakan nomor 1 - 10',
            'due_date' => Carbon::now()->addDays(2)->toDateTimeString(),
        ]);

        $response = $this->actingAs($this->guru)->deleteJson("/api/assignments/{$task->id}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        // Pastikan JournalTask terhapus
        $this->assertDatabaseMissing('journal_tasks', ['id' => $task->id]);

        // Pastikan Journal tetap ada dan has_task = true (kembali ke cangkang di tab Belum)
        $this->assertDatabaseHas('journals', [
            'id' => $this->journal->id,
            'has_task' => true,
        ]);
    }

    /**
     * Test 6: Bukan penerbit tidak bisa mengedit atau menghapus tugas
     */
    public function test_non_publisher_cannot_edit_or_delete_task(): void
    {
        $guruRole = Role::firstOrCreate(['name' => 'GURU']);
        $otherGuru = User::create([
            'full_name' => 'Guru Lain',
            'username' => 'guru_lain',
            'email' => 'otherguru@sekolah.sch.id',
            'password_hash' => bcrypt('password'),
            'role_id' => $guruRole->id,
            'is_active' => true,
        ]);

        $task = JournalTask::create([
            'journal_id' => $this->journal->id,
            'title' => 'Tugas Fisika',
            'description' => 'Hukum Newton',
            'due_date' => Carbon::now()->addDays(2)->toDateTimeString(),
        ]);

        // Coba edit oleh guru lain
        $editResponse = $this->actingAs($otherGuru)->putJson("/api/assignments/{$task->id}", [
            'title' => 'Ganti Judul Ilegal',
            'description' => 'Ganti deskripsi ilegal',
            'due_date' => Carbon::now()->addDays(5)->toDateTimeString(),
        ]);
        $editResponse->assertStatus(403);

        // Coba hapus oleh guru lain
        $deleteResponse = $this->actingAs($otherGuru)->deleteJson("/api/assignments/{$task->id}");
        $deleteResponse->assertStatus(403);

        // Pastikan tugas masih utuh
        $this->assertDatabaseHas('journal_tasks', [
            'id' => $task->id,
            'title' => 'Tugas Fisika',
        ]);
    }
}
