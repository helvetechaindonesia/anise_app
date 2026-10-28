import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math' as math;
import '../constants/colors.dart';
import '../constants/api_constants.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';
import '../../features/auth/models/user_model.dart';

/// AniseIdentityCard3D - Komponen baku universal kartu identitas digital 3D holographic.
/// Mendukung seluruh role (Siswa, Guru, BK, TU, Kepala Sekolah) secara adaptif.
/// Dilengkapi efek ambient floating tilt (gyro simulation) dan holographic shimmer overlay.
class AniseIdentityCard3D extends StatefulWidget {
  final UserModel? user;

  const AniseIdentityCard3D({
    super.key,
    required this.user,
  });

  @override
  State<AniseIdentityCard3D> createState() => _AniseIdentityCard3DState();
}

class _AniseIdentityCard3DState extends State<AniseIdentityCard3D> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    // Auto tilt animation (Ambient floating effect) - Kecepatan santai dan elegan
    _idleController = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _idleController.repeat();

    // Shimmer holographic sweep animation
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _startShimmerLoop();
  }

  void _startShimmerLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
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
        final double progress = _idleController.value * 2 * math.pi;
        final double xRotation = math.sin(progress) * 0.07;
        final double yRotation = math.cos(progress * 2) * 0.07;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(xRotation)
            ..rotateY(yRotation),
          alignment: FractionalOffset.center,
          child: child,
        );
      },
      child: RepaintBoundary(
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final bool isSiswa = widget.user?.role == UserRole.siswa;
    final userName = widget.user?.fullName ?? (isSiswa ? 'Siswa' : 'Tenaga Pendidik');

    String idText = 'NISN/NIS: -';
    String secondaryText = 'KELAS: -';

    if (isSiswa) {
      if (widget.user != null) {
        final nisn = widget.user!.uniqueId;
        final nis = widget.user!.nis;
        if (nisn != null && nisn.isNotEmpty && nis != null && nis.isNotEmpty) {
          idText = 'NISN/NIS: $nisn / $nis';
        } else if (nisn != null && nisn.isNotEmpty) {
          idText = 'NISN: $nisn';
        } else if (nis != null && nis.isNotEmpty) {
          idText = 'NIS: $nis';
        }
      }
      final className = (widget.user?.className != null && widget.user!.className!.isNotEmpty)
          ? widget.user!.className!
          : '-';
      secondaryText = 'KELAS: $className';
    } else {
      if (widget.user != null) {
        final nip = widget.user!.nip ?? widget.user!.uniqueId;
        if (nip != null && nip.isNotEmpty) {
          idText = 'NIP: $nip';
        } else {
          idText = 'NUPTK/NIP: -';
        }
      } else {
        idText = 'NUPTK/NIP: -';
      }

      String peranLabel = 'GURU MAPEL';
      if (widget.user?.role == UserRole.bk) {
        peranLabel = 'GURU BK';
      } else if (widget.user?.role == UserRole.kepalaSekolah) {
        peranLabel = 'KEPALA SEKOLAH';
      } else if (widget.user?.role == UserRole.tataUsaha) {
        peranLabel = 'STAF TATA USAHA';
      } else if (widget.user?.role == UserRole.pengajar && widget.user!.tugasTambahan.isNotEmpty) {
        peranLabel = widget.user!.tugasTambahan.first.replaceAll('_', ' ');
      }
      secondaryText = 'STATUS: $peranLabel';
    }

    return AspectRatio(
      aspectRatio: 1.58, // Standard credit / ID card aspect ratio
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.95),
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20.w(context)),
          border: Border.all(
            color: AppColors.onPrimary.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
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
              // 1. Decorative Concentric Circles
              Positioned(
                top: -60.w(context),
                right: -40.w(context),
                child: Container(
                  width: 180.w(context),
                  height: 180.w(context),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.08), width: 1.5),
                    color: AppColors.onPrimary.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: -90.w(context),
                left: -50.w(context),
                child: Container(
                  width: 220.w(context),
                  height: 220.w(context),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.06), width: 1.5),
                    color: AppColors.onPrimary.withValues(alpha: 0.03),
                  ),
                ),
              ),

              // 2. School Watermark
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

              // 3. Card Content
              Padding(
                padding: EdgeInsets.all(20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
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
                                style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary.withValues(alpha: 0.75))
                                    .copyWith(letterSpacing: 1.4),
                              ),
                              Text(
                                'SMA N 1 Peunaron',
                                style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(4.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.w(context)),
                          ),
                          child: Image.asset(
                            'assets/images/kemendikbud.webp',
                            height: 28.h(context),
                            width: 28.w(context),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                            errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                              'assets/images/kemendikbud.svg',
                              height: 28.h(context),
                              width: 28.w(context),
                              fit: BoxFit.contain,
                              placeholderBuilder: (context) => Icon(
                                PhosphorIcons.image(PhosphorIconsStyle.bold),
                                color: AppColors.onPrimary.withValues(alpha: 0.5),
                                size: 28.w(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // User Profile & Details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 64.w(context),
                              height: 64.w(context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w(context)),
                                color: AppColors.onPrimary.withValues(alpha: 0.15),
                                border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.35), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18.w(context)),
                                child: (widget.user?.avatar != null && widget.user!.avatar!.isNotEmpty)
                                    ? Image.network(
                                        widget.user!.avatar!.startsWith('http')
                                            ? widget.user!.avatar!
                                            : '${ApiConstants.baseUrl.replaceAll('/api', '')}${widget.user!.avatar!}',
                                        fit: BoxFit.cover,
                                        width: 64.w(context),
                                        height: 64.w(context),
                                        errorBuilder: (_, __, ___) => Icon(
                                          PhosphorIcons.user(PhosphorIconsStyle.fill),
                                          color: AppColors.onPrimary,
                                          size: 36.w(context),
                                        ),
                                      )
                                    : Icon(
                                        PhosphorIcons.user(PhosphorIconsStyle.fill),
                                        color: AppColors.onPrimary,
                                        size: 36.w(context),
                                      ),
                              ),
                            ),
                            Container(
                              transform: Matrix4.translationValues(4, 4, 0),
                              padding: EdgeInsets.all(2.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20.w(context)),
                                border: Border.all(color: AppColors.onPrimary, width: 2),
                              ),
                              child: Icon(
                                PhosphorIcons.check(PhosphorIconsStyle.bold),
                                color: AppColors.onPrimary,
                                size: 12.w(context),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 18.w(context)),

                        // User Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName.toUpperCase(),
                                style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5.h(context)),
                              Text(
                                idText,
                                style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary.withValues(alpha: 0.85)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 3.h(context)),
                              Text(
                                secondaryText,
                                style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 4. Holographic Shimmer Effect Overlay (Top Layer)
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
                            Colors.purpleAccent.withValues(alpha: 0.06),
                            Colors.white.withValues(alpha: 0.35),
                            Colors.cyanAccent.withValues(alpha: 0.06),
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

/// Backwards compatibility aliases
typedef IdentityCard3DWidget = AniseIdentityCard3D;
typedef GuruIdentityCard3DWidget = AniseIdentityCard3D;
