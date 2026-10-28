<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('complaints')) {
            Schema::table('complaints', function (Blueprint $table) {
                if (!Schema::hasColumn('complaints', 'handled_by')) {
                    $table->foreignUuid('handled_by')->nullable()->after('response_note')->constrained('users')->nullOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('complaints')) {
            Schema::table('complaints', function (Blueprint $table) {
                if (Schema::hasColumn('complaints', 'handled_by')) {
                    $table->dropForeign(['handled_by']);
                    $table->dropColumn('handled_by');
                }
            });
        }
    }
};
