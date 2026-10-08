<?php

namespace App\Core;

abstract class BaseController
{
    /**
     * Inisialisasi Base Class
     * 
     * [SOP ABSOLUT]: Waiters (Controllers) DILARANG KERAS menyajikan piring (Response JSON) 
     * selain dari hasil plating piring "Resources" yang telah lolos QC "Tests".
     */
    public function __construct()
    {
        // SOP dasar bisa disisipkan di sini
    }
}
