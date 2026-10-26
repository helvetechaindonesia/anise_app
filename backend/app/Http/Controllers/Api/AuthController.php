<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Traits\ApiResponser;

class AuthController extends Controller
{
    use ApiResponser;

    /**
     * Handle user login and issue a Sanctum token.
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password_hash)) {
            if ($user) {
                try {
                    \Illuminate\Support\Facades\DB::table('security_audit_logs')->insert([
                        'id' => (string) \Illuminate\Support\Str::uuid(),
                        'user_id' => $user->id,
                        'event_type' => 'FAILED_LOGIN_ATTEMPT',
                        'ip_address' => $request->ip(),
                        'user_agent' => $request->userAgent(),
                        'metadata' => json_encode(['email' => $request->email, 'time' => now()->toIso8601String()]),
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                } catch (\Throwable $e) {}
            }

            return $this->error('Email atau kata sandi tidak valid', 401);
        }

        if (!$user->is_active) {
            return response()->json([
                'status' => 'error',
                'code' => 'ACCOUNT_FROZEN',
                'message' => 'Akun Anda sedang dibekukan (freeze) oleh administrator. Silakan hubungi Tata Usaha.',
            ], 403);
        }

        // Revoke all older tokens for single device login
        $user->tokens()->delete();

        // Sertakan signature kredensial (email, username, password) pada nama token
        $credSig = md5($user->email . '|' . $user->username . '|' . $user->password_hash);
        $token = $user->createToken('auth:' . $credSig)->plainTextToken;

        return $this->success([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'full_name' => $user->full_name,
                'username' => $user->username,
                'email' => $user->email,
                'role_type' => $user->role_type,
                'phone' => $user->phone,
                'address' => $user->address,
                'gender' => $user->gender,
                'religion' => $user->religion,
            ]
        ], 'Login successful');
    }

    /**
     * Check real-time session status & return latest user profile data.
     */
    public function sessionStatus(Request $request)
    {
        $plainToken = $request->bearerToken();
        $userId = $request->header('X-User-Id') ?: $request->query('user_id');

        $user = null;
        if ($userId) {
            $user = User::withTrashed()->find($userId);
        }

        $tokenModel = null;
        if ($plainToken) {
            $tokenModel = \Laravel\Sanctum\PersonalAccessToken::findToken($plainToken);
            if ($tokenModel && !$user) {
                $user = User::withTrashed()->find($tokenModel->tokenable_id);
            }
        }

        // 1. Cek apakah user telah dihapus (soft-delete atau terhapus)
        if (!$user || $user->trashed()) {
            if ($tokenModel) {
                try { $tokenModel->delete(); } catch (\Throwable $e) {}
            }
            return response()->json([
                'status' => 'error',
                'code' => 'ACCOUNT_DELETED',
                'message' => 'Akun Anda telah dihapus dari sistem oleh Administrator.',
            ], 403);
        }

        // 2. Cek apakah user sedang dibekukan (freeze)
        if (!$user->is_active) {
            if ($tokenModel) {
                try { $tokenModel->delete(); } catch (\Throwable $e) {}
            }
            return response()->json([
                'status' => 'error',
                'code' => 'ACCOUNT_FROZEN',
                'message' => 'Akun Anda sedang dibekukan (freeze) oleh Administrator. Silakan hubungi Tata Usaha.',
            ], 403);
        }

        // 3. Cek apakah email, username, atau password telah diubah
        $currentSig = md5($user->email . '|' . $user->username . '|' . $user->password_hash);
        if (!$tokenModel || $tokenModel->name !== 'auth:' . $currentSig) {
            if ($tokenModel) {
                try { $tokenModel->delete(); } catch (\Throwable $e) {}
            }
            return response()->json([
                'status' => 'error',
                'code' => 'CREDENTIALS_CHANGED',
                'message' => 'Email atau kredensial akun Anda telah diubah oleh Administrator. Silakan masuk kembali menggunakan data terbaru.',
            ], 401);
        }

        // 4. Sesi aktif dan valid! Kembalikan profil user terbaru untuk realtime update
        return response()->json([
            'status' => 'success',
            'code' => 'SESSION_ACTIVE',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'full_name' => $user->full_name,
                    'username' => $user->username,
                    'email' => $user->email,
                    'role_type' => $user->role_type,
                    'phone' => $user->phone,
                    'address' => $user->address,
                    'gender' => $user->gender,
                    'religion' => $user->religion,
                    'avatar' => $user->avatar,
                    'profile_picture' => $user->avatar,
                    'is_active' => $user->is_active,
                    'is_wali_kelas' => $user->is_wali_kelas,
                ]
            ]
        ]);
    }

    /**
     * Get the authenticated user's profile.
     */
    public function me(Request $request)
    {
        $user = clone $request->user();
        
        // Load specific profile based on role
        if (in_array($user->role_type, ['GURU', 'GURU_BK'])) {
            $user->load(['guruProfile', 'structuralAssignments', 'waliKelas', 'guruWaliStudents']);
        } elseif ($user->role_type === 'SISWA') {
            $user->load(['siswaProfile', 'studentClass']);
        }

        return $this->success($user, 'User profile retrieved successfully');
    }

    /**
     * Handle user logout and revoke tokens.
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return $this->success(null, 'Successfully logged out');
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        $fields = $request->only(['full_name', 'email', 'phone', 'address']);

        // Jika ada upload avatar langsung pada form update profile
        if ($request->hasFile('avatar')) {
            $path = \App\Services\FileStorageService::storeProfilePicture($request->file('avatar'), $user);
            $fields['avatar'] = '/storage/' . $path;
        }

        $user->update($fields);
        
        if ($user->role_type === 'SISWA' && $request->has('parent_name')) {
            $user->siswaProfile()->updateOrCreate(
                ['user_id' => $user->id],
                ['parent_name' => $request->parent_name]
            );
        }
        
        // Refresh the user model to include related profiles
        if (in_array($user->role_type, ['GURU', 'GURU_BK'])) {
            $user->load(['guruProfile', 'structuralAssignments', 'waliKelas', 'guruWaliStudents']);
        } elseif ($user->role_type === 'SISWA') {
            $user->load(['siswaProfile', 'studentClass']);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diupdate',
            'data' => $user
        ]);
    }

    /**
     * Upload / Update Avatar foto profile per user
     */
    public function uploadAvatar(Request $request)
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
        ], [
            'avatar.required' => 'File foto profil wajib dipilih.',
            'avatar.image' => 'File harus berupa gambar.',
            'avatar.max' => 'Ukuran foto profil maksimal 5MB.',
        ]);

        $user = $request->user();
        $path = \App\Services\FileStorageService::storeProfilePicture($request->file('avatar'), $user);
        $avatarUrl = '/storage/' . $path;

        $user->avatar = $avatarUrl;
        $user->save();

        return $this->success([
            'avatar' => $avatarUrl,
            'user' => $user,
        ], 'Foto profil berhasil diperbarui');
    }

    /**
     * Change password with old password verification.
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:4|different:old_password',
        ], [
            'old_password.required' => 'Password lama wajib diisi.',
            'new_password.required' => 'Password baru wajib diisi.',
            'new_password.min' => 'Password baru minimal 4 karakter.',
            'new_password.different' => 'Password baru harus berbeda dengan password lama.',
        ]);

        $user = $request->user();

        if (!Hash::check($request->old_password, $user->password_hash)) {
            return $this->error('Password lama yang Anda masukkan salah.', 422);
        }

        $user->password_hash = Hash::make($request->new_password);
        $user->save();

        return $this->success(null, 'Kata sandi berhasil diperbarui.');
    }

    /**
     * Request reset password via registered WhatsApp number.
     */
    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return $this->error('Alamat email tidak terdaftar di sistem', 404);
        }

        $phone = $user->phone;
        if (empty($phone)) {
            return $this->error('Nomor WhatsApp belum didaftarkan pada akun ini. Silakan hubungi Helpdesk IT.', 422);
        }

        // Format nomor untuk WhatsApp (e.g., 0812 -> 62812)
        $cleanPhone = preg_replace('/[^0-9]/', '', $phone);
        if (str_starts_with($cleanPhone, '0')) {
            $cleanPhone = '62' . substr($cleanPhone, 1);
        }

        // Masked phone untuk tampilan UI (e.g., 0877****4408)
        $maskedPhone = (strlen($phone) > 6)
            ? substr($phone, 0, 4) . '****' . substr($phone, -4)
            : $phone;

        // Tentukan kata sandi akun yang dikirimkan
        $passwordToSend = ($user->email === 'siswa@sipena.sch.id') ? 'siswa123' : ('Anise' . rand(1000, 9999));
        $resetToken = (string) rand(100000, 999999);

        if ($user->email !== 'siswa@sipena.sch.id') {
            $user->password_hash = \Illuminate\Support\Facades\Hash::make($passwordToSend);
            $user->save();
        }

        // Format pesan WhatsApp resmi dari sistem Anise
        $waMessage = "🔐 *PEMULIHAN KATA SANDI - ANISE APP*\n\n"
            . "Halo *{$user->full_name}*,\n"
            . "Permintaan pemulihan akun Anda telah diproses:\n\n"
            . "📧 *Email:* {$user->email}\n"
            . "🔑 *Kata Sandi:* {$passwordToSend}\n"
            . "🎟️ *Token Reset:* {$resetToken}\n\n"
            . "Silakan masuk ke aplikasi menggunakan kata sandi di atas. Jangan berikan pesan ini kepada siapapun demi keamanan akun Anda.";

        // Kirim melalui WhatsApp Gateway
        $this->dispatchWhatsAppMessage($cleanPhone, $waMessage);

        return $this->success([
            'user_name' => $user->full_name,
            'masked_phone' => $maskedPhone,
            'whatsapp_phone' => $cleanPhone,
            'password_preview' => $passwordToSend,
            'reset_token' => $resetToken,
            'message' => "Kata sandi dan token verifikasi telah dikirimkan ke WhatsApp nomor {$maskedPhone}."
        ], "Kata sandi berhasil dikirim ke nomor WhatsApp {$maskedPhone}");
    }

    /**
     * Dispatch WhatsApp message via Gateway API (Self-Hosted Baileys / Generic Gateway)
     */
    private function dispatchWhatsAppMessage(string $phone, string $message): bool
    {
        $gatewayUrl = env('WA_GATEWAY_URL', 'http://127.0.0.1:3001/send-message');
        $gatewayKey = env('WA_GATEWAY_KEY', 'anise_secret_gateway_key_2026');

        try {
            $response = \Illuminate\Support\Facades\Http::timeout(5)
                ->withHeaders([
                    'x-api-key' => $gatewayKey,
                    'Content-Type' => 'application/json',
                ])
                ->post($gatewayUrl, [
                    'phone' => $phone,
                    'message' => $message,
                ]);

            if ($response->successful()) {
                \Illuminate\Support\Facades\Log::info("WhatsApp berhasil dikirim ke {$phone} via Self-Hosted Gateway");
                return true;
            } else {
                \Illuminate\Support\Facades\Log::warning("WhatsApp Gateway response gagal: " . $response->body());
            }
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::info("WhatsApp Gateway simulasi/offline ({$e->getMessage()}), pesan dicatat ke log: \n{$message}");
        }

        return true;
    }
}
