import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';
import '../../features/notifications/screens/notification_screen.dart';

enum AniseFeedbackType { success, error, warning, confirm }

/// Komponen terstandarisasi untuk seluruh popup umpan balik (Feedback Dialog / Modal):
/// Berhasil, Gagal, Ditolak / Peringatan, dan Konfirmasi Aksi.
class AniseFeedbackDialog extends StatelessWidget {
  final AniseFeedbackType type;
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? customActionText;
  final VoidCallback? onCustomAction;
  final IconData? customIcon;
  final bool isDestructive;

  const AniseFeedbackDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.confirmText = 'Tutup',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.customActionText,
    this.onCustomAction,
    this.customIcon,
    this.isDestructive = false,
  });

  /// 1. Dialog Berhasil
  static Future<void> showSuccess(
    BuildContext context, {
    String title = 'Berhasil',
    required String message,
    String buttonText = 'Tutup',
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AniseFeedbackDialog(
        type: AniseFeedbackType.success,
        title: title,
        message: message,
        confirmText: buttonText,
        onConfirm: () {
          Navigator.pop(ctx);
          if (onConfirm != null) onConfirm();
        },
      ),
    );
  }

  /// 2. Dialog Gagal / Kesalahan
  static Future<void> showError(
    BuildContext context, {
    String title = 'Gagal',
    required String message,
    String buttonText = 'Tutup',
    VoidCallback? onConfirm,
  }) {
    final hasNotifWord = message.toLowerCase().contains('notifikasi');

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AniseFeedbackDialog(
        type: AniseFeedbackType.error,
        title: title,
        message: message,
        confirmText: buttonText,
        onConfirm: () {
          Navigator.pop(ctx);
          if (onConfirm != null) onConfirm();
        },
        customActionText: hasNotifWord ? 'Buka Notif' : null,
        onCustomAction: hasNotifWord
            ? () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              }
            : null,
      ),
    );
  }

  /// 3. Dialog Peringatan / Berkas Ditolak
  static Future<void> showWarning(
    BuildContext context, {
    String title = 'Berkas Ditolak',
    required String message,
    String buttonText = 'Tutup',
    String? actionText,
    VoidCallback? onAction,
    VoidCallback? onConfirm,
  }) {
    final hasNotifWord = message.toLowerCase().contains('notifikasi');
    final effectiveActionText = actionText ?? (hasNotifWord ? 'Buka Notif' : null);

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AniseFeedbackDialog(
        type: AniseFeedbackType.warning,
        title: title,
        message: message,
        confirmText: buttonText,
        onConfirm: () {
          Navigator.pop(ctx);
          if (onConfirm != null) onConfirm();
        },
        customActionText: effectiveActionText,
        onCustomAction: () {
          Navigator.pop(ctx);
          if (onAction != null) {
            onAction();
          } else if (hasNotifWord) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          }
        },
      ),
    );
  }

  /// 4. Dialog Konfirmasi Aksi (misal Hapus / Bekukan)
  static Future<bool?> showConfirm(
    BuildContext context, {
    String title = 'Konfirmasi Tindakan',
    required String message,
    String confirmText = 'Ya, Lanjutkan',
    String cancelText = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AniseFeedbackDialog(
        type: AniseFeedbackType.confirm,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
  }

  static bool _isSessionDialogShowing = false;

  /// 5. Dialog Sesi Tidak Berlaku / Dibekukan / Dihapus / Kredensial Berubah
  /// Dialog ini WAJIB tidak dapat di-close lewat tap latar maupun back gesture (PopScope canPop: false).
  /// Hanya ada SATU tombol aksi (misal "Log Out" atau "Login").
  static Future<void> showSessionExpired(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onAction,
    AniseFeedbackType type = AniseFeedbackType.error,
  }) async {
    if (_isSessionDialogShowing) return;
    _isSessionDialogShowing = true;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AniseFeedbackDialog(
          type: type,
          title: title,
          message: message,
          confirmText: buttonText,
          onConfirm: () {
            _isSessionDialogShowing = false;
            Navigator.pop(ctx);
            onAction();
          },
        ),
      ),
    ).then((_) {
      _isSessionDialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    Color circleBgColor;

    switch (type) {
      case AniseFeedbackType.success:
        iconData = customIcon ?? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
        iconColor = AppColors.success;
        circleBgColor = AppColors.success.withValues(alpha: 0.12);
        break;
      case AniseFeedbackType.error:
        iconData = customIcon ?? PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
        iconColor = AppColors.error;
        circleBgColor = AppColors.error.withValues(alpha: 0.12);
        break;
      case AniseFeedbackType.warning:
        iconData = customIcon ?? PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
        iconColor = AppColors.warning;
        circleBgColor = AppColors.warning.withValues(alpha: 0.15);
        break;
      case AniseFeedbackType.confirm:
        iconData = customIcon ?? (isDestructive
            ? PhosphorIcons.trash(PhosphorIconsStyle.fill)
            : PhosphorIcons.question(PhosphorIconsStyle.fill));
        iconColor = isDestructive ? AppColors.error : AppColors.primary;
        circleBgColor = (isDestructive ? AppColors.error : AppColors.primary).withValues(alpha: 0.12);
        break;
    }

    final bool hasTwoButtons = cancelText != null || customActionText != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w(context)),
      ),
      backgroundColor: AppColors.surface,
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Badge Lingkaran
            Container(
              width: 56.w(context),
              height: 56.w(context),
              decoration: BoxDecoration(
                color: circleBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(iconData, color: iconColor, size: 32.w(context)),
              ),
            ),
            SizedBox(height: 16.h(context)),

            // Judul
            Text(
              title,
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h(context)),

            // Deskripsi Pesan
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 280.h(context)),
              child: SingleChildScrollView(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.85)),
                  textAlign: message.contains('\n') ? TextAlign.left : TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 24.h(context)),

            // Tombol Aksi
            if (!hasTwoButtons) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == AniseFeedbackType.error
                        ? AppColors.error
                        : (type == AniseFeedbackType.warning ? AppColors.warning : AppColors.primary),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                  ),
                  child: Text(
                    confirmText,
                    style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  // Tombol Kiri (Outlined / Batal / Tutup)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel ?? onConfirm ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w(context)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                      ),
                      child: Text(
                        cancelText ?? confirmText,
                        style: AppTextStyles.labelLarge(context, color: AppColors.onSurface),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w(context)),
                  // Tombol Kanan (Primary / Custom Action)
                  Expanded(
                    child: customActionText != null && customActionText!.toLowerCase().contains('notif')
                        ? ElevatedButton.icon(
                            onPressed: onCustomAction ?? onConfirm ?? () => Navigator.pop(context),
                            icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.onPrimary),
                            label: Text(
                              customActionText ?? confirmText,
                              style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.w(context)),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: onCustomAction ?? onConfirm ?? () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.w(context)),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                            ),
                            child: Text(
                              customActionText ?? confirmText,
                              style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
