<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\Schedule;
use App\Models\Journal;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class NotificationService
{
    /**
     * Format Indonesian phone numbers to international standard (628...)
     */
    public static function formatPhone(string $phone): string
    {
        $clean = preg_replace('/[^0-9]/', '', $phone);
        if (str_starts_with($clean, '0')) {
            $clean = '62' . substr($clean, 1);
        } elseif (str_starts_with($clean, '8')) {
            $clean = '62' . $clean;
        }
        return $clean;
    }

    /**
     * Dispatch WhatsApp message via Baileys Gateway API / Self-Hosted Gateway
     */
    public static function sendWhatsApp(string $phone, string $message): bool
    {
        $cleanPhone = self::formatPhone($phone);
        $gatewayUrl = env('WA_GATEWAY_URL', 'http://127.0.0.1:3001/send-message');
        $gatewayKey = env('WA_GATEWAY_KEY', 'anise_secret_gateway_key_2026');

        try {
            $response = Http::timeout(5)
                ->withHeaders([
                    'x-api-key' => $gatewayKey,
                    'Content-Type' => 'application/json',
                ])
                ->post($gatewayUrl, [
                    'phone' => $cleanPhone,
                    'message' => $message,
                ]);

            if ($response->successful()) {
                Log::info("WhatsApp berhasil dikirim ke {$cleanPhone} via Gateway");
                return true;
            } else {
                Log::warning("WhatsApp Gateway response gagal: " . $response->body());
            }
        } catch (\Throwable $e) {
            Log::info("WhatsApp Gateway offline ({$e->getMessage()}), pesan dicatat ke log untuk {$cleanPhone}:\n{$message}");
        }

        return true;
    }

    /**
     * Create in-app notification in notifications table
     */
    public static function sendInAppNotification(string $userId, string $title, string $message): bool
    {
        try {
            Notification::create([
                'user_id' => $userId,
                'title' => $title,
                'message' => $message,
                'is_read' => false,
            ]);
            return true;
        } catch (\Throwable $e) {
            Log::error("Gagal menyimpan notifikasi in-app: " . $e->getMessage());
        }
        return false;
    }

    /**
     * Send in-app task notification with embedded JSON payload for quick navigation
     */
    public static function sendTaskNotification(string $userId, string $title, string $message, array $taskData = []): bool
    {
        $payloadMessage = $message;
        if (!empty($taskData)) {
            $payloadMessage .= "\n<!--DATA:" . json_encode($taskData) . "-->";
        }
        return self::sendInAppNotification($userId, $title, $payloadMessage);
    }

    /**
     * Peringatan H-24 Jam: Guru wajib menerbitkan Jurnal Mengajar sebelum KBM
     */
    public static function notifyGuruH24Journal(Schedule $schedule, Carbon $teachingDate): bool
    {
        $teacher = $schedule->teacher;
        if (!$teacher) return false;

        $teacherName = $teacher->guruProfile?->full_name ?: ($teacher->full_name ?: ($teacher->username ?? 'Guru Pengampu'));
        $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
        $className = $schedule->class ? ($schedule->class->grade_level . ' ' . $schedule->class->name) : 'Kelas';
        $startTime = substr($schedule->start_time, 0, 5);
        $endTime = substr($schedule->end_time, 0, 5);
        $dateFormatted = $teachingDate->locale('id')->isoFormat('dddd, D MMMM Y');

        $title = "⚠️ Peringatan Terbitkan Jurnal (H-24 Jam)";
        $message = "Halo Bapak/Ibu {$teacherName}, Anda memiliki jadwal KBM {$subjectName} di kelas {$className} pada {$dateFormatted} pukul {$startTime} - {$endTime}. Status: Jurnal Mengajar (Micro-RPP) belum diterbitkan. Mohon segera terbitkan materi jurnal maksimal 24 jam sebelum KBM melalui aplikasi Anise.";

        $waMessage = "📢 *[PERINGATAN KBM - SMA N 1 PEUNARON]*\n\n"
            . "Yth. Bapak/Ibu *{$teacherName}*,\n\n"
            . "Sistem mendeteksi jadwal KBM Anda dalam 24 jam ke depan belum memiliki Jurnal Mengajar:\n"
            . "📚 *Mata Pelajaran:* {$subjectName}\n"
            . "🏫 *Kelas:* {$className}\n"
            . "🗓️ *Hari/Tanggal:* {$dateFormatted}\n"
            . "⏰ *Waktu:* {$startTime} - {$endTime} WIB\n\n"
            . "⚠️ *Status:* Belum Diterbitkan\n\n"
            . "Sesuai SOP Akademik, guru wajib menerbitkan Jurnal/Micro-RPP maksimal H-24 jam sebelum KBM agar siswa dapat mempersiapkan materi.\n\n"
            . "Silakan buka aplikasi *Anise App*, pilih menu *Jurnal Mengajar* dan klik *Terbitkan Jurnal*.\n\n"
            . "Terima kasih.\n_Kurikulum & IT Support Anise App_";

        self::sendInAppNotification($teacher->id, $title, $message);

        $phone = !empty($teacher->phone) ? $teacher->phone : ($teacher->guruProfile?->phone ?? null);
        if (!empty($phone)) {
            self::sendWhatsApp($phone, $waMessage);
        } else {
            Log::info("Guru {$teacherName} ({$teacher->username}) belum memiliki nomor telepon di master user.");
        }

        return true;
    }

    /**
     * Pengingat H-1 Jam sebelum KBM dimulai
     */
    public static function notifyGuruH1Journal(Schedule $schedule, Carbon $teachingDate): bool
    {
        $teacher = $schedule->teacher;
        if (!$teacher) return false;

        $teacherName = $teacher->guruProfile?->full_name ?: ($teacher->full_name ?: ($teacher->username ?? 'Guru Pengampu'));
        $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
        $className = $schedule->class ? ($schedule->class->grade_level . ' ' . $schedule->class->name) : 'Kelas';
        $startTime = substr($schedule->start_time, 0, 5);

        $title = "⏰ Pengingat KBM: 1 Jam Lagi ({$subjectName})";
        $message = "Halo Bapak/Ibu {$teacherName}, jadwal KBM {$subjectName} di kelas {$className} akan dimulai 1 jam lagi (pukul {$startTime} WIB). Mohon bersiap menuju ruang kelas.";

        $waMessage = "⏰ *[PENGINGAT KBM - 1 JAM LAGI]*\n\n"
            . "Yth. Bapak/Ibu *{$teacherName}*,\n\n"
            . "Jadwal KBM Anda sebentar lagi akan dimulai:\n"
            . "📚 *Mata Pelajaran:* {$subjectName}\n"
            . "🏫 *Kelas:* {$className}\n"
            . "⏰ *Waktu Mulai:* {$startTime} WIB\n\n"
            . "Mohon segera mempersiapkan materi dan bersiap menuju ruang kelas.\n\n"
            . "Terima kasih.\n_Kurikulum & IT Support Anise App_";

        self::sendInAppNotification($teacher->id, $title, $message);

        $phone = !empty($teacher->phone) ? $teacher->phone : ($teacher->guruProfile?->phone ?? null);
        if (!empty($phone)) {
            self::sendWhatsApp($phone, $waMessage);
        }

        return true;
    }

    /**
     * Notifikasi saat waktu KBM tepat dimulai (Start Time)
     */
    public static function notifyGuruKbmStart(Schedule $schedule, Journal $journal): bool
    {
        $teacher = $schedule->teacher;
        if (!$teacher) return false;

        $teacherName = $teacher->guruProfile?->full_name ?: ($teacher->full_name ?: ($teacher->username ?? 'Guru Pengampu'));
        $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
        $className = $schedule->class ? ($schedule->class->grade_level . ' ' . $schedule->class->name) : 'Kelas';
        $startTime = substr($schedule->start_time, 0, 5);

        $title = "🔔 KBM Dimulai: Presensi Jurnal Aktif ({$subjectName})";
        $message = "Bapak/Ibu {$teacherName}, jam KBM {$subjectName} ({$className}) telah dimulai pukul {$startTime} WIB. Tombol \"Presensi Jurnal\" telah muncul di aplikasi Anise. Segera lakukan presensi wajah di kelas sebelum toleransi 20 menit berakhir.";

        $waMessage = "🔔 *[KBM DIMULAI - PRESENSI JURNAL]*\n\n"
            . "Yth. Bapak/Ibu *{$teacherName}*,\n\n"
            . "Jam KBM mata pelajaran *{$subjectName}* di kelas *{$className}* telah dimulai ({$startTime} WIB).\n\n"
            . "📸 *Tombol 'Presensi Jurnal' sekarang sudah aktif di aplikasi Anise.*\n"
            . "Silakan buka aplikasi dan lakukan presensi wajah (Biometrik Cam & Geofence GPS) di kelas.\n\n"
            . "⏳ *Toleransi Waktu:* 20 menit dari waktu mulai KBM. Lewat dari itu tombol akan berubah menjadi 'Presensi Terlambat'.\n\n"
            . "Terima kasih.\n_Kurikulum Anise App_";

        self::sendInAppNotification($teacher->id, $title, $message);

        $phone = !empty($teacher->phone) ? $teacher->phone : ($teacher->guruProfile?->phone ?? null);
        if (!empty($phone)) {
            self::sendWhatsApp($phone, $waMessage);
        }

        return true;
    }

    /**
     * Peringatan Toleransi 20 Menit Habis: Presensi Cam KBM Berubah Jadi Terlambat
     */
    public static function notifyGuruPresensiCamLate(Schedule $schedule, Journal $journal, int $minutesLate): bool
    {
        $teacher = $schedule->teacher;
        if (!$teacher) return false;

        $teacherName = $teacher->guruProfile?->full_name ?: ($teacher->full_name ?: ($teacher->username ?? 'Guru Pengampu'));
        $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
        $className = $schedule->class ? ($schedule->class->grade_level . ' ' . $schedule->class->name) : 'Kelas';
        $startTime = substr($schedule->start_time, 0, 5);

        $title = "🚨 Peringatan: Presensi Jurnal Terlambat ({$subjectName})";
        $message = "Bapak/Ibu {$teacherName}, batas toleransi 20 menit KBM {$subjectName} ({$className}) telah terlewati (+{$minutesLate} menit). Tombol presensi telah berganti menjadi \"Presensi Terlambat\" (Merah). Segera lakukan presensi agar dapat mengisi jurnal mengajar.";

        $waMessage = "🚨 *[PERINGATAN KETERLAMBATAN KBM]*\n\n"
            . "Yth. Bapak/Ibu *{$teacherName}*,\n\n"
            . "Batas waktu toleransi 20 menit untuk KBM *{$subjectName}* di kelas *{$className}* telah berakhir (Keterlambatan: +{$minutesLate} menit).\n\n"
            . "⚠️ *Status:* Presensi Terlambat (Tombol Berwarna Merah)\n\n"
            . "Sesuai sistem akademik, Anda tidak dapat mengisi laporan jurnal sebelum melakukan presensi wajah & GPS terlebih dahulu.\n\n"
            . "Buka aplikasi *Anise App* sekarang dan klik tombol merah *'Presensi Terlambat'* pada kartu KBM yang bersangkutan.\n\n"
            . "Terima kasih.\n_Pengawas KBM & Kurikulum Anise App_";

        self::sendInAppNotification($teacher->id, $title, $message);

        $phone = !empty($teacher->phone) ? $teacher->phone : ($teacher->guruProfile?->phone ?? null);
        if (!empty($phone)) {
            self::sendWhatsApp($phone, $waMessage);
        }

        return true;
    }

    /**
     * Catat kegagalan unggah berkas ke tabel notifikasi dengan bahasa manusia yang detail dan informatif.
     */
    public static function recordUploadFailure(
        ?string $userId,
        string $moduleName,
        string $summaryReason,
        array|string $details = [],
        ?string $suggestion = null
    ): bool {
        if (!$userId) {
            $user = User::where('username', 'tu_dev')->first() ?? User::first();
            $userId = $user?->id;
        }

        if (!$userId) {
            return false;
        }

        $title = "⚠️ Gagal Unggah Master " . trim($moduleName);

        $detailLines = [];
        if (is_array($details)) {
            $totalDetails = count($details);
            $shownDetails = array_slice($details, 0, 20);
            foreach ($shownDetails as $d) {
                $detailLines[] = "• " . trim((string)$d);
            }
            if ($totalDetails > 20) {
                $detailLines[] = "• ... dan " . ($totalDetails - 20) . " kendala baris lainnya.";
            }
        } elseif (!empty($details)) {
            $detailLines[] = "• " . trim((string)$details);
        }

        $detailText = !empty($detailLines) 
            ? implode("\n", $detailLines) 
            : "• " . $summaryReason;

        $defaultSuggestion = match(true) {
            str_contains(strtolower($summaryReason), 'template') || str_contains(strtolower($summaryReason), 'terdeteksi') || str_contains(strtolower($summaryReason), 'bukan berkas')
                => "Pastikan Anda mengunggah berkas Excel dengan template Master {$moduleName} yang sesuai.",
            str_contains(strtolower($summaryReason), 'pdf') || str_contains(strtolower($summaryReason), 'format') 
                => "Harap gunakan berkas spreadsheet berekstensi .xlsx atau .xls, bukan berkas PDF atau dokumen teks.",
            str_contains(strtolower($summaryReason), 'kolom') || str_contains(strtolower($summaryReason), 'kosong') || str_contains(strtolower($summaryReason), 'wajib')
                => "Lengkapi semua data kolom wajib pada berkas Excel tersebut sesuai rincian di atas, lalu unggah kembali.",
            str_contains(strtolower($summaryReason), 'tidak ditemukan') || str_contains(strtolower($summaryReason), 'tidak cocok') 
                => "Pastikan data referensi penghubung (seperti Nama Guru, NUPTK, Nama Siswa, NISN, atau Nama Kelas) sudah terdaftar terlebih dahulu di menu master terkait dengan penulisan yang identik.",
            str_contains(strtolower($summaryReason), 'tanggal') || str_contains(strtolower($summaryReason), 'waktu')
                => "Periksa kembali format tanggal pada berkas Excel Anda. Gunakan format standar DD/MM/YYYY (contoh: 21/12/2025).",
            default 
                => "Silakan periksa kembali isi berkas Excel Anda atau hubungi admin teknis jika kendala terus berlanjut."
        };

        $finalSuggestion = $suggestion ?: $defaultSuggestion;

        $message = "Halo Bapak/Ibu, sistem mendeteksi proses impor/unggah berkas untuk Master {$moduleName} tidak dapat diselesaikan.\n\n"
            . "🔍 Penyebab Utama:\n{$summaryReason}\n\n"
            . "📋 Rincian Kendala:\n{$detailText}\n\n"
            . "💡 Solusi & Rekomendasi:\n{$finalSuggestion}";

        return self::sendInAppNotification($userId, $title, $message);
    }
}
