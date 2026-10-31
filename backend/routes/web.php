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

// Google Play Reviewer / Publisher Live Demo (Pure Flutter Web - No Login Required)
Route::get('/demo', function () {
    $indexPath = public_path('demo/index.html');
    if (file_exists($indexPath)) {
        return response()->file($indexPath, ['Content-Type' => 'text/html']);
    }
    return view('demo');
});

Route::get('/demo/{path}', function ($path) {
    $filePath = public_path('demo/' . $path);
    if (!file_exists($filePath)) {
        // Fallback jika single-page app route
        $indexPath = public_path('demo/index.html');
        if (file_exists($indexPath)) {
            return response()->file($indexPath, ['Content-Type' => 'text/html']);
        }
        abort(404);
    }

    $ext = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
    $mime = match ($ext) {
        'wasm' => 'application/wasm',
        'js' => 'application/javascript',
        'json' => 'application/json',
        'css' => 'text/css',
        'png' => 'image/png',
        'jpg', 'jpeg' => 'image/jpeg',
        'svg' => 'image/svg+xml',
        'otf' => 'font/otf',
        'ttf' => 'font/ttf',
        default => 'application/octet-stream',
    };

    return response()->file($filePath, ['Content-Type' => $mime]);
})->where('path', '.*');

Route::get('/live-demo', function () {
    return redirect('/demo');
});

// Fallback direct storage file serving (jika symlink public/storage belum di-generate di server)
Route::get('/storage/{path}', function ($path) {
    $filePath = storage_path('app/public/' . $path);
    if (!file_exists($filePath)) {
        abort(404);
    }
    return response()->file($filePath);
})->where('path', '.*');
