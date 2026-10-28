<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('counseling_requests', function (Blueprint $table) {
            if (!Schema::hasColumn('counseling_requests', 'check_in_time')) {
                $table->timestamp('check_in_time')->nullable()->after('status');
            }
            if (!Schema::hasColumn('counseling_requests', 'is_late')) {
                $table->boolean('is_late')->default(false)->after('check_in_time');
            }
            if (!Schema::hasColumn('counseling_requests', 'minutes_late')) {
                $table->integer('minutes_late')->default(0)->after('is_late');
            }
            if (!Schema::hasColumn('counseling_requests', 'filled_at')) {
                $table->timestamp('filled_at')->nullable()->after('counseling_result');
            }
            if (!Schema::hasColumn('counseling_requests', 'rating')) {
                $table->decimal('rating', 2, 1)->nullable()->after('filled_at');
            }
            if (!Schema::hasColumn('counseling_requests', 'notes_evaluasi')) {
                $table->text('notes_evaluasi')->nullable()->after('rating');
            }
            if (!Schema::hasColumn('counseling_requests', 'likes_count')) {
                $table->integer('likes_count')->default(0)->after('notes_evaluasi');
            }
        });

        // Tabel untuk like bimbingan (user can like a counseling item)
        if (!Schema::hasTable('counseling_likes')) {
            Schema::create('counseling_likes', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('counseling_id');
                $table->uuid('user_id');
                $table->timestamps();

                $table->unique(['counseling_id', 'user_id']);
            });
        }

        // Tabel untuk komentar bimbingan
        if (!Schema::hasTable('counseling_comments')) {
            Schema::create('counseling_comments', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('counseling_id');
                $table->uuid('user_id');
                $table->text('comment_text');
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::table('counseling_requests', function (Blueprint $table) {
            $table->dropColumn([
                'check_in_time',
                'is_late',
                'minutes_late',
                'filled_at',
                'rating',
                'notes_evaluasi',
                'likes_count'
            ]);
        });

        Schema::dropIfExists('counseling_likes');
        Schema::dropIfExists('counseling_comments');
    }
};
