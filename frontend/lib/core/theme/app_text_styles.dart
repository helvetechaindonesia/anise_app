import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../constants/colors.dart';

class AppTextStyles {
  // ==========================================
  // STANDAR BARU (M3 Typography Scale - Custom Range 32sp to 11sp)
  // ==========================================

  // --- DISPLAY (Black - w900) ---
  static TextStyle displayLarge(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 32.sp(context),
        fontWeight: FontWeight.w900,
        height: 1.2,
        letterSpacing: -0.25,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle displayMedium(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 28.sp(context),
        fontWeight: FontWeight.w900,
        height: 1.2,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle displaySmall(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 24.sp(context),
        fontWeight: FontWeight.w900,
        height: 1.2,
        color: color ?? AppColors.onBackground,
      );

  // --- HEADLINE (ExtraBold - w800) ---
  static TextStyle headlineLarge(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 22.sp(context),
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle headlineMedium(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 20.sp(context),
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle headlineSmall(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 18.sp(context),
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: color ?? AppColors.onBackground,
      );

  // --- TITLE (Bold - w700) ---
  static TextStyle titleLarge(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 16.sp(context),
        fontWeight: FontWeight.w700,
        height: 1.27,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle titleMedium(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 15.sp(context),
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0.15,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle titleSmall(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 12.sp(context),
        fontWeight: FontWeight.w700,
        height: 1.43,
        letterSpacing: 0.1,
        color: color ?? AppColors.onBackground,
      );

  // --- BODY (Regular - w400) ---
  static TextStyle bodyLarge(BuildContext context, {Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 16.sp(context),
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle bodyMedium(BuildContext context, {Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 15.sp(context),
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle bodySmall(BuildContext context, {Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 13.sp(context),
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: color ?? AppColors.onBackground,
      );

  // --- LABEL (Medium - w500) ---
  static TextStyle labelLarge(BuildContext context, {Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 14.sp(context),
        fontWeight: fontWeight ?? FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: color ?? AppColors.onBackground,
      );

  static TextStyle labelMedium(BuildContext context, {Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 12.sp(context),
        fontWeight: fontWeight ?? FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: color ?? AppColors.onBackground,
      );

  // labelSmall
  static TextStyle labelSmall(BuildContext context, {Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 11.sp(context),
        fontWeight: fontWeight ?? FontWeight.w500,
        height: 1.45,
        letterSpacing: 1.0,
        color: color ?? AppColors.onBackground,
      );
}
