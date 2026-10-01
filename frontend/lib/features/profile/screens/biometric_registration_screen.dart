import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/network/dio_client.dart';

class BiometricRegistrationScreen extends ConsumerStatefulWidget {
  const BiometricRegistrationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BiometricRegistrationScreen> createState() => _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState extends ConsumerState<BiometricRegistrationScreen> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Gunakan kamera depan
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
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
              CameraPreview(_controller!)
            else
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              
            // UI Overlay (Bingkai Wajah)
            Positioned.fill(
              child: CustomPaint(
                painter: FaceGuidelinePainter(),
              ),
            ),

            // Tombol & Teks Bawah
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    'Posisikan wajah Anda di dalam bingkai',
                    style: AppTextStyles.titleMedium(context, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FloatingActionButton.large(
                    onPressed: () async {
                      if (_controller == null || !_controller!.value.isInitialized) return;

                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text("Menganalisis biometrik wajah..."),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      try {
                        // Capture picture
                        final XFile file = await _controller!.takePicture();
                        
                        // Kirim request ke backend menggunakan Dio (lewat dioProvider)
                        final dio = ref.read(dioProvider);
                        await dio.post('/auth/users/biometric/register');
                        
                        if (mounted) {
                          Navigator.pop(context); // Close dialog
                          
                          // Show success
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Biometrik wajah berhasil didaftarkan di Database!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context); // Go back to profile
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mendaftar wajah: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    backgroundColor: AppColors.primary,
                    shape: const CircleBorder(),
                    child: Icon(PhosphorIcons.scan(PhosphorIconsStyle.bold), color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaceGuidelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final faceRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 50),
      width: size.width * 0.7,
      height: size.height * 0.5,
    );

    final facePath = Path()
      ..addOval(faceRect);

    // Potong lubang (lubang bentuk oval wajah)
    final resultPath = Path.combine(PathOperation.difference, path, facePath);
    canvas.drawPath(resultPath, paint);

    // Gambar border oval
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(faceRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
