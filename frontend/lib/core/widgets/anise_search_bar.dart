import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Komponen Search Bar terstandarisasi untuk seluruh aplikasi Anise.
/// Menyediakan input pencarian interaktif real-time dengan ikon magnifying glass
/// dan tombol hapus cepat (clear button) otomatis ketika teks tidak kosong.
class AniseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? padding;

  const AniseSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.magnifyingGlass(),
              color: AppColors.onSurface.withValues(alpha: 0.5),
              size: 20.w(context),
            ),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h(context)),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                  size: 18.w(context),
                  color: AppColors.onSurface.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  controller.clear();
                  if (onClear != null) {
                    onClear!();
                  } else if (onChanged != null) {
                    onChanged!('');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
