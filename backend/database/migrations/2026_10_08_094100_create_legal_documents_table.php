<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('legal_documents', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->enum('document_type', ['PRIVACY_POLICY', 'TERMS_OF_SERVICE', 'DATA_RETENTION_POLICY']);
            $table->string('version_number'); // e.g. v1.0.0
            $table->text('content');
            $table->boolean('is_active')->default(false);
            $table->foreignUuid('published_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('legal_documents');
    }
};
