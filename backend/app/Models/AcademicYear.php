<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class AcademicYear extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'academic_years';
    protected $fillable = [
        'name',
        'semester',
        'is_active',
        'start_date',
        'end_date'
    ];
}
