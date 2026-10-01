import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_text_styles.dart';
class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(now);
    
    // Fallback to english if locale id_ID fails without intl initialization
    final fallbackDate = DateFormat('EEEE, dd MMM yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $userName!',
          style: AppTextStyles.headlineMedium(context, color: AppColors.onBackground),
        ),
        const SizedBox(height: 4),
        Text(
          fallbackDate,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
