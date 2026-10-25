<?php

declare(strict_types=1);

namespace App\Enums;

enum ComplaintCategory: string
{
    case Fasilitas = 'FASILITAS';
    case Bullying = 'BULLYING';
    case Aspirasi = 'ASPIRASI';
}
