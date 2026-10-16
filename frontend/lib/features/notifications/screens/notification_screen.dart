import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/widgets/anise_app_bar.dart';
import 'package:frontend/core/widgets/anise_empty_state.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/notifications');
      
      final rawData = response.data['data'] as List<dynamic>? ?? [];
      
      final mapped = rawData.map((item) {
        final id = item['id']?.toString() ?? '';
        final title = item['title']?.toString() ?? 'Pemberitahuan';
        final message = item['message']?.toString() ?? '';
        final isRead = item['is_read'] == true;
        final createdAt = item['created_at']?.toString() ?? '';

        String timeStr = 'Baru saja';
        if (createdAt.isNotEmpty) {
          try {
            final dt = DateTime.parse(createdAt).toLocal();
            final now = DateTime.now();
            final diff = now.difference(dt);
            if (diff.inMinutes < 60) {
              timeStr = '${diff.inMinutes > 0 ? diff.inMinutes : 1} menit lalu';
            } else if (diff.inHours < 24) {
              timeStr = '${diff.inHours} jam lalu';
            } else if (diff.inDays < 7) {
              timeStr = '${diff.inDays} hari lalu';
            } else {
              timeStr = '${dt.day}/${dt.month}/${dt.year}';
            }
          } catch (_) {
            timeStr = createdAt;
          }
        }

        String type = 'info';
        if (title.contains('⚠️') || title.toLowerCase().contains('ditolak') || title.toLowerCase().contains('peringatan')) {
          type = 'warning';
        } else if (title.toLowerCase().contains('tugas')) {
          type = 'task';
        } else if (title.toLowerCase().contains('berhasil') || title.toLowerCase().contains('validasi')) {
          type = 'habit';
        }

        return {
          'id': id,
          'title': title,
          'body': message,
          'time': timeStr,
          'type': type,
          'isRead': isRead,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _notifications = mapped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/notifications/$id/read');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Notifikasi',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? RefreshIndicator(
                  onRefresh: _fetchNotifications,
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
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 1,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];

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
                        onTap: () {
                          if (notif['isRead'] == false && (notif['id'] as String).isNotEmpty) {
                            setState(() {
                              notif['isRead'] = true;
                            });
                            _markAsRead(notif['id'] as String);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationDetailScreen(notification: notif),
                            ),
                          );
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
                ),
    );
  }
}
