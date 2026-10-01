<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Major extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'majors';
    protected $fillable = [
        'code',
        'name'
    ];
}
