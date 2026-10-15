<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class AcademicCalendar extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'academic_calendars';

    protected $fillable = [
        'academic_year_id',
        'name',
        'type',
        'start_date',
        'end_date',
        'target_grade',
        'is_holiday',
    ];

    protected $casts = [
        'start_date' => 'date:Y-m-d',
        'end_date' => 'date:Y-m-d',
        'is_holiday' => 'boolean',
    ];

    public function academicYear()
    {
        return $this->belongsTo(AcademicYear::class, 'academic_year_id');
    }

    public function assessments()
    {
        return $this->hasMany(Assessment::class, 'academic_calendar_id');
    }
}
