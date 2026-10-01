import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../auth/models/user_model.dart';
import 'dart:ui';
import '../../../core/theme/app_text_styles.dart';
class DigitalIdCard extends StatelessWidget {
  final UserModel user;

  const DigitalIdCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isGuru = user.role == UserRole.pengajar || user.role == UserRole.bk;
    bool isSiswa = user.role == UserRole.siswa;
    final roleDisplay = isGuru ? 'Tenaga Pendidik' : (isSiswa ? 'Peserta Didik' : 'Administrator');
    final idNumber = isGuru ? 'NIP. 198001012010011001' : (isSiswa ? 'NISN. 0012345678' : 'ID. 000001');

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.5),
                AppColors.primary.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: AppTextStyles.titleLarge(context, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleDisplay,
                        style: AppTextStyles.bodyMedium(context, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        idNumber,
                        style: AppTextStyles.labelMedium(context, color: AppColors.primary),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), size: 40, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Status Kehadiran
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.bold), color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Hadir - Tepat Waktu',
                      style: AppTextStyles.labelMedium(context, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

