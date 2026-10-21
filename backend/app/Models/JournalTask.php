<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class JournalTask extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'journal_tasks';
    protected $fillable = [
        'journal_id',
        'title',
        'due_date',
        'description'
    ];

    public function journal()
    {
        return $this->belongsTo(\App\Models\Journal::class, 'journal_id');
    }

    public function attachments()
    {
        return $this->hasMany(\App\Models\JournalTaskAttachment::class, 'journal_task_id');
    }

    public function submissions()
    {
        return $this->hasMany(\App\Models\StudentTaskSubmission::class, 'journal_task_id');
    }

    public function lateRequests()
    {
        return $this->hasMany(\App\Models\TaskLateSubmissionRequest::class, 'journal_task_id');
    }
}

