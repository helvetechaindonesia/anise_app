<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class TeacherEvaluation extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'teacher_evaluations';

    protected $fillable = [
        'teacher_id',
        'evaluator_id',
        'academic_year_id',
        'praktik_kinerja',
        'perilaku_kerja',
        'predikat_kinerja',
        'notes',
        'is_published',
    ];

    protected $casts = [
        'is_published' => 'boolean',
    ];

    public function teacher()
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function evaluator()
    {
        return $this->belongsTo(User::class, 'evaluator_id');
    }

    public function academicYear()
    {
        return $this->belongsTo(AcademicYear::class, 'academic_year_id');
    }
}
