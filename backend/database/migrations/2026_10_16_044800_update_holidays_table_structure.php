<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('holidays')) {
            Schema::create('holidays', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->foreignUuid('academic_year_id')->nullable()->constrained('academic_years')->nullOnDelete();
                $table->string('name');
                $table->date('start_date');
                $table->date('end_date');
                $table->string('type')->default('NASIONAL');
                $table->text('description')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
            return;
        }

        // Jika tabel sudah ada dari migrasi lama (hanya kolom 'tanggal' & 'keterangan')
        Schema::table('holidays', function (Blueprint $table) {
            if (!Schema::hasColumn('holidays', 'academic_year_id')) {
                $table->foreignUuid('academic_year_id')->nullable()->constrained('academic_years')->nullOnDelete();
            }
            if (!Schema::hasColumn('holidays', 'name')) {
                $table->string('name')->default('Hari Libur');
            }
            if (!Schema::hasColumn('holidays', 'start_date')) {
                $table->date('start_date')->nullable();
            }
            if (!Schema::hasColumn('holidays', 'end_date')) {
                $table->date('end_date')->nullable();
            }
            if (!Schema::hasColumn('holidays', 'type')) {
                $table->string('type')->default('NASIONAL');
            }
            if (!Schema::hasColumn('holidays', 'description')) {
                $table->text('description')->nullable();
            }
            if (!Schema::hasColumn('holidays', 'is_active')) {
                $table->boolean('is_active')->default(true);
            }
        });

        // Migrasi data lama dari kolom tanggal/keterangan jika ada
        if (Schema::hasColumn('holidays', 'tanggal') && Schema::hasColumn('holidays', 'start_date')) {
            try {
                DB::table('holidays')->whereNull('start_date')->update([
                    'start_date' => DB::raw('tanggal'),
                    'end_date' => DB::raw('tanggal'),
                    'name' => DB::raw('keterangan'),
                ]);
            } catch (\Throwable $e) {
                // Ignore if empty
            }

            Schema::table('holidays', function (Blueprint $table) {
                $table->dropColumn(['tanggal', 'keterangan']);
            });
        }
    }

    public function down(): void
    {
        // Keep intact for safety
    }
};
