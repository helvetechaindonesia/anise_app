import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_schedule_card.dart';
import '../../../core/widgets/section_action_link.dart';
import '../../jadwal/screens/guru_jurnal_screen.dart';

final kepsekClassesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/curriculum/classes');
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    return [];
  }
});

class KepsekPantauJurnalWidget extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const KepsekPantauJurnalWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(kepsekClassesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantau Jurnal',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  'Monitoring KBM seluruh kelas',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
              ],
            ),
            SectionActionLink(
              text: 'Semua',
              onTap: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuruJurnalScreen()),
                  );
                }
              },
            ),
          ],
        ),
        Spacing.custom(context, 16),
        classesAsync.when(
          loading: () => Container(
            height: 145.h(context),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Container(
            height: 145.h(context),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 20.w(context)),
                SizedBox(width: 8.w(context)),
                Text('Gagal memuat daftar kelas', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                SizedBox(width: 8.w(context)),
                IconButton(
                  icon: Icon(PhosphorIcons.arrowClockwise(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                  onPressed: () => ref.refresh(kepsekClassesProvider),
                ),
              ],
            ),
          ),
          data: (classes) {
            if (classes.isEmpty) {
              return Container(
                height: 145.h(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'Belum ada data kelas terdaftar.',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                ),
              );
            }

            return SizedBox(
              height: 145.h(context),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: classes.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final cls = classes[index];
                  final gradeLevel = cls['grade_level']?.toString() ?? '';
                  final name = cls['name']?.toString() ?? '';
                  final fullClassName = '$gradeLevel $name'.trim();
                  final waliName = cls['wali_kelas']?['full_name'] ?? 'Wali Kelas Belum Diatur';

                  return AniseScheduleCard(
                    title: fullClassName,
                    subtitle: waliName,
                    topWidget: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 44.w(context),
                          height: 44.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16.w(context)),
                            border: Border.all(
                              color: AppColors.onPrimaryContainer.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.fill),
                            color: AppColors.onPrimaryContainer,
                            size: 22.w(context),
                          ),
                        ),
                        Container(
                          width: 12.w(context),
                          height: 12.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryContainer, width: 2),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GuruJurnalScreen(className: fullClassName),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
