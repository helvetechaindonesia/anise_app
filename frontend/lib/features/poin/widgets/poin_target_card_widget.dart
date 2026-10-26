import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/poin_provider.dart';

class PoinTargetCardWidget extends ConsumerWidget {
  const PoinTargetCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(pointBalanceProvider);
    final balanceData = balanceAsync.valueOrNull ?? {};
    final int daysInMonth = balanceData['days_in_month'] ?? 30;
    final num deduction = balanceData['deduction_per_violation'] ?? (100 / daysInMonth / 3);

    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.onSecondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.info(PhosphorIconsStyle.bold), color: AppColors.onSecondary, size: 24.w(context)),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kebijakan Sistem Poin Disiplin',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onSecondary).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'Setiap user diberikan 100 poin di awal bulan dan direset setiap bulan. Batas pelanggaran maksimal 3x per hari. Tiap pelanggaran mengurangi 100 ÷ $daysInMonth hari ÷ 3 = -${deduction.toStringAsFixed(1)} poin.',
                  style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
