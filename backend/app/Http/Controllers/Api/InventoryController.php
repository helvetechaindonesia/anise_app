<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class InventoryController extends Controller
{
    use ApiResponser;

    public function getItems(Request $request)
    {
        return $this->success([]);
    }

    public function getLoans(Request $request)
    {
        return $this->success([]);
    }

    public function requestLoan(Request $request)
    {
        return $this->success(null, 'Loan requested');
    }

    public function returnLoan(Request $request, $id)
    {
        return $this->success(null, 'Item returned');
    }
}
