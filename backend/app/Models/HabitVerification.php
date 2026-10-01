<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class HabitVerification extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'habit_verifications';
    protected $fillable = [
        'student_habit_log_id',
        'teacher_id',
        'status',
        'verification_note'
    ];

    public function studentHabitLog()
    {
        return $this->belongsTo(\App\Models\StudentHabitLog::class, 'student_habit_log_id');
    }

    public function teacher()
    {
        return $this->belongsTo(\App\Models\User::class, 'teacher_id');
    }

}
