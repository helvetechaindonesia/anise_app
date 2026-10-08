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
use App\Traits\ApiResponser;

class UserController extends Controller
{
    use ApiResponser;

    public function getUsers(Request $request)
    {
        $roleName = $request->query('role');
        $query = User::query()->with(['role', 'siswaProfile', 'guruProfile']);
        if ($roleName) $query->whereHas('role', fn($q) => $q->where('name', $roleName));
        return $this->success($query->orderBy('full_name', 'asc')->get(), 'Data User berhasil diambil');
    }

    public function storeUser(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username',
            'email' => 'required|string|max:255',
            'role_id' => 'required|exists:roles,id'
        ]);

        $user = User::create([
            'full_name' => $request->full_name,
            'username' => $request->username,
            'email' => $request->email,
            'password' => bcrypt($request->username),
            'role_id' => $request->role_id,
        ]);
        return $this->success($user, 'User berhasil ditambahkan');
    }

    public function updateUser(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $request->validate([
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username,'.$user->id,
            'email' => 'required|string|max:255',
        ]);
        $user->update($request->only('full_name', 'username', 'email'));
        return $this->success($user, 'User berhasil diperbarui');
    }

    public function deleteUser($id)
    {
        User::findOrFail($id)->delete();
        return $this->success(null, 'User berhasil dihapus');
    }

    public function freezeUser($id)
    {
        return $this->success(null, 'User berhasil dibekukan (Freeze)');
    }

    public function searchSiswa(Request $request)
    {
        $query = $request->get('q', '');
        $students = User::where('role', 'SISWA')
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

    public function updateJabatan(Request $request, $id)
    {
        $jabatan = Jabatan::findOrFail($id);
        $request->validate(['name' => 'required|string|max:255']);
        $jabatan->update(['name' => $request->name]);
        return $this->success($jabatan);
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
        $path = $file->store('user_files', 'public');
        $userFile = UserFile::create([
            'user_id' => $request->user()->id,
            'title' => $file->getClientOriginalName(),
            'type' => $file->getClientOriginalExtension(),
            'size' => number_format($file->getSize() / 1048576, 2) . ' MB',
            'path' => $path,
        ]);
        return response()->json(['status' => 'success', 'data' => $userFile]);
    }

    public function getUserFiles(Request $request)
    {
        return response()->json(['status' => 'success', 'data' => UserFile::where('user_id', $request->user()->id)->latest()->get()]);
    }
}
