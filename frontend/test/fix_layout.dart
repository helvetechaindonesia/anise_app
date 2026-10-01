import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/tugas/widgets/tugas_item_card.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    
    // We will rewrite the Column children
    final newColumn = '''
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '\ • \',
                    style: AppTextStyles.overline(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w(context)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8.w(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelesai ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold) : PhosphorIcons.timer(PhosphorIconsStyle.bold),
                        size: 12.w(context),
                        color: AppColors.onSecondary,
                      ),
                      SizedBox(width: 4.w(context)),
                      Text(
                        timeInfo,
                        style: AppTextStyles.overline(context, color: AppColors.onSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h(context)),
            Text(
              title,
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 14.w(context),
                      color: AppColors.onBackground,
                    ),
                    SizedBox(width: 6.w(context)),
                    Text(
                      'Status: ',
                      style: AppTextStyles.caption(context, color: AppColors.onBackground),
                    ),
                    Text(
                      statusText,
                      style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isSelesai && nilai != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.onSecondary, size: 12.w(context)),
                        SizedBox(width: 4.w(context)),
                        Text(
                          nilai.toString(),
                          style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
''';
    
    // Replace the Column inside GestureDetector
    final startIdx = content.indexOf('child: Column(');
    final endIdx = content.lastIndexOf('),') + 2; // the end of Column
    // Better way: regex or string manipulation
    // Since we know exactly what we are replacing
    // The gesture detector child is the Column. 
    
    // I will just use string replacement on a large chunk.
    final oldChunk = '''
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\ • \',
                        style: AppTextStyles.overline(context, color: AppColors.onBackground.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8.w(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelesai ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold) : PhosphorIcons.timer(PhosphorIconsStyle.bold),
                        size: 12.w(context),
                        color: AppColors.onSecondary,
                      ),
                      SizedBox(width: 4.w(context)),
                      Text(
                        timeInfo,
                        style: AppTextStyles.overline(context, color: AppColors.onSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacing.custom(context, 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 14.w(context),
                      color: AppColors.onBackground,
                    ),
                    SizedBox(width: 6.w(context)),
                    Text(
                      'Status: ',
                      style: AppTextStyles.caption(context, color: AppColors.onBackground),
                    ),
                    Text(
                      statusText,
                      style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isSelesai && nilai != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.onSecondary, size: 12.w(context)),
                        SizedBox(width: 4.w(context)),
                        Text(
                          nilai.toString(),
                          style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
''';
    content = content.replaceFirst(oldChunk, newColumn);
    file.writeAsStringSync(content);
  }
}
