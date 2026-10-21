import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/widgets/anise_app_bar.dart';
import 'package:frontend/core/widgets/anise_empty_state.dart';
import '../../../providers/notification_provider.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Polling setiap 4 detik saat halaman notifikasi sedang dibuka
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        ref.invalidate(notificationsListProvider);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Jika string tidak memiliki offset/Z (misal: "2026-10-21 19:40:00" dari MySQL/Postgres),
      // anggap sebagai UTC agar saat toLocal() dikonversi ke waktu perangkat lokal dengan tepat
      String normalized = dateStr.trim();
      if (!normalized.contains('Z') && !normalized.contains('+') && !RegExp(r'-\d{2}:\d{2}$').hasMatch(normalized)) {
        normalized = '${normalized.replaceFirst(' ', 'T')}Z';
      }
      return DateTime.parse(normalized).toLocal();
    } catch (_) {
      try {
        return DateTime.parse(dateStr).toLocal();
      } catch (_) {
        return null;
      }
    }
  }

  String _formatRelativeTime(DateTime? dt, String fallback) {
    if (dt == null) return fallback.isNotEmpty ? fallback : 'Baru saja';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.isNegative || diff.inSeconds < 45) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return '$mins menit lalu';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours jam lalu';
    } else if (diff.inDays < 7) {
      final days = diff.inDays;
      return '$days hari lalu';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  List<Map<String, dynamic>> _processNotifications(List<dynamic> rawData) {
    int serverIndex = 0;
    final mapped = rawData.map((item) {
      final id = item['id']?.toString() ?? '';
      final title = item['title']?.toString() ?? 'Pemberitahuan';
      final message = item['message']?.toString() ?? '';
      final isRead = item['is_read'] == true || item['is_read'] == 1 || item['is_read'] == '1';
      final createdAt = item['created_at']?.toString() ?? '';
      final dt = _parseDateTime(createdAt);
      final timeStr = _formatRelativeTime(dt, createdAt);

      String cleanMessage = message;
      Map<String, dynamic> extraData = {};
      if (message.contains('<!--DATA:') && message.contains('-->')) {
        try {
          final startIdx = message.indexOf('<!--DATA:') + 9;
          final endIdx = message.indexOf('-->', startIdx);
          final jsonStr = message.substring(startIdx, endIdx);
          extraData = jsonDecode(jsonStr) as Map<String, dynamic>;
          cleanMessage = message.substring(0, message.indexOf('<!--DATA:')).trim();
        } catch (_) {}
      }

      String type = extraData['type']?.toString() ?? 'info';
      if (type == 'info') {
        if (title.contains('⚠️') || title.toLowerCase().contains('ditolak') || title.toLowerCase().contains('peringatan')) {
          type = 'warning';
        } else if (title.toLowerCase().contains('tugas')) {
          type = 'task';
        } else if (title.toLowerCase().contains('berhasil') || title.toLowerCase().contains('validasi')) {
          type = 'habit';
        }
      }

      final currentIndex = serverIndex++;
      return {
        'id': id,
        'title': title,
        'body': cleanMessage,
        'time': timeStr,
        'type': type,
        'isRead': isRead,
        'data': extraData,
        'raw_created_at': createdAt,
        'parsed_date': dt,
      };
    }).toList();

    return mapped;
  }

  Future<void> _markAsRead(String id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/notifications/$id/read');
      ref.invalidate(notificationsListProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Notifikasi',
      ),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat notifikasi: $err', style: AppTextStyles.bodySmall(context)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(notificationsListProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (rawData) {
          final notifications = _processNotifications(rawData);

          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationsListProvider);
                await ref.read(notificationsListProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  AniseEmptyState(
                    title: 'Belum Ada Notifikasi',
                    subtitle: 'Pemberitahuan terkait akun dan aktivitas akan muncul di sini.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsListProvider);
              await ref.read(notificationsListProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 1,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              itemBuilder: (context, index) {
                final notif = notifications[index];

                IconData notifIcon;
                Color iconColor = AppColors.onSecondary;
                Color bgColor = AppColors.secondary;

                switch (notif['type']) {
                  case 'task':
                    notifIcon = PhosphorIcons.clipboardText(PhosphorIconsStyle.fill);
                    break;
                  case 'habit':
                    notifIcon = PhosphorIcons.heart(PhosphorIconsStyle.fill);
                    break;
                  case 'warning':
                    notifIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
                    bgColor = AppColors.error.withValues(alpha: 0.15);
                    iconColor = AppColors.error;
                    break;
                  default:
                    notifIcon = PhosphorIcons.info(PhosphorIconsStyle.fill);
                }

                return GestureDetector(
                  onTap: () async {
                    final notifId = notif['id']?.toString() ?? '';
                    if (notif['isRead'] != true && notifId.isNotEmpty) {
                      _markAsRead(notifId);
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailScreen(notification: notif),
                      ),
                    );
                    if (mounted) {
                      ref.invalidate(notificationsListProvider);
                    }
                  },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(notifIcon, color: iconColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif['title'],
                                            style: AppTextStyles.bodyMedium(
                                              context,
                                              color: AppColors.onBackground,
                                            ).copyWith(
                                              fontWeight: notif['isRead'] == false
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (!notif['isRead'])
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notif['body'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium(
                                        context,
                                        color: AppColors.onBackground.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      notif['time'],
                                      style: AppTextStyles.labelMedium(
                                        context,
                                        color: AppColors.onBackground.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
