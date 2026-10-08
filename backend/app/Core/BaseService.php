<?php

namespace App\Core;

abstract class BaseService
{
    /**
     * Inisialisasi Base Class
     * 
     * [SOP ABSOLUT]: Chefs (Services) DILARANG KERAS ngambil bahan baku sendiri!
     * Tidak boleh ada query ke database, Eloquent ORM, atau koneksi ke rak penyimpanan di dalam Service. 
     * Chef harus menyuruh Helper (Repository) untuk mengambilkannya.
     */
    public function __construct()
    {
        // SOP dasar bisa disisipkan di sini
    }
}
