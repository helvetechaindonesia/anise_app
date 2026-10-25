<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/dev/status-presensi', [\App\Http\Controllers\Api\DevController::class, 'statusPresensi']);
Route::get('/api/dev/status-presensi', [\App\Http\Controllers\Api\DevController::class, 'statusPresensi']);
