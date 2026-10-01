<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
            // Standar KKM Mata Pelajaran (Bisa diatur beda-beda tiap mapel oleh Kurikulum)
            $table->decimal('passing_grade', 5, 2)->default(75.00)->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
            $table->dropColumn('passing_grade');
        });
    }
};
