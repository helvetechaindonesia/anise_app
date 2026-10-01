<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class StudentPointLog extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'student_point_logs';
    protected $fillable = [
        'student_id',
        'point_rule_id',
        'reporter_id',
        'points_change',
        'status'
    ];

    public function student()
    {
        return $this->belongsTo(\App\Models\User::class, 'student_id');
    }

    public function pointRule()
    {
        return $this->belongsTo(\App\Models\PointRule::class, 'point_rule_id');
    }

    public function reporter()
    {
        return $this->belongsTo(\App\Models\User::class, 'reporter_id');
    }

}
