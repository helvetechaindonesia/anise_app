import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/leave_provider.dart';

class TuDispensasiScreen extends ConsumerWidget {
  const TuDispensasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dispensasiAsync = ref.watch(dispensasiListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Dispensasi',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ),
      body: dispensasiAsync.when(
        data: (leaves) {
          if (leaves.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.regular), size: 64.w(context), color: AppColors.outline),
                  SizedBox(height: 16.h(context)),
                  Text('Belum ada data dispensasi.', style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(dispensasiListProvider),
            child: ListView.separated(
              padding: EdgeInsets.all(20.w(context)),
              itemCount: leaves.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h(context)),
              itemBuilder: (context, index) {
                final leave = leaves[index];
                final studentName = leave['student']?['full_name'] ?? 'Siswa Tidak Diketahui';
                return _buildLeaveCard(context, leave, studentName);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, dynamic leave, String studentName) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  studentName,
                  style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                decoration: BoxDecoration(
                  color: leave['status'] == 'APPROVED' ? AppColors.secondary.withValues(alpha: 0.2) 
                       : leave['status'] == 'REJECTED' ? AppColors.error.withValues(alpha: 0.1)
                       : AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.w(context)),
                ),
                child: Text(
                  leave['status'],
                  style: AppTextStyles.labelSmall(context, color: leave['status'] == 'APPROVED' ? AppColors.secondary 
                       : leave['status'] == 'REJECTED' ? AppColors.error 
                       : AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          Row(
            children: [
              Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular), color: AppColors.primary, size: 18.w(context)),
              SizedBox(width: 8.w(context)),
              Text('${leave['start_date']} s/d ${leave['end_date']}', style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)),
            ],
          ),
          SizedBox(height: 8.h(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIcons.info(PhosphorIconsStyle.regular), color: AppColors.primary, size: 18.w(context)),
              SizedBox(width: 8.w(context)),
              Expanded(
                child: Text(
                  leave['reason'],
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
