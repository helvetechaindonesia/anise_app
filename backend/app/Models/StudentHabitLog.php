<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class StudentHabitLog extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'student_habit_logs';
    protected $fillable = [
        'student_id',
        'habit_id',
        'logged_date',
        'status'
    ];

    public function student()
    {
        return $this->belongsTo(\App\Models\User::class, 'student_id');
    }

    public function habit()
    {
        return $this->belongsTo(\App\Models\Habit::class, 'habit_id');
    }

}
