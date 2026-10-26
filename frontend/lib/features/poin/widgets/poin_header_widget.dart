import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/poin_provider.dart';

class PoinHeaderWidget extends ConsumerWidget {
  const PoinHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(pointBalanceProvider);
    final monthLabel = balanceAsync.valueOrNull?['month_label']?.toString();
    final periodText = (monthLabel != null && monthLabel.isNotEmpty) 
        ? 'Periode $monthLabel (Reset Tiap Bulan)' 
        : 'Siklus Poin Bulanan (100 Poin)';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poin Kedisiplinan',
              style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              periodText,
              style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(12.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            PhosphorIcons.star(PhosphorIconsStyle.bold),
            color: AppColors.onPrimaryContainer,
            size: 24.w(context),
          ),
        ),
      ],
    );
  }
}
