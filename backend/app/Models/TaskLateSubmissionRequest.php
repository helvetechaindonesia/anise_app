<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class TaskLateSubmissionRequest extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'task_late_submission_requests';

    protected $fillable = [
        'journal_task_id',
        'student_id',
        'teacher_id',
        'reason',
        'status',
        'teacher_note',
        'extended_until',
        'responded_at'
    ];

    protected $casts = [
        'extended_until' => 'datetime',
        'responded_at' => 'datetime',
    ];

    protected function serializeDate(\DateTimeInterface $date): string
    {
        return $date->format(\DateTimeInterface::ATOM);
    }

    public function journalTask()
    {
        return $this->belongsTo(JournalTask::class, 'journal_task_id');
    }

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function teacher()
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }
}
