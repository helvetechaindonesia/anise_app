<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class JournalInteraction extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'journal_interactions';
    
    protected $fillable = [
        'id',
        'journal_id',
        'student_id',
        'interaction_type'
    ];

    public function journal()
    {
        return $this->belongsTo(Journal::class, 'journal_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}
