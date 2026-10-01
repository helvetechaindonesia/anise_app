<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('complaints', function (Blueprint $table) {
            // Flag Whistleblower: true jika pelapor minta dirahasiakan identitasnya dari publik/tersangka
            $table->boolean('is_anonymous')->default(false)->after('description');
        });
    }

    public function down(): void
    {
        Schema::table('complaints', function (Blueprint $table) {
            $table->dropColumn('is_anonymous');
        });
    }
};
