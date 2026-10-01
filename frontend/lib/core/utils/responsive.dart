import 'package:flutter/material.dart';

/// Extension untuk membuat angka (px) menjadi fluid berdasarkan ukuran layar
/// Asumsi desain dasar dibuat pada layar dengan tinggi 812px (iPhone 11 Pro / X)
/// dan lebar 375px.
extension ResponsiveSpacing on num {
  /// Fluid Height: Menghitung persentase tinggi layar yang setara dengan nilai [this]
  double h(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // HACK BUAT SCREENSHOT: Batasi tinggi maksimal biar nggak jadi raksasa pas layarnya ditarik ke 3000px
    if (screenHeight > 900) screenHeight = 812; 
    return this * screenHeight / 812;
  }

  /// Fluid Width: Menghitung persentase lebar layar yang setara dengan nilai [this]
  double w(BuildContext context) {
    return this * MediaQuery.of(context).size.width / 375;
  }

  /// Scale-independent Pixels (SP) untuk ukuran font yang beradaptasi dengan setingan layar
  double sp(BuildContext context) {
    // Gunakan textScaleFactor agar kompatibel dengan versi Flutter lama
    return (this * MediaQuery.of(context).size.width / 375) * MediaQuery.of(context).textScaleFactor;
  }
}

class Spacing {
  /// Jarak antar Item dalam satu komponen (Base: 12px fluid)
  static Widget item(BuildContext context) => SizedBox(height: 12.h(context));
  
  /// Jarak antar Komponen (Base: 16px fluid)
  static Widget component(BuildContext context) => SizedBox(height: 16.h(context));
  
  /// Jarak kustom fluid
  static Widget custom(BuildContext context, double height) => SizedBox(height: height.h(context));
}
