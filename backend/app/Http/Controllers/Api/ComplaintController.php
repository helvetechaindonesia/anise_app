<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Enums\ComplaintCategory;
use App\Enums\ComplaintStatus;
use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Traits\ApiResponser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ComplaintController extends Controller
{
    use ApiResponser;

    /**
     * Get complaints list with filtering by category, status, and search.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Complaint::with(['user:id,full_name,username', 'handler:id,full_name,username'])
            ->orderBy('created_at', 'desc');

        // Jika siswa, batasi hanya melihat laporan miliknya sendiri
        if ($user && $user->role_type === 'SISWA') {
            $query->where('user_id', $user->id);
        }

        // Filter multi kategori: categories=BULLYING,ASPIRASI atau category=FASILITAS
        if ($request->filled('categories')) {
            $categories = is_array($request->categories) 
                ? $request->categories 
                : explode(',', (string) $request->categories);
            $query->whereIn('category', array_map('trim', $categories));
        } elseif ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // Filter status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Filter pencarian teks
        if ($request->filled('search')) {
            $search = (string) $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $complaints = $query->get()->map(function ($complaint) use ($user) {
            return $this->formatComplaint($complaint, $user);
        });

        return $this->success($complaints);
    }

    /**
     * Submit a new complaint (Siswa / Pelapor).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category' => ['required', 'string', Rule::in(['FASILITAS', 'BULLYING', 'ASPIRASI'])],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'is_anonymous' => ['nullable'],
            'attachment' => ['nullable', 'file', 'max:10240', 'mimes:jpeg,png,jpg,webp,pdf'],
            'image' => ['nullable', 'file', 'max:10240', 'mimes:jpeg,png,jpg,webp,pdf'],
        ]);

        $attachmentUrl = null;
        $file = $request->file('attachment') ?? $request->file('image');
        if ($file) {
            $path = $file->store('complaints', 'public');
            $attachmentUrl = '/storage/' . $path;
        }

        $isAnonymous = false;
        if ($request->has('is_anonymous')) {
            $raw = $request->input('is_anonymous');
            $isAnonymous = ($raw === true || $raw === 1 || $raw === '1' || $raw === 'true');
        }

        $complaint = Complaint::create([
            'user_id' => $request->user()->id,
            'category' => $validated['category'],
            'title' => $validated['title'],
            'description' => $validated['description'],
            'is_anonymous' => $isAnonymous,
            'attachment_url' => $attachmentUrl,
            'status' => ComplaintStatus::Pending->value,
        ]);

        return $this->success(
            $this->formatComplaint($complaint->load('user'), $request->user()),
            'Laporan pengaduan berhasil dikirim',
            201
        );
    }

    /**
     * Get detail of a specific complaint.
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::with(['user:id,full_name,username', 'handler:id,full_name,username'])->find($id);

        if (!$complaint) {
            return $this->error('Laporan tidak ditemukan', 404);
        }

        $user = $request->user();
        if ($user && $user->role_type === 'SISWA' && $complaint->user_id !== $user->id) {
            return $this->error('Akses ditolak: Anda tidak memiliki akses ke laporan ini.', 403);
        }

        return $this->success($this->formatComplaint($complaint, $user));
    }

    /**
     * Update status and response note (TU / Petugas / BK).
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'string', Rule::in(['PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED'])],
            'response_note' => ['nullable', 'string', 'max:2000'],
        ]);

        $complaint = Complaint::find($id);
        if (!$complaint) {
            return $this->error('Laporan tidak ditemukan', 404);
        }

        $complaint->status = $validated['status'];
        if (array_key_exists('response_note', $validated)) {
            $complaint->response_note = $validated['response_note'];
        }
        $complaint->handled_by = $request->user()->id;
        $complaint->save();

        return $this->success(
            $this->formatComplaint($complaint->load(['user', 'handler']), $request->user()),
            'Status laporan berhasil diperbarui'
        );
    }

    /**
     * Delete a complaint.
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $complaint = Complaint::find($id);
        if (!$complaint) {
            return $this->error('Laporan tidak ditemukan', 404);
        }

        $user = $request->user();
        $isAuthor = $user && $complaint->user_id === $user->id;
        $isStaff = $user && in_array($user->role_type, ['TATA_USAHA', 'KEPALA_SEKOLAH', 'SUPER_ADMIN']);

        if (!$isAuthor && !$isStaff) {
            return $this->error('Anda tidak berwenang menghapus laporan ini.', 403);
        }

        if ($complaint->attachment_url) {
            $relativePath = ltrim(str_replace('/storage/', '', $complaint->attachment_url), '/');
            Storage::disk('public')->delete($relativePath);
        }

        $complaint->delete();
        return $this->success(null, 'Laporan berhasil dihapus');
    }

    /**
     * Download lampiran berkas laporan/pengaduan.
     */
    public function downloadAttachment(string $id)
    {
        $complaint = Complaint::find($id);
        if (!$complaint || empty($complaint->attachment_url)) {
            return response()->json(['status' => 'error', 'message' => 'Lampiran tidak ditemukan.'], 404);
        }

        $relativePath = ltrim(str_replace('/storage/', '', $complaint->attachment_url), '/');
        $relativePath = ltrim(str_replace('public/', '', $relativePath), '/');

        if (!Storage::disk('public')->exists($relativePath)) {
            $candidatePath = storage_path('app/public/' . $relativePath);
            if (!file_exists($candidatePath)) {
                return response()->json(['status' => 'error', 'message' => 'Berkas fisik tidak ditemukan di server.'], 404);
            }
            return response()->download($candidatePath, basename($candidatePath));
        }

        return Storage::disk('public')->download($relativePath, basename($relativePath));
    }

    /**
     * Format complaint object for client response, masking anonymous identity if necessary.
     */
    private function formatComplaint(Complaint $complaint, $viewer): array
    {
        $isAuthor = $viewer && $complaint->user_id === $viewer->id;
        $shouldMask = (bool) $complaint->is_anonymous && !$isAuthor;

        $categoryValue = $complaint->category instanceof ComplaintCategory 
            ? $complaint->category->value 
            : (string) $complaint->category;

        $statusValue = $complaint->status instanceof ComplaintStatus 
            ? $complaint->status->value 
            : (string) $complaint->status;

        return [
            'id' => $complaint->id,
            'user_id' => $shouldMask ? null : $complaint->user_id,
            'category' => $categoryValue,
            'title' => $complaint->title,
            'description' => $complaint->description,
            'is_anonymous' => (bool) $complaint->is_anonymous,
            'attachment_url' => $complaint->attachment_url,
            'status' => $statusValue,
            'response_note' => $complaint->response_note,
            'handled_by' => $complaint->handled_by,
            'user' => $shouldMask ? [
                'id' => null,
                'full_name' => 'Anonim',
                'username' => 'anonim',
            ] : ($complaint->user ? [
                'id' => $complaint->user->id,
                'full_name' => $complaint->user->full_name,
                'username' => $complaint->user->username,
            ] : null),
            'handler' => $complaint->handler ? [
                'id' => $complaint->handler->id,
                'full_name' => $complaint->handler->full_name,
                'username' => $complaint->handler->username,
            ] : null,
            'created_at' => $complaint->created_at?->toIso8601String(),
            'updated_at' => $complaint->updated_at?->toIso8601String(),
        ];
    }
}
