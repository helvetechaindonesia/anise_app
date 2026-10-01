<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Tambah kolom deskripsi di journal_tasks
        Schema::table('journal_tasks', function (Blueprint $table) {
            $table->text('description')->nullable()->after('title');
        });

        // 2. Ubah penamaan kolom di journal_task_attachments (ubah file_url jadi attachment_url)
        Schema::table('journal_task_attachments', function (Blueprint $table) {
            $table->renameColumn('file_name', 'attachment_name');
            $table->renameColumn('file_url', 'attachment_url');
        });

        // 3. Tambah kolom jawaban di student_task_submissions
        Schema::table('student_task_submissions', function (Blueprint $table) {
            $table->text('answer_text')->nullable()->after('status');
            $table->text('attachment_url')->nullable()->after('answer_text');
        });

        // 4. Hapus assessments karena akan dipindah ke Modul Agenda Penilaian
        Schema::dropIfExists('assessments');
    }

    public function down(): void
    {
        Schema::create('assessments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
            $table->foreignUuid('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->string('title');
            $table->date('assessment_date');
            $table->timestamps();
        });

        Schema::table('student_task_submissions', function (Blueprint $table) {
            $table->dropColumn(['answer_text', 'attachment_url']);
        });

        Schema::table('journal_task_attachments', function (Blueprint $table) {
            $table->renameColumn('attachment_name', 'file_name');
            $table->renameColumn('attachment_url', 'file_url');
        });

        Schema::table('journal_tasks', function (Blueprint $table) {
            $table->dropColumn('description');
        });
    }
};
