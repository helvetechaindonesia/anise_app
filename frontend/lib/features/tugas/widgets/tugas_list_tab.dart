import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/anise_empty_state.dart';
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
      return AniseEmptyState(
        title: 'Belum Ada Tugas',
        subtitle: status == 'Belum Dikerjakan'
            ? 'Tidak ada tugas yang perlu dikerjakan saat ini.'
            : (status == 'Selesai Dikerjakan'
                ? 'Belum ada tugas yang selesai dikerjakan.'
                : 'Tidak ada tugas yang terlewatkan.'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w(context), right: 20.w(context), top: 8.h(context), bottom: 40.h(context)),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final isLast = index == filteredTasks.length - 1;
        return _buildTaskCard(context, filteredTasks[index], showDivider: !isLast);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task, {bool showDivider = true}) {
    bool isSelesai = task['status'] == 'Selesai Dikerjakan';
    bool isTerlewat = task['status'] == 'Terlewat';

    String timeInfo = isSelesai ? 'Diselesaikan' : (isTerlewat ? 'Terlewat: ${task['deadline']}' : 'Tenggat: ${task['deadline']}');
    Color timeBgColor = isSelesai ? AppColors.primary.withValues(alpha: 0.5) : (isTerlewat ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.5));
    Color timeIconColor = isSelesai ? AppColors.primary : (isTerlewat ? AppColors.primary : AppColors.primary);
    
    String statusText = task['status'].toString();
    Color statusColor = AppColors.warning;
    IconData statusIcon = PhosphorIcons.hourglass(PhosphorIconsStyle.bold);
    
    if (isSelesai) {
      statusColor = AppColors.secondary;
      statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.bold);
    } else if (isTerlewat) {
      statusColor = AppColors.error;
      statusIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.bold);
    } else {
      statusColor = AppColors.warning;
      statusIcon = PhosphorIcons.hourglass(PhosphorIconsStyle.bold);
    }

    return TugasItemCard(
      id: task['id']?.toString(),
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
      showDivider: showDivider,
      nilai: task['nilai'] != null ? (task['nilai'] as num).toInt() : null,
      description: task['description']?.toString(),
      submission: task['submission'] as Map<String, dynamic>?,
      attachments: task['attachments'] as List<dynamic>?,
    );
  }
}
