<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class AssessmentController extends Controller
{
    use ApiResponser;

    public function getAgendas(Request $request)
    {
        // TODO: Implement get agendas
        return $this->success([]);
    }

    public function storeAgenda(Request $request)
    {
        // TODO: Implement store agenda
        return $this->success(null, 'Agenda created');
    }

    public function storeScores(Request $request, $id)
    {
        // TODO: Implement store scores
        return $this->success(null, 'Scores saved');
    }
}
