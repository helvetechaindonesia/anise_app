import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Standarisasi Baku Capsule Tab Bar untuk Filter Jenis (Pill Tabs)
class AniseCapsuleTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabTitles;
  final EdgeInsetsGeometry? padding;

  const AniseCapsuleTabBar({
    super.key,
    required this.controller,
    required this.tabTitles,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w(context)),
      child: Container(
        height: 44.h(context),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.12)),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: AppColors.onSurface,
            borderRadius: BorderRadius.circular(100),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.surface,
          unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.6),
          labelStyle: AppTextStyles.labelMedium(context).copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelMedium(context),
          tabs: tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
    );
  }
}
