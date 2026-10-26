import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/poin_provider.dart';

class PoinMainCardWidget extends ConsumerWidget {
  const PoinMainCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(pointBalanceProvider);

    final balanceData = balanceAsync.valueOrNull ?? {};
    final num balanceVal = balanceData['balance'] ?? 100;
    final int todayViolations = balanceData['today_violations'] ?? 0;
    final int remainingToday = balanceData['remaining_violations_today'] ?? (3 - todayViolations);

    // Format nilai balance (misal 98.9 atau 100)
    final String balanceStr = (balanceVal % 1 == 0) ? balanceVal.toInt().toString() : balanceVal.toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(22.w(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 22.w(context)),
                  SizedBox(width: 8.w(context)),
                  Text(
                    'SALDO POIN BULANAN',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer).copyWith(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
                child: Text(
                  'Awal: 100 Poin',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balanceStr,
                    style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimaryContainer).copyWith(
                      fontSize: 48.w(context),
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 8.w(context)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h(context)),
                    child: Text(
                      '/ 100 Poin',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.8)),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.w(context)),
                ),
                child: Icon(
                  PhosphorIcons.medal(PhosphorIconsStyle.fill),
                  color: AppColors.onPrimaryContainer,
                  size: 30.w(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),
          Divider(color: AppColors.onPrimaryContainer.withValues(alpha: 0.15), height: 1),
          SizedBox(height: 12.h(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onPrimaryContainer),
                  SizedBox(width: 6.w(context)),
                  Text(
                    'Hari Ini: $todayViolations/3 Pelanggaran',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'Sisa Kuota: $remainingToday kali',
                style: AppTextStyles.labelSmall(context, color: remainingToday == 0 ? AppColors.error : AppColors.onPrimaryContainer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
