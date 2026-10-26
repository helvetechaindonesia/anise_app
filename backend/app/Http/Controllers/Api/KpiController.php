<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Traits\ApiResponser;
use App\Models\User;
use App\Models\TeacherEvaluation;
use App\Models\AcademicYear;
use Illuminate\Support\Facades\Auth;

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

    /**
     * Mengambil daftar evaluasi kinerja tendik.
     * Jika Kepsek: melihat seluruh tendik (Guru, BK, TU) beserta status evaluasinya pada semester/tahun ajaran terpilih.
     * Jika Guru/TU: melihat hasil evaluasi dirinya sendiri.
     */
    public function getEvaluations(Request $request)
    {
        try {
            $user = Auth::user();
            $academicYearId = $request->query('academic_year_id');

            // Ambil daftar seluruh semester/tahun ajaran untuk filter
            $academicYears = AcademicYear::orderBy('created_at', 'desc')->get();
            $currentAcademicYear = null;

            if ($academicYearId) {
                $currentAcademicYear = AcademicYear::find($academicYearId);
            }
            if (!$currentAcademicYear) {
                $currentAcademicYear = AcademicYear::where('is_active', true)->first() ?? $academicYears->first();
            }

            // Jika user adalah Kepala Sekolah: Tampilkan seluruh Tendik
            if ($user->role_type === 'KEPALA_SEKOLAH') {
                $tendikUsers = User::whereHas('role', function ($q) {
                    $q->whereIn('name', ['GURU', 'GURU_BK', 'TATA_USAHA']);
                })
                ->where('is_active', true)
                ->orderBy('full_name', 'asc')
                ->get();

                $evaluations = [];
                if ($currentAcademicYear) {
                    $evaluations = TeacherEvaluation::where('academic_year_id', $currentAcademicYear->id)
                        ->get()
                        ->keyBy('teacher_id');
                }

                $list = $tendikUsers->map(function ($tendik) use ($evaluations, $currentAcademicYear) {
                    $eval = $evaluations->get($tendik->id);

                    return [
                        'user_id' => $tendik->id,
                        'full_name' => $tendik->full_name,
                        'username' => $tendik->username,
                        'nip' => $tendik->nip ?? $tendik->unique_id,
                        'role_type' => $tendik->role_type,
                        'avatar' => $tendik->avatar ?? $tendik->profile_picture,
                        'is_evaluated' => $eval !== null,
                        'evaluation' => $eval ? [
                            'id' => $eval->id,
                            'praktik_kinerja' => $eval->praktik_kinerja,
                            'perilaku_kerja' => $eval->perilaku_kerja,
                            'predikat_kinerja' => $eval->predikat_kinerja,
                            'notes' => $eval->notes,
                            'is_published' => (bool)$eval->is_published,
                            'updated_at' => $eval->updated_at ? $eval->updated_at->toIso8601String() : null,
                        ] : null,
                    ];
                });

                return $this->success([
                    'academic_years' => $academicYears,
                    'current_academic_year' => $currentAcademicYear,
                    'tendik_list' => $list,
                ]);
            }

            // Jika user adalah Guru / TU: Tampilkan evaluasi miliknya
            $myEvaluation = null;
            if ($currentAcademicYear) {
                $myEvaluation = TeacherEvaluation::where('teacher_id', $user->id)
                    ->where('academic_year_id', $currentAcademicYear->id)
                    ->first();
            }

            return $this->success([
                'academic_years' => $academicYears,
                'current_academic_year' => $currentAcademicYear,
                'my_evaluation' => $myEvaluation ? [
                    'id' => $myEvaluation->id,
                    'praktik_kinerja' => $myEvaluation->praktik_kinerja,
                    'perilaku_kerja' => $myEvaluation->perilaku_kerja,
                    'predikat_kinerja' => $myEvaluation->predikat_kinerja,
                    'notes' => $myEvaluation->notes,
                    'is_published' => (bool)$myEvaluation->is_published,
                ] : null,
            ]);
        } catch (\Throwable $e) {
            return $this->error($e->getMessage(), 500);
        }
    }

    /**
     * Menyimpan atau memperbarui evaluasi kinerja tendik oleh Kepala Sekolah.
     */
    public function storeEvaluations(Request $request)
    {
        $request->validate([
            'teacher_id' => 'required|exists:users,id',
            'academic_year_id' => 'required|exists:academic_years,id',
            'praktik_kinerja' => 'required|in:DI_BAWAH_EKSPEKTASI,SESUAI_EKSPEKTASI,DI_ATAS_EKSPEKTASI',
            'perilaku_kerja' => 'required|in:DI_BAWAH_EKSPEKTASI,SESUAI_EKSPEKTASI,DI_ATAS_EKSPEKTASI',
            'predikat_kinerja' => 'required|in:SANGAT_KURANG,KURANG,CUKUP,BAIK,SANGAT_BAIK',
            'notes' => 'nullable|string',
        ]);

        try {
            $evaluator = Auth::user();

            $evaluation = TeacherEvaluation::updateOrCreate(
                [
                    'teacher_id' => $request->teacher_id,
                    'academic_year_id' => $request->academic_year_id,
                ],
                [
                    'evaluator_id' => $evaluator->id,
                    'praktik_kinerja' => $request->praktik_kinerja,
                    'perilaku_kerja' => $request->perilaku_kerja,
                    'predikat_kinerja' => $request->predikat_kinerja,
                    'notes' => $request->notes,
                    'is_published' => true,
                ]
            );

            return $this->success($evaluation, 'Evaluasi kinerja berhasil disimpan.');
        } catch (\Throwable $e) {
            return $this->error($e->getMessage(), 500);
        }
    }
}
