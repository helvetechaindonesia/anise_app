<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Role;
use App\Models\Jabatan;
use App\Models\SchoolClass;
use App\Models\GuruWaliStudent;
use App\Models\UserFile;
use App\Http\Resources\UserResource;
use App\Traits\ApiResponser;

class UserController extends Controller
{
    use ApiResponser;

    public function getUsers(Request $request)
    {
        $roleName = $request->query('role');
        $query = User::query()->with(['role', 'siswaProfile', 'guruProfile']);
        if ($roleName) $query->whereHas('role', fn($q) => $q->where('name', $roleName));
        return $this->success(UserResource::collection($query->orderBy('full_name', 'asc')->get()), 'Data User berhasil diambil');
    }

    public function storeUser(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username',
            'email' => 'required|string|max:255',
            'role_id' => 'required|exists:roles,id',
            'phone' => 'nullable|string|max:30',
            'address' => 'nullable|string|max:500',
            'password' => 'nullable|string|min:4',
            'nip_nuptk' => 'nullable|string|max:50',
            'nisn' => 'nullable|string|max:50',
            'nis' => 'nullable|string|max:50',
            'gender' => 'nullable|string|in:L,P',
            'religion' => 'nullable|string|max:50',
        ]);

        $password = $request->filled('password') ? $request->password : $request->username;

        $user = User::create([
            'full_name' => $request->full_name,
            'username' => $request->username,
            'email' => $request->email,
            'phone' => $request->phone,
            'address' => $request->address,
            'gender' => $request->gender ?? 'L',
            'religion' => $request->religion,
            'password_hash' => \Illuminate\Support\Facades\Hash::make($password),
            'role_id' => $request->role_id,
            'is_active' => true,
        ]);

        if ($request->filled('nip_nuptk')) {
            $user->guruProfile()->create(['nip_nuptk' => $request->nip_nuptk]);
        }

        if ($request->filled('nisn') || $request->filled('nis')) {
            $user->siswaProfile()->create([
                'nisn' => $request->nisn,
                'nis' => $request->nis,
            ]);
        }

        $user->load(['role', 'siswaProfile', 'guruProfile']);
        return $this->success(new UserResource($user), 'User berhasil ditambahkan', 201);
    }

    public function updateUser(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $request->validate([
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username,'.$user->id,
            'email' => 'required|string|max:255',
            'phone' => 'nullable|string|max:30',
            'address' => 'nullable|string|max:500',
            'password' => 'nullable|string|min:4',
            'nip_nuptk' => 'nullable|string|max:50',
            'nisn' => 'nullable|string|max:50',
            'nis' => 'nullable|string|max:50',
            'gender' => 'nullable|string|in:L,P',
            'religion' => 'nullable|string|max:50',
        ]);

        $credentialsChanged = false;
        $data = $request->only('full_name', 'username', 'email', 'phone', 'address', 'gender', 'religion');
        if ($request->filled('password')) {
            $data['password_hash'] = \Illuminate\Support\Facades\Hash::make($request->password);
            $credentialsChanged = true;
        }
        if ($request->filled('email') && $request->email !== $user->email) {
            $credentialsChanged = true;
        }
        if ($request->filled('username') && $request->username !== $user->username) {
            $credentialsChanged = true;
        }

        $user->update($data);

        if ($credentialsChanged) {
            $user->tokens()->delete();
        }

        // Update profile terkait jika ada
        if ($request->filled('nip_nuptk')) {
            $user->guruProfile()->updateOrCreate(
                ['user_id' => $user->id],
                ['nip_nuptk' => $request->nip_nuptk]
            );
        }

        if ($request->filled('nisn') || $request->filled('nis')) {
            $siswaData = [];
            if ($request->filled('nisn')) $siswaData['nisn'] = $request->nisn;
            if ($request->filled('nis')) $siswaData['nis'] = $request->nis;
            $user->siswaProfile()->updateOrCreate(
                ['user_id' => $user->id],
                $siswaData
            );
        }

        $user->load(['role', 'siswaProfile', 'guruProfile']);
        return $this->success(new UserResource($user), 'User berhasil diperbarui');
    }

    public function deleteUser(Request $request, $id)
    {
        $user = User::findOrFail($id);

        // Jangan izinkan menghapus akun sendiri
        if ($request->user() && $request->user()->id === $user->id) {
            return $this->error('Anda tidak dapat menghapus akun Anda sendiri!', 400);
        }

        $user->tokens()->delete();
        $user->delete();
        return $this->success(null, 'User berhasil dihapus');
    }

    public function freezeUser(Request $request, $id)
    {
        $user = User::findOrFail($id);

        // Jangan izinkan membekukan akun sendiri
        if ($request->user() && $request->user()->id === $user->id) {
            return $this->error('Anda tidak dapat membekukan akun Anda sendiri!', 400);
        }

        $user->is_active = !$user->is_active;
        $user->save();

        if (!$user->is_active) {
            $user->tokens()->delete();
        }

        $statusText = $user->is_active ? 'diaktifkan kembali' : 'berhasil dibekukan';
        return $this->success($user, "Akun {$user->full_name} {$statusText}");
    }

    public function searchSiswa(Request $request)
    {
        $query = $request->get('q', '');
        $students = User::whereHas('role', fn($q) => $q->where('name', 'SISWA'))
            ->where(fn($q) => $q->where('full_name', 'like', "%{$query}%")->orWhere('username', 'like', "%{$query}%"))
            ->select('id', 'full_name', 'username')->take(20)->get();
        return response()->json($students);
    }

    public function getAllSiswa(Request $request)
    {
        $students = User::whereHas('role', fn($q) => $q->where('name', 'SISWA'))
            ->select('id', 'full_name', 'username')->orderBy('full_name', 'asc')->get();
        return $this->success($students);
    }

    public function getRoles()
    {
        return $this->success(Role::orderBy('created_at', 'desc')->get());
    }

    public function updateRole(Request $request, $id)
    {
        $role = Role::findOrFail($id);
        $request->validate(['name' => 'required|string|max:255']);
        $role->update(['name' => $request->name]);
        return $this->success($role);
    }

    public function getJabatans()
    {
        return $this->success(Jabatan::orderBy('created_at', 'desc')->get());
    }

    public function storeJabatan(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'task_area' => 'nullable|string|max:255',
        ]);

        $jabatan = Jabatan::create([
            'name' => strtoupper(str_replace(' ', '_', trim($request->name))),
            'task_area' => $request->task_area,
        ]);

        return $this->success($jabatan, 'Jabatan berhasil dibuat', 201);
    }

    public function updateJabatan(Request $request, $id)
    {
        $jabatan = Jabatan::findOrFail($id);
        $request->validate([
            'name' => 'required|string|max:255',
            'task_area' => 'nullable|string|max:255',
        ]);

        $updateData = ['name' => strtoupper(str_replace(' ', '_', trim($request->name)))];
        if ($request->has('task_area')) {
            $updateData['task_area'] = $request->task_area;
        }

        $jabatan->update($updateData);
        return $this->success($jabatan);
    }

    public function deleteJabatan($id)
    {
        Jabatan::findOrFail($id)->delete();
        return $this->success(null, 'Jabatan berhasil dihapus');
    }

    public function getWaliKelas()
    {
        return $this->success(SchoolClass::whereNotNull('wali_kelas_id')->with(['waliKelas'])->orderBy('grade_level', 'asc')->orderBy('name', 'asc')->get());
    }

    public function getGuruWali()
    {
        return $this->success(GuruWaliStudent::with(['guru', 'student'])->get());
    }

    public function uploadFile(Request $request)
    {
        $request->validate(['file' => 'required|file']);
        $file = $request->file('file');
        $user = $request->user();
        
        $path = FileStorageService::storeUserFile($file, $user, 'umum');
        $userFile = UserFile::create([
            'user_id' => $user->id,
            'title' => $file->getClientOriginalName(),
            'type' => strtolower($file->getClientOriginalExtension() ?: 'bin'),
            'size' => number_format($file->getSize() / 1048576, 2) . ' MB',
            'path' => $path,
        ]);
        return response()->json(['status' => 'success', 'data' => $userFile]);
    }

    /**
     * E-File: Menampung seluruh file yang pernah diupload oleh user tersebut di modul apapun
     * Mengambil langsung dari storage yang telah dipetakan, read-only (tidak bisa diedit/dihapus, hanya download).
     */
    public function getUserFiles(Request $request)
    {
        $user = $request->user();
        $files = collect();

        // 1. Berkas dari user_files (Unggahan mandiri)
        $userFiles = UserFile::where('user_id', $user->id)->get()->map(function ($f) {
            $ext = strtolower($f->type ?: pathinfo($f->path, PATHINFO_EXTENSION) ?: 'file');
            return [
                'id' => 'uf_' . $f->id,
                'title' => $f->title,
                'source' => 'Berkas Mandiri',
                'type' => $ext,
                'size' => $f->size,
                'file_url' => '/storage/' . ltrim($f->path, '/'),
                'created_at' => $f->created_at ? $f->created_at->toIso8601String() : now()->toIso8601String(),
            ];
        });
        $files = $files->concat($userFiles);

        // 2. Berkas Tugas Siswa (Submissions)
        $submissions = DB::table('student_task_submissions')
            ->where('student_id', $user->id)
            ->whereNotNull('attachment_url')
            ->where('attachment_url', '!=', '')
            ->get()->map(function ($s) {
                $rawPath = ltrim(str_replace('/storage/', '', $s->attachment_url), '/');
                $size = 'Dokumen';
                if (\Illuminate\Support\Facades\Storage::disk('public')->exists($rawPath)) {
                    $bytes = \Illuminate\Support\Facades\Storage::disk('public')->size($rawPath);
                    $size = number_format($bytes / 1048576, 2) . ' MB';
                }
                $ext = strtolower(pathinfo($rawPath, PATHINFO_EXTENSION) ?: 'file');
                $filename = basename($rawPath);

                return [
                    'id' => 'sub_' . $s->id,
                    'title' => 'Jawaban Tugas: ' . $filename,
                    'source' => 'Tugas & Pembelajaran',
                    'type' => $ext,
                    'size' => $size,
                    'file_url' => str_starts_with($s->attachment_url, '/storage/') ? $s->attachment_url : ('/storage/' . $rawPath),
                    'created_at' => $s->created_at ? \Carbon\Carbon::parse($s->created_at)->toIso8601String() : now()->toIso8601String(),
                ];
            });
        $files = $files->concat($submissions);

        // 3. Berkas Materi / Lampiran Jurnal Mengajar (Khusus Guru Pengampu)
        $journalMaterials = DB::table('journals')
            ->where('teacher_id', $user->id)
            ->whereNotNull('attachment_url')
            ->where('attachment_url', '!=', '')
            ->get()->map(function ($j) {
                $rawPath = ltrim(str_replace('/storage/', '', $j->attachment_url), '/');
                $size = 'Dokumen';
                if (\Illuminate\Support\Facades\Storage::disk('public')->exists($rawPath)) {
                    $bytes = \Illuminate\Support\Facades\Storage::disk('public')->size($rawPath);
                    $size = number_format($bytes / 1048576, 2) . ' MB';
                }
                $ext = strtolower(pathinfo($rawPath, PATHINFO_EXTENSION) ?: 'file');
                $filename = basename($rawPath);

                return [
                    'id' => 'jrn_' . $j->id,
                    'title' => 'Materi KBM: ' . ($j->topic_material ?: $filename),
                    'source' => 'Jurnal Mengajar',
                    'type' => $ext,
                    'size' => $size,
                    'file_url' => str_starts_with($j->attachment_url, '/storage/') ? $j->attachment_url : ('/storage/' . $rawPath),
                    'created_at' => $j->created_at ? \Carbon\Carbon::parse($j->created_at)->toIso8601String() : now()->toIso8601String(),
                ];
            });
        $files = $files->concat($journalMaterials);

        // 4. Berkas Surat Permohonan Izin / Keterangan Dokter (Modul Leaves)
        $leaveAttachments = DB::table('leaves')
            ->where('user_id', $user->id)
            ->whereNotNull('attachment_path')
            ->where('attachment_path', '!=', '')
            ->get()->map(function ($l) {
                $rawPath = ltrim(str_replace('/storage/', '', $l->attachment_path), '/');
                $size = 'Dokumen';
                if (\Illuminate\Support\Facades\Storage::disk('public')->exists($rawPath)) {
                    $bytes = \Illuminate\Support\Facades\Storage::disk('public')->size($rawPath);
                    $size = number_format($bytes / 1048576, 2) . ' MB';
                }
                $ext = strtolower(pathinfo($rawPath, PATHINFO_EXTENSION) ?: 'pdf');
                $filename = basename($rawPath);

                return [
                    'id' => 'lev_' . $l->id,
                    'title' => 'Surat ' . ucfirst(strtolower($l->type)) . ': ' . $filename,
                    'source' => 'Perizinan',
                    'type' => $ext,
                    'size' => $size,
                    'file_url' => str_starts_with($l->attachment_path, '/storage/') ? $l->attachment_path : ('/storage/' . $rawPath),
                    'created_at' => $l->created_at ? \Carbon\Carbon::parse($l->created_at)->toIso8601String() : now()->toIso8601String(),
                ];
            });
        $files = $files->concat($leaveAttachments);

        // 5. Berkas Lampiran Pengaduan (Complaints)
        $complaintAttachments = DB::table('complaints')
            ->where('user_id', $user->id)
            ->whereNotNull('attachment_url')
            ->where('attachment_url', '!=', '')
            ->get()->map(function ($c) {
                $rawPath = ltrim(str_replace('/storage/', '', $c->attachment_url), '/');
                $size = 'Dokumen';
                if (\Illuminate\Support\Facades\Storage::disk('public')->exists($rawPath)) {
                    $bytes = \Illuminate\Support\Facades\Storage::disk('public')->size($rawPath);
                    $size = number_format($bytes / 1048576, 2) . ' MB';
                }
                $ext = strtolower(pathinfo($rawPath, PATHINFO_EXTENSION) ?: 'file');

                return [
                    'id' => 'cmp_' . $c->id,
                    'title' => 'Bukti Aduan: ' . ($c->title ?: basename($rawPath)),
                    'source' => 'Pengaduan',
                    'type' => $ext,
                    'size' => $size,
                    'file_url' => str_starts_with($c->attachment_url, '/storage/') ? $c->attachment_url : ('/storage/' . $rawPath),
                    'created_at' => $c->created_at ? \Carbon\Carbon::parse($c->created_at)->toIso8601String() : now()->toIso8601String(),
                ];
            });
        $files = $files->concat($complaintAttachments);

        // 6. Urutkan berdasarkan waktu unggah terbaru
        $sortedFiles = $files->sortByDesc('created_at')->values();

        return response()->json([
            'status' => 'success',
            'data' => $sortedFiles,
        ]);
    }
}
