import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomExpandableFab extends StatefulWidget {
  final VoidCallback onUploadPressed;
  final VoidCallback onAddPressed;

  const CustomExpandableFab({
    Key? key,
    required this.onUploadPressed,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  _CustomExpandableFabState createState() => _CustomExpandableFabState();
}

class _CustomExpandableFabState extends State<CustomExpandableFab> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0, // expands from bottom to top
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSubButton(
                icon: PhosphorIcons.plus(PhosphorIconsStyle.bold),
                label: 'Tambah Data',
                onTap: () {
                  _toggle();
                  widget.onAddPressed();
                },
              ),
              const SizedBox(height: 12),
              _buildSubButton(
                icon: PhosphorIcons.fileXls(PhosphorIconsStyle.bold),
                label: 'Upload Excel',
                onTap: () {
                  _toggle();
                  widget.onUploadPressed();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FloatingActionButton.extended(
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: child.key == const ValueKey('icon1')
                    ? Tween<double>(begin: 1, end: 1).animate(anim)
                    : Tween<double>(begin: 0.75, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _isOpen
                  ? Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: AppColors.onPrimary, key: const ValueKey('icon2'))
                  : Icon(PhosphorIcons.upload(PhosphorIconsStyle.bold), color: AppColors.onPrimary, key: const ValueKey('icon1')),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _isOpen ? 'Tutup' : 'Sunting Data',
                key: ValueKey(_isOpen ? 'Tutup' : 'Sunting Data'),
                style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.onPrimary, size: 20),
                const SizedBox(width: 8),
                Text(label, style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
