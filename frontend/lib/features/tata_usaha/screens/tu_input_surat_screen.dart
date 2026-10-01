import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';

class TuInputSuratScreen extends StatefulWidget {
  const TuInputSuratScreen({Key? key}) : super(key: key);

  @override
  State<TuInputSuratScreen> createState() => _TuInputSuratScreenState();
}

class _TuInputSuratScreenState extends State<TuInputSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  String _jenisSurat = 'Surat Keluar';
  String _kategori = 'Umum';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Surat Baru',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
      ),
      body: DecorativeBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w(context)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeSelector(context),
                Spacing.custom(context, 24),
                
                _buildTextField(context, 'Nomor Surat', '001/TU/SMAN1/2026', icon: PhosphorIcons.hash(PhosphorIconsStyle.regular)),
                Spacing.custom(context, 16),
                
                _buildDropdownField(context, 'Kategori', _kategori, ['Umum', 'Undangan', 'Tugas', 'Keterangan'], (val) {
                  setState(() => _kategori = val!);
                }, icon: PhosphorIcons.tag(PhosphorIconsStyle.regular)),
                Spacing.custom(context, 16),
                
                _buildTextField(context, 'Perihal', 'Masukkan perihal surat', icon: PhosphorIcons.textT(PhosphorIconsStyle.regular)),
                Spacing.custom(context, 16),
                
                _buildTextField(context, 'Tujuan / Kepada', 'Masukkan nama atau instansi', icon: PhosphorIcons.buildings(PhosphorIconsStyle.regular)),
                Spacing.custom(context, 16),
                
                _buildDateField(context, 'Tanggal Surat', 'Pilih Tanggal', icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular)),
                Spacing.custom(context, 24),
                
                _buildAttachmentBox(context),
                Spacing.custom(context, 32),
                
                _buildSubmitButton(context),
                Spacing.custom(context, 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _jenisSurat = 'Surat Keluar'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h(context)),
              decoration: BoxDecoration(
                color: _jenisSurat == 'Surat Keluar' ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: _jenisSurat == 'Surat Keluar' ? AppColors.primary : AppColors.outline),
              ),
              child: Center(
                child: Text(
                  'Surat Keluar',
                  style: AppTextStyles.labelMedium(context, color: _jenisSurat == 'Surat Keluar' ? AppColors.onPrimary : AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _jenisSurat = 'Surat Masuk'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h(context)),
              decoration: BoxDecoration(
                color: _jenisSurat == 'Surat Masuk' ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: _jenisSurat == 'Surat Masuk' ? AppColors.primary : AppColors.outline),
              ),
              child: Center(
                child: Text(
                  'Surat Masuk',
                  style: AppTextStyles.labelMedium(context, color: _jenisSurat == 'Surat Masuk' ? AppColors.onPrimary : AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, {required IconData icon, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        TextFormField(
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
            prefixIcon: Icon(icon, color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged, {required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), size: 16.w(context)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, String label, String hint, {required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        GestureDetector(
          onTap: () async {
            await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 16.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)),
                SizedBox(width: 12.w(context)),
                Text(hint, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h(context)),
      decoration: BoxDecoration(
        color: AppColors.menuPastelBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.menuPastelBlue.withValues(alpha: 0.5), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold), color: AppColors.menuPastelBlue, size: 32.w(context)),
          SizedBox(height: 8.h(context)),
          Text(
            'Unggah Dokumen Surat',
            style: AppTextStyles.labelMedium(context, color: AppColors.menuPastelBlue),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            'Format PDF/JPG (Max 5MB)',
            style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_jenisSurat berhasil disimpan!', style: AppTextStyles.bodyMedium(context)),
            backgroundColor: AppColors.menuPastelGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.w(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            'Simpan Surat',
            style: AppTextStyles.titleSmall(context, color: AppColors.onPrimary),
          ),
        ),
      ),
    );
  }
}
