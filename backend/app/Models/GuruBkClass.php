<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class GuruBkClass extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'guru_bk_classes';
    protected $fillable = [
        'guru_id',
        'class_id',
        'academic_year_id'
    ];

    public function guru()
    {
        return $this->belongsTo(\App\Models\User::class, 'guru_id');
    }

    public function class()
    {
        return $this->belongsTo(\App\Models\SchoolClass::class, 'class_id');
    }

    public function academicYear()
    {
        return $this->belongsTo(\App\Models\AcademicYear::class, 'academic_year_id');
    }

}
