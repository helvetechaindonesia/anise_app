<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Attendance extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'attendances';
    protected $fillable = [
        'user_id',
        'tanggal',
        'jam_masuk',
        'jam_pulang',
        'status',
        'pulang_awal_reason',
    ];

    protected $casts = [
        'tanggal' => 'date',
        'jam_masuk' => 'datetime',
        'jam_pulang' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(\App\Models\User::class, 'user_id');
    }
}
