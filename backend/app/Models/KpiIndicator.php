<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class KpiIndicator extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'kpi_indicators';
    protected $fillable = [
        'code',
        'weight_percentage'
    ];
}
