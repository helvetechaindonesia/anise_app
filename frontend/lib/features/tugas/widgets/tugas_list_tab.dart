import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import 'tugas_item_card.dart';

class TugasListTab extends StatelessWidget {
  final String status;
  final List<Map<String, dynamic>> allTasks;

  const TugasListTab({
    Key? key,
    required this.status,
    required this.allTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredTasks = allTasks.where((t) => t['status'] == status).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.checks(PhosphorIconsStyle.fill), size: 48.w(context), color: AppColors.onBackground.withValues(alpha: 0.2)),
            SizedBox(height: 16.h(context)),
            Text(
              'Tidak ada tugas',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(left: 20.w(context), right: 20.w(context), bottom: 40.h(context)),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredTasks.length,
      separatorBuilder: (context, index) => Divider(color: AppColors.primary, height: 24.h(context)),
      itemBuilder: (context, index) {
        return _buildTaskCard(context, filteredTasks[index]);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    bool isSelesai = task['status'] == 'Selesai Dikerjakan';
    bool isTerlewat = task['status'] == 'Terlewat';

    String timeInfo = isSelesai ? 'Diselesaikan' : (isTerlewat ? 'Terlewat: ${task['deadline']}' : 'Tenggat: ${task['deadline']}');
    Color timeBgColor = isSelesai ? AppColors.primary.withValues(alpha: 0.5) : (isTerlewat ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.5));
    Color timeIconColor = isSelesai ? AppColors.primary : (isTerlewat ? AppColors.primary : AppColors.primary);
    
    String statusText = task['status'].toString();
    Color statusColor = AppColors.primary;
    IconData statusIcon = PhosphorIcons.hourglass(PhosphorIconsStyle.bold);
    
    if (isSelesai) {
      statusColor = AppColors.primary;
      statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.bold);
    } else if (isTerlewat) {
      statusColor = AppColors.primary;
      statusIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.bold);
    } else {
      statusColor = AppColors.primary;
      statusIcon = PhosphorIcons.hourglass(PhosphorIconsStyle.bold);
    }

    return TugasItemCard(
      subject: task['mata_pelajaran'].toString().toUpperCase(),
      teacher: task['teacher']?.toString().toUpperCase() ?? 'GURU',
      title: task['judul'].toString(),
      timeInfo: timeInfo,
      statusText: statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
      timeBgColor: timeBgColor,
      timeIconColor: timeIconColor,
      isSelesai: isSelesai,
      nilai: task['nilai'] as int?,
    );
  }
}
