import 'dart:io';

void main() {
  final content = '''
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class SiswaProfileCardWidget extends StatelessWidget {
  const SiswaProfileCardWidget({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email disalin ke clipboard'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20.w(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24.w(context)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20.w(context),
            top: -20.w(context),
            child: Container(
              width: 150.w(context),
              height: 150.w(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.onBackground.withValues(alpha: 0.05),
                    AppColors.onBackground.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 72.w(context),
                        height: 72.w(context),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        child: Icon(
                          PhosphorIcons.user(PhosphorIconsStyle.fill),
                          color: AppColors.onSurface,
                          size: 32.w(context),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20.w(context),
                          height: 20.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryContainer, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h(context)),
                        Text(
                          'Aisyah Ramadhani',
                          style: AppTextStyles.h3(context, color: AppColors.onPrimaryContainer),
                        ),
                        SizedBox(height: 6.h(context)),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12.w(context)),
                              ),
                              child: Text(
                                'XII MIPA 2',
                                style: AppTextStyles.overline(context, color: AppColors.onPrimary, fontWeight: FontWeight.w800),
                              ),
                            ),
                            SizedBox(width: 8.w(context)),
                            Text(
                              'Aktif',
                              style: AppTextStyles.caption(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h(context)),
                        Text(
                          'NISN: 0074829103 • NIS: 22231008',
                          style: AppTextStyles.caption(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h(context)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.at(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 16.w(context)),
                    SizedBox(width: 12.w(context)),
                    Expanded(
                      child: Text(
                        'aisyah.ramadhani@siswa.helvetecha.sch.id',
                        style: AppTextStyles.caption(context, color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, 'aisyah.ramadhani@siswa.helvetecha.sch.id'),
                      child: Icon(PhosphorIcons.copy(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 18.w(context)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h(context)),
              Container(
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.w(context)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12.w(context)),
                      ),
                      child: Icon(PhosphorIcons.identificationCard(PhosphorIconsStyle.regular), color: AppColors.onPrimaryContainer, size: 24.w(context)),
                    ),
                    SizedBox(width: 16.w(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unduh Kartu Digital',
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h(context)),
                          Text(
                            'Format PDF Resmi • Valid 2024-2025',
                            style: AppTextStyles.overline(context, color: AppColors.onPrimary.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w(context)),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 16.w(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
''';
  File('f:/projek/anise_app/frontend/lib/features/profile/widgets/siswa_profile_card_widget.dart').writeAsStringSync(content);
}
