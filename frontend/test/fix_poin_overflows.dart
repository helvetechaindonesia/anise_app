import 'dart:io';

void main() {
  final fMain = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_main_card_widget.dart');
  if (fMain.existsSync()) {
    var c = fMain.readAsStringSync();
    
    // Top Row Overflow Fix
    c = c.replaceAll(
      "                      Text(\n                        'Kategori: Sangat Baik / Teladan',",
      "                      Expanded(\n                        child: Text(\n                          'Kategori: Sangat Baik / Teladan',\n                          overflow: TextOverflow.ellipsis,"
    );
    // Since I wrapped Text in Expanded, I need to close it. The original structure was:
    // Text(
    //   'Kategori: Sangat Baik / Teladan',
    //   style: AppTextStyles.overline(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w600),
    // ),
    c = c.replaceAll(
      "AppTextStyles.overline(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w600),\n                    ),",
      "AppTextStyles.overline(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w600),\n                        ),\n                      ),"
    );

    // Also, the right side of the Top Row 'XII MIPA 2' has an icon that was somehow colored AppColors.primary (dark green on dark green container). Let's make it onPrimaryContainer (white) or secondary (teal). Let's make it secondary so it looks like a gold star or teal star.
    c = c.replaceAll(
      "Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.primary, size: 14.w(context))",
      "Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 14.w(context))"
    );

    // Bottom Row Overflow Fix: Prestasi column
    c = c.replaceAll(
      "                      Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: [\n                          Text(\n                            'Prestasi',",
      "                      Expanded(\n                        child: Column(\n                          crossAxisAlignment: CrossAxisAlignment.start,\n                          children: [\n                            Text(\n                              'Prestasi',\n                              overflow: TextOverflow.ellipsis,"
    );
    // Close the Expanded for Prestasi
    c = c.replaceAll(
      "Text(\n                            '+195',\n                            style: AppTextStyles.bodyLarge(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),\n                          ),\n                        ],\n                      ),",
      "Text(\n                              '+195',\n                              style: AppTextStyles.bodyLarge(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),\n                              overflow: TextOverflow.ellipsis,\n                            ),\n                          ],\n                        ),\n                      ),"
    );

    // Bottom Row Overflow Fix: Pelanggaran column
    c = c.replaceAll(
      "                      Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: [\n                          Text(\n                            'Pelanggaran',",
      "                      Expanded(\n                        child: Column(\n                          crossAxisAlignment: CrossAxisAlignment.start,\n                          children: [\n                            Text(\n                              'Pelanggaran',\n                              overflow: TextOverflow.ellipsis,"
    );
    // Close the Expanded for Pelanggaran
    c = c.replaceAll(
      "Text(\n                            '-10',\n                            style: AppTextStyles.bodyLarge(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),\n                          ),\n                        ],\n                      ),",
      "Text(\n                              '-10',\n                              style: AppTextStyles.bodyLarge(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),\n                              overflow: TextOverflow.ellipsis,\n                            ),\n                          ],\n                        ),\n                      ),"
    );
    
    // In Pelanggaran, the minus icon was AppColors.primary (dark green on dark green), let's change to AppColors.error (red) or onPrimaryContainer (white)
    c = c.replaceAll(
      "Icon(PhosphorIcons.minusCircle(PhosphorIconsStyle.fill), color: AppColors.primary, size: 16.w(context))",
      "Icon(PhosphorIcons.minusCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 16.w(context))"
    );

    fMain.writeAsStringSync(c);
  }
}
