import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/anise_insight_card.dart';
import '../../../core/widgets/anise_time_filter_dropdowns.dart';
import '../../../core/widgets/anise_capsule_tab_bar.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../../core/widgets/anise_cangkang_tugas_card.dart';
import '../../../core/widgets/anise_guru_task_card.dart';
import 'guru_tugas_penilaian_screen.dart';
import 'guru_input_tugas_screen.dart';
import '../providers/tugas_provider.dart';

class GuruTugasScreen extends ConsumerStatefulWidget {
  const GuruTugasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GuruTugasScreen> createState() => _GuruTugasScreenState();
}

class _GuruTugasScreenState extends ConsumerState<GuruTugasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static final DateTime _releaseDate = ApiConstants.appReleaseDate; // 26 Oktober 2026

  List<String> get _years {
    final currentYear = DateTime.now().year;
    final releaseYear = _releaseDate.year;
    final maxYear = currentYear >= releaseYear ? currentYear + 1 : releaseYear + 1;
    final List<String> list = ['Semua Tahun'];
    for (int y = releaseYear; y <= maxYear; y++) {
      list.add(y.toString());
    }
    return list;
  }

  List<String> get _months {
    const allMonths = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final List<String> list = ['Semua Bulan'];
    if (_selectedYear == _releaseDate.year.toString()) {
      // Tidak boleh memilih bulan sebelum rilis aplikasi (Oktober 2026)
      list.addAll(allMonths.sublist(_releaseDate.month - 1));
    } else {
      list.addAll(allMonths);
    }
    return list;
  }

  late String _selectedMonth;
  late String _selectedYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _selectedYear = 'Semua Tahun';
    _selectedMonth = 'Semua Bulan';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmDialog(BuildContext context, String taskId, String taskTitle) async {
    final confirmed = await AniseFeedbackDialog.showConfirm(
      context,
      title: 'Hapus Tugas',
      message: 'Apakah Anda yakin ingin menghapus tugas "$taskTitle"? Data pengumpulan dan nilai siswa yang berkaitan juga akan terhapus.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(tugasProvider.notifier).deleteTugas(taskId: taskId);
      if (mounted) {
        if (success) {
          ref.invalidate(getTasksProvider);
          AniseFeedbackDialog.showSuccess(
            context,
            title: 'Tugas Dihapus',
            message: 'Tugas "$taskTitle" beserta data pengumpulan siswa berhasil dihapus.',
          );
        } else {
          AniseFeedbackDialog.showError(
            context,
            title: 'Gagal Menghapus',
            message: 'Terjadi kendala saat menghapus tugas. Silakan periksa koneksi internet Anda.',
          );
        }
      }
    }
  }

  void _showEditTaskModal(BuildContext context, Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title']?.toString() ?? '');
    final descController = TextEditingController(text: task['description']?.toString() ?? '');
    DateTime dueDateTime = DateTime.tryParse(task['due_date']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 1));

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w(context),
                right: 24.w(context),
                top: 24.h(context),
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h(context),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w(context),
                        height: 4.h(context),
                        decoration: BoxDecoration(
                          color: AppColors.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h(context)),
                    Text('Edit Informasi Tugas', style: AppTextStyles.titleLarge(context, color: AppColors.onSurface)),
                    SizedBox(height: 16.h(context)),
                    
                    Text('Judul Tugas', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h(context)),
                    TextField(
                      controller: titleController,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      ),
                    ),
                    SizedBox(height: 16.h(context)),

                    Text('Instruksi Tugas', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h(context)),
                    TextField(
                      controller: descController,
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      ),
                    ),
                    SizedBox(height: 20.h(context)),

                    SizedBox(
                      width: double.infinity,
                      height: 48.h(context),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (titleController.text.trim().isEmpty) return;
                                setModalState(() => isSubmitting = true);
                                
                                final success = await ref.read(tugasProvider.notifier).updateTugas(
                                  taskId: task['id'].toString(),
                                  title: titleController.text.trim(),
                                  description: descController.text.trim(),
                                  dueDate: dueDateTime.toIso8601String(),
                                );

                                setModalState(() => isSubmitting = false);
                                if (success) {
                                  ref.invalidate(getTasksProvider);
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    AniseFeedbackDialog.showSuccess(
                                      context,
                                      title: 'Tugas Diperbarui',
                                      message: 'Perubahan judul, deskripsi, dan tenggat waktu tugas berhasil disimpan.',
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(getTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Manajemen Tugas',
      ),
      body: tasksAsync.when(
        data: (allRawTasks) {
          final now = DateTime.now();

          // Filter Waktu (Tahun & Bulan)
          final filteredList = allRawTasks.where((t) {
            final tMap = t is Map ? t : {};
            final dateStr = tMap['due_date']?.toString() ?? tMap['created_at']?.toString() ?? '';
            final parsedDate = DateTime.tryParse(dateStr) ?? now;

            if (_selectedYear != 'Semua Tahun' && parsedDate.year.toString() != _selectedYear) {
              return false;
            }
            if (_selectedMonth != 'Semua Bulan') {
              const allCalendarMonths = [
                'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
              ];
              final calMonthIdx = allCalendarMonths.indexOf(_selectedMonth) + 1;
              if (calMonthIdx > 0 && parsedDate.month != calMonthIdx) {
                return false;
              }
            }
            return true;
          }).toList();

          // Kelompokkan 3 Jenis
          final pendingTasks = filteredList.where((t) => t['is_cangkang'] == true || t['status_category'] == 'PENDING').toList();
          final activeTasks = filteredList.where((t) => t['is_cangkang'] != true && t['status_category'] == 'ACTIVE').toList();
          final completedTasks = filteredList.where((t) => t['is_cangkang'] != true && t['status_category'] == 'COMPLETED').toList();

          final pendingCount = pendingTasks.length;
          final activeCount = activeTasks.length;
          final completedCount = completedTasks.length;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(getTasksProvider);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacing.custom(context, 16),

                // 1. Standarisasi Filter Dropdown Waktu
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  child: AniseTimeFilterDropdowns(
                    selectedMonth: _selectedMonth,
                    selectedYear: _selectedYear,
                    months: _months,
                    years: _years,
                    onMonthChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedMonth = newValue;
                        });
                      }
                    },
                    onYearChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedYear = newValue;
                          if (!_months.contains(_selectedMonth)) {
                            _selectedMonth = 'Semua Bulan';
                          }
                        });
                      }
                    },
                  ),
                ),
                Spacing.custom(context, 16),

                // 2. Standarisasi Card Insight Metrik
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  child: AniseInsightCard(
                    items: [
                      AniseInsightItemData(
                        label: 'Belum Terbit',
                        value: pendingCount.toString(),
                        icon: PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
                        color: const Color(0xFFF59E0B),
                      ),
                      AniseInsightItemData(
                        label: 'Tugas Aktif',
                        value: activeCount.toString(),
                        icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                        color: AppColors.primary,
                      ),
                      AniseInsightItemData(
                        label: 'Selesai',
                        value: completedCount.toString(),
                        icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
                Spacing.custom(context, 16),

                // 3. Standarisasi Filter Jenis (Capsule Tab Bar)
                AniseCapsuleTabBar(
                  controller: _tabController,
                  tabTitles: const ['Belum', 'Aktif', 'Selesai'],
                ),
                Spacing.custom(context, 12),

                // 4. TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Belum Terbit (Card Cangkang Tugas)
                      _buildPendingList(context, pendingTasks),

                      // Tab 2: Tugas Aktif
                      _buildPublishedList(context, activeTasks, isActive: true),

                      // Tab 3: Tugas Selesai
                      _buildPublishedList(context, completedTasks, isActive: false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gagal memuat tugas: $error', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
              SizedBox(height: 8.h(context)),
              ElevatedButton(
                onPressed: () => ref.invalidate(getTasksProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Poin 1d: Tab Belum Terbit (Card Cangkang Tugas)
  Widget _buildPendingList(BuildContext context, List<dynamic> pendingTasks) {
    if (pendingTasks.isEmpty) {
      return const AniseEmptyState(
        title: 'Belum Ada Tugas Dibuat',
        subtitle: 'Ketika Anda menerbitkan jurnal dengan opsi tugas aktif, cangkang tugas akan muncul di sini siap untuk diterbitkan.',
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 8.h(context)),
      itemCount: pendingTasks.length,
      itemBuilder: (context, index) {
        final item = pendingTasks[index] as Map<String, dynamic>;
        final journalId = item['journal_id']?.toString() ?? item['id']?.toString() ?? '';
        final subjectId = item['subject_id']?.toString();
        final subject = item['subject_name']?.toString() ?? 'Mata Pelajaran';
        final className = item['class_name']?.toString() ?? 'Kelas';
        final journalTitle = item['title']?.toString() ?? 'Jurnal Pembelajaran';
        final journalDesc = item['description']?.toString() ?? '';

        return AniseCangkangTugasCard(
          subject: subject,
          className: className,
          journalTitle: journalTitle,
          journalDescription: journalDesc,
          onBuatTugas: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GuruInputTugasScreen(
                  initialJournalId: journalId,
                  initialSubjectId: subjectId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Poin 1e: Tab Tugas Aktif & Tugas Selesai
  Widget _buildPublishedList(BuildContext context, List<dynamic> taskList, {required bool isActive}) {
    if (taskList.isEmpty) {
      return AniseEmptyState(
        title: isActive ? 'Belum Ada Tugas Aktif' : 'Belum Ada Tugas Selesai',
        subtitle: isActive
            ? 'Buat tugas dari tab "Belum" untuk membagikannya ke siswa.'
            : 'Tugas yang telah melewati batas waktu pengumpulan akan tampil di sini.',
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 8.h(context)),
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        final item = taskList[index] as Map<String, dynamic>;
        return _buildActiveTaskCard(context, item, isActive);
      },
    );
  }

  /// Poin 1e: Card Tugas Terbit (Aktif & Selesai)
  Widget _buildActiveTaskCard(BuildContext context, Map<String, dynamic> data, bool isActive) {
    final taskId = data['id']?.toString() ?? '';
    final title = data['title']?.toString() ?? 'Tugas';
    final description = data['description']?.toString() ?? '';
    final subject = data['subject_name']?.toString() ?? 'Mata Pelajaran';
    final className = data['class_name']?.toString() ?? 'Kelas';
    final dueDateFormatted = data['due_date_formatted']?.toString() ?? data['due_date']?.toString() ?? '-';
    final isPublisher = data['is_publisher'] == true;
    
    final submitted = (data['submitted_count'] ?? 0) as int;
    final graded = (data['graded_count'] ?? 0) as int;
    final total = (data['total_students'] ?? 0) as int;

    return AniseGuruTaskCard(
      taskId: taskId,
      subject: subject,
      className: className,
      title: title,
      description: description,
      dueDateFormatted: dueDateFormatted,
      submittedCount: submitted,
      gradedCount: graded,
      totalStudents: total,
      isActive: isActive,
      isPublisher: isPublisher,
      onEdit: () => _showEditTaskModal(context, data),
      onDelete: () => _showDeleteConfirmDialog(context, taskId, title),
      onPenilaian: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuruTugasPenilaianScreen(
              taskId: taskId,
              title: title,
              subject: subject,
              className: className,
            ),
          ),
        );
      },
    );
  }
}
