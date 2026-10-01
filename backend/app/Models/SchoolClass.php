<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class SchoolClass extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'classes';
    protected $fillable = [
        'academic_year_id',
        'name',
        'code',
        'grade_level',
        'major_id',
        'wali_kelas_id'
    ];

    public function waliKelas()
    {
        return $this->belongsTo(User::class, 'wali_kelas_id');
    }

    public function academicYear()
    {
        return $this->belongsTo(AcademicYear::class, 'academic_year_id');
    }

    public function major()
    {
        return $this->belongsTo(\App\Models\Major::class, 'major_id');
    }

}
