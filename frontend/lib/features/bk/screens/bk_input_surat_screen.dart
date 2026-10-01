import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class BkInputSuratScreen extends StatefulWidget {
  const BkInputSuratScreen({Key? key}) : super(key: key);

  @override
  State<BkInputSuratScreen> createState() => _BkInputSuratScreenState();
}

class _BkInputSuratScreenState extends State<BkInputSuratScreen> {
  String? _selectedClass;
  String? _selectedStudent;
  String? _jenisSurat;
  
  final List<String> _classList = ['X A', 'X B', 'X C', 'X D', 'X E', 'XI IPS 1', 'XI MIPA 1'];
  final List<String> _studentList = ['Aji Akbar', 'Sendi Aritanoga', 'Budi Santoso', 'Siti Aminah'];
  final List<String> _jenisSuratList = ['SP1', 'SP2', 'SP3', 'Panggilan Orang Tua'];

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
          'Buat Surat Panggilan',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 24.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField('Pilih Kelas', _classList, _selectedClass, (val) => setState(() => _selectedClass = val)),
            Spacing.custom(context, 20),
            _buildDropdownField('Pilih Siswa', _studentList, _selectedStudent, (val) => setState(() => _selectedStudent = val)),
            Spacing.custom(context, 20),
            _buildDropdownField('Jenis Surat', _jenisSuratList, _jenisSurat, (val) => setState(() => _jenisSurat = val)),
            Spacing.custom(context, 20),
            _buildTextField('Keterangan Pelanggaran', maxLines: 4),
            Spacing.custom(context, 20),
            _buildTextField('Jadwal Pemanggilan', hint: 'Contoh: Besok, 09:00 WIB (Ruang BK)'),
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
                      content: Text('Surat berhasil dibuat!', style: AppTextStyles.bodyMedium(context)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  'Keluarkan Surat',
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

  Widget _buildTextField(String label, {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
        ),
        Spacing.custom(context, 8),
        TextField(
          maxLines: maxLines,
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
