<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class JournalReview extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'journal_reviews';
    protected $fillable = [
        'journal_id',
        'student_id',
        'rating',
        'review_text'
    ];

    public function journal()
    {
        return $this->belongsTo(\App\Models\Journal::class, 'journal_id');
    }

    public function student()
    {
        return $this->belongsTo(\App\Models\User::class, 'student_id');
    }

}
