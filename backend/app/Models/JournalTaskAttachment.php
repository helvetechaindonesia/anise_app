<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class JournalTaskAttachment extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'journal_task_attachments';
    protected $fillable = [
        'journal_task_id',
        'file_name',
        'file_url'
    ];

    public function journalTask()
    {
        return $this->belongsTo(\App\Models\JournalTask::class, 'journal_task_id');
    }

}
