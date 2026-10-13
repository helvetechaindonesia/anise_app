import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// AniseExpandableCard - Standar kartu accordion kolapsibel dengan animasi halus
class AniseExpandableCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Color? headerBgColor;
  final Color? contentBgColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AniseExpandableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.headerBgColor,
    this.contentBgColor,
    this.textColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<AniseExpandableCard> createState() => _AniseExpandableCardState();
}

class _AniseExpandableCardState extends State<AniseExpandableCard> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(16.w(context));
    final effectiveBg = widget.headerBgColor ?? AppColors.primaryContainer;
    final effectiveTextColor = widget.textColor ?? AppColors.onPrimaryContainer;
    final effectiveContentBg = widget.contentBgColor ?? AppColors.surface;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: effectiveRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.onBackground.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Bar (Icon + Title/Subtitle + Caret)
            Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: effectiveTextColor,
                    size: 18.w(context),
                  ),
                  SizedBox(width: 12.w(context)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.titleSmall(context, color: effectiveTextColor).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                        SizedBox(height: 2.h(context)),
                        Text(
                          widget.subtitle!,
                          style: AppTextStyles.labelSmall(
                            context,
                            color: effectiveTextColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                    color: effectiveTextColor,
                    size: 16.w(context),
                  ),
                ),
              ],
            ),

            // 2. Expandable Body
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 16.h(context)),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w(context)),
                  decoration: BoxDecoration(
                    color: effectiveContentBg,
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: widget.child,
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
