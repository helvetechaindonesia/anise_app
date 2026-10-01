<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class PointRule extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'point_rules';
    protected $fillable = [
        'code',
        'type',
        'points'
    ];
}
