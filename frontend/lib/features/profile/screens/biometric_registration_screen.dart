import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../../core/biometric/face_3d_mesh_analyzer.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';

enum LivenessStep {
  lookStraight,
  turnHead,
  smileOrBlink,
  capturing,
  completed,
}

class BiometricRegistrationScreen extends ConsumerStatefulWidget {
  const BiometricRegistrationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BiometricRegistrationScreen> createState() => _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState extends ConsumerState<BiometricRegistrationScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  // Face Detector
  late FaceDetector _faceDetector;
  bool _isProcessingFrame = false;

  // Liveness Logic
  LivenessStep _currentStep = LivenessStep.lookStraight;
  double _stepProgress = 0.0;
  String _hintMessage = "Posisikan wajah Anda tepat di dalam lingkaran";
  bool _hasPassedStep1 = false;
  bool _hasPassedStep2 = false;
  bool _hasPassedStep3 = false;
  int _consecutiveValidFrames = 0;

  // Animation controller for scanner ring
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // Minta izin kustom Sipena terlebih dahulu sebelum init kamera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermissionWithCustomDialog();
    });
  }

  Future<void> _requestCameraPermissionWithCustomDialog() async {
    // Pop up konfirmasi kustom Sipena
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AniseFeedbackDialog(
        type: AniseFeedbackType.confirm,
        title: "Izin Akses Kamera",
        message: "Sipena memerlukan izin Kamera untuk mendaftarkan kontur biometrik wajah Anda dengan aman.",
        confirmText: "Lanjutkan",
        cancelText: "Batal",
        customIcon: PhosphorIcons.camera(PhosphorIconsStyle.bold),
        onConfirm: () async {
          Navigator.pop(ctx);
          await _initializeCamera();
        },
        onCancel: () {
          Navigator.pop(ctx);
          if (mounted) {
            Navigator.pop(context); // Auto-exit kembali ke halaman profil
          }
        },
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AniseFeedbackDialog.showError(
            context,
            title: "Kamera Tidak Ditemukan",
            message: "Perangkat ini tidak memiliki kamera yang dapat diakses.",
            onConfirm: () => Navigator.pop(context),
          );
        }
        return;
      }

      // Gunakan kamera depan
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
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

      // Start Image Stream untuk Real-time AI Face Detection
      await _controller!.startImageStream(_processCameraFrame);
    } catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: "Izin Ditolak",
          message: "Akses kamera tidak diizinkan. Silakan izinkan akses kamera di pengaturan perangkat Anda.",
          onConfirm: () => Navigator.pop(context),
        );
      }
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _currentStep == LivenessStep.capturing || _currentStep == LivenessStep.completed) {
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
        _consecutiveValidFrames = 0;
        setState(() {
          _hintMessage = "Wajah tidak terdeteksi. Posisikan di dalam lingkaran.";
        });
        _isProcessingFrame = false;
        return;
      }

      if (faces.length > 1) {
        _consecutiveValidFrames = 0;
        setState(() {
          _hintMessage = "Terdeteksi lebih dari 1 wajah! Harap sendirian.";
        });
        _isProcessingFrame = false;
        return;
      }

      final face = faces.first;
      final headEulerY = face.headEulerAngleY ?? 0; // Toleh kanan (-) atau kiri (+)
      final smileProb = face.smilingProbability ?? 0;
      final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;

      // Evaluasi Step Liveness
      switch (_currentStep) {
        case LivenessStep.lookStraight:
          if (headEulerY.abs() < 12) {
            _consecutiveValidFrames++;
            if (_consecutiveValidFrames >= 4) {
              _hasPassedStep1 = true;
              _consecutiveValidFrames = 0;
              setState(() {
                _currentStep = LivenessStep.turnHead;
                _stepProgress = 0.35;
                _hintMessage = "Bagus! Sekarang tolehkan kepala sedikit ke kanan atau kiri";
              });
              HapticFeedback.lightImpact();
            } else {
              setState(() {
                _hintMessage = "Tahan posisi wajah lurus...";
              });
            }
          } else {
            _consecutiveValidFrames = 0;
            setState(() {
              _hintMessage = "Posisikan wajah lurus menghadap kamera";
            });
          }
          break;

        case LivenessStep.turnHead:
          if (headEulerY.abs() > 16) {
            _consecutiveValidFrames++;
            if (_consecutiveValidFrames >= 3) {
              _hasPassedStep2 = true;
              _consecutiveValidFrames = 0;
              setState(() {
                _currentStep = LivenessStep.smileOrBlink;
                _stepProgress = 0.70;
                _hintMessage = "Mantap! Sekarang kedipkan mata atau tersenyumlah";
              });
              HapticFeedback.mediumImpact();
            }
          }
          break;

        case LivenessStep.smileOrBlink:
          // Senyum > 0.4 atau salah satu mata berkedip (< 0.25)
          if (smileProb > 0.4 || leftEyeOpen < 0.25 || rightEyeOpen < 0.25) {
            _consecutiveValidFrames++;
            if (_consecutiveValidFrames >= 2) {
              _hasPassedStep3 = true;
              _consecutiveValidFrames = 0;
              setState(() {
                _currentStep = LivenessStep.capturing;
                _stepProgress = 1.0;
                _hintMessage = "Sempurna! Mengambil biometrik wajah...";
              });
              HapticFeedback.heavyImpact();
              _autoCaptureAndRegister(face);
            }
          }
          break;

        case LivenessStep.capturing:
        case LivenessStep.completed:
          break;
      }
    } catch (e) {
      debugPrint("Frame processing error: $e");
    } finally {
      _isProcessingFrame = false;
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

  Future<void> _autoCaptureAndRegister(Face face) async {
    try {
      await _controller?.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));

      final XFile photo = await _controller!.takePicture();
      final dio = ref.read(dioProvider);

      final formData = FormData.fromMap({
        'face_image': await MultipartFile.fromFile(
          photo.path,
          filename: 'face_register_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await dio.post('/attendance/biometric/register', data: formData);

      // Update auth user profile state agar badge biometrik langsung hijau
      ref.read(authProvider.notifier).checkAuth();

      if (mounted) {
        setState(() {
          _currentStep = LivenessStep.completed;
        });

        final successMsg = response.data['message'] ?? 'Data biometrik wajah Anda telah tersimpan dan aktif untuk presensi.';
        AniseFeedbackDialog.showSuccess(
          context,
          title: "Pendaftaran Berhasil!",
          message: successMsg,
          onConfirm: () {
            Navigator.pop(context, true);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = "Terjadi kesalahan saat memproses biometrik.";
        if (e is DioException && e.response?.data != null) {
          errorMsg = e.response?.data['message'] ?? e.response?.data['detail'] ?? errorMsg;
        } else {
          errorMsg = "$e";
        }

        AniseFeedbackDialog.showError(
          context,
          title: "Pendaftaran Ditolak",
          message: errorMsg,
          onConfirm: () {
            // Reset status agar user bisa mengulang
            if (mounted) {
              setState(() {
                _currentStep = LivenessStep.lookStraight;
                _stepProgress = 0.0;
                _hasPassedStep1 = false;
                _hasPassedStep2 = false;
                _hasPassedStep3 = false;
                _consecutiveValidFrames = 0;
                _hintMessage = "Posisikan wajah lurus menghadap kamera";
              });
              _controller?.startImageStream(_processCameraFrame);
            }
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BiometricCircleGuidelinePainter(
                      pulseValue: _pulseController.value,
                      isCapturing: _currentStep == LivenessStep.capturing ||
                          _currentStep == LivenessStep.completed,
                      progress: _stepProgress,
                    ),
                  );
                },
              ),
            ),

            // Top Header: Tombol Tutup & Judul
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
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIconsFill.shieldCheck, color: AppColors.menuPastelGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Pendaftaran Face ID",
                          style: AppTextStyles.labelMedium(context, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 44), // Balancer
                ],
              ),
            ),

            // Step Progress Checklist
            Positioned(
              top: 80,
              left: 32,
              right: 32,
              child: Row(
                children: [
                  _buildStepItem("1. Lurus", _hasPassedStep1, _currentStep == LivenessStep.lookStraight),
                  const SizedBox(width: 8),
                  _buildStepItem("2. Toleh", _hasPassedStep2, _currentStep == LivenessStep.turnHead),
                  const SizedBox(width: 8),
                  _buildStepItem("3. Senyum", _hasPassedStep3, _currentStep == LivenessStep.smileOrBlink),
                ],
              ),
            ),

            // Bottom Prompt & Hint Panel
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
                        color: _currentStep == LivenessStep.capturing
                            ? AppColors.menuPastelGreen
                            : Colors.white24,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getStepIcon(),
                          color: _currentStep == LivenessStep.capturing
                              ? AppColors.menuPastelGreen
                              : AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _hintMessage,
                          style: AppTextStyles.titleMedium(context, color: Colors.white).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _stepProgress,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _currentStep == LivenessStep.capturing
                                  ? AppColors.menuPastelGreen
                                  : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sistem akan otomatis mengambil biometrik saat gestur selesai",
                    style: AppTextStyles.bodySmall(context, color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String title, bool isDone, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.menuPastelGreen.withOpacity(0.2)
              : (isActive ? AppColors.primary.withOpacity(0.2) : Colors.black54),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone
                ? AppColors.menuPastelGreen
                : (isActive ? AppColors.primary : Colors.white24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone
                  ? PhosphorIconsFill.checkCircle
                  : (isActive ? PhosphorIconsFill.record : PhosphorIconsRegular.circle),
              color: isDone
                  ? AppColors.menuPastelGreen
                  : (isActive ? AppColors.primary : Colors.white54),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.labelSmall(
                context,
                color: isDone ? Colors.white : (isActive ? Colors.white : Colors.white60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon() {
    switch (_currentStep) {
      case LivenessStep.lookStraight:
        return PhosphorIconsRegular.userFocus;
      case LivenessStep.turnHead:
        return PhosphorIconsRegular.arrowsLeftRight;
      case LivenessStep.smileOrBlink:
        return PhosphorIconsRegular.smiley;
      case LivenessStep.capturing:
      case LivenessStep.completed:
        return PhosphorIconsFill.checkCircle;
    }
  }
}

class BiometricCircleGuidelinePainter extends CustomPainter {
  final double pulseValue;
  final bool isCapturing;
  final double progress;

  BiometricCircleGuidelinePainter({
    required this.pulseValue,
    required this.isCapturing,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2 - 40);
    final radius = size.width * 0.38;

    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // Potong lubang lingkaran sempurna di tengah
    final resultPath = Path.combine(PathOperation.difference, path, circlePath);
    canvas.drawPath(resultPath, backgroundPaint);

    // Border Lingkaran Luar Statis
    final baseBorderPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, baseBorderPaint);

    // Border Progress Ring (Berputar & Menyala)
    final progressPaint = Paint()
      ..color = isCapturing ? AppColors.menuPastelGreen : AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Pulse Ring radar efek
    if (!isCapturing) {
      final pulseRadius = radius + (pulseValue * 12);
      final pulsePaint = Paint()
        ..color = AppColors.primary.withOpacity((1 - pulseValue) * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BiometricCircleGuidelinePainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.isCapturing != isCapturing ||
        oldDelegate.progress != progress;
  }
}
