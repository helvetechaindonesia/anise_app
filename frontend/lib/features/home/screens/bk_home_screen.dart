import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/guru_identity_card_3d_widget.dart';
import '../widgets/guru_home_header.dart';
import '../widgets/bk_layanan_cepat_widget.dart';
import '../widgets/bk_bimbingan_widget.dart';
import '../widgets/bk_surat_widget.dart';
import '../widgets/bk_disiplin_widget.dart';
import '../../../core/utils/time_helper.dart';

class BkHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const BkHomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  ConsumerState<BkHomeScreen> createState() => _BkHomeScreenState();
}

class _BkHomeScreenState extends ConsumerState<BkHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userName = user?.fullName ?? 'Bpk/Ibu Guru BK';

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
                    
                    // 3. Kartu Identitas Digital Guru (Bisa dipake ulang)
                    GuruIdentityCard3DWidget(user: user),
                    Spacing.custom(context, 20),
                    
                    // 4. Layanan Cepat Grid BK
                    BkLayananCepatWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 24),
                    
                    // 5. Bimbingan (Pengganti Jurnal)
                    BkBimbinganWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 32),
                    
                    // 6. Pantau Disiplin (Pengganti Agenda Penilaian)
                    const BkDisiplinWidget(),
                    Spacing.custom(context, 32),
                    
                    // 7. Pantau Surat (Pengganti Penugasan)
                    const BkSuratWidget(),
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
}
