<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Drop old tables
        Schema::dropIfExists('teaching_administrations');
        Schema::dropIfExists('teacher_attendances');
        Schema::dropIfExists('journal_reviews');

        // 2. Refactor journals table
        Schema::table('journals', function (Blueprint $table) {
            $table->timestamp('published_at')->nullable()->after('teaching_date');
            
            $table->timestamp('check_in_time')->nullable()->after('status');
            $table->text('face_snapshot_url')->nullable()->after('check_in_time');
            $table->decimal('latitude', 10, 8)->nullable()->after('face_snapshot_url');
            $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
            
            $table->timestamp('filled_at')->nullable()->after('longitude');
            $table->text('class_notes')->nullable()->after('filled_at');
        });

        // 3. Create journal_student_records
        Schema::create('journal_student_records', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('record_type'); // ABSENCE, VIOLATION, ACHIEVEMENT
            $table->text('keterangan');
            $table->timestamps();
        });

        // 4. Create journal_interactions
        Schema::create('journal_interactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('interaction_type'); // LIKE, SAVE, SHARE
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('journal_interactions');
        Schema::dropIfExists('journal_student_records');

        Schema::table('journals', function (Blueprint $table) {
            $table->dropColumn([
                'published_at',
                'check_in_time',
                'face_snapshot_url',
                'latitude',
                'longitude',
                'filled_at',
                'class_notes'
            ]);
        });
    }
};
