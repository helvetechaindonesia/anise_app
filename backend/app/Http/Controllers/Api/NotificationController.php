<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class NotificationController extends Controller
{
    use ApiResponser;

    public function getNotifications(Request $request)
    {
        return $this->success([]);
    }

    public function markAsRead(Request $request, $id)
    {
        return $this->success(null, 'Marked as read');
    }

    public function markAllAsRead(Request $request)
    {
        return $this->success(null, 'All marked as read');
    }
}
