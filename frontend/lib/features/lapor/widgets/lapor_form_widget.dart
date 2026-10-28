import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/anise_feedback_dialog.dart';
import '../providers/report_provider.dart';

class LaporFormWidget extends ConsumerStatefulWidget {
  const LaporFormWidget({super.key});

  @override
  ConsumerState<LaporFormWidget> createState() => _LaporFormWidgetState();
}

class _LaporFormWidgetState extends ConsumerState<LaporFormWidget> {
  String _selectedCategoryKey = '';
  bool _isAnonymous = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'FASILITAS',
      'label': 'Fasilitas\nSekolah',
      'icon': PhosphorIcons.buildings(PhosphorIconsStyle.fill)
    },
    {
      'key': 'BULLYING',
      'label': 'Aduan\nBullying',
      'icon': PhosphorIcons.usersThree(PhosphorIconsStyle.fill)
    },
    {
      'key': 'ASPIRASI',
      'label': 'Aspirasi\nSiswa',
      'icon': PhosphorIcons.chatTeardropText(PhosphorIconsStyle.fill)
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReport() async {
    if (_selectedCategoryKey.isEmpty) {
      AniseFeedbackDialog.showWarning(
        context,
        title: 'Kategori Belum Dipilih',
        message: 'Silakan pilih salah satu kategori laporan terlebih dahulu.',
        buttonText: 'Pilih Kategori',
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      AniseFeedbackDialog.showWarning(
        context,
        title: 'Judul Belum Diisi',
        message: 'Judul atau perihal laporan wajib diisi.',
        buttonText: 'Mengerti',
      );
      return;
    }

    if (_descController.text.trim().isEmpty) {
      AniseFeedbackDialog.showWarning(
        context,
        title: 'Deskripsi Belum Diisi',
        message: 'Rincian deskripsi laporan wajib diisi secara jelas.',
        buttonText: 'Mengerti',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final complaintService = ref.read(complaintServiceProvider);
      await complaintService.submitComplaint(
        category: _selectedCategoryKey,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        isAnonymous: _isAnonymous,
        imageFile: _imageFile,
      );

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      AniseFeedbackDialog.showError(
        context,
        title: 'Gagal Mengirim Laporan',
        message: e.toString().replaceAll('Exception: ', ''),
        buttonText: 'Tutup',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    AniseFeedbackDialog.showSuccess(
      context,
      title: 'Laporan Terkirim',
      message: 'Terima kasih atas partisipasi Anda. Laporan Anda telah berhasil dicatat dan akan segera ditindaklanjuti oleh pihak sekolah.',
      buttonText: 'Selesai',
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategorySelector(context),
        SizedBox(height: 24.h(context)),
        _buildInputFields(context),
        SizedBox(height: 24.h(context)),
        _buildUploadSection(context),
        SizedBox(height: 24.h(context)),
        _buildAnonymousToggle(context),
        SizedBox(height: 16.h(context)),
        _buildWarningInfo(context),
        SizedBox(height: 32.h(context)),
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kategori Laporan',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
            ),
            Text(
              'Pilih Salah Satu',
              style: AppTextStyles.labelSmall(context,
                  color: AppColors.onBackground.withValues(alpha: 0.7)),
            ),
          ],
        ),
        SizedBox(height: 12.h(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _categories.map((cat) {
            final key = cat['key'] as String;
            final isSelected = _selectedCategoryKey == key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryKey = key;
                });
              },
              child: Container(
                width: 96.w(context),
                padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : AppColors.surface,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : AppColors.outline,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? AppColors.onSecondary : AppColors.onSurface,
                      size: 28.w(context),
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      cat['label'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall(
                        context,
                        color: isSelected
                            ? AppColors.onSecondary
                            : AppColors.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputFields(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Judul Laporan Singkat',
            hintStyle: AppTextStyles.bodyMedium(context,
                color: AppColors.onSurface.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        SizedBox(height: 16.h(context)),
        TextField(
          controller: _descController,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Jelaskan detail kejadian, lokasi, dan waktu secara rinci...',
            hintStyle: AppTextStyles.bodyMedium(context,
                color: AppColors.onSurface.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w(context)),
              borderSide: const BorderSide(color: AppColors.outline),
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

  Widget _buildUploadSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Unggah Foto Pendukung',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                ),
              ),
              SizedBox(width: 8.w(context)),
              Text(
                'Opsional',
                style: AppTextStyles.labelSmall(context,
                    color: AppColors.onSurface.withValues(alpha: 0.7)),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w(context)),
                    decoration: const BoxDecoration(
                        color: AppColors.primaryContainer, shape: BoxShape.circle),
                    child: Icon(PhosphorIcons.camera(PhosphorIconsStyle.fill),
                        color: AppColors.onPrimaryContainer, size: 20.w(context)),
                  ),
                  SizedBox(height: 12.h(context)),
                  Text(
                    'Unggah Foto Bukti Kejadian',
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Ketuk untuk memilih foto (JPG, PNG)',
                    style: AppTextStyles.labelSmall(context,
                        color: AppColors.onSurface.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
          if (_imageFile != null) ...[
            SizedBox(height: 12.h(context)),
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12.w(context)),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.w(context)),
                    child: Image.file(
                      _imageFile!,
                      width: 44.w(context),
                      height: 44.w(context),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Foto Terpilih',
                            style: AppTextStyles.bodySmall(context,
                                color: AppColors.onSurface)),
                        Text('Siap dikirim',
                            style: AppTextStyles.labelSmall(context,
                                color: AppColors.onSurface.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _imageFile = null),
                    child: Container(
                      padding: EdgeInsets.all(4.w(context)),
                      child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold),
                          color: AppColors.onSurface.withValues(alpha: 0.5),
                          size: 20.w(context)),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAnonymousToggle(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.w(context)),
            decoration: const BoxDecoration(
                color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: Icon(PhosphorIcons.eyeClosed(PhosphorIconsStyle.bold),
                color: AppColors.onPrimaryContainer, size: 20.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lapor Secara Anonim',
                        style: AppTextStyles.bodyMedium(context,
                            color: AppColors.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w(context), vertical: 2.h(context)),
                      decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        'Aman',
                        style: AppTextStyles.labelSmall(context,
                            color: AppColors.onSecondary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'Identitas dan NISN Anda dirahasiakan sepenuhnya.',
                  style: AppTextStyles.labelMedium(context,
                      color: AppColors.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnonymous,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.onSurface.withValues(alpha: 0.5),
            inactiveTrackColor: AppColors.backgroundLight,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarningInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(PhosphorIcons.info(PhosphorIconsStyle.fill),
            color: AppColors.onBackground.withValues(alpha: 0.5), size: 16.w(context)),
        SizedBox(width: 8.w(context)),
        Expanded(
          child: Text(
            'Laporan palsu atau fitnah dapat dikenakan sanksi tata tertib siswa SMA N 1 Peunaron.',
            style: AppTextStyles.labelMedium(context,
                color: AppColors.onBackground.withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h(context),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.w(context))),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                      color: AppColors.onPrimary, size: 20.w(context)),
                  SizedBox(width: 12.w(context)),
                  Text(
                    'Kirim Laporan Resmi',
                    style: AppTextStyles.bodyMedium(context,
                        color: AppColors.onPrimary),
                  ),
                ],
              ),
      ),
    );
  }
}
