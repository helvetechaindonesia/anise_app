<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\ComplaintCategory;
use App\Enums\ComplaintStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property string $id
 * @property string $user_id
 * @property ComplaintCategory $category
 * @property string $title
 * @property string $description
 * @property bool $is_anonymous
 * @property string|null $attachment_url
 * @property ComplaintStatus $status
 * @property string|null $response_note
 * @property string|null $handled_by
 * @property-read User|null $user
 * @property-read User|null $handler
 */
class Complaint extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'id',
        'user_id',
        'category',
        'title',
        'description',
        'is_anonymous',
        'attachment_url',
        'status',
        'response_note',
        'handled_by',
    ];

    protected $attributes = [
        'is_anonymous' => false,
        'status' => ComplaintStatus::Pending,
    ];

    protected function casts(): array
    {
        return [
            'category' => ComplaintCategory::class,
            'status' => ComplaintStatus::class,
            'is_anonymous' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function handler(): BelongsTo
    {
        return $this->belongsTo(User::class, 'handled_by');
    }
}
