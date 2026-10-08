<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;

class LegalController extends Controller
{
    use ApiResponser;

    public function getDocument(Request $request, $document_type)
    {
        return $this->success(['content' => '']);
    }

    public function submitConsent(Request $request)
    {
        return $this->success(null, 'Consent recorded');
    }
}
