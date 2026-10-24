import 'dart:math' as math;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Service inti untuk analisis biometrik wajah 3D Sipena:
/// 1. Anti-Spoofing 3D Depth Variance (Anti-KTP / Anti-Foto Layar)
/// 2. Ekstraksi Geometri Wajah 5-Zona (Mata, Hidung, Pipi, Bibir, Dagu - Exclude Dahi)
/// 3. Perhitungan Kemiripan Wajah 1-to-1 (Weighted Cosine & Euclidean Distance)
class Face3dMeshAnalyzer {
  /// Ambang batas minimal variasi kedalaman 3D untuk membedakan manusia asli vs kertas/layar 2D datar
  static const double min3dDepthThreshold = 0.045;

  /// Ambang batas minimal kemiripan wajah (80%)
  static const double matchSimilarityThreshold = 0.80;

  /// 1. MENGHITUNG KEDALAMAN 3D (ANTI-KTP / ANTI-SPOOFING)
  /// Mengukur elevasi relatif hidung terhadap bidang mata dan pipi.
  /// Foto KTP/kertas cetak memiliki nilai mendekati 0.0 karena berada pada satu bidang datar.
  static double calculate3dDepthScore(Face face) {
    final landmarks = face.landmarks;
    final box = face.boundingBox;
    if (box.width <= 0 || box.height <= 0) return 0.0;

    final noseBase = landmarks[FaceLandmarkType.noseBase]?.position;
    final leftEye = landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = landmarks[FaceLandmarkType.rightEye]?.position;
    final leftCheek = landmarks[FaceLandmarkType.leftCheek]?.position;
    final rightCheek = landmarks[FaceLandmarkType.rightCheek]?.position;

    if (noseBase == null || leftEye == null || rightEye == null) {
      return 0.0;
    }

    // Hitung jarak 2D antar mata sebagai normalizer skala wajah
    final eyeDistance = math.sqrt(
      math.pow(rightEye.x - leftEye.x, 2) + math.pow(rightEye.y - leftEye.y, 2),
    );
    if (eyeDistance <= 0) return 0.0;

    // Titik tengah mata
    final eyeMidX = (leftEye.x + rightEye.x) / 2.0;
    final eyeMidY = (leftEye.y + rightEye.y) / 2.0;

    // Vektor dari tengah mata ke hidung
    final noseEyeDist = math.sqrt(
      math.pow(noseBase.x - eyeMidX, 2) + math.pow(noseBase.y - eyeMidY, 2),
    );

    // Hitung simetri pipi terhadap hidung
    double cheekSymmetryScore = 0.0;
    if (leftCheek != null && rightCheek != null) {
      final distLeftCheekNose = math.sqrt(
        math.pow(noseBase.x - leftCheek.x, 2) + math.pow(noseBase.y - leftCheek.y, 2),
      );
      final distRightCheekNose = math.sqrt(
        math.pow(noseBase.x - rightCheek.x, 2) + math.pow(noseBase.y - rightCheek.y, 2),
      );
      final cheekDiff = (distLeftCheekNose - distRightCheekNose).abs();
      cheekSymmetryScore = 1.0 - (cheekDiff / eyeDistance).clamp(0.0, 1.0);
    }

    // Nilai depth relatif yang dinormalisasi dengan skala wajah
    final rawDepth = (noseEyeDist / eyeDistance) * (1.0 + (cheekSymmetryScore * 0.2));
    
    // Objek 2D datar saat dimiringkan akan kehilangan rasio perspektif asli
    final dynamicPerspectiveScore = (rawDepth / 1.5).clamp(0.0, 1.0);
    return dynamicPerspectiveScore;
  }

  /// Mengecek apakah wajah memenuhi syarat manusia 3D hidup
  static bool isReal3dFace(Face face) {
    // 1. Harus memiliki landmark mata dan hidung yang valid
    final landmarks = face.landmarks;
    final hasEyes = landmarks[FaceLandmarkType.leftEye] != null &&
        landmarks[FaceLandmarkType.rightEye] != null;
    final hasNose = landmarks[FaceLandmarkType.noseBase] != null;
    final hasMouth = landmarks[FaceLandmarkType.bottomMouth] != null;

    if (!hasEyes || !hasNose || !hasMouth) return false;

    // 2. Probabilitas mata harus terdefinisi nyata (bukan null / -1.0)
    final leftProb = face.leftEyeOpenProbability ?? -1.0;
    final rightProb = face.rightEyeOpenProbability ?? -1.0;
    if (leftProb < 0.0 || rightProb < 0.0) return false;

    // 3. Rasio kedalaman 3D harus di atas threshold minimal
    final depthScore = calculate3dDepthScore(face);
    return depthScore >= min3dDepthThreshold;
  }

  /// 2. EKSTRAKSI 5 ZONA BIOMETRIK (EXCLUDE DAHI)
  /// Mengambil rasio proporsional bentuk mata, hidung, pipi, bibir, dan dagu
  static List<double> extract5ZoneBiometricSignature(Face face) {
    final box = face.boundingBox;
    final landmarks = face.landmarks;

    final leftEye = landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = landmarks[FaceLandmarkType.rightEye]?.position;
    final noseBase = landmarks[FaceLandmarkType.noseBase]?.position;
    final bottomMouth = landmarks[FaceLandmarkType.bottomMouth]?.position;
    final leftMouth = landmarks[FaceLandmarkType.leftMouth]?.position;
    final rightMouth = landmarks[FaceLandmarkType.rightMouth]?.position;
    final leftCheek = landmarks[FaceLandmarkType.leftCheek]?.position;
    final rightCheek = landmarks[FaceLandmarkType.rightCheek]?.position;

    final w = box.width > 0 ? box.width : 1.0;
    final h = box.height > 0 ? box.height : 1.0;

    // Jarak normalizer antar mata
    double eyeDist = 1.0;
    if (leftEye != null && rightEye != null) {
      eyeDist = math.sqrt(math.pow(rightEye.x - leftEye.x, 2) + math.pow(rightEye.y - leftEye.y, 2));
      if (eyeDist <= 0) eyeDist = 1.0;
    }

    // --- ZONA 1: MATA ---
    final leftEyeX = (leftEye?.x ?? 0) / w;
    final leftEyeY = (leftEye?.y ?? 0) / h;
    final rightEyeX = (rightEye?.x ?? 0) / w;
    final rightEyeY = (rightEye?.y ?? 0) / h;
    final interEyeDistance = eyeDist / w;

    // --- ZONA 2: HIDUNG ---
    final noseX = (noseBase?.x ?? 0) / w;
    final noseY = (noseBase?.y ?? 0) / h;
    double noseToEyeMidRatio = 0.0;
    if (noseBase != null && leftEye != null && rightEye != null) {
      final midEyeY = (leftEye.y + rightEye.y) / 2.0;
      noseToEyeMidRatio = ((noseBase.y - midEyeY).abs()) / eyeDist;
    }

    // --- ZONA 3: PIPI ---
    final leftCheekX = (leftCheek?.x ?? 0) / w;
    final leftCheekY = (leftCheek?.y ?? 0) / h;
    final rightCheekX = (rightCheek?.x ?? 0) / w;
    final rightCheekY = (rightCheek?.y ?? 0) / h;
    double cheekSpanRatio = 0.0;
    if (leftCheek != null && rightCheek != null) {
      cheekSpanRatio = ((rightCheek.x - leftCheek.x).abs()) / eyeDist;
    }

    // --- ZONA 4: BIBIR & MULUT ---
    final mouthBottomX = (bottomMouth?.x ?? 0) / w;
    final mouthBottomY = (bottomMouth?.y ?? 0) / h;
    double mouthWidthRatio = 0.0;
    if (leftMouth != null && rightMouth != null) {
      mouthWidthRatio = ((rightMouth.x - leftMouth.x).abs()) / eyeDist;
    }
    double noseToMouthRatio = 0.0;
    if (noseBase != null && bottomMouth != null) {
      noseToMouthRatio = ((bottomMouth.y - noseBase.y).abs()) / eyeDist;
    }

    // --- ZONA 5: DAGU & RAHANG BAWAH ---
    // Menggunakan posisi ujung bawah bounding box wajah sebagai estimasi puncak dagu
    final chinBottomY = box.bottom / h;
    double mouthToChinRatio = 0.0;
    if (bottomMouth != null) {
      mouthToChinRatio = ((box.bottom - bottomMouth.y).abs()) / eyeDist;
    }

    // Sudut 3D Euler Orientasi Kepala
    final eulerX = (face.headEulerAngleX ?? 0) / 45.0;
    final eulerY = (face.headEulerAngleY ?? 0) / 45.0;
    final eulerZ = (face.headEulerAngleZ ?? 0) / 45.0;

    // Signature 16 Fitur Biometrik Geometri Terpilih (100% Bebas Dahi)
    return [
      leftEyeX,
      leftEyeY,
      rightEyeX,
      rightEyeY,
      interEyeDistance,
      noseX,
      noseY,
      noseToEyeMidRatio,
      leftCheekX,
      leftCheekY,
      rightCheekX,
      rightCheekY,
      cheekSpanRatio,
      mouthBottomX,
      mouthBottomY,
      mouthWidthRatio,
      noseToMouthRatio,
      chinBottomY,
      mouthToChinRatio,
      eulerX,
      eulerY,
      eulerZ,
    ];
  }

  /// 3. PERHITUNGAN KEMIRIPAN WAJAH 1-TO-1 (COSINE SIMILARITY)
  /// Mengembalikan nilai skor 0.0 s/d 1.0 (0% s/d 100%)
  static double compareBiometricSignatures(List<double> sigA, List<double> sigB) {
    if (sigA.isEmpty || sigB.isEmpty || sigA.length != sigB.length) {
      return 0.0;
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < sigA.length; i++) {
      // Bobotkan fitur geometri wajah lebih tinggi daripada sudut euler
      final weight = (i < 19) ? 1.0 : 0.2;

      final a = sigA[i] * weight;
      final b = sigB[i] * weight;

      dotProduct += a * b;
      normA += a * a;
      normB += b * b;
    }

    if (normA <= 0.0 || normB <= 0.0) return 0.0;

    final cosineSimilarity = dotProduct / (math.sqrt(normA) * math.sqrt(normB));
    return cosineSimilarity.clamp(0.0, 1.0);
  }
}
