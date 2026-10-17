import 'package:flutter/material.dart';
import '../../../../core/widgets/anise_siswa_task_card.dart';
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
    return AniseSiswaTaskCard(
      id: id,
      subject: subject,
      teacher: teacher,
      title: title,
      timeInfo: timeInfo,
      statusText: statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
      timeBgColor: timeBgColor,
      timeIconColor: timeIconColor,
      nilai: nilai,
      isSelesai: isSelesai,
      showDivider: showDivider,
      dividerThickness: dividerThickness,
      dividerColor: dividerColor,
      description: description,
      submission: submission,
      attachments: attachments,
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
