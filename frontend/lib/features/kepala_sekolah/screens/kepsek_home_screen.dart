import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/time_helper.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/main_header.dart';
import '../../../core/widgets/anise_identity_card_3d.dart';
import '../widgets/kepsek_layanan_cepat_widget.dart';
import '../widgets/kepsek_pantau_jurnal_widget.dart';
import '../widgets/kepsek_pantau_kpi_widget.dart';
import '../../auth/providers/auth_provider.dart';

class KepsekHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const KepsekHomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  ConsumerState<KepsekHomeScreen> createState() => _KepsekHomeScreenState();
}

class _KepsekHomeScreenState extends ConsumerState<KepsekHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userName = user?.fullName ?? 'Kepala Sekolah';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: CustomScrollView(
          slivers: [
            const MainHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacing.custom(context, 10),
                    Text(
                      TimeHelper.getGreeting(),
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                    ),
                    Text(
                      '$userName!!',
                      style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground), 
                    ),
                    Spacing.custom(context, 20),
                    AniseIdentityCard3D(user: user),
                    Spacing.custom(context, 20),
                    KepsekLayananCepatWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 24),
                    KepsekPantauJurnalWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 24),
                    const KepsekPantauKpiWidget(),
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
