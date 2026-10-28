import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_empty_state.dart';

class BkSuratWidget extends StatelessWidget {
  const BkSuratWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  'Pantau Surat Panggilan',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
                SizedBox(width: 8.w(context)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 2.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Text(
                    'Segera Hadir',
                    style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Spacing.custom(context, 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 24.h(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.w(context)),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.onBackground.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52.w(context),
                height: 52.w(context),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    PhosphorIcons.envelopeSimple(PhosphorIconsStyle.duotone),
                    color: AppColors.primary,
                    size: 26.w(context),
                  ),
                ),
              ),
              SizedBox(height: 12.h(context)),
              Text(
                'Segera Hadir',
                style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h(context)),
              Text(
                'Fitur penerbitan dan pemantauan surat panggilan orang tua sedang dalam tahap integrasi.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
