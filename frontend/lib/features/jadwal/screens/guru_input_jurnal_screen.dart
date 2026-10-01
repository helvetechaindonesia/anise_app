import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class GuruInputJurnalScreen extends StatefulWidget {
  const GuruInputJurnalScreen({Key? key}) : super(key: key);

  @override
  State<GuruInputJurnalScreen> createState() => _GuruInputJurnalScreenState();
}

class _GuruInputJurnalScreenState extends State<GuruInputJurnalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedKelas = 'Kelas XII IPS 1';
  final List<String> _kelasList = ['Kelas X MIPA 1', 'Kelas X IPS 2', 'Kelas XI MIPA 3', 'Kelas XII IPS 1'];

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
        title: Column(
          children: [
            Text(
              'Jurnal Mengajar',
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
            Text(
              'Isi Catatan Kegiatan',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 24.h(context)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Info Jadwal
              _buildSectionTitle(context, 'Informasi Jadwal', PhosphorIcons.calendarPlus(PhosphorIconsStyle.bold)),
              Spacing.custom(context, 16),
              _buildDropdownField(
                context,
                label: 'Kelas',
                value: _selectedKelas,
                items: _kelasList,
                onChanged: (val) {
                  setState(() {
                    _selectedKelas = val!;
                  });
                },
                icon: PhosphorIcons.usersThree(PhosphorIconsStyle.regular),
              ),
              Spacing.custom(context, 16),
              _buildTextField(
                context,
                label: 'Mata Pelajaran',
                initialValue: 'Seni Budaya',
                icon: PhosphorIcons.bookBookmark(PhosphorIconsStyle.regular),
              ),
              Spacing.custom(context, 16),
              _buildTextField(
                context,
                label: 'Jam Ke- (contoh: 1-2)',
                initialValue: '1-2',
                icon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
              ),

              Spacing.custom(context, 32),

              // 2. Kehadiran Singkat
              _buildSectionTitle(context, 'Rekap Kehadiran', PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)),
              Spacing.custom(context, 16),
              Row(
                children: [
                  Expanded(child: _buildNumberField(context, label: 'Hadir', icon: PhosphorIcons.handWaving(PhosphorIconsStyle.regular))),
                  SizedBox(width: 12.w(context)),
                  Expanded(child: _buildNumberField(context, label: 'Izin', icon: PhosphorIcons.envelopeSimple(PhosphorIconsStyle.regular))),
                ],
              ),
              Spacing.custom(context, 12),
              Row(
                children: [
                  Expanded(child: _buildNumberField(context, label: 'Sakit', icon: PhosphorIcons.pill(PhosphorIconsStyle.regular))),
                  SizedBox(width: 12.w(context)),
                  Expanded(child: _buildNumberField(context, label: 'Alpa', icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.regular))),
                ],
              ),

              Spacing.custom(context, 32),

              // 3. Jurnal Utama
              _buildSectionTitle(context, 'Catatan Jurnal', PhosphorIcons.notePencil(PhosphorIconsStyle.bold)),
              Spacing.custom(context, 16),
              _buildTextField(
                context,
                label: 'Topik / Materi Pembahasan',
                hint: 'Masukkan topik yang dibahas hari ini',
              ),
              Spacing.custom(context, 16),
              _buildTextField(
                context,
                label: 'Deskripsi Kegiatan / Evaluasi',
                hint: 'Ceritakan progress belajar, kendala, atau catatan penting untuk kelas ini...',
                maxLines: 4,
              ),

              Spacing.custom(context, 32),

              // 4. Lampiran
              _buildSectionTitle(context, 'Lampiran (Opsional)', PhosphorIcons.paperclip(PhosphorIconsStyle.bold)),
              Spacing.custom(context, 16),
              _buildAttachmentButton(context),

              Spacing.custom(context, 48),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 54.h(context),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.w(context)),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Dummy action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Jurnal berhasil disimpan!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Simpan Jurnal',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary),
                  ),
                ),
              ),
              Spacing.custom(context, 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.w(context)),
        SizedBox(width: 8.w(context)),
        Text(
          title,
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, String? hint, String? initialValue, IconData? icon, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8))),
        SizedBox(height: 8.h(context)),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)) : null,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(BuildContext context, {required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8))),
        SizedBox(height: 8.h(context)),
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue: '0',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context, {required String label, required String value, required List<String> items, required Function(String?) onChanged, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8))),
        SizedBox(height: 8.h(context)),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.5)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
          ),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAttachmentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.light), color: AppColors.onBackground.withValues(alpha: 0.4), size: 32.w(context)),
          SizedBox(height: 12.h(context)),
          Text(
            'Unggah Foto / Dokumen',
            style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            'Maksimal ukuran file 10MB',
            style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
