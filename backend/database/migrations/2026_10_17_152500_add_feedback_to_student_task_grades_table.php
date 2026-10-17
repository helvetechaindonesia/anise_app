<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('student_task_grades') && !Schema::hasColumn('student_task_grades', 'feedback')) {
            Schema::table('student_task_grades', function (Blueprint $table) {
                $table->text('feedback')->nullable()->after('score');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('student_task_grades') && Schema::hasColumn('student_task_grades', 'feedback')) {
            Schema::table('student_task_grades', function (Blueprint $table) {
                $table->dropColumn('feedback');
            });
        }
    }
};
