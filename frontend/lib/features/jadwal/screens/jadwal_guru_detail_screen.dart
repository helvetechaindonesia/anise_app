import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/schedule_card.dart';
import '../../notifications/screens/notification_screen.dart';
import '../providers/jurnal_provider.dart';
import 'package:intl/intl.dart';

class JadwalGuruDetailScreen extends ConsumerStatefulWidget {
  final String teacherName;
  final String subject;
  final Color themeColor;
  final String? className;

  const JadwalGuruDetailScreen({
    super.key,
    required this.teacherName,
    required this.subject,
    required this.themeColor,
    this.className,
  });

  @override
  ConsumerState<JadwalGuruDetailScreen> createState() => _JadwalGuruDetailScreenState();
}

class _JadwalGuruDetailScreenState extends ConsumerState<JadwalGuruDetailScreen> {
  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _years = ['2024', '2025', '2026', '2027'];

  String _selectedMonth = 'Oktober';
  String _selectedYear = '2025';

  @override
  Widget build(BuildContext context) {
    final journalsAsync = ref.watch(allJournalsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h(context)),
                  _buildHeader(context),
                  SizedBox(height: 16.h(context)),
                  _buildFilter(context),
                  SizedBox(height: 24.h(context)),
                ],
              ),
            ),
          ),
          journalsAsync.when(
            data: (journals) {
              var filteredJournals = journals.where((j) => j['teacher'] == widget.teacherName).toList();
              
              if (widget.className != null) {
                filteredJournals = filteredJournals.where((j) => j['class_name'] == widget.className).toList();
              }

              if (filteredJournals.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.notebook(PhosphorIconsStyle.fill), color: AppColors.onBackground.withValues(alpha: 0.2), size: 64.w(context)),
                        SizedBox(height: 16.h(context)),
                        Text(
                          'Tidak ada jurnal mengajar',
                          style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                        ),
                        SizedBox(height: 8.h(context)),
                        Text(
                          'Guru belum menerbitkan jurnal untuk kelas ini.',
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == filteredJournals.length) return SizedBox(height: 40.h(context));
                      
                      final journal = filteredJournals[index];
                      final date = DateTime.parse(journal['created_at']);
                      final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);

                      return ScheduleCard(
                        status: ScheduleStatus.selesai,
                        timeRange: dateStr,
                        uploadTime: dateStr,
                        subjectName: journal['subject'],
                        teacherName: journal['teacher'],
                        teacherImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=250&auto=format&fit=crop',
                        teacherRole: 'Guru',
                        description: journal['description'] ?? journal['topic'],
                        hasFileAttachment: journal['has_task'] == true,
                        fileName: journal['has_task'] == true ? 'Ada Tugas' : null,
                        likes: 0,
                        comments: 0,
                      );
                    },
                    childCount: filteredJournals.length + 1,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, s) => SliverFillRemaining(
              child: Center(
                child: Text('Gagal memuat jurnal: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 65.h(context),
      expandedHeight: 65.h(context),
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18.w(context),
            backgroundColor: widget.themeColor.withValues(alpha: 0.2),
            child: Text(
              widget.teacherName.substring(0, 1).toUpperCase(),
              style: AppTextStyles.titleMedium(context, color: widget.themeColor),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.teacherName,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.subject,
                  style: AppTextStyles.labelMedium(context, color: widget.themeColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
          icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        ),
        SizedBox(width: 8.w(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekap Jurnal',
          style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
        ),
        SizedBox(height: 4.h(context)),
        Text(
          'Daftar jurnal mengajar dan materi yang diunggah oleh guru ini.',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
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
                    child: Text('Bulan: $value', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
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
                    });
                  }
                },
                items: _years.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Tahun: $value', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
