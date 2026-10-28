<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class CounselingRequest extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'counseling_requests';
    protected $fillable = [
        'id',
        'student_id',
        'guru_bk_id',
        'initiator',
        'topic',
        'schedule_date',
        'schedule_time',
        'description',
        'status',
        'check_in_time',
        'is_late',
        'minutes_late',
        'counseling_result',
        'filled_at',
        'rating',
        'notes_evaluasi',
        'likes_count',
    ];

    public function student()
    {
        return $this->belongsTo(\App\Models\User::class, 'student_id');
    }

    public function guruBk()
    {
        return $this->belongsTo(\App\Models\User::class, 'guru_bk_id');
    }

    public function comments()
    {
        return $this->hasMany(\App\Models\CounselingComment::class, 'counseling_id');
    }

    public function likes()
    {
        return $this->hasMany(\App\Models\CounselingLike::class, 'counseling_id');
    }
}
