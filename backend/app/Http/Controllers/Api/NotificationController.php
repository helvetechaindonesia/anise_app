<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

use App\Models\Notification;

class NotificationController extends Controller
{
    use ApiResponser;

    public function getNotifications(Request $request)
    {
        $userId = $request->user()?->id;
        if (!$userId) {
            return $this->success([]);
        }

        $notifications = Notification::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->orderBy('updated_at', 'desc')
            ->limit(100)
            ->get();

        return $this->success($notifications);
    }

    public function markAsRead(Request $request, $id)
    {
        Notification::where('user_id', $request->user()?->id)
            ->where('id', $id)
            ->update(['is_read' => true]);
        return $this->success(null, 'Marked as read');
    }

    public function markAllAsRead(Request $request)
    {
        Notification::where('user_id', $request->user()?->id)
            ->update(['is_read' => true]);
        return $this->success(null, 'All marked as read');
    }

    public function deleteAll(Request $request)
    {
        Notification::where('user_id', $request->user()?->id)->delete();
        return $this->success(null, 'All notifications deleted');
    }

    public function deleteNotification(Request $request, $id)
    {
        Notification::where('user_id', $request->user()?->id)
            ->where('id', $id)
            ->delete();
        return $this->success(null, 'Notification deleted');
    }
}
