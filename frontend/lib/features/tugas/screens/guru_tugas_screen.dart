import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/api_constants.dart';
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

  void _showDeleteConfirmDialog(BuildContext context, String taskId, String taskTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w(context))),
        title: Text('Hapus Tugas', style: AppTextStyles.titleMedium(context, color: AppColors.error)),
        content: Text(
          'Apakah Anda yakin ingin menghapus tugas "$taskTitle"? Data pengumpulan dan nilai siswa yang berkaitan juga akan terhapus.',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppTextStyles.labelLarge(context, color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(tugasProvider.notifier).deleteTugas(taskId: taskId);
              if (success && mounted) {
                ref.invalidate(getTasksProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tugas berhasil dihapus!'), backgroundColor: AppColors.secondary),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal menghapus tugas.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Tugas berhasil diperbarui!'), backgroundColor: AppColors.secondary),
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manajemen Tugas',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
        // Poin 2: Hapus tanda plus di pojok kanan atas halaman penugasan
        actions: const [],
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

                // 1. Filter Dropdown Waktu
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 2.h(context)),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.w(context)),
                            border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedMonth,
                              isExpanded: true,
                              icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
                              dropdownColor: AppColors.surface,
                              style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedMonth = newValue;
                                  });
                                }
                              },
                              items: _months.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 2.h(context)),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.w(context)),
                            border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedYear,
                              isExpanded: true,
                              icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
                              dropdownColor: AppColors.surface,
                              style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedYear = newValue;
                                    if (!_months.contains(_selectedMonth)) {
                                      _selectedMonth = 'Semua Bulan';
                                    }
                                  });
                                }
                              },
                              items: _years.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacing.custom(context, 16),

                // 2. Poin 4: Card Insight Statistik
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  child: _buildInsightCard(
                    context,
                    pendingCount: pendingCount,
                    activeCount: activeCount,
                    completedCount: completedCount,
                  ),
                ),
                Spacing.custom(context, 16),

                // 3. Poin 3: Filter Tab Bar (3 Tab)
                _buildTabBar(
                  context,
                  pendingCount: pendingCount,
                  activeCount: activeCount,
                  completedCount: completedCount,
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

  /// Poin 4: Widget Card Insight di bawah dropdown waktu dan di atas tab filter
  Widget _buildInsightCard(
    BuildContext context, {
    required int pendingCount,
    required int activeCount,
    required int completedCount,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInsightItem(
            context,
            count: pendingCount,
            label: 'Belum Terbit',
            icon: PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
            color: const Color(0xFFF59E0B), // Amber / Oranye
          ),
          Container(width: 1, height: 32.h(context), color: AppColors.outline.withValues(alpha: 0.15)),
          _buildInsightItem(
            context,
            count: activeCount,
            label: 'Tugas Aktif',
            icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
            color: AppColors.primary,
          ),
          Container(width: 1, height: 32.h(context), color: AppColors.outline.withValues(alpha: 0.15)),
          _buildInsightItem(
            context,
            count: completedCount,
            label: 'Selesai',
            icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context, {
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16.w(context)),
            SizedBox(width: 6.w(context)),
            Text(
              '$count',
              style: AppTextStyles.titleLarge(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        SizedBox(height: 2.h(context)),
        Text(
          label,
          style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Poin 3: TabBar 3 Jenis (Belum Terbit, Tugas Aktif, Tugas Selesai)
  Widget _buildTabBar(
    BuildContext context, {
    required int pendingCount,
    required int activeCount,
    required int completedCount,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
      child: Container(
        height: 44.h(context),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.onSurface,
            borderRadius: BorderRadius.circular(100),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.surface,
          unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.6),
          labelStyle: AppTextStyles.labelMedium(context).copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.labelMedium(context),
          tabs: const [
            Tab(text: 'Belum'),
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
    );
  }

  /// Poin 1d: Tab Belum Terbit (Card Cangkang Tugas)
  Widget _buildPendingList(BuildContext context, List<dynamic> pendingTasks) {
    if (pendingTasks.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.checkSquareOffset(PhosphorIconsStyle.fill), color: AppColors.onSurfaceVariant.withValues(alpha: 0.25), size: 56.w(context)),
              SizedBox(height: 14.h(context)),
              Text(
                'Tidak ada tugas yang menunggu dibuat',
                style: AppTextStyles.titleMedium(context, color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: 6.h(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w(context)),
                child: Text(
                  'Ketika Anda menerbitkan jurnal dengan toggle "Ada Tugas" aktif, cangkang tugas akan muncul di sini siap untuk diterbitkan.',
                  style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 8.h(context)),
      itemCount: pendingTasks.length,
      itemBuilder: (context, index) {
        final item = pendingTasks[index] as Map<String, dynamic>;
        return _buildCangkangTugasCard(context, item);
      },
    );
  }

  /// Poin 1d: Card Cangkang Tugas
  Widget _buildCangkangTugasCard(BuildContext context, Map<String, dynamic> data) {
    final journalId = data['journal_id']?.toString() ?? data['id']?.toString() ?? '';
    final subjectId = data['subject_id']?.toString();
    final subject = data['subject_name']?.toString() ?? 'Mata Pelajaran';
    final className = data['class_name']?.toString() ?? 'Kelas';
    final journalTitle = data['title']?.toString() ?? 'Jurnal Pembelajaran';
    final journalDesc = data['description']?.toString() ?? '';

    // Efek border kuning tua menyala untuk belum terbit / cangkang
    final cardBorderColor = const Color(0xFFF59E0B);
    final cardShadow = [
      BoxShadow(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        blurRadius: 10,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: cardBorderColor, width: 1.5),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Mata Pelajaran
          Text(
            subject,
            style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h(context)),

          // 2. Kelas (tepat di bawah mata pelajaran)
          Text(
            className,
            style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // Kasih jarak
          SizedBox(height: 12.h(context)),

          // 3. Judul Jurnal
          Text(
            journalTitle,
            style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          // 4. Deskripsi Jurnal
          if (journalDesc.isNotEmpty) ...[
            SizedBox(height: 4.h(context)),
            Text(
              journalDesc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
            ),
          ],

          SizedBox(height: 16.h(context)),

          // 5. Tombol Buat Tugas
          SizedBox(
            width: double.infinity,
            height: 42.h(context),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
              ),
              onPressed: () {
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
              icon: Icon(PhosphorIcons.plusCircle(PhosphorIconsStyle.bold), size: 18.w(context)),
              label: Text(
                'Buat Tugas',
                style: AppTextStyles.labelLarge(context).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Poin 1e: Tab Tugas Aktif & Tugas Selesai
  Widget _buildPublishedList(BuildContext context, List<dynamic> taskList, {required bool isActive}) {
    if (taskList.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.clipboardText(PhosphorIconsStyle.fill), color: AppColors.onSurfaceVariant.withValues(alpha: 0.25), size: 56.w(context)),
              SizedBox(height: 14.h(context)),
              Text(
                isActive ? 'Tidak ada tugas aktif' : 'Tidak ada tugas selesai',
                style: AppTextStyles.titleMedium(context, color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: 6.h(context)),
              Text(
                isActive
                    ? 'Buat tugas dari tab "Belum" untuk membagikannya ke siswa.'
                    : 'Tugas yang telah melewati batas waktu pengumpulan akan tampil di sini.',
                style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
    
    final submitted = (data['submitted_count'] ?? 0) as int;
    final graded = (data['graded_count'] ?? 0) as int;
    final total = (data['total_students'] ?? 0) as int;
    final progress = total > 0 ? (submitted / total).clamp(0.0, 1.0) : 0.0;

    // Warna & efek border menyala sesuai status
    final Color cardBorderColor;
    final List<BoxShadow> cardShadow;

    if (isActive) {
      // Hijau agak menyala untuk aktif
      cardBorderColor = const Color(0xFF10B981);
      cardShadow = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      // Abu-abu / hitam muda untuk selesai
      cardBorderColor = AppColors.outlineVariant;
      cardShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: cardBorderColor, width: isActive ? 1.5 : 1.0),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris 1: Mata Pelajaran & Hamburger Menu (titik tiga)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                  color: AppColors.onSurfaceVariant,
                  size: 22.w(context),
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditTaskModal(context, data);
                  } else if (val == 'delete') {
                    _showDeleteConfirmDialog(context, taskId, title);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.onSurface),
                        SizedBox(width: 8.w(context)),
                        const Text('Edit Tugas'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.error),
                        SizedBox(width: 8.w(context)),
                        Text('Hapus Tugas', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Header Baris 2: Kelas (tepat di bawah mata pelajaran)
          Text(
            className,
            style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // Kasih jarak
          SizedBox(height: 12.h(context)),

          // 3. Judul Tugas (Bukan judul jurnal)
          Text(
            title,
            style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          // 4. Keterangan Tugas (tidak perlu full, maxLines 2)
          if (description.isNotEmpty) ...[
            SizedBox(height: 4.h(context)),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
            ),
          ],

          SizedBox(height: 8.h(context)),
          Row(
            children: [
              Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular), size: 14.w(context), color: AppColors.onSurfaceVariant),
              SizedBox(width: 4.w(context)),
              Text(
                'Tenggat: $dueDateFormatted',
                style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),

          Spacing.custom(context, 12),

          // Progress Pengumpulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengumpulan Siswa',
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant),
              ),
              Row(
                children: [
                  Text(
                    '$submitted / $total Siswa',
                    style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (submitted > 0) ...[
                    Text(' • ', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    Text(
                      '$graded Dinilai',
                      style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ]
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.w(context)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h(context),
              backgroundColor: AppColors.backgroundLight,
              valueColor: AlwaysStoppedAnimation<Color>(isActive ? const Color(0xFF10B981) : AppColors.outline),
            ),
          ),
          Spacing.custom(context, 14),

          // 5. Tombol Penilaian
          SizedBox(
            width: double.infinity,
            height: 42.h(context),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
              ),
              onPressed: () {
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
              icon: Icon(PhosphorIcons.checks(PhosphorIconsStyle.bold), size: 18.w(context)),
              label: Text(
                'Penilaian',
                style: AppTextStyles.labelLarge(context).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
