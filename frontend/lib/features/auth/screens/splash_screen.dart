import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/utils/responsive.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final AudioPlayer _swooshPlayer = AudioPlayer();
  final AudioPlayer _cringPlayer = AudioPlayer();
  
  // Phase 1: Anise Logo (0.0 to 0.4)
  late Animation<double> _aniseScale;
  late Animation<double> _aniseRotate;
  
  // Phase 2: Morphing (0.4 to 0.6)
  late Animation<double> _aniseOpacity;
  late Animation<double> _smkOpacity;
  late Animation<double> _smkScale;
  
  // Phase 3: School Name (0.6 to 0.8)
  late Animation<double> _nameOpacity;
  late Animation<double> _nameScale;
  
  // Phase 4: Tagline (0.75 to 1.0)
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    // Phase 1 & 2 Setup (Anise Scale)
    _aniseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40.0, // 0.0 to 0.4 (Fase 1: Muncul)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInBack)),
        weight: 20.0, // 0.4 to 0.6 (Fase 2: Menyusut hilang)
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 40.0, // 0.6 to 1.0 (Tetap hilang)
      ),
    ]).animate(_controller);
    
    _aniseRotate = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    // Phase 2 Setup
    _aniseOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _smkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _smkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOutBack), // Disulap membesar dari 0
      ),
    );
    
    // Phase 3 Setup
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _nameScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOutBack), // Efek pop out
      ),
    );
    
    // Phase 4 Setup
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.9, curve: Curves.easeOut), // Dimajukan agar berbarengan dengan nama sekolah
      ),
    );
    
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.9, curve: Curves.easeOut),
      ),
    );

    // Mulai animasi
    _controller.forward().then((_) {
      // Tunggu 0.5 detik setelah semua selesai sebelum menavigasi ke Login
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
    });
    
    // Mainkan sound effects sesuai timing fase animasi
    _swooshPlayer.play(AssetSource('sounds/swoosh.wav')); // Phase 1 mulai
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _cringPlayer.play(AssetSource('sounds/cring.wav')); // Phase 2 (Morphing) mulai
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _swooshPlayer.dispose();
    _cringPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Morphing Logo Container
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fase 1 & 2: Logo Anise (Berputar, Mantul, lalu Memudar)
                        Opacity(
                          opacity: _aniseOpacity.value,
                          child: Transform.scale(
                            scale: _aniseScale.value,
                            child: Transform.rotate(
                              angle: _aniseRotate.value,
                              child: Image.asset(
                                'assets/images/logo-anise.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                                // Tangani error jika aset logo-anise.png belum di-reload Flutter Web
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 80, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        
                        // Fase 2: Logo SMK (Memudar Masuk & Scale Up)
                        Opacity(
                          opacity: _smkOpacity.value,
                          child: Transform.scale(
                            scale: _smkScale.value,
                            child: Hero(
                              tag: 'logo-smk',
                              child: Image.asset(
                                'assets/images/logo-smk.png',
                                height: 80.h(context),
                                width: 80.h(context),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Fase 3: App Name (Muncul membesar)
                  Opacity(
                    opacity: _nameOpacity.value,
                    child: Transform.scale(
                      scale: _nameScale.value,
                      child: Hero(
                        tag: 'school-name',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            'SMA N 1 Peunaron',
                            style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Fase 4: Tagline (Meluncur naik & memudar masuk)
                  Opacity(
                    opacity: _taglineOpacity.value,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Hero(
                        tag: 'school-tagline',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            'Anise by Helvetecha',
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
