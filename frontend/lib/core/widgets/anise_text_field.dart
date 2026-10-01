import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AniseTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool enabled;
  final TextInputType? keyboardType;
  final int maxLines;

  const AniseTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  State<AniseTextField> createState() => _AniseTextFieldState();
}

class _AniseTextFieldState extends State<AniseTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: AppTextStyles.bodyMedium(context, color: widget.enabled ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.5)),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.labelLarge(context, color: AppColors.onSurfaceVariant),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.primary; // Warna saat aktif
          }
          return AppColors.onSurfaceVariant; // Warna saat diam
        }),
        prefixIcon: Icon(widget.icon),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.primary;
          }
          return AppColors.onSurfaceVariant;
        }),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscureText ? PhosphorIcons.eye(PhosphorIconsStyle.bold) : PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold)),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
      ),
    );
  }
}
