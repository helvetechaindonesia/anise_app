import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

const List<String> _hariSingkat = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
const List<String> _hariLengkap = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
const List<String> _bulanLengkap = [
  '',
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember'
];

/// Tombol Pill Standar "Pilih Tanggal" / "Ubah Tanggal" pada header halaman
class AniseDatePickerButton extends StatelessWidget {
  final DateTime selectedDate;
  final bool isCustomDateSelected;
  final ValueChanged<DateTime> onDateSelected;
  final String defaultText;
  final String activeText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AniseDatePickerButton({
    Key? key,
    required this.selectedDate,
    required this.isCustomDateSelected,
    required this.onDateSelected,
    this.defaultText = 'Pilih Tanggal',
    this.activeText = 'Ubah Tanggal',
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onPrimary,
                  surface: AppColors.surface,
                  onSurface: AppColors.onSurface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
        decoration: BoxDecoration(
          color: isCustomDateSelected ? AppColors.surfaceVariant : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(20.w(context)),
          border: isCustomDateSelected ? Border.all(color: AppColors.secondary, width: 1.2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
              color: isCustomDateSelected ? AppColors.primary : AppColors.onPrimaryContainer,
              size: 14.w(context),
            ),
            SizedBox(width: 6.w(context)),
            Text(
              isCustomDateSelected ? activeText : defaultText,
              style: AppTextStyles.labelMedium(
                context,
                color: isCustomDateSelected ? AppColors.primary : AppColors.onPrimaryContainer,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner Card Standar "FILTER TANGGAL AKTIF" saat pengguna memilih tanggal spesifik
class AniseActiveDateBanner extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onReset;
  final String label;

  const AniseActiveDateBanner({
    Key? key,
    required this.selectedDate,
    required this.onReset,
    this.label = 'FILTER TANGGAL AKTIF',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayName = _hariLengkap[selectedDate.weekday % 7];
    final dateFormatted = '$dayName, ${selectedDate.day} ${_bulanLengkap[selectedDate.month]} ${selectedDate.year}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w(context)),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold),
              color: AppColors.onSecondary,
              size: 18.w(context),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  dateFormatted,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.w(context)),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.error),
                  SizedBox(width: 4.w(context)),
                  Text(
                    'Reset',
                    style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar Horizontal Pill Tanggal Standar dengan Indikator "Hari Ini" dan Highlight Aktif
class AniseDatePillBar extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final double? height;
  final double? itemWidth;

  const AniseDatePillBar({
    Key? key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
    this.height,
    this.itemWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SizedBox(
      height: height ?? 74.h(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
          final dayName = _hariSingkat[date.weekday % 7];

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: itemWidth ?? 56.w(context),
              margin: EdgeInsets.only(right: 12.w(context)),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday ? AppColors.secondary : AppColors.outlineVariant),
                  width: isSelected ? 1.5 : (isToday ? 1.2 : 1),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: AppTextStyles.labelSmall(
                          context,
                          color: isSelected
                              ? AppColors.onPrimaryContainer.withValues(alpha: 0.85)
                              : (isToday ? AppColors.secondary : AppColors.onSurfaceVariant),
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        '${date.day}',
                        style: AppTextStyles.titleMedium(
                          context,
                          color: isSelected
                              ? (isToday ? AppColors.onPrimaryContainer : AppColors.primary)
                              : (isToday ? AppColors.secondary : AppColors.onSurface),
                        ).copyWith(
                          fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (isToday)
                    Positioned(
                      bottom: 5.h(context),
                      child: Container(
                        width: 20.w(context),
                        height: 3.h(context),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.onPrimaryContainer : AppColors.secondary,
                          borderRadius: BorderRadius.circular(2.w(context)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget Gabungan Standar (Menangani State Custom Date & Pill Bar)
class AniseDateFilter extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final bool isCustomDateSelected;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onReset;
  final Widget? weekNavigator;
  final String emptyMessage;

  const AniseDateFilter({
    Key? key,
    required this.dates,
    required this.selectedDate,
    required this.isCustomDateSelected,
    required this.onDateSelected,
    required this.onReset,
    this.weekNavigator,
    this.emptyMessage = 'Tidak ada hari KBM aktif pada pekan ini (Libur Sekolah).',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCustomDateSelected) {
      return AniseActiveDateBanner(
        selectedDate: selectedDate,
        onReset: onReset,
      );
    }

    if (dates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        child: Text(
          emptyMessage,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (weekNavigator != null) ...[
          weekNavigator!,
          SizedBox(height: 12.h(context)),
        ],
        AniseDatePillBar(
          dates: dates,
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        ),
      ],
    );
  }
}
