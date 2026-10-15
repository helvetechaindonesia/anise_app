<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckUserSessionStatus
{
    /**
     * Handle an incoming request and verify user session validity.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user) {
            // 1. Cek apakah akun sedang di-freeze / tidak aktif
            if (!$user->is_active) {
                try {
                    $user->currentAccessToken()?->delete();
                } catch (\Throwable $e) {}

                return response()->json([
                    'status' => 'error',
                    'code' => 'ACCOUNT_FROZEN',
                    'message' => 'Akun Anda sedang dibekukan (freeze) oleh Administrator. Silakan hubungi Tata Usaha.',
                ], 403);
            }

            // 2. Cek apakah email, username, atau password (kredensial) telah diedit sejak token diterbitkan
            $token = $user->currentAccessToken();
            if ($token) {
                $currentSig = md5($user->email . '|' . $user->username . '|' . $user->password_hash);
                if ($token->name !== 'auth:' . $currentSig) {
                    try {
                        $token->delete();
                    } catch (\Throwable $e) {}

                    return response()->json([
                        'status' => 'error',
                        'code' => 'CREDENTIALS_CHANGED',
                        'message' => 'Email atau kredensial akun Anda telah diubah oleh Administrator. Silakan masuk kembali menggunakan data terbaru.',
                    ], 401);
                }
            }
        }

        return $next($request);
    }
}
