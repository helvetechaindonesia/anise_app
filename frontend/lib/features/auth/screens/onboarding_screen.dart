import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/shared_prefs.dart';
import 'login_screen.dart';
import '../../home/screens/main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isAuthenticated;

  const OnboardingScreen({
    super.key,
    required this.isAuthenticated,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Selamat Datang di Sipena',
      'subtitle': 'Sistem Informasi Presensi & Pembelajaran Digital',
      'description':
          'Pantau jadwal akademik, presensi pintar dengan biometrik wajah, jurnal KBM, dan kedisiplinan sekolah dalam satu genggaman modern.',
      'icon': PhosphorIcons.graduationCap(PhosphorIconsStyle.fill),
      'iconColor': AppColors.primary,
      'badge': 'SMKN 1 KAWALI',
    },
    {
      'title': 'Terhubung & Terintegrasi',
      'subtitle': 'Efisiensi Belajar & Tata Kelola Sekolah',
      'description':
          'Kemudahan komunikasi terpadu untuk siswa, guru, staf administrasi, hingga kepala sekolah demi terwujudnya sekolah berintegritas.',
      'icon': PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
      'iconColor': AppColors.secondary,
      'badge': 'DIGITAL ECOSYSTEM',
    },
  ];

  Future<void> _completeOnboarding() async {
    await SharedPrefs.setOnboardingSeen();
    if (!mounted) return;

    final targetScreen = widget.isAuthenticated
        ? const MainNavigationScreen()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _nextPage() {
    if (_currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar: Skip button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 16.h(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo-smk.png',
                        width: 32.w(context),
                        height: 32.w(context),
                        errorBuilder: (_, __, ___) => Icon(
                          PhosphorIcons.buildings(PhosphorIconsStyle.fill),
                          color: AppColors.primary,
                          size: 28.w(context),
                        ),
                      ),
                      SizedBox(width: 10.w(context)),
                      Text(
                        'Sipena',
                        style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.labelLarge(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),

            // Page View Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = _onboardingData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decorative visual badge / icon container
                        Container(
                          width: 180.w(context),
                          height: 180.w(context),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            boxShadow: [
                              BoxShadow(
                                color: (item['iconColor'] as Color).withValues(alpha: 0.15),
                                blurRadius: 32,
                                spreadRadius: 8,
                                offset: const Offset(0, 12),
                              ),
                            ],
                            border: Border.all(
                              color: (item['iconColor'] as Color).withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item['icon'] as IconData,
                              size: 80.w(context),
                              color: item['iconColor'] as Color,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h(context)),

                        // Pill badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 6.h(context)),
                          decoration: BoxDecoration(
                            color: (item['iconColor'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.w(context)),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: AppTextStyles.labelSmall(context, color: item['iconColor'] as Color).copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h(context)),

                        // Title
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium(context, color: AppColors.onBackground).copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h(context)),

                        // Subtitle
                        Text(
                          item['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleSmall(context, color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16.h(context)),

                        // Description
                        Text(
                          item['description'] as String,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.65)).copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area: Page Indicators & Action Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w(context), vertical: 24.h(context)),
              child: Column(
                children: [
                  // Smooth Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingData.length, (index) {
                      final bool isActive = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w(context)),
                        height: 8.h(context),
                        width: isActive ? 28.w(context) : 8.w(context),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8.w(context)),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 28.h(context)),

                  // Next / Mulai Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _onboardingData.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
                            style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          Icon(
                            _currentIndex == _onboardingData.length - 1
                                ? PhosphorIcons.rocketLaunch(PhosphorIconsStyle.bold)
                                : PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                            color: AppColors.onPrimary,
                            size: 18.w(context),
                          ),
                        ],
                      ),
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
}
