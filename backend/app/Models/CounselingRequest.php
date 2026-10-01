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
        'topic',
        'schedule_date',
        'schedule_time',
        'description',
        'status',
    ];

    public function student()
    {
        return $this->belongsTo(\App\Models\User::class, 'student_id');
    }

    public function guruBk()
    {
        return $this->belongsTo(\App\Models\User::class, 'guru_bk_id');
    }
}
