import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/guru_identity_card_3d_widget.dart';
import '../widgets/guru_layanan_cepat_widget.dart';
import '../widgets/bimbingan_mentor_widget.dart';
import '../widgets/guru_jurnal_mengajar_widget.dart';
import '../widgets/guru_pantau_penugasan_widget.dart';
import '../widgets/guru_home_header.dart';
import '../../../core/utils/time_helper.dart';

class GuruHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const GuruHomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  ConsumerState<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends ConsumerState<GuruHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userName = user?.fullName ?? 'Bpk. Guru';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: CustomScrollView(
          slivers: [
            // 1. Header (Fixed/Pinned)
            GuruHomeHeader(
              user: user,
              onNotificationTap: () {},
              onProfileTap: () {},
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacing.custom(context, 10),
                    // 2. Greeting
                    Text(
                      TimeHelper.getGreeting(),
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                    ),
                    Text(
                      '$userName!!',
                      style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground), 
                    ),
                    Spacing.custom(context, 20),
                    
                    // 4. Kartu Identitas Digital Guru
                    _buildIdentityCard(user),
                    Spacing.custom(context, 20),
                    
                    // 5. Layanan Cepat Grid Guru
                    GuruLayananCepatWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 24),
                    
                    // 6. Jurnal Mengajar
                    GuruJurnalMengajarWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 32),
                    
                    // 7. Pantau Penugasan
                    const GuruPantauPenugasanWidget(),
                    Spacing.custom(context, 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(UserModel? user) {
    return GuruIdentityCard3DWidget(user: user);
  }
}


