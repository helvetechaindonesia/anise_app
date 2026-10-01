import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class BkInputBimbinganScreen extends StatefulWidget {
  const BkInputBimbinganScreen({Key? key}) : super(key: key);

  @override
  State<BkInputBimbinganScreen> createState() => _BkInputBimbinganScreenState();
}

class _BkInputBimbinganScreenState extends State<BkInputBimbinganScreen> {
  String? _selectedType;
  String? _selectedClass;
  
  final List<String> _typeList = ['Konseling Individu', 'Bimbingan Klasikal', 'Konseling Kelompok'];
  final List<String> _classList = ['X A', 'X B', 'X D', 'X E', 'XI IPS 1', 'XI MIPA 1'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Jadwalkan Bimbingan',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 24.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField('Jenis Bimbingan', _typeList, _selectedType, (val) => setState(() => _selectedType = val)),
            Spacing.custom(context, 20),
            _buildDropdownField('Pilih Kelas', _classList, _selectedClass, (val) => setState(() => _selectedClass = val)),
            Spacing.custom(context, 20),
            _buildTextField('Nama Siswa (Opsional jika Individu/Kelompok)'),
            Spacing.custom(context, 20),
            _buildTextField('Topik / Agenda', hint: 'Contoh: Motivasi Belajar, Karir, dll'),
            Spacing.custom(context, 20),
            _buildTextField('Waktu Pelaksanaan', hint: 'Pilih Tanggal & Waktu'),
            Spacing.custom(context, 40),
            SizedBox(
              width: double.infinity,
              height: 56.h(context),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w(context)),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Jadwal bimbingan berhasil dibuat!', style: AppTextStyles.bodyMedium(context)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'Buat Jadwal',
                  style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
        ),
        Spacing.custom(context, 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.w(context)),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text('Pilih $label', style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: AppTextStyles.bodyMedium(context)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
        ),
        Spacing.custom(context, 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan $label',
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
