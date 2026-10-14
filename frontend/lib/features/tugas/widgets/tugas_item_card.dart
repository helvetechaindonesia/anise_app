import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/item_list_tile.dart';
import '../screens/tugas_detail_screen.dart';

class TugasItemCard extends StatelessWidget {
  final String? id;
  final String subject;
  final String teacher;
  final String title;
  final String timeInfo;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;
  final Color timeBgColor;
  final Color timeIconColor;
  final int? nilai;
  final bool isSelesai;
  final bool showDivider;
  final double? dividerThickness;
  final Color? dividerColor;
  final String? description;
  final Map<String, dynamic>? submission;
  final List<dynamic>? attachments;
  final VoidCallback? onTap;

  const TugasItemCard({
    super.key,
    this.id,
    required this.subject,
    required this.teacher,
    required this.title,
    required this.timeInfo,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.timeBgColor,
    required this.timeIconColor,
    this.nilai,
    this.isSelesai = false,
    this.showDivider = true,
    this.dividerThickness,
    this.dividerColor,
    this.description,
    this.submission,
    this.attachments,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ItemListTile(
      category: subject,
      subcategory: teacher,
      title: title,
      metadataText: timeInfo,
      metadataIcon: isSelesai
          ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)
          : PhosphorIcons.timer(PhosphorIconsStyle.bold),
      statusText: 'Status: $statusText',
      statusIcon: statusIcon,
      statusColor: statusColor,
      showDivider: showDivider,
      dividerThickness: dividerThickness,
      dividerColor: dividerColor,
      trailing: (isSelesai && nilai != null)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12.w(context)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.onSecondary, size: 12.w(context)),
                  SizedBox(width: 4.w(context)),
                  Text(
                    nilai.toString(),
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          : null,
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TugasDetailScreen(
                  taskId: id ?? '',
                  subject: subject,
                  teacher: teacher,
                  title: title,
                  timeInfo: timeInfo,
                  description: description ?? '',
                  status: statusText,
                  isSubmitted: isSelesai,
                  submission: submission,
                  attachments: attachments,
                ),
              ),
            );
          },
    );
  }
}
