<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class JournalStudentRecord extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'journal_student_records';

    protected $fillable = [
        'id',
        'journal_id',
        'student_id',
        'record_type', // ABSENCE, VIOLATION, ACHIEVEMENT
        'keterangan',
        'attachment_url'
    ];

    public function journal()
    {
        return $this->belongsTo(Journal::class, 'journal_id');
    }

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}
