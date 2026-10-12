import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/responsive.dart';

/// Standard Card container untuk membungkus konten di seluruh aplikasi Anise
class AniseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final Border? border;
  final double? borderRadius;

  const AniseCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.border,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 20.w(context));

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        border: border ?? Border.all(color: AppColors.outline.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.primary.withValues(alpha: 0.05),
            highlightColor: AppColors.primary.withValues(alpha: 0.02),
            child: Padding(
              padding: padding ?? EdgeInsets.all(16.w(context)),
              child: child,
            ),
          ),
        ),
      ),
    );

    return content;
  }
}
