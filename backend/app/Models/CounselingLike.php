<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class CounselingLike extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'counseling_likes';
    protected $fillable = [
        'id',
        'counseling_id',
        'user_id',
    ];

    public function counseling()
    {
        return $this->belongsTo(\App\Models\CounselingRequest::class, 'counseling_id');
    }

    public function user()
    {
        return $this->belongsTo(\App\Models\User::class, 'user_id');
    }
}
