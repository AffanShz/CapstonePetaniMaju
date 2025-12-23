import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // --- SINGLETON PATTERN (Mencegah LateInitializationError) ---
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inisialisasi Service (Panggil di main.dart)
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Init Timezone Database
      tz_data.initializeTimeZones();

      // Opsional: Set lokasi default jika diperlukan, misal 'Asia/Jakarta'
      // tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      // 2. Android Settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS Settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // 4. Init Plugin
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

      _isInitialized = true;
      if (kDebugMode) print("NotificationService berhasil diinisialisasi");
    } catch (e) {
      if (kDebugMode) print("Gagal init notifikasi: $e");
    }
  }

  /// Meminta Izin (Panggil di Home/Screen awal)
  Future<void> requestPermissions() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      if (kDebugMode) print("Gagal meminta izin: $e");
    }
  }

  /// Menampilkan Notifikasi Langsung (Untuk Alert Cuaca, dsb)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_petani_alert_v2',
        'Peringatan Cuaca',
        channelDescription: 'Notifikasi darurat untuk petani',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Peringatan',
        color: Color(0xFFD32F2F), // Merah
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) print("Gagal showNotification: $e");
    }
  }

  /// Menjadwalkan Notifikasi (Untuk Jadwal Tanam - H-16 Jam & H-8 Jam)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Konversi ke TimeZone Local
      final tz.TZDateTime tzScheduledDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      // Cek apakah waktu sudah lewat? Jika ya, jangan jadwalkan (atau handle khusus)
      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        if (kDebugMode)
          print("Waktu jadwal $title sudah berlalu, skip notifikasi.");
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_jadwal_tanam',
            'Jadwal Tanam',
            channelDescription: 'Pengingat aktivitas pertanian',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      if (kDebugMode) {
        print("Notifikasi sukses dijadwalkan: $title pada $tzScheduledDate");
      }
    } catch (e) {
      if (kDebugMode) print("Gagal menjadwalkan notifikasi: $e");
    }
  }

  /// Membatalkan notifikasi (opsional)
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
