<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('complaints', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('category', 30); // FASILITAS, BULLYING, ASPIRASI
            $table->string('title');
            $table->text('description');
            $table->boolean('is_anonymous')->default(false);
            $table->text('attachment_url')->nullable();
            $table->string('status', 20)->default('PENDING'); // PENDING, IN_PROGRESS, RESOLVED, REJECTED
            $table->text('response_note')->nullable();
            $table->foreignUuid('handled_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('complaints');
    }
};
