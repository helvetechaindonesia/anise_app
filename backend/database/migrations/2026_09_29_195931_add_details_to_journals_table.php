<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('journals', function (Blueprint $table) {
            $table->text('description')->nullable()->after('topic_material');
            $table->string('attachment_url')->nullable()->after('description');
            $table->boolean('has_task')->default(false)->after('attachment_url');
            $table->string('status')->default('Aktif')->after('has_task'); // Aktif / Selesai
        });
    }

    public function down(): void
    {
        Schema::table('journals', function (Blueprint $table) {
            $table->dropColumn(['description', 'attachment_url', 'has_task', 'status']);
        });
    }
};
