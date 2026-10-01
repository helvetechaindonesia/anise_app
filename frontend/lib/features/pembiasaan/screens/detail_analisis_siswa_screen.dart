import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/analisis_tab.dart';

class DetailAnalisisSiswaScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const DetailAnalisisSiswaScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Analisis Pembiasaan',
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
            Text(
              studentName,
              style: AppTextStyles.labelSmall(context, color: AppColors.primary),
            ),
          ],
        ),
      ),
      body: AnalisisTabWidget(studentId: studentId),
    );
  }
}

