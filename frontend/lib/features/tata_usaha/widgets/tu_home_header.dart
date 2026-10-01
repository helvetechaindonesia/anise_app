import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/time_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/widgets/identity_card_3d_widget.dart';

class TuHomeHeader extends ConsumerWidget {
  const TuHomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final userName = user?.fullName ?? 'Staf Tata Usaha';

    return SliverAppBar(
      expandedHeight: 340.h(context),
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                TimeHelper.getGreeting(),
                style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
              ),
              Text(
                '$userName!!',
                style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
              ),
              Spacing.custom(context, 20),
              IdentityCard3DWidget(userName: userName),
              Spacing.custom(context, 20),
            ],
          ),
        ),
      ),
    );
  }
}
