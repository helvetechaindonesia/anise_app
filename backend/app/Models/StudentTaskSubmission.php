<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class StudentTaskSubmission extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'student_task_submissions';
    protected $fillable = [
        'journal_task_id',
        'student_id',
        'status',
        'answer_text',
        'attachment_url',
        'submitted_at'
    ];

    public function journalTask()
    {
        return $this->belongsTo(\App\Models\JournalTask::class, 'journal_task_id');
    }

    public function student()
    {
        return $this->belongsTo(\App\Models\User::class, 'student_id');
    }

    public function grade()
    {
        return $this->hasOne(\App\Models\StudentTaskGrade::class, 'submission_id');
    }
}
