import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../models/schedule_model.dart';
import '../providers/journal_provider.dart';

class JournalFormScreen extends ConsumerStatefulWidget {
  final ScheduleModel schedule;

  const JournalFormScreen({Key? key, required this.schedule}) : super(key: key);

  @override
  ConsumerState<JournalFormScreen> createState() => _JournalFormScreenState();
}

class _JournalFormScreenState extends ConsumerState<JournalFormScreen> {
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();
  final _taskTitleController = TextEditingController();
  final _taskDescController = TextEditingController();
  
  bool _hasTask = false;
  DateTime? _taskDeadline;

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    _taskTitleController.dispose();
    _taskDescController.dispose();
    super.dispose();
  }

  void _submit() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Topik materi tidak boleh kosong')),
      );
      return;
    }

    if (_hasTask && _taskTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas harus diisi')),
      );
      return;
    }

    final success = await ref.read(journalSubmitProvider.notifier).submit(
      scheduleId: widget.schedule.id,
      date: DateTime.now().toIso8601String().split('T').first,
      topic: topic,
      notes: _notesController.text,
      hasTask: _hasTask,
      taskTitle: _hasTask ? _taskTitleController.text : null,
      taskDescription: _hasTask ? _taskDescController.text : null,
      taskDeadline: _hasTask && _taskDeadline != null 
          ? _taskDeadline!.toIso8601String().split('T').first 
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jurnal berhasil disimpan!')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      final err = ref.read(journalSubmitProvider).error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(journalSubmitProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Isi Jurnal Mengajar'),
        backgroundColor: AppColors.cardGlass,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.schedule.subjectName} - ${widget.schedule.className}',
              style: AppTextStyles.titleLarge(context, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            
            Text('Topik Materi', style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary),
              decoration: _inputDecoration('Contoh: Pengenalan OOP'),
            ),
            
            const SizedBox(height: 16),
            Text('Catatan Tambahan', style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary),
              decoration: _inputDecoration('Opsional...'),
            ),
            
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text('Beri Tugas Siswa', style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary)),
              activeColor: AppColors.primary,
              value: _hasTask,
              onChanged: (val) => setState(() => _hasTask = val),
              contentPadding: EdgeInsets.zero,
            ),
            
            if (_hasTask) ...[
              const SizedBox(height: 16),
              Text('Judul Tugas', style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _taskTitleController,
                style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary),
                decoration: _inputDecoration('Judul tugas'),
              ),
              const SizedBox(height: 16),
              Text('Deskripsi Tugas', style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _taskDescController,
                maxLines: 2,
                style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary),
                decoration: _inputDecoration('Deskripsi singkat'),
              ),
            ],
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: submitState.isLoading
                    ? const CircularProgressIndicator(color: AppColors.surface)
                    : Text('Simpan Jurnal', style: AppTextStyles.titleMedium(context, color: AppColors.surface)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.cardGlass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardGlassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardGlassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

