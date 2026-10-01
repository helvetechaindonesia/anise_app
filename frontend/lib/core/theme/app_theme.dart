import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

class AppTheme {
  static List<BoxShadow> get defaultShadow => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.5),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.5),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.5),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];
}
