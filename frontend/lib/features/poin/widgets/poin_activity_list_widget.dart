import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/poin_provider.dart';

class PoinActivityListWidget extends ConsumerStatefulWidget {
  const PoinActivityListWidget({super.key});

  @override
  ConsumerState<PoinActivityListWidget> createState() => _PoinActivityListWidgetState();
}

class _PoinActivityListWidgetState extends ConsumerState<PoinActivityListWidget> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Co-Kurikuler', 'Ekstra-Kurikuler', 'Intra-Kurikuler'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActivityHeader(context),
        SizedBox(height: 16.h(context)),
        _buildFilterRow(context),
        SizedBox(height: 24.h(context)),
        _buildActivityCards(context),
      ],
    );
  }

  Widget _buildActivityHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Aktivitas & Riwayat Poin',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        Row(
          children: [
            Icon(PhosphorIcons.faders(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 14.w(context)),
            SizedBox(width: 4.w(context)),
            Text(
              'Filter',
              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w(context)),
              padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 8.h(context)),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                borderRadius: BorderRadius.circular(20.w(context)),
                border: Border.all(
                  color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                ),
              ),
              child: Text(
                _filters[index],
                style: AppTextStyles.bodySmall(context, color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivityCards(BuildContext context) {
    final activities = ref.watch(poinActivitiesProvider);
    List<Map<String, dynamic>> displayedActivities = activities;
    
    // Simulate filtering
    if (_selectedFilterIndex != 0) {
      displayedActivities = activities.where((act) => act['category'].toString().contains(_filters[_selectedFilterIndex])).toList();
    }

    if (displayedActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w(context)),
          child: Text(
            'Tidak ada riwayat',
            style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
          ),
        ),
      );
    }

    return Column(
      children: displayedActivities.map((activity) => Padding(
        padding: EdgeInsets.only(bottom: 16.h(context)),
        child: _buildSingleActivityCard(context, activity),
      )).toList(),
    );
  }

  Widget _buildSingleActivityCard(BuildContext context, Map<String, dynamic> activity) {
    final isPlus = activity['type'] == 'plus';
    final accentColor = isPlus ? AppColors.primary : AppColors.error;
    final bgColor = isPlus ? AppColors.secondary : AppColors.error;
    
    // Fallback colors for light mode
    final accentColorText = isPlus ? AppColors.onSecondary : AppColors.onPrimary; // Darker for text contrast
    
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.transparent,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(activity['icon'], color: accentColorText, size: 24.w(context)),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(8.w(context)),
                                  ),
                                  child: Text(
                                    activity['category'],
                                    style: AppTextStyles.labelSmall(context, color: accentColorText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w(context)),
                              Text(
                                activity['date'],
                                style: AppTextStyles.labelSmall(context, color: AppColors.onBackground),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12.w(context)),
                          ),
                          child: Text(
                            activity['points'],
                            style: AppTextStyles.labelMedium(context, color: accentColorText),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      activity['title'],
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          Text(
            activity['description'],
            style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
          ),
          SizedBox(height: 16.h(context)),
          Divider(color: AppColors.outline, height: 1),
          SizedBox(height: 12.h(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isPlus ? PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill) : PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), 
                    color: isPlus ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5), 
                    size: 14.w(context)
                  ),
                  SizedBox(width: 6.w(context)),
                  Text(
                    isPlus ? 'Diverifikasi oleh: ' : 'Petugas Piket: ',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground),
                  ),
                  Text(
                    activity['verifier'],
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground),
                  ),
                ],
              ),
              Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 12.w(context)),
            ],
          ),
        ],
      ),
    );
  }
}

