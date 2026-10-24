import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../../core/biometric/face_3d_mesh_analyzer.dart';
import 'package:dio/dio.dart';

enum CameraScanStatus {
  checkingPermission,
  verifyingGeofence,
  outsideRadius,
  locatingFace,
  turnHeadPrompt,
  blinkPrompt,
  capturing,
  success,
}

class PresensiCameraScreen extends ConsumerStatefulWidget {
  final String? journalId;
  final String? kbmTitle;

  const PresensiCameraScreen({
    Key? key,
    this.journalId,
    this.kbmTitle,
  }) : super(key: key);

  @override
  ConsumerState<PresensiCameraScreen> createState() => _PresensiCameraScreenState();
}

class _PresensiCameraScreenState extends ConsumerState<PresensiCameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  // Face Detection ML Kit
  late FaceDetector _faceDetector;
  bool _isProcessingFrame = false;

  // Geofence & Location
  Position? _currentPosition;
  bool _isInsideRadius = true;

  // Status & Liveness Timing
  CameraScanStatus _status = CameraScanStatus.checkingPermission;
  String _hintMessage = "Menyiapkan kamera...";
  bool _hasPassedTurnHead = false;
  bool _hasPassedBlink = false;
  bool _hasTriggeredCapture = false;
  int _consecutiveFaceFrames = 0;

  // Animation controller
  late AnimationController _scannerPulseController;

  @override
  void initState() {
    super.initState();
    _scannerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // ML Kit dengan deteksi orientasi kepala dan kedipan mata
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // Untuk baca mata kedip & senyum
        enableTracking: true,
        enableLandmarks: true, // Untuk feature matching geometri wajah
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // Minta perizinan custom Sipena
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsWithCustomDialog();
    });
  }

  Future<void> _requestPermissionsWithCustomDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AniseFeedbackDialog(
        type: AniseFeedbackType.confirm,
        title: "Izin Kamera & Lokasi",
        message: "Sipena memerlukan izin Kamera dan Lokasi (GPS) untuk memastikan kehadiran Anda valid dalam radius sekolah.",
        confirmText: "Lanjutkan",
        cancelText: "Batal",
        customIcon: PhosphorIcons.camera(PhosphorIconsStyle.bold),
        onConfirm: () async {
          Navigator.pop(ctx);
          await _checkGpsAndPermissions();
        },
        onCancel: () {
          Navigator.pop(ctx);
          if (mounted) {
            Navigator.pop(context); // Auto-exit
          }
        },
      ),
    );
  }

  Future<void> _checkGpsAndPermissions() async {
    try {
      // 1. Cek Service Lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          AniseFeedbackDialog.showError(
            context,
            title: "GPS Tidak Aktif",
            message: "Layanan Lokasi (GPS) pada perangkat Anda mati. Harap nyalakan GPS untuk melakukan presensi.",
            onConfirm: () => Navigator.pop(context),
          );
        }
        return;
      }

      // 2. Cek Izin Lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            AniseFeedbackDialog.showError(
              context,
              title: "Izin Lokasi Ditolak",
              message: "Izin lokasi diperlukan untuk memverifikasi posisi sekolah Anda.",
              onConfirm: () => Navigator.pop(context),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          AniseFeedbackDialog.showError(
            context,
            title: "Izin Lokasi Ditolak Permanen",
            message: "Harap izinkan akses lokasi melalui pengaturan aplikasi di HP Anda.",
            onConfirm: () => Navigator.pop(context),
          );
        }
        return;
      }

      // Ambil posisi awal GPS
      _currentPosition = await Geolocator.getCurrentPosition();

      setState(() {
        _status = CameraScanStatus.locatingFace;
        _hintMessage = "Posisikan wajah Anda di dalam lingkaran";
      });

      // Init Kamera
      await _initializeCamera();
    } catch (e) {
      debugPrint("Permission error: $e");
      if (mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: "Terjadi Kendala",
          message: "Tidak dapat mengakses GPS atau Kamera: $e",
          onConfirm: () => Navigator.pop(context),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AniseFeedbackDialog.showError(
            context,
            title: "Kamera Tidak Ditemukan",
            message: "Kamera tidak terdeteksi pada perangkat ini.",
            onConfirm: () => Navigator.pop(context),
          );
        }
        return;
      }

      final frontCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      // Mulai AI Face Stream
      await _controller!.startImageStream(_processCameraFrame);
    } catch (e) {
      debugPrint("Camera init error: $e");
      if (mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: "Izin Kamera Dibutuhkan",
          message: "Tidak dapat membuka kamera. Pastikan izin kamera telah diberikan.",
          onConfirm: () => Navigator.pop(context),
        );
      }
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _hasTriggeredCapture || !_isInsideRadius) {
      return;
    }
    _isProcessingFrame = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted) {
        _isProcessingFrame = false;
        return;
      }

      if (faces.isEmpty) {
        _consecutiveFaceFrames = 0;
        if (_status != CameraScanStatus.locatingFace) {
          setState(() {
            _status = CameraScanStatus.locatingFace;
            _hintMessage = "Posisikan wajah Anda di dalam lingkaran";
          });
        }
        _isProcessingFrame = false;
        return;
      }

      if (faces.length > 1) {
        _consecutiveFaceFrames = 0;
        setState(() {
          _hintMessage = "Terdeteksi lebih dari 1 wajah! Pastikan Anda sendirian";
        });
        _isProcessingFrame = false;
        return;
      }

      final face = faces.first;
      _evaluateLivenessAntiSpoof(face);
    } catch (e) {
      debugPrint("Presensi frame error: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  // Liveness state: Sudut awal kepala dinamis
  double? _initialHeadEulerY;

  // Liveness Step Execution (Anti-Spoofing Ketat)
  void _evaluateLivenessAntiSpoof(Face face) {
    final headEulerY = face.headEulerAngleY ?? 0;
    final leftEye = face.leftEyeOpenProbability ?? -1.0;
    final rightEye = face.rightEyeOpenProbability ?? -1.0;

    // Step 0: UJI KEDALAMAN 3D REAL-TIME (TOLAK MUTLAK FOTO KTP / KERTAS / LAYAR HP)
    if (!Face3dMeshAnalyzer.isReal3dFace(face)) {
      setState(() {
        _status = CameraScanStatus.outsideRadius; // Trigger ring merah
        _hintMessage = "Objek datar terdeteksi! Gunakan wajah manusia asli (Bukan Foto/KTP)";
      });
      return;
    }

    // Step 1: Rekam posisi awal kepala & pastikan kedua mata melek terbuka nyata
    if (_initialHeadEulerY == null) {
      if (headEulerY.abs() < 12 && leftEye > 0.65 && rightEye > 0.65) {
        _consecutiveFaceFrames++;
        if (_consecutiveFaceFrames >= 3) {
          _initialHeadEulerY = headEulerY;
          _consecutiveFaceFrames = 0;
          setState(() {
            _status = CameraScanStatus.turnHeadPrompt;
            _hintMessage = "Tolehkan kepala sedikit ke kanan atau kiri";
          });
        }
      }
      return;
    }

    // Step 2: Deteksi Perubahan Sudut Kepala Dinamis (Beda minimal 15 derajat dari posisi awal)
    // Foto KTP yang digoyang pelan tidak akan mengubah rasio sudut Euler 3D
    if (!_hasPassedTurnHead) {
      final deltaAngle = (headEulerY - _initialHeadEulerY!).abs();
      if (deltaAngle >= 14.0) {
        _hasPassedTurnHead = true;
        HapticFeedback.lightImpact();
        setState(() {
          _status = CameraScanStatus.blinkPrompt;
          _hintMessage = "Bagus! Sekarang KEDIPKAN MATA Anda 😉";
        });
      }
      return;
    }

    // Step 3: Deteksi Transisi Kedip Nyata (Mata tadinya melek -> merem tutup -> melek lagi)
    // FOTO KTP TIDAK BISA BERUBAH DARI MELEK KE MEREM!
    if (_hasPassedTurnHead && !_hasPassedBlink) {
      // Kondisi mata terpejam / kedip (salah satu atau kedua mata < 0.20)
      if (leftEye < 0.22 || rightEye < 0.22) {
        _hasPassedBlink = true;
        _hasTriggeredCapture = true;
        HapticFeedback.mediumImpact();

        setState(() {
          _status = CameraScanStatus.capturing;
          _hintMessage = "Kedip terverifikasi! Menjepret presensi...";
        });

        // Delay 350ms agar mata terbuka kembali secara alami sebelum difoto
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            _autoCapturePresensi(face);
          }
        });
      }
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation = _orientations[deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  DeviceOrientation get deviceOrientation => DeviceOrientation.portraitUp;

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Future<void> _autoCapturePresensi(Face face) async {
    setState(() {
      _status = CameraScanStatus.capturing;
      _hintMessage = "Mengirim data presensi...";
    });

    try {
      await _controller?.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));

      final XFile photo = await _controller!.takePicture();
      final embedding = Face3dMeshAnalyzer.extract5ZoneBiometricSignature(face);

      // Refresh posisi terbaru agar akurat
      Position position = _currentPosition ??
          await Geolocator.getCurrentPosition();

      final dio = ref.read(dioProvider);
      final endpoint = widget.journalId != null
          ? '/journals/${widget.journalId}/check-in-cam'
          : '/attendance/check-in-cam';

      // Kirim via FormData dengan foto snapshot asli dan vektor geometri wajah sebagai JSON String
      final formData = FormData.fromMap({
        'lat': position.latitude,
        'lng': position.longitude,
        'face_embedding': jsonEncode(embedding),
        'face_image': await MultipartFile.fromFile(
          photo.path,
          filename: 'face_presensi_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await dio.post(endpoint, data: formData);

      if (!mounted) return;

      setState(() {
        _status = CameraScanStatus.success;
      });
      HapticFeedback.heavyImpact();

      final msg = response.data['message'] ?? 'Presensi berhasil dicatat!';

      AniseFeedbackDialog.showSuccess(
        context,
        title: "Presensi Berhasil!",
        message: msg,
        buttonText: "Selesai",
        onConfirm: () {
          Navigator.pop(context, true); // Kembali dengan hasil sukses
        },
      );
    } catch (e) {
      String errorMsg = "Presensi gagal.";
      if (e is DioException) {
        if (e.response != null && e.response?.data is Map) {
          errorMsg = e.response?.data['message'] ?? e.message;
        } else {
          errorMsg = e.message ?? e.toString();
        }
      } else {
        errorMsg = e.toString();
      }

      // Jika ditolak karena di luar radius, update status visual di layar
      if (errorMsg.toLowerCase().contains("radius") || errorMsg.toLowerCase().contains("luar")) {
        setState(() {
          _isInsideRadius = false;
          _status = CameraScanStatus.outsideRadius;
          _hintMessage = errorMsg;
          _hasTriggeredCapture = false;
        });
      } else {
        if (mounted) {
          AniseFeedbackDialog.showError(
            context,
            title: "Presensi Ditolak",
            message: errorMsg,
            buttonText: "Kembali",
            onConfirm: () {
              Navigator.pop(context, false);
            },
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scannerPulseController.dispose();
    _faceDetector.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview Kamera (Aspect Ratio Presisi Anti-Peyang)
            if (_isCameraInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: 1 / _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            // Frame Lingkaran Sempurna
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scannerPulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: PresensiCircleGuidelinePainter(
                      pulseValue: _scannerPulseController.value,
                      status: _status,
                    ),
                  );
                },
              ),
            ),

            // Top Header: Tombol Batal & Status Geofence Pill
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(PhosphorIconsRegular.x, color: Colors.white, size: 20),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _status == CameraScanStatus.outsideRadius
                            ? AppColors.error
                            : AppColors.menuPastelGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsFill.mapPin,
                          color: _status == CameraScanStatus.outsideRadius
                              ? AppColors.error
                              : AppColors.menuPastelGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _status == CameraScanStatus.outsideRadius
                              ? "Di Luar Radius Sekolah"
                              : "Dalam Radius Lokasi",
                          style: AppTextStyles.labelMedium(context, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 44), // Balancer
                ],
              ),
            ),

            // Bottom Real-time Dynamic Info Banner (BUKAN Pop-up!)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _getBorderColorByStatus(),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getBorderColorByStatus().withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStatusIcon(),
                            color: _getBorderColorByStatus(),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _hintMessage,
                                style: AppTextStyles.titleSmall(context, color: Colors.white).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.kbmTitle != null
                                    ? "Presensi Jurnal: ${widget.kbmTitle}"
                                    : "Liveness Check Anti-Foto KTP",
                                style: AppTextStyles.bodySmall(context, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColorByStatus() {
    switch (_status) {
      case CameraScanStatus.outsideRadius:
        return AppColors.error;
      case CameraScanStatus.turnHeadPrompt:
        return AppColors.secondary;
      case CameraScanStatus.blinkPrompt:
        return AppColors.warning;
      case CameraScanStatus.capturing:
      case CameraScanStatus.success:
        return AppColors.menuPastelGreen;
      case CameraScanStatus.locatingFace:
      case CameraScanStatus.verifyingGeofence:
      case CameraScanStatus.checkingPermission:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case CameraScanStatus.outsideRadius:
        return PhosphorIconsRegular.warning;
      case CameraScanStatus.turnHeadPrompt:
        return PhosphorIconsRegular.arrowsLeftRight;
      case CameraScanStatus.blinkPrompt:
        return PhosphorIconsRegular.eye;
      case CameraScanStatus.capturing:
        return PhosphorIconsFill.camera;
      case CameraScanStatus.success:
        return PhosphorIconsFill.checkCircle;
      case CameraScanStatus.locatingFace:
      default:
        return PhosphorIconsRegular.userFocus;
    }
  }
}

class PresensiCircleGuidelinePainter extends CustomPainter {
  final double pulseValue;
  final CameraScanStatus status;

  PresensiCircleGuidelinePainter({
    required this.pulseValue,
    required this.status,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2 - 40);
    final radius = size.width * 0.38;

    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // Lubang lingkaran
    final resultPath = Path.combine(PathOperation.difference, path, circlePath);
    canvas.drawPath(resultPath, backgroundPaint);

    // Border Lingkaran
    Color borderColor;
    if (status == CameraScanStatus.outsideRadius) {
      borderColor = AppColors.error;
    } else if (status == CameraScanStatus.turnHeadPrompt) {
      borderColor = AppColors.secondary;
    } else if (status == CameraScanStatus.blinkPrompt) {
      borderColor = AppColors.warning;
    } else if (status == CameraScanStatus.capturing ||
        status == CameraScanStatus.success) {
      borderColor = AppColors.menuPastelGreen;
    } else {
      borderColor = AppColors.primary;
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Pulse Ring radar efek
    final pulseRadius = radius + (pulseValue * 14);
    final pulsePaint = Paint()
      ..color = borderColor.withValues(alpha: (1 - pulseValue) * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, pulseRadius, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant PresensiCircleGuidelinePainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.status != status;
  }
}
