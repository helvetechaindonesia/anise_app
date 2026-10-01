import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/dio_client.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PresensiCameraScreen extends ConsumerStatefulWidget {
  const PresensiCameraScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PresensiCameraScreen> createState() => _PresensiCameraScreenState();
}

class _PresensiCameraScreenState extends ConsumerState<PresensiCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _initializeCamera();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan Lokasi (GPS) mati. Harap nyalakan.'), backgroundColor: Colors.red));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak!'), backgroundColor: Colors.red));
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak secara permanen.'), backgroundColor: Colors.red));
      }
      return;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;

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

  Future<void> _processPresensi() async {
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
                Text("Memverifikasi Geofence & Wajah...", textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final XFile file = await _controller!.takePicture();
      
      // Ambil lokasi saat ini
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/users/presensi-cam', data: {
        'lat': position.latitude,
        'lng': position.longitude,
      });
      
      if (mounted) {
        Navigator.pop(context); // Tutup dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${response.data['message']}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        
        String errorMsg = e.toString();
        if (e is DioException) {
          if (e.response != null && e.response?.data is Map) {
             errorMsg = e.response?.data['message'] ?? e.message;
          } else {
             errorMsg = e.message ?? e.toString();
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $errorMsg'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
              
            Positioned.fill(
              child: CustomPaint(
                painter: PresensiGuidelinePainter(),
              ),
            ),

            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), color: AppColors.menuPastelGreen, size: 20),
                    const SizedBox(width: 8),
                    const Text('Dalam Radius Sekolah', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    'Posisikan wajah Anda untuk absen',
                    style: AppTextStyles.titleMedium(context, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FloatingActionButton.large(
                    onPressed: _processPresensi,
                    backgroundColor: AppColors.primary,
                    shape: const CircleBorder(),
                    child: Icon(PhosphorIcons.fingerprint(PhosphorIconsStyle.bold), color: Colors.white, size: 36),
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

class PresensiGuidelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final faceRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 50),
      width: size.width * 0.7,
      height: size.height * 0.5,
    );

    final facePath = Path()..addOval(faceRect);

    final resultPath = Path.combine(PathOperation.difference, path, facePath);
    canvas.drawPath(resultPath, paint);

    final borderPaint = Paint()
      ..color = AppColors.menuPastelGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(faceRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
