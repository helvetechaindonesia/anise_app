<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class StudentReport extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'student_reports';
    protected $fillable = [
        'student_id',
        'report_title',
        'report_text',
        'status', 'category', 'image_path', 'is_anonymous'
    ];

    public function student()
    {
        return $this->belongsTo(\App\Models\User::class, 'student_id');
    }

}

