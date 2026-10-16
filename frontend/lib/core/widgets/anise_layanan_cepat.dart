import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';
import 'menu_icon_button.dart';

/// Item aksi cepat untuk AniseLayananCepat
class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Komponen baku Layanan Cepat terstandarisasi untuk semua Role (Siswa, Guru, BK, TU).
/// Mengelola grid 4 kolom responsif, animasi buka/tutup (expand/collapse) jika > 8 item,
/// dan transisi ukuran yang mulus.
class AniseLayananCepat extends StatefulWidget {
  final String title;
  final List<QuickActionItem> items;
  final EdgeInsetsGeometry? padding;

  const AniseLayananCepat({
    super.key,
    this.title = 'Layanan Cepat',
    required this.items,
    this.padding,
  });

  @override
  State<AniseLayananCepat> createState() => _AniseLayananCepatState();
}

class _AniseLayananCepatState extends State<AniseLayananCepat> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool hasOverflow = widget.items.length > 8;

    final List<Widget> actionWidgets;
    if (!hasOverflow) {
      actionWidgets = widget.items.map((item) {
        return MenuIconButton(
          icon: item.icon,
          label: item.label,
          onTap: item.onTap,
        );
      }).toList();
    } else if (!_isExpanded) {
      // 7 item pertama + Tombol Lainnya
      actionWidgets = widget.items.take(7).map((item) {
        return MenuIconButton(
          icon: item.icon,
          label: item.label,
          onTap: item.onTap,
        );
      }).toList()
        ..add(
          MenuIconButton(
            icon: PhosphorIcons.dotsNine(PhosphorIconsStyle.bold),
            label: 'Lainnya',
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
          ),
        );
    } else {
      // Seluruh item + Tombol Tutup
      actionWidgets = widget.items.map((item) {
        return MenuIconButton(
          icon: item.icon,
          label: item.label,
          onTap: item.onTap,
        );
      }).toList()
        ..add(
          MenuIconButton(
            icon: PhosphorIcons.caretUp(PhosphorIconsStyle.bold),
            label: 'Tutup',
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
          ),
        );
    }

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
          ),
          Spacing.custom(context, 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.72,
                crossAxisSpacing: 8.w(context),
                mainAxisSpacing: 16.h(context),
              ),
              itemCount: actionWidgets.length,
              itemBuilder: (context, index) => actionWidgets[index],
            ),
          ),
        ],
      ),
    );
  }
}
