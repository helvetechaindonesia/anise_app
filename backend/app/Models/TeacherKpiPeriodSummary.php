<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class TeacherKpiPeriodSummary extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'teacher_kpi_period_summaries';
    protected $fillable = [
        'teacher_id',
        'academic_year_id',
        'period_month',
        'final_kpi_score'
    ];

    public function teacher()
    {
        return $this->belongsTo(\App\Models\User::class, 'teacher_id');
    }

    public function academicYear()
    {
        return $this->belongsTo(\App\Models\AcademicYear::class, 'academic_year_id');
    }

}
