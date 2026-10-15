<?php

namespace App\Repositories;

use App\Models\User;

class UserRepository
{
    /**
     * Find user by username
     */
    public function findByUsername(string $username): ?User
    {
        return User::where('username', $username)->first();
    }

    /**
     * Find user by ID
     */
    public function findById(string $id): ?User
    {
        return User::find($id);
    }

    /**
     * Create or update user with attributes including religion
     */
    public function createOrUpdate(array $attributes, array $values): User
    {
        return User::updateOrCreate($attributes, $values);
    }

    /**
     * Get users by role
     */
    public function getByRole(string $roleName)
    {
        return User::whereHas('role', fn($q) => $q->where('name', $roleName))
            ->orderBy('full_name', 'asc')
            ->get();
    }
}
