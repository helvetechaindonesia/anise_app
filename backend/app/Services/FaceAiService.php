<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FaceAiService
{
    /**
     * URL Microservice Python Face AI di VPS (Port 5000 internal)
     */
    protected static function getBaseUrl(): string
    {
        return env('FACE_AI_ENGINE_URL', 'http://127.0.0.1:5000');
    }

    /**
     * Ekstrak 512-D ArcFace Biometric Embedding dari Foto Wajah
     * Digunakan saat pendaftaran biometrik (Biometric Registration).
     *
     * @param \Illuminate\Http\UploadedFile $photo
     * @return array [ 'success' => bool, 'embedding' => array|null, 'message' => string ]
     */
    public static function extractEmbedding($photo): array
    {
        $url = self::getBaseUrl() . '/extract-face';

        try {
            $response = Http::timeout(15)
                ->attach('face_image', file_get_contents($photo->getRealPath()), $photo->getClientOriginalName())
                ->post($url);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'embedding' => $data['embedding'] ?? null,
                    'message' => $data['message'] ?? 'Biometrik wajah berhasil diekstrak.'
                ];
            }

            $errorData = $response->json();
            $message = $errorData['message'] ?? $errorData['detail'] ?? 'Gagal mengekstrak wajah dari foto.';
            return [
                'success' => false,
                'embedding' => null,
                'message' => $message
            ];

        } catch (\Throwable $e) {
            Log::error('FaceAiService::extractEmbedding Error: ' . $e->getMessage());
            return [
                'success' => false,
                'embedding' => null,
                'message' => 'Layanan pemrosesan AI wajah sedang tidak merespons (' . $e->getMessage() . ')'
            ];
        }
    }

    /**
     * Verifikasi Kemiripan Wajah Snapshot Kamera dengan Embedding Terdaftar
     * Digunakan saat Presensi Cam Harian & Jurnal KBM.
     *
     * @param \Illuminate\Http\UploadedFile $photo
     * @param string|array $registeredEmbedding
     * @return array [ 'success' => bool, 'verified' => bool, 'similarity' => float, 'message' => string ]
     */
    public static function verifyFace($photo, $registeredEmbedding): array
    {
        $url = self::getBaseUrl() . '/verify-face';

        $embeddingStr = is_array($registeredEmbedding) 
            ? json_encode($registeredEmbedding) 
            : (string)$registeredEmbedding;

        try {
            $response = Http::timeout(15)
                ->attach('face_image', file_get_contents($photo->getRealPath()), $photo->getClientOriginalName())
                ->asMultipart()
                ->post($url, [
                    'registered_embedding' => $embeddingStr
                ]);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'verified' => (bool)($data['verified'] ?? false),
                    'similarity' => (float)($data['similarity'] ?? 0.0),
                    'message' => $data['message'] ?? 'Verifikasi wajah selesai.'
                ];
            }

            $errorData = $response->json();
            $message = $errorData['message'] ?? $errorData['detail'] ?? 'Verifikasi biometrik wajah gagal.';
            return [
                'success' => false,
                'verified' => false,
                'similarity' => 0.0,
                'message' => $message
            ];

        } catch (\Throwable $e) {
            Log::error('FaceAiService::verifyFace Error: ' . $e->getMessage());
            return [
                'success' => false,
                'verified' => false,
                'similarity' => 0.0,
                'message' => 'Layanan pemrosesan AI wajah sedang tidak merespons (' . $e->getMessage() . ')'
            ];
        }
    }
}
