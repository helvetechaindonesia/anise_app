import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/agenda_penilaian_provider.dart';

import 'guru_input_agenda_screen.dart';
import '../widgets/agenda_featured_card_widget.dart';
import '../widgets/agenda_bottom_banner_widget.dart';

class GuruAgendaPenilaianScreen extends ConsumerStatefulWidget {
  const GuruAgendaPenilaianScreen({super.key});

  @override
  ConsumerState<GuruAgendaPenilaianScreen> createState() => _GuruAgendaPenilaianScreenState();
}

class _GuruAgendaPenilaianScreenState extends ConsumerState<GuruAgendaPenilaianScreen> {
  String _selectedFilter = 'Semua Kategori';
  final List<String> _filters = ['Semua Kategori', 'Formatif', 'STS (Tengah)', 'SAS (Akhir)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h(context)),
                    _buildDropdownFilter(context),
                    SizedBox(height: 24.h(context)),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular), color: AppColors.onBackground.withValues(alpha: 0.2), size: 64.w(context)),
                    SizedBox(height: 16.h(context)),
                    Text(
                      'Tidak Ada Agenda Penilaian Terdekat',
                      style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Agenda Penilaian',
        style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GuruInputAgendaScreen()),
            );
          },
          icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        ),
        SizedBox(width: 8.w(context)),
      ],
    );
  }

  Widget _buildDropdownFilter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
              });
            }
          },
          items: _filters.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAgendaListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Jadwal Lengkap & Penugasan',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        Text(
          '3 Agenda\nAktif',
          textAlign: TextAlign.right,
          style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildAgendaCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.w(context)),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16.w(context)),
                ),
                child: Icon(data['icon'] as IconData, color: AppColors.onPrimaryContainer, size: 24.w(context)),
              ),
              SizedBox(width: 16.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['label'] as String,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      data['title'] as String,
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: data['type'] == 'SAS' ? AppColors.secondary : AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Bobot\n${data['weight']}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall(context, color: data['type'] == 'SAS' ? AppColors.onSecondary : AppColors.onPrimary),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h(context)),
          Container(
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16.w(context)),
            ),
            child: Column(
              children: [
                _buildAgendaInfoRow(context, PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill), data['date'] as String),
                SizedBox(height: 10.h(context)),
                _buildAgendaInfoRow(context, data['type'] == 'SAS' || data['type'] == 'STS' ? PhosphorIcons.bookOpen(PhosphorIconsStyle.fill) : PhosphorIcons.usersThree(PhosphorIconsStyle.fill), data['type'] == 'SAS' || data['type'] == 'STS' ? (data['subtitle'] as String) : 'Kelas: XII IPS 1'),
              ],
            ),
          ),
          SizedBox(height: 16.h(context)),
          if (data['type'] == 'SAS' || data['type'] == 'STS')
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h(context)),
              decoration: BoxDecoration(
                color: AppColors.menuPastelRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.w(context)),
                border: Border.all(color: AppColors.menuPastelRed.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.bold), color: AppColors.menuPastelRed, size: 16.w(context)),
                  SizedBox(width: 8.w(context)),
                  Text(
                    'Dijadwalkan oleh Kurikulum',
                    style: AppTextStyles.labelMedium(context, color: AppColors.menuPastelRed, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 16.w(context)),
                        SizedBox(width: 8.w(context)),
                        Text(
                          'Edit Agenda',
                          style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Container(
                  padding: EdgeInsets.all(12.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.menuPastelRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), color: AppColors.menuPastelRed, size: 18.w(context)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAgendaInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.onSurface, size: 16.w(context)),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}



