<?php

declare(strict_types=1);

namespace App\Enums;

enum ComplaintStatus: string
{
    case Pending = 'PENDING';
    case InProgress = 'IN_PROGRESS';
    case Resolved = 'RESOLVED';
    case Rejected = 'REJECTED';
}
