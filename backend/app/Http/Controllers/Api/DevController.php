<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use Illuminate\Support\Facades\Artisan;

class DevController extends Controller
{
    use ApiResponser;

    public function getLogs(Request $request)
    {
        return $this->success(['logs' => '']);
    }

    public function clearCache(Request $request)
    {
        Artisan::call('optimize:clear');
        return $this->success(null, 'Cache cleared');
    }

    public function impersonate(Request $request, $user_id)
    {
        return $this->success(null, 'Impersonating user ' . $user_id);
    }
}
