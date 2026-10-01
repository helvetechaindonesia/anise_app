import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/leave_provider.dart';

class SiswaAjukanIzinScreen extends ConsumerStatefulWidget {
  const SiswaAjukanIzinScreen({super.key});

  @override
  ConsumerState<SiswaAjukanIzinScreen> createState() => _SiswaAjukanIzinScreenState();
}

class _SiswaAjukanIzinScreenState extends ConsumerState<SiswaAjukanIzinScreen> {
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _filePath;
  String? _fileName;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result.isNotEmpty) {
      setState(() {
        _filePath = result.first.path;
        _fileName = result.first.name;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_reasonController.text.trim().isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi alasan dan tanggal terlebih dahulu.')),
      );
      return;
    }
    
    final success = await ref.read(leaveNotifierProvider.notifier).submitLeave(
      type: 'IZIN',
      reason: _reasonController.text.trim(),
      startDate: "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}",
      endDate: "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}",
      filePath: _filePath,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin berhasil diajukan!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengajukan izin. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(leaveNotifierProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildHeaderInfo(context),
                  SizedBox(height: 24.h(context)),
                  _buildInputField(context, 'Alasan Izin', 'Contoh: Sakit demam, urusan keluarga mendesak', _reasonController, maxLines: 3),
                  SizedBox(height: 16.h(context)),
                  _buildDatePicker(context, 'Mulai Tanggal', _startDate, true),
                  SizedBox(height: 16.h(context)),
                  _buildDatePicker(context, 'Sampai Tanggal', _endDate, false),
                  SizedBox(height: 16.h(context)),
                  _buildFileUpload(context),
                  SizedBox(height: 32.h(context)),
                  _buildSubmitButton(context, isSubmitting),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
          Text(
            'Ajukan Izin',
            style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 24.w(context)),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Text(
              'Pengajuan izin akan masuk ke Tata Usaha dan diteruskan ke Wali Kelas untuk persetujuan.',
              style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16.w(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? selectedDate, bool isStart) {
    String dateStr = selectedDate != null 
        ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}" 
        : 'Pilih tanggal';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        GestureDetector(
          onTap: () => _selectDate(context, isStart),
          child: Container(
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular), color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)),
                SizedBox(width: 12.w(context)),
                Text(dateStr, style: AppTextStyles.bodyMedium(context, color: selectedDate != null ? AppColors.onBackground : AppColors.onBackground.withValues(alpha: 0.4))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lampiran Surat / Bukti (opsional)', style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.regular), color: AppColors.primary, size: 32.w(context)),
                SizedBox(height: 12.h(context)),
                Text(_fileName ?? 'Unggah foto surat sakit atau dokumen (PDF/JPG)', style: AppTextStyles.labelMedium(context, color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isSubmitting) {
    return ElevatedButton(
      onPressed: isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: 16.h(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
        elevation: 0,
      ),
      child: Center(
        child: isSubmitting 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
          : Text(
              'Kirim Pengajuan',
              style: AppTextStyles.titleSmall(context, color: AppColors.onPrimary),
            ),
      ),
    );
  }
}
