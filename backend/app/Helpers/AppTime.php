<?php

namespace App\Helpers;

use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;

class AppTime
{
    /**
     * Get the current effective application time.
     * Uses virtual mock time if set via 'php artisan server:travel', otherwise real system time.
     */
    public static function now(): Carbon
    {
        try {
            $mock = Cache::get('app_mock_time');
            if (!empty($mock)) {
                return Carbon::parse($mock);
            }

            $filePath = storage_path('app/mock_time.txt');
            if (file_exists($filePath)) {
                $fileMock = trim(file_get_contents($filePath));
                if (!empty($fileMock)) {
                    return Carbon::parse($fileMock);
                }
            }
        } catch (\Throwable $e) {}

        return Carbon::now();
    }
}
