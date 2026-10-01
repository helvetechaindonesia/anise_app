import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class AgendaBottomBannerWidget extends StatelessWidget {
  const AgendaBottomBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.secondary, // Light purple/blue
        borderRadius: BorderRadius.circular(20.w(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.onSecondary.withValues(alpha: 0.2), // Dark Blue
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.lightbulb(PhosphorIconsStyle.fill), color: AppColors.onSecondary, size: 24.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standar Kesiapan Belajar',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onSecondary),
                ),
                SizedBox(height: 8.h(context)),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary),
                    children: [
                      const TextSpan(text: 'Nilai ketuntasan minimal (KKTP) untuk rumpun MIPA: '),
                      TextSpan(text: '78.00', style: AppTextStyles.bodyMedium(context, color: AppColors.onSecondary)),
                      const TextSpan(text: '. Akses kisi-kisi dan bank soal pada tab materi kelas.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
