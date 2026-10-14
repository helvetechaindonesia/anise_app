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
            if (Schema::hasTable('notifications')) {
                DB::table('notifications')->insert([
                    'id' => Str::uuid()->toString(),
                    'user_id' => $userId,
                    'title' => $title,
                    'message' => $message,
                    'is_read' => false,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                return true;
            }
        } catch (\Throwable $e) {
            Log::error("Gagal menyimpan notifikasi in-app: " . $e->getMessage());
        }
        return false;
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

        if (!empty($teacher->phone)) {
            self::sendWhatsApp($teacher->phone, $waMessage);
        }

        return true;
    }

    /**
     * Peringatan Toleransi 15 Menit: Guru belum presensi cam saat KBM aktif
     */
    public static function notifyGuruPresensiCamLate(Schedule $schedule, Journal $journal, int $minutesLate): bool
    {
        $teacher = $schedule->teacher;
        if (!$teacher) return false;

        $teacherName = $teacher->guruProfile?->full_name ?: ($teacher->full_name ?: ($teacher->username ?? 'Guru Pengampu'));
        $subjectName = $schedule->subject?->name ?? 'Mata Pelajaran';
        $className = $schedule->class ? ($schedule->class->grade_level . ' ' . $schedule->class->name) : 'Kelas';
        $startTime = substr($schedule->start_time, 0, 5);

        $title = "🚨 Peringatan Presensi Cam KBM (Toleransi 15 Menit)";
        $message = "Bapak/Ibu {$teacherName}, KBM {$subjectName} ({$className}) telah dimulai pukul {$startTime}. Anda belum melakukan Presensi Cam (keterlambatan {$minutesLate} menit). Anda tidak dapat mengisi jurnal mengajar sebelum presensi cam terverifikasi.";

        $waMessage = "🚨 *[PERINGATAN PRESENSI CAM KBM]*\n\n"
            . "Yth. Bapak/Ibu *{$teacherName}*,\n\n"
            . "KBM mata pelajaran *{$subjectName}* di kelas *{$className}* telah dimulai sejak pukul *{$startTime} WIB*.\n\n"
            . "⚠️ *Peringatan Keterlambatan:* {$minutesLate} menit.\n"
            . "Anda belum melakukan *Presensi Cam (Face Recognition + Geofence GPS)* di dalam kelas.\n\n"
            . "Ingat: Batas toleransi presensi cam adalah 15 menit dari jam mulai. Anda tidak dapat mengisi laporan jurnal sebelum presensi cam terverifikasi.\n\n"
            . "Buka aplikasi *Anise App* sekarang dan lakukan Presensi Cam pada kartu KBM yang sedang aktif.\n\n"
            . "Terima kasih.\n_Kurikulum & Pengawas KBM Anise App_";

        self::sendInAppNotification($teacher->id, $title, $message);

        if (!empty($teacher->phone)) {
            self::sendWhatsApp($teacher->phone, $waMessage);
        }

        return true;
    }
}
