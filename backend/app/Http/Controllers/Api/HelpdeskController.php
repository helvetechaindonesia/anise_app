<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\StudentReport;
use App\Traits\ApiResponser;

class HelpdeskController extends Controller
{
    use ApiResponser;

    public function submitStudentReport(Request $request)
    {
        $request->validate([
            'category' => 'required|string',
            'report_title' => 'required|string',
            'report_text' => 'required|string',
            'is_anonymous' => 'boolean'
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('reports', 'public');
        }

        StudentReport::create([
            'student_id' => $request->user()->id,
            'category' => $request->category,
            'report_title' => $request->report_title,
            'report_text' => $request->report_text,
            'is_anonymous' => $request->is_anonymous ?? false,
            'image_path' => $imagePath,
            'status' => 'PENDING'
        ]);

        return $this->success(null, 'Report submitted successfully');
    }

    public function getStudentReports(Request $request)
    {
        $reports = StudentReport::with('student')->orderBy('created_at', 'desc')->get();
        return $this->success($reports);
    }
}
