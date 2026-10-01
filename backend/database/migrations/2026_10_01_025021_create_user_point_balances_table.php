<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_point_balances', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('point_type'); // e.g., 'KEDISIPLINAN', 'KPI'
            $table->integer('total_points')->default(0);
            $table->timestamps();
            
            // Mencegah duplikat tipe poin untuk user yang sama
            $table->unique(['user_id', 'point_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_point_balances');
    }
};
