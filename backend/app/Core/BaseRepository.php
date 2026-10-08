<?php

namespace App\Core;

abstract class BaseRepository
{
    /**
     * Inisialisasi Base Class
     * 
     * [SOP ABSOLUT]: Helpers (Repositories) DILARANG KERAS ikut masak!
     * Tidak boleh ada logika bisnis, if/else rumit, atau manipulasi data di dalam Repository. 
     * Helper murni hanya kurir pembawa bahan baku dari Database/Rak.
     */
    public function __construct()
    {
        // SOP dasar bisa disisipkan di sini
    }
}
