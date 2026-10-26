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
    protected $appends = ['role_type', 'profile_picture', 'is_wali_kelas', 'class_name'];

    public function getRoleTypeAttribute()
    {
        return $this->role ? $this->role->name : null;
    }

    public function getProfilePictureAttribute()
    {
        return $this->avatar;
    }

    public function getIsWaliKelasAttribute(): bool
    {
        return \App\Models\SchoolClass::where('wali_kelas_id', $this->id)->exists();
    }

    public function getClassNameAttribute(): ?string
    {
        if ($this->relationLoaded('studentClass') && $this->studentClass) {
            return trim(($this->studentClass->grade_level ?? '') . ' ' . ($this->studentClass->name ?? ''));
        }

        // Cek via class_students
        $class = \Illuminate\Support\Facades\DB::table('class_students')
            ->join('classes', 'class_students.class_id', '=', 'classes.id')
            ->where('class_students.student_id', $this->id)
            ->where('class_students.status', 'ACTIVE')
            ->select('classes.grade_level', 'classes.name')
            ->first();

        if ($class) {
            return trim(($class->grade_level ?? '') . ' ' . ($class->name ?? ''));
        }

        return null;
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

    public function classStudent()
    {
        return $this->hasOne(ClassStudent::class, 'student_id')->where('status', 'ACTIVE');
    }

    public function studentClass()
    {
        return $this->hasOneThrough(
            SchoolClass::class,
            ClassStudent::class,
            'student_id', // Foreign key on ClassStudent table
            'id',         // Foreign key on SchoolClass table
            'id',         // Local key on User table
            'class_id'    // Local key on ClassStudent table
        )->where('class_students.status', 'ACTIVE');
    }
}
