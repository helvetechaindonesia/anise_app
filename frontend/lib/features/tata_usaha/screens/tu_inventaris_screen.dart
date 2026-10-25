import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../lapor/models/complaint_model.dart';
import '../../lapor/providers/report_provider.dart';
import '../widgets/complaint_detail_modal.dart';

class TuInventarisScreen extends ConsumerStatefulWidget {
  const TuInventarisScreen({super.key});

  @override
  ConsumerState<TuInventarisScreen> createState() => _TuInventarisScreenState();
}

class _TuInventarisScreenState extends ConsumerState<TuInventarisScreen> {
  String? _selectedStatus; // null = Semua status
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ComplaintFilter _buildFilter() {
    return ComplaintFilter(
      categories: ['FASILITAS'],
      status: _selectedStatus,
      search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = _buildFilter();
    final complaintsAsync = ref.watch(complaintsProvider(filter));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(complaintsProvider(filter));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              const AniseSliverAppBar(title: 'Laporan Kerusakan Fasilitas'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w(context), 12.h(context), 20.w(context), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context),
                      SizedBox(height: 12.h(context)),
                      _buildStatusFilter(context),
                      SizedBox(height: 12.h(context)),
                    ],
                  ),
                ),
              ),
              complaintsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, st) => SliverFillRemaining(
                  child: AniseEmptyState(
                    title: 'Gagal Memuat Laporan',
                    subtitle: e.toString().replaceAll('Exception: ', ''),
                  ),
                ),
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return const SliverFillRemaining(
                      child: AniseEmptyState(
                        title: 'Belum Ada Laporan Fasilitas',
                        subtitle: 'Belum ada aduan terkait kerusakan fasilitas atau sarana prasarana sekolah.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 8.h(context)),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final complaint = complaints[index];
                          return _buildFacilityCard(context, complaint, filter);
                        },
                        childCount: complaints.length,
                      ),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: 32.h(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari laporan fasilitas atau ruangan...',
          hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
              color: AppColors.onBackground.withValues(alpha: 0.5)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    final statuses = [
      {'key': null, 'label': 'Semua Status'},
      {'key': 'PENDING', 'label': 'Menunggu'},
      {'key': 'IN_PROGRESS', 'label': 'Diproses'},
      {'key': 'RESOLVED', 'label': 'Selesai'},
      {'key': 'REJECTED', 'label': 'Ditolak'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((st) {
          final isSelected = _selectedStatus == st['key'];
          return Padding(
            padding: EdgeInsets.only(right: 8.w(context)),
            child: FilterChip(
              label: Text(st['label'] as String),
              selected: isSelected,
              selectedColor: AppColors.secondary.withValues(alpha: 0.4),
              backgroundColor: AppColors.surface,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.onSurface.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? st['key'] : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFacilityCard(BuildContext context, ComplaintModel complaint, ComplaintFilter filter) {
    final dateStr = complaint.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(complaint.createdAt!)
        : '-';

    return GestureDetector(
      onTap: () {
        ComplaintDetailModal.show(
          context,
          complaint,
          onUpdated: () => ref.invalidate(complaintsProvider(filter)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h(context)),
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or thumbnail image
            if (complaint.fullAttachmentUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.w(context)),
                child: Image.network(
                  complaint.fullAttachmentUrl!,
                  width: 60.w(context),
                  height: 60.w(context),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 60.w(context),
                    height: 60.w(context),
                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                    child: Icon(PhosphorIcons.buildings(PhosphorIconsStyle.bold),
                        color: const Color(0xFFD97706), size: 28.w(context)),
                  ),
                ),
              )
            else
              Container(
                width: 60.w(context),
                height: 60.w(context),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
                child: Icon(PhosphorIcons.wrench(PhosphorIconsStyle.bold),
                    color: const Color(0xFFD97706), size: 28.w(context)),
              ),
            SizedBox(width: 14.w(context)),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 3.h(context)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.w(context)),
                        ),
                        child: Text(
                          'Fasilitas',
                          style: AppTextStyles.labelSmall(context, color: const Color(0xFFD97706))
                              .copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 3.h(context)),
                        decoration: BoxDecoration(
                          color: complaint.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.w(context)),
                        ),
                        child: Text(
                          complaint.statusLabel,
                          style: AppTextStyles.labelSmall(context, color: complaint.statusColor)
                              .copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h(context)),
                  Text(
                    complaint.title,
                    style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    complaint.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 8.h(context)),
                  Row(
                    children: [
                      Icon(
                        complaint.isAnonymous
                            ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold)
                            : PhosphorIcons.user(PhosphorIconsStyle.bold),
                        color: complaint.isAnonymous ? AppColors.warning : AppColors.onSurfaceVariant,
                        size: 14.w(context),
                      ),
                      SizedBox(width: 4.w(context)),
                      Expanded(
                        child: Text(
                          complaint.isAnonymous ? 'Anonim' : (complaint.userName ?? 'Siswa'),
                          style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (complaint.responseNote != null && complaint.responseNote!.trim().isNotEmpty) ...[
                    SizedBox(height: 8.h(context)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(6.w(context)),
                        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        'Tanggapan: ${complaint.responseNote}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
