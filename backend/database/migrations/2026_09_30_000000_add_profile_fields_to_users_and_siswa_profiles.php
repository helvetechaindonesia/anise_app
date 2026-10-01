<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->nullable();
            $table->text('address')->nullable();
        });

        Schema::table('siswa_profiles', function (Blueprint $table) {
            $table->string('parent_name')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'address']);
        });

        Schema::table('siswa_profiles', function (Blueprint $table) {
            $table->dropColumn('parent_name');
        });
    }
};
