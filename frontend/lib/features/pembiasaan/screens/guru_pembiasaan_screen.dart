import 'package:flutter/material.dart';
import 'pembiasaan_screen.dart';

/// Backward-compatible screen wrapper agar navigasi lama guru tetap langsung membuka
/// modul G7-KAIH lengkap (Checklist mandiri, Grafik saya, dan Pantauan).
class GuruPembiasaanScreen extends StatelessWidget {
  const GuruPembiasaanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PembiasaanScreen();
  }
}
