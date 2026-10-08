<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class AnnouncementController extends Controller
{
    use ApiResponser;

    public function getAnnouncements(Request $request)
    {
        return $this->success([]);
    }

    public function storeAnnouncement(Request $request)
    {
        return $this->success(null, 'Announcement created');
    }

    public function markAsRead(Request $request, $id)
    {
        return $this->success(null, 'Announcement marked as read');
    }
}
