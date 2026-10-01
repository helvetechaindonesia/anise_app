import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/auth/models/user_model.dart';

class IdentityCard3DWidget extends StatefulWidget {
  final UserModel? user;
  const IdentityCard3DWidget({Key? key, required this.user}) : super(key: key);

  @override
  State<IdentityCard3DWidget> createState() => _IdentityCard3DWidgetState();
}

class _IdentityCard3DWidgetState extends State<IdentityCard3DWidget> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    // Auto tilt animation (Ambient floating effect) - Diperlambat agar lebih elegan
    _idleController = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _idleController.repeat();

    // Shimmer animation
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
    
    _startShimmerLoop();
  }

  void _startShimmerLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _shimmerController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        double progress = _idleController.value * 2 * math.pi;
        double xRotation = math.sin(progress) * 0.08;
        double yRotation = math.cos(progress * 2) * 0.08;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(xRotation)
            ..rotateY(yRotation),
          alignment: FractionalOffset.center,
          child: child, // child is wrapped in RepaintBoundary for performance
        );
      },
      child: RepaintBoundary(
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    String nisnNisText = 'NISN/NIS: 0074829103 / 22231008';
    if (widget.user != null) {
      final nisn = widget.user!.uniqueId;
      final nis = widget.user!.nis;
      if (nisn != null && nisn.isNotEmpty && nis != null && nis.isNotEmpty) {
        nisnNisText = 'NISN/NIS: $nisn / $nis';
      } else if (nisn != null && nisn.isNotEmpty) {
        nisnNisText = 'NISN: $nisn';
      } else if (nis != null && nis.isNotEmpty) {
        nisnNisText = 'NIS: $nis';
      }
    }

    String className = widget.user?.className ?? 'XII M2';

    return AspectRatio(
      aspectRatio: 1.58, // Standar rasio ID card / credit card
      child: Container(
        decoration: BoxDecoration(
          // Premium Gradient Background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.9),
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20.w(context)),
          border: Border.all(
            color: AppColors.onPrimary.withValues(alpha: 0.2), // Glass border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.w(context)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Abstrak Decorative Elements (pengganti watermark kaku)
              Positioned(
                top: -50.w(context),
                right: -20.w(context),
                child: Container(
                  width: 150.w(context),
                  height: 150.w(context),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w(context)),
                    color: AppColors.onPrimary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -80.w(context),
                left: -30.w(context),
                child: Container(
                  width: 200.w(context),
                  height: 200.w(context),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w(context)),
                    color: AppColors.onPrimary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              
              // Watermark Halus
              Positioned(
                bottom: -20.w(context),
                right: -20.w(context),
                child: Image.asset(
                  'assets/images/logo-smk.png',
                  width: 140.w(context),
                  height: 140.w(context),
                  fit: BoxFit.contain,
                  color: AppColors.onPrimary.withValues(alpha: 0.05),
                  colorBlendMode: BlendMode.modulate,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),

              // Main Content
              Padding(
                padding: EdgeInsets.all(20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo-smk.png',
                          height: 36.h(context),
                          width: 36.w(context),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                        ),
                        SizedBox(width: 12.w(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KARTU IDENTITAS DIGITAL',
                                style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary.withValues(alpha: 0.7)).copyWith(letterSpacing: 1.5),
                              ),
                              Text(
                                'SMA N 1 Peunaron',
                                style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(4.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.w(context)),
                          ),
                          child: Image.asset(
                            'assets/images/logo-kemendikbud.png',
                            height: 28.h(context),
                            width: 28.w(context),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                            errorBuilder: (context, error, stackTrace) => Icon(PhosphorIcons.image(PhosphorIconsStyle.bold), color: AppColors.onPrimary.withValues(alpha: 0.5), size: 28.w(context)),
                          ),
                        ),
                      ],
                    ),
                    
                    Spacer(),
                    
                    // USER PROFILE & DETAILS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar Bulat Premium
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 64.w(context),
                              height: 64.w(context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w(context)),
                                color: AppColors.onPrimary.withValues(alpha: 0.15),
                                border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.3), width: 2),
                              ),
                              child: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill), color: AppColors.onPrimary, size: 36.w(context)),
                            ),
                            Container(
                              transform: Matrix4.translationValues(4, 4, 0),
                              padding: EdgeInsets.all(2.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20.w(context)),
                                border: Border.all(color: AppColors.onPrimary, width: 2),
                              ),
                              child: Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 12.w(context)),
                            ),
                          ],
                        ),
                        SizedBox(width: 20.w(context)),
                        
                        // User Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.user?.fullName.toUpperCase() ?? 'SISWA',
                                style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.h(context)),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                                      decoration: BoxDecoration(
                                        color: AppColors.onPrimary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20.w(context)),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          nisnNisText,
                                          style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h(context)),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.2),
                                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                                        borderRadius: BorderRadius.circular(20.w(context)),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'KELAS: $className',
                                          style: AppTextStyles.labelSmall(context, color: AppColors.secondary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Optimized Holographic Shimmer Effect Overlay (Top Layer)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation: Offset(_shimmerAnim.value, 0.0),
                        child: child,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.0),
                            Colors.purpleAccent.withValues(alpha: 0.05), // Sedikit efek hologram
                            Colors.white.withValues(alpha: 0.3), // Pantulan kilap utama
                            Colors.cyanAccent.withValues(alpha: 0.05), // Sedikit efek hologram
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.3, 0.45, 0.5, 0.55, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




