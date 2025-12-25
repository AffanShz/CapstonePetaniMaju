import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:petani_maju/core/services/notification_service.dart';
import 'package:petani_maju/data/datasources/weather_service.dart';

// Nama unik task
const String simplePeriodicTask = "simplePeriodicTask";
const String weatherCheckTask = "weatherCheckTask";

// Fungsi callback ini harus TOP-LEVEL (di luar class)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Load Environment Variables
      await dotenv.load(fileName: ".env");

      // 2. Init Notification Service
      final notificationService = NotificationService();
      await notificationService.init();

      // 3. Logic Pengecekan Cuaca
      if (task == weatherCheckTask) {
        if (kDebugMode) print("Running Background Task: Checking Weather...");

        final weatherService = WeatherService();

        // Fetch cuaca terbaru
        final weatherData = await weatherService.fetchCurrentWeather();

        if (weatherData.isNotEmpty && weatherData['weather'] != null) {
          final List weatherList = weatherData['weather'];
          if (weatherList.isNotEmpty) {
            final int conditionId = weatherList[0]['id'];
            final String mainCondition = weatherList[0]['main'];
            final String description = weatherList[0]['description'];

            // LOGIC PINTAR: Deteksi cuaca buruk (Kode < 600 atau 804 mendung pekat)
            if (conditionId < 600 || conditionId == 804) {
              String title = "Peringatan Cuaca!";
              String body =
                  "Cuaca saat ini: $mainCondition ($description). Siapkan langkah antisipasi.";

              if (conditionId >= 200 && conditionId < 300) {
                title = "BAHAYA: Badai Petir";
                body =
                    "Terdeteksi badai petir di lokasi lahan. Segera cari tempat aman!";
              } else if (conditionId >= 500 && conditionId < 600) {
                title = "Hujan Turun";
                body = "Hujan mulai turun. Pastikan saluran air lahan terbuka.";
              }

              // Tampilkan Notifikasi
              await notificationService.showNotification(
                id: 999,
                title: title,
                body: body,
                payload: 'weather_alert',
              );

              if (kDebugMode) print("Background Notification Sent: $title");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Background Task Error: $e");
      // Return true agar tidak retry terus menerus jika error coding
      return Future.value(true);
    }

    return Future.value(true);
  });
}

class BackgroundService {
  /// Inisialisasi WorkManager
  static Future<void> init() async {
    try {
      // PERUBAHAN VERSI 0.9.0: isInDebugMode dihapus/deprecated.
      // Debug mode sekarang otomatis aktif jika app dalam mode debug,
      // atau gunakan WorkmanagerDebug.check() jika perlu manual.
      await Workmanager().initialize(
        callbackDispatcher,
      );

      if (kDebugMode) print("Background Service Initialized");
    } catch (e) {
      if (kDebugMode) print("Gagal init background service: $e");
    }
  }

  /// Mulai Penjadwalan
  static Future<void> registerPeriodicTask() async {
    try {
      await Workmanager().cancelAll();

      await Workmanager().registerPeriodicTask(
        simplePeriodicTask,
        weatherCheckTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        // PERUBAHAN VERSI 0.9.0: Gunakan ExistingPeriodicWorkPolicy
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        initialDelay: const Duration(seconds: 10),
      );

      if (kDebugMode) {
        print("Periodic Task Registered: Check weather every 15 min");
      }
    } catch (e) {
      if (kDebugMode) print("Gagal register task: $e");
    }
  }
}
