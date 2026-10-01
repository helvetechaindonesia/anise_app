<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('assessments', function (Blueprint $table) {
            // Nullable karena ujian formatif tidak wajib ikut kalender akademik
            $table->uuid('academic_calendar_id')->nullable()->change();
            // Judul ditambahkan khusus untuk penamaan ujian formatif
            $table->string('title')->nullable()->after('teacher_id');
        });
    }

    public function down(): void
    {
        Schema::table('assessments', function (Blueprint $table) {
            $table->uuid('academic_calendar_id')->nullable(false)->change();
            $table->dropColumn('title');
        });
    }
};
