import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();

      final String timeZoneName = _detectLocalTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      if (kDebugMode) print("Timezone set: $timeZoneName");

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          if (kDebugMode) print('Notification payload: ${details.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print("Init failed: $e");
    }
  }

  String _detectLocalTimeZone() {
    try {
      final int offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      String? bestMatch;

      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.timeZone(nowMs).offset == offsetMs) {
          bestMatch = loc.name;
          if (bestMatch.startsWith('Asia/Jakarta') ||
              bestMatch.startsWith('Asia/Makassar') ||
              bestMatch.startsWith('Asia/Jayapura')) {
            return bestMatch;
          }
        }
      }

      if (bestMatch != null) return bestMatch;

      final int hourOffset = DateTime.now().timeZoneOffset.inHours;
      switch (hourOffset) {
        case 7:
          return 'Asia/Jakarta';
        case 8:
          return 'Asia/Makassar';
        case 9:
          return 'Asia/Jayapura';
        default:
          return 'Asia/Jakarta';
      }
    } catch (e) {
      return 'Asia/Jakarta';
    }
  }

  Future<void> requestPermissions() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final platform =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (platform != null) {
        await platform.requestExactAlarmsPermission();
      }
    } catch (e) {
      if (kDebugMode) print("Permission request failed: $e");
    }
  }

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
        color: Color(0xFFD32F2F),
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
      if (kDebugMode) print("Show notification failed: $e");
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime tzScheduledDate =
          tz.TZDateTime.from(scheduledDate, tz.local);
      tz.TZDateTime finalScheduledDate = tzScheduledDate;
      final now = tz.TZDateTime.now(tz.local);

      if (finalScheduledDate.isBefore(now)) {
        if (now.difference(finalScheduledDate).inMinutes < 5) {
          finalScheduledDate = now.add(const Duration(seconds: 2));
        } else {
          return;
        }
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        finalScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_jadwal_tanam_v2',
            'Jadwal Tanam Petani',
            channelDescription: 'Pengingat aktivitas pertanian penting',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) print("Schedule failed: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
