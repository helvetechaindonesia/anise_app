<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Leave extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'leaves';

    protected $fillable = [
        'user_id',
        'type', // IZIN, SAKIT, DISPENSASI
        'reason',
        'start_date',
        'end_date',
        'exit_time',
        'returned_at',
        'attachment_path',
        'face_snapshot_url',
        'latitude',
        'longitude',
        'location_name',
        'status', // PENDING, APPROVED, REJECTED
        'approved_by',
        'approval_notes',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'returned_at' => 'datetime',
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
