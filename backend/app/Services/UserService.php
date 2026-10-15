<?php

namespace App\Services;

use App\Repositories\UserRepository;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserService
{
    protected UserRepository $userRepo;

    /**
     * Inisialisasi Service (Chef)
     * Inject Helper (Repositories) yang dibutuhkan di sini via Dependency Injection
     */
    public function __construct(UserRepository $userRepo)
    {
        $this->userRepo = $userRepo;
    }

    /**
     * Register or update user with complete profile data including religion
     */
    public function syncUserData(array $data): User
    {
        $username = $data['username'];
        $attributes = ['username' => $username];
        
        $values = [
            'full_name' => $data['full_name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
            'address' => $data['address'] ?? null,
            'gender' => $data['gender'] ?? 'L',
            'religion' => $data['religion'] ?? null,
            'role_id' => $data['role_id'],
            'is_active' => $data['is_active'] ?? true,
        ];

        if (!empty($data['password'])) {
            $values['password_hash'] = Hash::make($data['password']);
        }

        return $this->userRepo->createOrUpdate($attributes, $values);
    }
}
