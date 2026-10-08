<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class SupportController extends Controller
{
    use ApiResponser;

    public function getFaqs(Request $request)
    {
        return $this->success([]);
    }

    public function getSecurityLogs(Request $request)
    {
        return $this->success([]);
    }
}
