<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Data Master Fasilitas (Ruangan / Bangunan / Lapangan)
        Schema::create('facilities', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name'); // Misal: Lab Komputer 1, Lapangan Basket, Kelas 12 IPA
            $table->string('facility_type'); // CLASSROOM, LAB, FIELD, TOILET, BUILDING
            $table->integer('capacity')->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
        });

        // 2. Data Master Kategori Barang Inventaris
        Schema::create('inventory_categories', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name'); // Misal: Elektronik, Mebel, Alat Olahraga
            $table->text('description')->nullable();
            $table->timestamps();
        });

        // 3. Data Master Barang Inventaris (Aset Bergerak / Benda)
        Schema::create('inventory_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            
            // Barang ini ada di fasilitas/ruangan mana?
            $table->foreignUuid('facility_id')->nullable()->constrained('facilities')->nullOnDelete();
            
            // Kategori barangnya apa?
            $table->foreignUuid('category_id')->nullable()->constrained('inventory_categories')->nullOnDelete();
            
            $table->string('item_code')->unique(); // Barcode / Nomor Seri
            $table->string('name'); // Misal: Proyektor Epson, Bola Basket Spalding
            $table->integer('quantity')->default(1);
            $table->string('condition')->default('GOOD'); // GOOD, FAIR, BROKEN
            $table->date('purchase_date')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventory_items');
        Schema::dropIfExists('inventory_categories');
        Schema::dropIfExists('facilities');
    }
};
