<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('student_reports', function (Blueprint $table) {
            $table->string('category')->nullable();
            $table->string('image_path')->nullable();
            $table->boolean('is_anonymous')->default(false);
        });
    }

    public function down()
    {
        Schema::table('student_reports', function (Blueprint $table) {
            $table->dropColumn(['category', 'image_path', 'is_anonymous']);
        });
    }
};
