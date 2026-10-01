<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('counseling_requests', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('student_id');
            $table->uuid('guru_bk_id')->nullable();
            $table->string('topic');
            $table->date('schedule_date');
            $table->string('schedule_time');
            $table->text('description')->nullable();
            $table->string('status')->default('PENDING'); // PENDING, APPROVED, REJECTED, COMPLETED
            $table->timestamps();

            $table->foreign('student_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('guru_bk_id')->references('id')->on('users')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('counseling_requests');
    }
};
