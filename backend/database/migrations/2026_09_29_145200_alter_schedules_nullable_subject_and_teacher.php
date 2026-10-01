<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            $table->uuid('subject_id')->nullable()->change();
            $table->uuid('teacher_id')->nullable()->change();
            $table->string('activity_name')->nullable()->after('teacher_id');
        });
    }

    public function down(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            $table->uuid('subject_id')->nullable(false)->change();
            $table->uuid('teacher_id')->nullable(false)->change();
            $table->dropColumn('activity_name');
        });
    }
};
