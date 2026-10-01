import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class GuruTugasPenilaianScreen extends StatefulWidget {
  final String title;
  final String subject;
  final String className;

  const GuruTugasPenilaianScreen({
    Key? key,
    required this.title,
    required this.subject,
    required this.className,
  }) : super(key: key);

  @override
  State<GuruTugasPenilaianScreen> createState() => _GuruTugasPenilaianScreenState();
}

class _GuruTugasPenilaianScreenState extends State<GuruTugasPenilaianScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Budi Santoso',
      'avatar': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=150&auto=format&fit=crop',
      'status': 'Sudah Mengumpulkan',
      'time': 'Hari ini, 09:12',
      'hasAttachment': true,
      'score': '85',
    },
    {
      'name': 'Siti Aminah',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
      'status': 'Sudah Mengumpulkan',
      'time': 'Kemarin, 21:40',
      'hasAttachment': true,
      'score': '',
    },
    {
      'name': 'Ahmad Fauzi',
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150&auto=format&fit=crop',
      'status': 'Sudah Mengumpulkan',
      'time': 'Kemarin, 19:30',
      'hasAttachment': true,
      'score': '90',
    },
    {
      'name': 'Rina Fitriani',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=150&auto=format&fit=crop',
      'status': 'Terlambat',
      'time': 'Hari ini, 01:15 (Terlambat 1 Jam)',
      'hasAttachment': true,
      'score': '',
    },
    {
      'name': 'Dimas Pratama',
      'avatar': 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=150&auto=format&fit=crop',
      'status': 'Belum Mengumpulkan',
      'time': '-',
      'hasAttachment': false,
      'score': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Penilaian Tugas',
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
            Text(
              widget.className,
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTaskHeader(context),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 16.h(context)),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return _buildStudentItem(context, _students[index], index);
              },
            ),
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 20.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subject,
            style: AppTextStyles.labelSmall(context, color: AppColors.primary),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            widget.title,
            style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
          ),
          SizedBox(height: 12.h(context)),
          Row(
            children: [
              _buildStatBadge(context, '4/5', 'Mengumpulkan', AppColors.menuPastelGreen),
              SizedBox(width: 8.w(context)),
              _buildStatBadge(context, '2/5', 'Dinilai', AppColors.menuPastelBlue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.w(context)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
          ),
          SizedBox(width: 4.w(context)),
          Text(
            label,
            style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(BuildContext context, Map<String, dynamic> student, int index) {
    final isNotSubmitted = student['status'] == 'Belum Mengumpulkan';
    final isLate = student['status'] == 'Terlambat';
    final hasScore = student['score'].isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.w(context),
                backgroundImage: NetworkImage(student['avatar']),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'],
                      style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      student['status'],
                      style: AppTextStyles.labelSmall(
                        context,
                        color: isNotSubmitted
                            ? AppColors.error
                            : (isLate ? AppColors.warning : AppColors.menuPastelGreen),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isNotSubmitted)
                Container(
                  width: 60.w(context),
                  height: 40.h(context),
                  decoration: BoxDecoration(
                    color: hasScore ? AppColors.menuPastelGreen.withValues(alpha: 0.2) : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8.w(context)),
                    border: Border.all(
                      color: hasScore ? AppColors.menuPastelGreen : AppColors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: TextFormField(
                      initialValue: student['score'],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: '-',
                      ),
                      onChanged: (val) {
                        setState(() {
                          _students[index]['score'] = val;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
          if (!isNotSubmitted) ...[
            Spacing.custom(context, 12),
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12.w(context)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), color: AppColors.error, size: 24.w(context)),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tugas_${student['name'].replaceAll(" ", "_")}.pdf',
                          style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h(context)),
                        Text(
                          student['time'],
                          style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 20.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline.withValues(alpha: 0.3))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h(context),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
            ),
            elevation: 0,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Penilaian berhasil disimpan.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context);
          },
          child: Text(
            'Simpan Semua Nilai',
            style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary),
          ),
        ),
      ),
    );
  }
}
