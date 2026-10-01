import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/home_provider.dart';
import '../../tugas/screens/tugas_screen.dart';
import '../../tugas/widgets/tugas_item_card.dart';

class TugasMendatangWidget extends ConsumerWidget {
  const TugasMendatangWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Tugas Mendatang',
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
                  MaterialPageRoute(builder: (context) => const TugasScreen()),
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
        ref.watch(tugasMendatangProvider).when(
          data: (tugasList) {
            if (tugasList.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h(context)),
                  child: Text('Tidak ada tugas mendatang', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant)),
                ),
              );
            }
            return Column(
              children: tugasList.asMap().entries.map((entry) {
                final index = entry.key;
                final tugas = entry.value;
                final isLast = index == tugasList.length - 1;
                
                return Column(
                  children: [
                    TugasItemCard(
                      subject: tugas['subject'] as String,
                      teacher: tugas['teacher'] as String,
                      title: tugas['title'] as String,
                      timeInfo: tugas['timeInfo'] as String,
                      statusText: tugas['statusText'] as String,
                      statusColor: tugas['statusColor'] as Color,
                      statusIcon: tugas['statusIcon'] as IconData,
                      timeBgColor: tugas['timeBgColor'] as Color,
                      timeIconColor: tugas['timeIconColor'] as Color,
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
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, st) => Center(child: Text('Gagal memuat tugas', style: AppTextStyles.bodyMedium(context, color: AppColors.error))),
        ),
      ],
    );
  }
}




