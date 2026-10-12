import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Standard Link Action untuk Header Seksi (Pengganti "Lihat\nSemua")
/// Menampilkan teks satu baris ramping: "Semua" + ikon caret panah kanan ">"
class SectionActionLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const SectionActionLink({
    Key? key,
    this.text = 'Semua',
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.onBackground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.w(context)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w(context), vertical: 4.h(context)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppTextStyles.labelMedium(context, color: activeColor).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w(context)),
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              size: 14.w(context),
              color: activeColor,
            ),
          ],
        ),
      ),
    );
  }
}
