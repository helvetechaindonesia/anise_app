<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class EmployeeLeave extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'employee_leaves';

    protected $fillable = [
        'employee_id',
        'type', // SAKIT, CUTI, DINAS_LUAR, IZIN
        'reason',
        'start_date',
        'end_date',
        'attachment_path',
        'status', // PENDING, APPROVED, REJECTED
        'approved_by',
        'face_snapshot_url',
        'latitude',
        'longitude',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    public function employee()
    {
        return $this->belongsTo(User::class, 'employee_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
