<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class PresensiLog extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'presensi_logs';
    protected $fillable = [
        'user_id',
        'scan_time',
        'status',
        'snapshot_url'
    ];

    public function user()
    {
        return $this->belongsTo(\App\Models\User::class, 'user_id');
    }

}
