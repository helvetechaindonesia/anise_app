<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class PointController extends Controller
{
    use ApiResponser;

    public function getBalance(Request $request)
    {
        return $this->success(['balance' => 0]);
    }

    public function getRules(Request $request)
    {
        return $this->success([]);
    }

    public function getHistory(Request $request)
    {
        return $this->success([]);
    }
}
