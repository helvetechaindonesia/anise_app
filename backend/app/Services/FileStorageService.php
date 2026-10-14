<?php

namespace App\Services;

use App\Models\JournalTask;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;

class FileStorageService
{
    /**
     * Simpan berkas jawaban tugas siswa (Submissions)
     * Format: submissions/{TAHUN_AJARAN}/{KODE_KELAS}/{KODE_MAPEL}/task_{ID}/{NIS}_{NAMA}/ans_{timestamp}.{ext}
     */
    public static function storeTaskSubmission(UploadedFile $file, JournalTask $task, User $user): string
    {
        // 1. Tahun Ajaran
        $academicYear = $task->journal?->class?->academicYear?->name ?? date('Y');
        $academicYearSlug = Str::slug($academicYear);

        // 2. Kode Kelas
        $classCode = Str::upper(Str::slug($task->journal?->class?->code ?? $task->journal?->class?->name ?? 'UMUM'));

        // 3. Kode Mapel
        $subjectCode = Str::upper(Str::slug($task->journal?->subject?->code ?? $task->journal?->subject?->name ?? 'MAPEL'));

        // 4. Folder Tugas (task_{short_uuid})
        $taskFolder = 'task_' . substr($task->id, 0, 8);

        // 5. Folder Siswa ({NIS}_{SLUG_NAMA})
        $nis = $user->siswaProfile?->nis ?? $user->username ?? substr($user->id, 0, 8);
        $studentSlug = Str::slug($user->full_name ?? $user->username ?? 'siswa');
        $studentFolder = "{$nis}_{$studentSlug}";

        // 6. Nama Berkas Aman
        $ext = $file->getClientOriginalExtension() ?: 'bin';
        $filename = "ans_{$nis}_" . time() . "_" . Str::random(4) . ".{$ext}";

        // Simpan ke disk public
        $targetDirectory = "submissions/{$academicYearSlug}/{$classCode}/{$subjectCode}/{$taskFolder}/{$studentFolder}";
        
        return $file->storeAs($targetDirectory, $filename, 'public');
    }

    /**
     * Simpan lampiran soal/materi dari guru (Tasks)
     * Format: tasks/{TAHUN_AJARAN}/{KODE_KELAS}/{KODE_MAPEL}/task_{ID}/materi_{timestamp}_{name}.{ext}
     */
    public static function storeTaskAttachment(UploadedFile $file, JournalTask $task): string
    {
        $academicYear = $task->journal?->class?->academicYear?->name ?? date('Y');
        $academicYearSlug = Str::slug($academicYear);

        $classCode = Str::upper(Str::slug($task->journal?->class?->code ?? $task->journal?->class?->name ?? 'UMUM'));
        $subjectCode = Str::upper(Str::slug($task->journal?->subject?->code ?? $task->journal?->subject?->name ?? 'MAPEL'));
        $taskFolder = 'task_' . substr($task->id, 0, 8);

        $ext = $file->getClientOriginalExtension() ?: 'bin';
        $origName = Str::slug(pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME));
        $filename = "materi_" . time() . "_{$origName}.{$ext}";

        $targetDirectory = "tasks/{$academicYearSlug}/{$classCode}/{$subjectCode}/{$taskFolder}";

        return $file->storeAs($targetDirectory, $filename, 'public');
    }

    /**
     * Simpan surat izin / keterangan dokter (Leaves)
     * Format: leaves/{siswa|pegawai}/{TAHUN}/{BULAN}/{IDENTIFIER}/surat_{timestamp}.{ext}
     */
    public static function storeLeaveAttachment(UploadedFile $file, User $user): string
    {
        $year = date('Y');
        $month = date('m');
        $role = strtolower($user->role_type ?? 'siswa');

        if ($role === 'siswa') {
            $classCode = Str::upper(Str::slug($user->siswaProfile?->schoolClass?->code ?? 'KELAS'));
            $nis = $user->siswaProfile?->nis ?? $user->username ?? substr($user->id, 0, 8);
            $slug = Str::slug($user->full_name ?? $user->username ?? 'siswa');
            $targetDirectory = "leaves/siswa/{$year}/{$month}/{$classCode}/{$nis}_{$slug}";
        } else {
            $nip = $user->guruProfile?->nip ?? $user->username ?? substr($user->id, 0, 8);
            $slug = Str::slug($user->full_name ?? $user->username ?? 'pegawai');
            $targetDirectory = "leaves/pegawai/{$year}/{$month}/{$nip}_{$slug}";
        }

        $ext = $file->getClientOriginalExtension() ?: 'bin';
        $filename = "surat_" . time() . "_" . Str::random(4) . ".{$ext}";

        return $file->storeAs($targetDirectory, $filename, 'public');
    }

    /**
     * Simpan bukti aduan / laporan (Reports)
     * Format: reports/{pengaduan|disiplin|helpdesk}/{TAHUN}/{BULAN}/report_{ID}/bukti_{timestamp}.{ext}
     */
    public static function storeReportAttachment(UploadedFile $file, string $type, string $identifier): string
    {
        $year = date('Y');
        $month = date('m');
        $safeType = Str::slug($type);

        $targetDirectory = "reports/{$safeType}/{$year}/{$month}/item_{$identifier}";
        $ext = $file->getClientOriginalExtension() ?: 'bin';
        $filename = "bukti_" . time() . "_" . Str::random(4) . ".{$ext}";

        return $file->storeAs($targetDirectory, $filename, 'public');
    }

    /**
     * Simpan berkas pribadi / portofolio pengguna (User Files)
     * Format: user_files/{ROLE}/{IDENTIFIER}_{NAMA}/{KATEGORI}/doc_{timestamp}.{ext}
     */
    public static function storeUserFile(UploadedFile $file, User $user, string $category = 'dokumen'): string
    {
        $role = strtolower($user->role_type ?? 'user');
        $identifier = $user->siswaProfile?->nis ?? $user->guruProfile?->nip ?? $user->username ?? substr($user->id, 0, 8);
        $slug = Str::slug($user->full_name ?? $user->username ?? 'user');
        $safeCategory = Str::slug($category);

        $targetDirectory = "user_files/{$role}/{$identifier}_{$slug}/{$safeCategory}";
        $ext = $file->getClientOriginalExtension() ?: 'bin';
        $filename = "doc_" . time() . "_" . Str::random(4) . ".{$ext}";

        return $file->storeAs($targetDirectory, $filename, 'public');
    }
}
