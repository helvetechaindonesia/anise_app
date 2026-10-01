<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class TeachingAdministration extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'teaching_administrations';
    protected $fillable = [
        'guru_id',
        'subject_id',
        'document_name',
        'document_url'
    ];

    public function guru()
    {
        return $this->belongsTo(\App\Models\User::class, 'guru_id');
    }

    public function subject()
    {
        return $this->belongsTo(\App\Models\Subject::class, 'subject_id');
    }

}
