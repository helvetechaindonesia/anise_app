<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

#[Fillable(['full_name', 'username', 'email', 'password_hash', 'role_id', 'is_active', 'phone', 'address', 'gender', 'religion', 'avatar', 'birth_place', 'birth_date'])]
#[Hidden(['password_hash', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable, \Laravel\Sanctum\HasApiTokens, \Illuminate\Database\Eloquent\Concerns\HasUuids, \Illuminate\Database\Eloquent\SoftDeletes;

    protected $fillable = [
        'full_name',
        'username',
        'email',
        'password_hash',
        'role_id',
        'is_active',
        'phone',
        'address',
        'gender',
        'religion',
        'avatar',
        'birth_place',
        'birth_date',
        'has_registered_biometric',
        'face_embedding',
    ];

    /**
     * Get the password for the user.
     */
    public function getAuthPasswordName(): string
    {
        return 'password_hash';
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password_hash' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    // Append custom attribute
    protected $appends = ['role_type', 'profile_picture'];

    public function getRoleTypeAttribute()
    {
        return $this->role ? $this->role->name : null;
    }

    public function getProfilePictureAttribute()
    {
        return $this->avatar;
    }

    // Relationships
    public function role()
    {
        return $this->belongsTo(Role::class, 'role_id');
    }

    public function guruProfile()
    {
        return $this->hasOne(GuruProfile::class, 'user_id');
    }

    public function siswaProfile()
    {
        return $this->hasOne(SiswaProfile::class, 'user_id');
    }

    public function structuralAssignments()
    {
        return $this->hasMany(StructuralAssignment::class, 'guru_id');
    }

    public function waliKelas()
    {
        return $this->hasMany(SchoolClass::class, 'wali_kelas_id');
    }

    public function guruWaliStudents()
    {
        return $this->hasMany(GuruWaliStudent::class, 'guru_id');
    }
}
