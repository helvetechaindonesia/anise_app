<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('subject_teachers')) {
            Schema::create('subject_teachers', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('subject_id')->constrained('subjects')->cascadeOnDelete();
                $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
                $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
                $table->foreignUuid('academic_year_id')->nullable()->constrained('academic_years')->nullOnDelete();
                $table->timestamps();

                $table->unique(['subject_id', 'teacher_id', 'class_id', 'academic_year_id'], 'sub_teach_cls_year_unique');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('subject_teachers');
    }
};
