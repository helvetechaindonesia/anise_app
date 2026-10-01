<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class TeacherAttendance extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'teacher_attendances';
    protected $fillable = [
        'schedule_id',
        'teacher_id',
        'attendance_date',
        'check_in_time'
    ];

    public function schedule()
    {
        return $this->belongsTo(\App\Models\Schedule::class, 'schedule_id');
    }

    public function teacher()
    {
        return $this->belongsTo(\App\Models\User::class, 'teacher_id');
    }

}
