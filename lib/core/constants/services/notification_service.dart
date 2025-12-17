import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. Init: Hanya setup konfigurasi, JANGAN minta izin di sini agar tidak blocking
  static Future<void> init() async {
    try {
      tz_data.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Setup untuk iOS (opsional, untuk mencegah error di iOS)
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (kDebugMode) {
            print('Notifikasi diklik: ${details.payload}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) print("Gagal init notifikasi: $e");
    }
  }

  // 2. Request Permission: Panggil ini dari UI (HomeScreen)
  static Future<void> requestPermissions() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      if (kDebugMode) print("Gagal meminta izin: $e");
    }
  }

  // 3. Show Notification: Dengan pengaman try-catch
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id_petani_alert', // ID Channel harus unik
        'Peringatan Cuaca', // Nama Channel
        channelDescription: 'Notifikasi darurat cuaca untuk petani',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Peringatan Cuaca',
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
      );
    } catch (e) {
      if (kDebugMode) print("Gagal menampilkan notifikasi: $e");
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id_petani_schedule',
            'Jadwal Tanam',
            channelDescription: 'Notifikasi jadwal bertani',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) print("Gagal menjadwalkan notifikasi: $e");
    }
  }
}
