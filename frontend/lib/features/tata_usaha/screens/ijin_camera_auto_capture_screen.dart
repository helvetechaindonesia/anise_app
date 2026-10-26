import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../screens/presensi_camera_screen.dart';

class IjinCameraAutoCaptureScreen extends StatefulWidget {
  const IjinCameraAutoCaptureScreen({Key? key}) : super(key: key);

  @override
  State<IjinCameraAutoCaptureScreen> createState() => _IjinCameraAutoCaptureScreenState();
}

class _IjinCameraAutoCaptureScreenState extends State<IjinCameraAutoCaptureScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  late FaceDetector _faceDetector;
  bool _isProcessingFrame = false;

  Position? _currentPosition;
  String _locationDisplay = "Mendeteksi posisi GPS...";

  CameraScanStatus _status = CameraScanStatus.checkingPermission;
  String _hintMessage = "Menyiapkan kamera...";
  bool _hasPassedTurnHead = false;
  bool _hasPassedBlinkClose = false;
  bool _hasPassedBlink = false;
  bool _hasTriggeredCapture = false;
  Rect? _lastBoundingBox;
  int _consecutiveFaceFrames = 0;
  double? _initialHeadEulerY;

  late AnimationController _scannerPulseController;

  @override
  void initState() {
    super.initState();
    _scannerPulseController = AnimationController(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCameraAndLocation();
    });
  }

  Future<void> _startCameraAndLocation() async {
    try {
      // 1. Ambil Lokasi Realtime (bukan dicocokkan radius sekolah, murni koordinat user)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
          _currentPosition = pos;
          _locationDisplay = "GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
        }
      }

      // 2. Inisialisasi Kamera Depan
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AniseFeedbackDialog.showError(
            context,
            title: "Kamera Tidak Tersedia",
            message: "Tidak ditemukan kamera pada perangkat ini.",
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
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _status = CameraScanStatus.locatingFace;
        _hintMessage = "Posisikan wajah Anda di dalam lingkaran";
      });

      await _controller!.startImageStream(_processCameraFrame);
    } catch (e) {
      if (mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: "Gagal Membuka Kamera",
          message: "Pastikan izin kamera dan lokasi telah diberikan: $e",
          onConfirm: () => Navigator.pop(context),
        );
      }
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _hasTriggeredCapture) return;
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
      _evaluateLiveness(face);
    } catch (_) {
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _evaluateLiveness(Face face) {
    final headEulerY = face.headEulerAngleY ?? 0;
    final leftEye = face.leftEyeOpenProbability ?? -1.0;
    final rightEye = face.rightEyeOpenProbability ?? -1.0;
    final bbox = face.boundingBox;

    // Filter Goyang
    if (_lastBoundingBox != null) {
      final deltaX = (bbox.left - _lastBoundingBox!.left).abs();
      final deltaY = (bbox.top - _lastBoundingBox!.top).abs();
      if (deltaX > 65 || deltaY > 65) {
        _lastBoundingBox = bbox;
        setState(() {
          _hintMessage = "Tahan kamera stabil, jangan digoyang.";
        });
        return;
      }
    }
    _lastBoundingBox = bbox;

    // Tahap 1: Deteksi Wajah
    if (!_hasPassedTurnHead) {
      _consecutiveFaceFrames++;
      if (_consecutiveFaceFrames < 3) {
        setState(() {
          _hintMessage = "Wajah terdeteksi! Tahan posisi...";
        });
        return;
      }

      _initialHeadEulerY ??= headEulerY;
      setState(() {
        _status = CameraScanStatus.turnHeadPrompt;
        _hintMessage = "Silakan GELENGKAN kepala sedikit ke Kiri atau Kanan";
      });

      final angleDiff = (headEulerY - _initialHeadEulerY!).abs();
      if (angleDiff >= 9.0) {
        _hasPassedTurnHead = true;
        HapticFeedback.lightImpact();
        setState(() {
          _status = CameraScanStatus.blinkPrompt;
          _hintMessage = "Bagus! Sekarang KEDIPKAN kedua mata Anda";
        });
      }
      return;
    }

    // Tahap 2: Kedip Mata (Melek -> Merem -> Melek)
    if (_hasPassedTurnHead && !_hasPassedBlink) {
      if (!_hasPassedBlinkClose) {
        if (leftEye >= 0 && rightEye >= 0 && (leftEye < 0.25 || rightEye < 0.25)) {
          _hasPassedBlinkClose = true;
          HapticFeedback.lightImpact();
          setState(() {
            _hintMessage = "Bagus! Sekarang BUKA mata Anda kembali";
          });
        }
      } else {
        if (leftEye > 0.55 && rightEye > 0.55) {
          _hasPassedBlink = true;
          _hasTriggeredCapture = true;
          HapticFeedback.mediumImpact();

          setState(() {
            _status = CameraScanStatus.capturing;
            _hintMessage = "Wajah terverifikasi! Menjepret foto...";
          });

          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) {
              _doCaptureAndReturn();
            }
          });
        }
      }
    }
  }

  Future<void> _doCaptureAndReturn() async {
    try {
      await _controller?.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 150));

      final XFile photo = await _controller!.takePicture();

      // Refresh GPS lokasi asli user sekali lagi
      Position? finalPosition = _currentPosition;
      try {
        finalPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _status = CameraScanStatus.success;
        _hintMessage = "Foto wajah berhasil diambil!";
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      // Kembalikan file foto dan koordinat realtime ke layar pemanggil
      Navigator.pop(context, {
        'photo_file': File(photo.path),
        'latitude': finalPosition?.latitude,
        'longitude': finalPosition?.longitude,
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasTriggeredCapture = false;
          _hasPassedBlink = false;
          _status = CameraScanStatus.locatingFace;
          _hintMessage = "Gagal mengambil foto, silakan coba lagi.";
        });
        _controller?.startImageStream(_processCameraFrame);
      }
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      int rotationCompensation = (sensorOrientation + 0) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

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

            // Lingkaran Sempurna Guideline
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

            // Top Header: Tombol Tutup & Indikator Lokasi Realtime
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
                      border: Border.all(color: AppColors.menuPastelGreen.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIconsFill.mapPin, color: AppColors.menuPastelGreen, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _locationDisplay,
                          style: AppTextStyles.labelSmall(context, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Bottom Prompt Bar
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _status == CameraScanStatus.turnHeadPrompt
                          ? PhosphorIconsRegular.arrowsLeftRight
                          : (_status == CameraScanStatus.blinkPrompt
                              ? PhosphorIconsRegular.eye
                              : PhosphorIconsRegular.userFocus),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _hintMessage,
                        style: AppTextStyles.bodyMedium(context, color: Colors.white).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
