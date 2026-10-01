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
            return $this->error('Invalid credentials', 401);
        }

        if (!$user->is_active) {
            return $this->error('Account is inactive', 403);
        }

        // Revoke all older tokens for single device login, or just issue a new one
        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return $this->success([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'full_name' => $user->full_name,
                'username' => $user->username,
                'role_type' => $user->role_type,
            ]
        ], 'Login successful');
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
            $user->load('siswaProfile');
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
        $user = clone $request->user();
        $user->update($request->only(['full_name', 'email', 'phone', 'address']));
        
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
            $user->load('siswaProfile');
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diupdate',
            'data' => $user
        ]);
    }
}
