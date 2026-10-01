import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Text(
          'Notifications Screen',
          style: AppTextStyles.titleLarge(context, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
