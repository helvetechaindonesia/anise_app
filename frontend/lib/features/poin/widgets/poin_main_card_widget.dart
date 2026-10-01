import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class PoinMainCardWidget extends StatelessWidget {
  const PoinMainCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w(context)),
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
            children: [
              Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 24.w(context)),
              SizedBox(width: 8.w(context)),
              Text(
                'POIN KEDISIPLINAN',
                style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer),
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
                    '100',
                    style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimaryContainer).copyWith(
                      fontSize: 48.w(context),
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 8.w(context)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h(context)),
                    child: Text(
                      'Poin',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onPrimaryContainer),
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
                  size: 32.w(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
