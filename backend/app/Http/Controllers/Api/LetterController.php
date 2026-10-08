<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class LetterController extends Controller
{
    use ApiResponser;

    public function getIncomingLetters(Request $request)
    {
        return $this->success([]);
    }

    public function getOutgoingLetters(Request $request)
    {
        return $this->success([]);
    }

    public function storeOutgoingLetter(Request $request)
    {
        return $this->success(null, 'Outgoing letter archived');
    }
}
