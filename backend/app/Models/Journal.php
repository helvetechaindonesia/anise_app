<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Journal extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'journals';
    protected $fillable = [
        'schedule_id',
        'teacher_id',
        'class_id',
        'subject_id',
        'teaching_date',
        'published_at',
        'topic_material',
        'description',
        'attachment_url',
        'has_task',
        'status',
        'check_in_time',
        'face_snapshot_url',
        'latitude',
        'longitude',
        'filled_at',
        'class_notes'
    ];

    protected $casts = [
        'has_task' => 'boolean',
    ];

    public function schedule()
    {
        return $this->belongsTo(\App\Models\Schedule::class, 'schedule_id');
    }

    public function teacher()
    {
        return $this->belongsTo(\App\Models\User::class, 'teacher_id');
    }

    public function class()
    {
        return $this->belongsTo(\App\Models\SchoolClass::class, 'class_id');
    }

    public function subject()
    {
        return $this->belongsTo(\App\Models\Subject::class, 'subject_id');
    }

    public function tasks()
    {
        return $this->hasMany(\App\Models\JournalTask::class, 'journal_id');
    }

    public function reviews()
    {
        return $this->hasMany(\App\Models\JournalReview::class, 'journal_id');
    }

    public function comments()
    {
        return $this->hasMany(\App\Models\JournalComment::class, 'journal_id');
    }

    public function interactions()
    {
        return $this->hasMany(\App\Models\JournalInteraction::class, 'journal_id');
    }

    public function studentRecords()
    {
        return $this->hasMany(\App\Models\JournalStudentRecord::class, 'journal_id');
    }
}
