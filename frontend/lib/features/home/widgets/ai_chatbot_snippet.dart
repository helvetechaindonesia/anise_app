import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AiChatbotSnippet extends StatelessWidget {
  const AiChatbotSnippet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: Icon(PhosphorIcons.robot(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tanya Anise jadwal hari ini...',
              style: AppTextStyles.bodyMedium(context, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold), color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }
}

