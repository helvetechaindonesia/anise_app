import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Inisialisasi awal notifikasi lokal
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          // Ketika notifikasi diketuk, buka berkas langsung via OpenFilex
          try {
            await OpenFilex.open(payload);
          } catch (e) {
            debugPrint('Gagal membuka file dari notifikasi: $e');
          }
        }
      },
    );

    // Request permission di Android 13+ (API 33+)
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  /// Tampilkan Push Notifikasi bahwa file berhasil diunduh
  static Future<void> showDownloadCompleteNotification({
    required String filePath,
    required String fileName,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const androidDetails = AndroidNotificationDetails(
        'download_channel',
        'Unduhan Berkas',
        channelDescription: 'Pemberitahuan berkas yang selesai diunduh',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _notificationsPlugin.show(
        id,
        'Unduhan Selesai',
        '$fileName berhasil disimpan. Ketuk untuk membuka berkas.',
        notificationDetails,
        payload: filePath, // Payload berisi path fisik file untuk dibuka
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }
}
