import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_text_field.dart';

class GuruInputAgendaScreen extends StatefulWidget {
  const GuruInputAgendaScreen({super.key});

  @override
  State<GuruInputAgendaScreen> createState() => _GuruInputAgendaScreenState();
}

class _GuruInputAgendaScreenState extends State<GuruInputAgendaScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedType = 'Formatif';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Agenda Formatif',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Judul Agenda',
              style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 8.h(context)),
            TextFormField(
              controller: _titleController,
              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Misal: Ulangan Harian Bab 1',
                hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.5)),
                prefixIcon: Icon(PhosphorIcons.textAa(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: 24.h(context)),
            Text(
              'Jenis Agenda',
              style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 8.h(context)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                border: Border.all(color: AppColors.outline),
                borderRadius: BorderRadius.circular(12.w(context)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: Icon(PhosphorIcons.caretDown(), color: AppColors.onBackground),
                  items: ['Formatif', 'Praktikum', 'Tugas Proyek'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24.h(context)),
            Text(
              'Tanggal & Waktu',
              style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 8.h(context)),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () {
                // Dummy tap
              },
              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Pilih Jadwal',
                hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.5)),
                prefixIcon: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: 40.h(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Agenda Formatif berhasil dibuat!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                ),
                child: Text(
                  'Simpan Agenda',
                  style: AppTextStyles.titleSmall(context, color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
