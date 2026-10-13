import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// MainHeader adalah payung identitas visual teratas pada layar dashboard utama
/// aplikasi Anise (Siswa, Guru, BK, TU).
class MainHeader extends StatelessWidget {
  final String schoolName;
  final String? subtitle;
  final String? logoPath;
  final bool hasUnreadNotification;
  final VoidCallback? onNotificationPressed;
  final bool pinned;

  const MainHeader({
    Key? key,
    this.schoolName = 'SMA N 1 Peunaron',
    this.subtitle = 'Anise by Helvetecha',
    this.logoPath = 'assets/images/logo-smk.png',
    this.hasUnreadNotification = false,
    this.onNotificationPressed,
    this.pinned = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 65.h(context),
      expandedHeight: 65.h(context),
      titleSpacing: 24.w(context),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset(
            logoPath ?? 'assets/images/logo-smk.png',
            height: 36.h(context),
            width: 36.w(context),
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  schoolName,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: onNotificationPressed,
              icon: Icon(
                PhosphorIcons.bell(PhosphorIconsStyle.bold),
                color: AppColors.onSurface,
                size: 24.w(context),
              ),
            ),
            if (hasUnreadNotification)
              Positioned(
                top: 14.h(context),
                right: 14.w(context),
                child: Container(
                  width: 8.w(context),
                  height: 8.w(context),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 16.w(context)),
      ],
    );
  }
}
