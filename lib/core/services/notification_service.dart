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

      // DETEKSI ZONA WAKTU (Tanpa plugin tambahan)
      // Kita gunakan offset dari DateTime.now() untuk menebak zona waktu Indonesia
      final String timeZoneName = _detectLocalTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      if (kDebugMode) print("Timezone diset ke: $timeZoneName");

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

  String _detectLocalTimeZone() {
    try {
      final int offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
      final int nowMs = DateTime.now().millisecondsSinceEpoch;

      // Cari lokasi yang offset-nya cocok dengan Device
      // Kita prioritas 'Asia/Jakarta' dkk jika cocok, tapi kalau tidak, ambil yang pertama ketemu
      String? bestMatch;

      for (var loc in tz.timeZoneDatabase.locations.values) {
        if (loc.timeZone(nowMs).offset == offsetMs) {
          bestMatch = loc.name;
          // Prioritas Indonesia agar nama zona 'friendly'
          if (bestMatch.startsWith('Asia/Jakarta') ||
              bestMatch.startsWith('Asia/Makassar') ||
              bestMatch.startsWith('Asia/Jayapura')) {
            return bestMatch;
          }
        }
      }

      if (bestMatch != null) return bestMatch;

      // Fallback manual jika database tidak lengkap
      final int hourOffset = DateTime.now().timeZoneOffset.inHours;
      if (hourOffset == 7) return 'Asia/Jakarta';
      if (hourOffset == 8) return 'Asia/Makassar';
      if (hourOffset == 9) return 'Asia/Jayapura';

      return 'Asia/Jakarta'; // Default ultimate
    } catch (e) {
      if (kDebugMode) print("Error detect timezone: $e");
      return 'Asia/Jakarta';
    }
  }

  /// Meminta Izin (Panggil di Home/Screen awal)
  Future<void> requestPermissions() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Tambahan: Request Exact Alarm permission untuk Android 12+
      // Ini krusial agar notifikasi terjadwal (zonedSchedule) berjalan tepat waktu
      final platform =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (platform != null) {
        await platform.requestExactAlarmsPermission();
      }
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

      // Cek apakah waktu sudah lewat?
      // Revisi: Jika waktu sudah lewat (misal testing jam sekarang),
      // tapi masih dalam batas toleransi (misal 1 menit),
      // jadwalkan untuk 5 detik dari sekarang agar tetap bunyi.

      tz.TZDateTime finalScheduledDate = tzScheduledDate;
      final now = tz.TZDateTime.now(tz.local);

      if (finalScheduledDate.isBefore(now)) {
        // Jika selisihnya kurang dari 5 menit, anggap user ingin test "sekarang"
        if (now.difference(finalScheduledDate).inMinutes < 5) {
          finalScheduledDate = now.add(const Duration(seconds: 2));
          if (kDebugMode)
            print("Waktu lewat, dijadwalkan ulang ke 2 detik lagi.");
        } else {
          if (kDebugMode)
            print("Waktu jadwal $title sudah berlalu lama, skip notifikasi.");
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
            'channel_jadwal_tanam_v2', // Ganti ID agar settings fresh
            'Jadwal Tanam Petani',
            channelDescription: 'Pengingat aktivitas pertanian penting',
            importance: Importance.max, // Pastikan MAX
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
