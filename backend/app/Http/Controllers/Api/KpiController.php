<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class KpiController extends Controller
{
    use ApiResponser;

    public function getAnalysis(Request $request)
    {
        return $this->success([]);
    }

    public function getReports(Request $request)
    {
        return $this->success([]);
    }

    public function getEvaluations(Request $request)
    {
        return $this->success([]);
    }

    public function storeEvaluations(Request $request)
    {
        return $this->success(null, 'Evaluations submitted');
    }
}
