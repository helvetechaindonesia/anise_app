<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class StudentTaskGrade extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'student_task_grades';
    protected $fillable = [
        'submission_id',
        'teacher_id',
        'score'
    ];

    public function submission()
    {
        return $this->belongsTo(\App\Models\StudentTaskSubmission::class, 'submission_id');
    }

    public function teacher()
    {
        return $this->belongsTo(\App\Models\User::class, 'teacher_id');
    }

}
