import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Warna Identitas Utama)
  static const Color primary = Color(0xFF1C3F4A);           // Hijau Gelap
  static const Color onPrimary = Color(0xFFFFFFFF);         // Putih (Teks di atas Primary)
  static const Color primaryContainer = Color(0xFF1C3F4A);  // Disamakan dengan primary
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);// Putih (Teks di atas PrimaryContainer)
  
  static const Color secondary = Color(0xFF87D0C5);         // Hijau Teal
  static const Color onSecondary = Color(0xFF000000);       // Hitam (Teks di atas Secondary)

  // Structural Colors (Warna Tata Letak & Kanvas)
  static const Color backgroundLight = Color(0xFFF9FAFB);   // Abu-abu sangat muda (Background Scaffold)
  static const Color onBackground = Color(0xFF1C3F4A);      // Hijau Gelap (Teks judul/utama di background)
  
  static const Color surface = Color(0xFFFFFFFF);           // Putih Bersih (Background Card biasa)
  static const Color onSurface = Color(0xFF1C3F4A);         // Hijau Gelap (Teks utama di dalam Card)
  
  static const Color surfaceVariant = Color(0xFFF0F4F5);    // Putih agak butek (Background area sekunder)
  static const Color onSurfaceVariant = Color(0xFFB3B3B3);  // Abu-abu (Subtitle/Caption di dalam area sekunder)

  // Neutral & Outline
  static const Color outline = primary;                     // Hijau Gelap (Garis tepi tegas)
  
  // Status Colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF87D0C5);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Glassmorphism & Utilities
  static const Color transparent = Colors.transparent;
  static const Color cardGlass = Color(0x1AFFFFFF);         // 10% white
  static const Color cardGlassBorder = Color(0x33FFFFFF);   // 20% white
  
  // Backward compatibility sementara agar layar yang belum di-refactor tidak error merah
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDark = Color(0xFF1C3F4A);
  static const Color black = Colors.black;
  static const Color backgroundDark = Color(0xFF050B0D);
  static const Color primaryDark = Color(0xFF132A31);
  
  // Menu Pastel Colors (Khusus untuk icon grid / layanan cepat)
  static const Color menuPastelGreen = Color(0xFF90F0D5);
  static const Color menuPastelBlue = Color(0xFFBCE3F7);
  static const Color menuPastelPurple = Color(0xFFDCDAFB);
  static const Color menuPastelLilac = Color(0xFFE2E0FF);
  static const Color menuPastelGreyish = Color(0xFFEBE9FF);
  static const Color menuPastelRed = Color(0xFFFFCDCD);
  static const Color menuPastelMint = Color(0xFF67F69B);
}
