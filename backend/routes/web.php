<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/dev/status-presensi', [\App\Http\Controllers\Api\DevController::class, 'statusPresensi']);
Route::get('/api/dev/status-presensi', [\App\Http\Controllers\Api\DevController::class, 'statusPresensi']);

// Mission Control / Project Retrospective Dashboard
Route::get('/retrospective', function () {
    return view('retrospective');
});
Route::get('/stats', function () {
    return view('retrospective');
});

// Fallback direct storage file serving (jika symlink public/storage belum di-generate di server)
Route::get('/storage/{path}', function ($path) {
    $filePath = storage_path('app/public/' . $path);
    if (!file_exists($filePath)) {
        abort(404);
    }
    return response()->file($filePath);
})->where('path', '.*');
