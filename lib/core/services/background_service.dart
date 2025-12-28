import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:petani_maju/core/services/notification_service.dart';
import 'package:petani_maju/data/datasources/weather_service.dart';
import 'package:petani_maju/core/services/cache_service.dart';
import 'package:petani_maju/utils/weather_utils.dart';

const String simplePeriodicTask = "simplePeriodicTask";
const String weatherCheckTask = "weatherCheckTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await dotenv.load(fileName: ".env");

      await CacheService.init();
      final cacheService = CacheService();

      final notificationService = NotificationService();
      await notificationService.init();

      if (task == weatherCheckTask) {
        final weatherService = WeatherService();
        final cachedCoords = cacheService.getCachedCoordinates();

        final weatherData = await weatherService.fetchCurrentWeather(
            lat: cachedCoords?['latitude'], lon: cachedCoords?['longitude']);

        if (weatherData.isNotEmpty && weatherData['weather'] != null) {
          final conditionId = weatherData['weather'][0]['id'] as int;
          final cityName = weatherData['name'] ?? 'Lokasi Anda';

          final recommendation = WeatherUtils.getRecommendation(conditionId);

          final bool shouldNotify = (conditionId < 700) ||
              (conditionId == 800) ||
              (conditionId == 804);

          if (shouldNotify && recommendation != null) {
            await notificationService.showNotification(
              id: 999,
              title: "PERINGATAN CUACA di $cityName!",
              body: recommendation,
              payload: 'weather_alert',
            );
          }
        }
      }
    } catch (_) {
      return Future.value(true);
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().cancelAll();
    await Workmanager().registerPeriodicTask(
      simplePeriodicTask,
      weatherCheckTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      initialDelay: const Duration(seconds: 10),
    );
  }
}
