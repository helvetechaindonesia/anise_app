<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('journal_task_attachments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('journal_task_id')->constrained('journal_tasks')->cascadeOnDelete();
            $table->string('file_name');
            $table->text('file_url');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('journal_task_attachments');
    }
};
