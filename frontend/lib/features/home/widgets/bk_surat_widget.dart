import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../tugas/widgets/tugas_item_card.dart';
import '../../bk/screens/bk_surat_screen.dart';

class BkSuratWidget extends StatelessWidget {
  const BkSuratWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> suratList = [
      {
        'subject': 'Siswa: Aji Akbar (X CND)',
        'teacher': 'Pelanggaran: Bolos Sekolah 3x',
        'title': 'Surat Panggilan Orang Tua (SP1)',
        'timeInfo': 'Besok, 09:00 WIB',
        'statusText': 'Menunggu TTD',
        'statusColor': AppColors.warning,
        'statusIcon': PhosphorIcons.clock(PhosphorIconsStyle.bold),
        'timeBgColor': AppColors.warning.withValues(alpha: 0.1),
        'timeIconColor': AppColors.warning,
      },
      {
        'subject': 'Siswa: Sendi Aritanoga (XI JS)',
        'teacher': 'Pelanggaran: Berkelahi',
        'title': 'Surat Peringatan (SP2)',
        'timeInfo': 'Hari ini, 13:00 WIB',
        'statusText': 'Terkirim',
        'statusColor': AppColors.primary,
        'statusIcon': PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
        'timeBgColor': AppColors.primary.withValues(alpha: 0.1),
        'timeIconColor': AppColors.primary,
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  'Pantau Surat Panggilan',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
                SizedBox(width: 8.w(context)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20.w(context)),
                  ),
                  child: Text(
                    '2',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BkSuratScreen()),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Lihat\nSemua',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(width: 4.w(context)),
                  Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground),
                ],
              ),
            ),
          ],
        ),
        Spacing.custom(context, 16),
        ...suratList.asMap().entries.map((entry) {
          final index = entry.key;
          final surat = entry.value;
          final isLast = index == suratList.length - 1;
          
          return Column(
            children: [
              TugasItemCard(
                subject: surat['subject'] as String,
                teacher: surat['teacher'] as String,
                title: surat['title'] as String,
                timeInfo: surat['timeInfo'] as String,
                statusText: surat['statusText'] as String,
                statusColor: surat['statusColor'] as Color,
                statusIcon: surat['statusIcon'] as IconData,
                timeBgColor: surat['timeBgColor'] as Color,
                timeIconColor: surat['timeIconColor'] as Color,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Detail surat ${surat['title']} segera hadir!', style: AppTextStyles.bodyMedium(context)),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 1,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }
}



