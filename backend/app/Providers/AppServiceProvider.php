<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // 1. Anti-Brute Force Login: Maksimal 5 percobaan gagal per 1 menit per kombinasi IP + Email
        RateLimiter::for('login', function (Request $request) {
            $email = (string) $request->email;
            $ip = $request->ip();

            return Limit::perMinute(5)->by($email . '|' . $ip)->response(function () {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Terlalu banyak percobaan login gagal. Demi keamanan, silakan coba lagi dalam 1 menit.',
                ], 429);
            });
        });

        // 2. Anti-Spam / Flooding Lupa Kata Sandi WhatsApp: Maksimal 3 request per 5 menit per IP + Email
        RateLimiter::for('forgot-password', function (Request $request) {
            $email = (string) $request->email;
            $ip = $request->ip();

            return Limit::perMinutes(5, 3)->by($email . '|' . $ip)->response(function () {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Terlalu banyak permintaan pemulihan kata sandi. Silakan tunggu 5 menit sebelum mencoba kembali.',
                ], 429);
            });
        });

        // 3. Global API Protection: Maksimal 120 request per menit per User / IP
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(120)->by($request->user()?->id ?: $request->ip());
        });

        // 4. Virtual Time Travel (php artisan server:travel)
        try {
            $mockTime = \Illuminate\Support\Facades\Cache::get('app_mock_time');
            if (!empty($mockTime)) {
                \Carbon\Carbon::setTestNow(\Carbon\Carbon::parse($mockTime));
            }
        } catch (\Throwable $e) {}
    }
}
