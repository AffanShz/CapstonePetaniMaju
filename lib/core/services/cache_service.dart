import 'package:hive_flutter/hive_flutter.dart';
import 'package:petani_maju/data/models/notification_settings.dart';

/// Service for caching API data locally using Hive
/// Supports offline-first approach: load cache first, then fetch API
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Box names
  static const String _weatherBoxName = 'weatherCache';
  static const String _tipsBoxName = 'tipsCache';
  static const String _locationBoxName = 'locationCache';
  static const String _settingsBoxName = 'settingsCache';

  /// Initialize Hive and open all boxes
  /// Call this in main() before runApp()
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_weatherBoxName);
    await Hive.openBox(_tipsBoxName);
    await Hive.openBox(_locationBoxName);
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox(_plantingScheduleBoxName);
  }

  static const String _plantingScheduleBoxName = 'plantingSchedule';

  // ==================== SETTINGS & ONBOARDING ====================

  /// Check if it's the first time the app is run
  bool isFirstTime() {
    return _settingsBox.get('isFirstTime', defaultValue: true) as bool;
  }

  /// Set first time flag
  Future<void> setFirstTime(bool value) async {
    await _settingsBox.put('isFirstTime', value);
  }

  // ==================== WEATHER CACHE ====================

  Box get _weatherBox => Hive.box(_weatherBoxName);

  /// Save current weather and forecast to cache
  Future<void> saveWeatherData({
    required Map<String, dynamic> currentWeather,
    required List<dynamic> forecastList,
  }) async {
    await _weatherBox.put('currentWeather', currentWeather);
    await _weatherBox.put('forecastList', forecastList);
    await _weatherBox.put('lastUpdated', DateTime.now().toIso8601String());
  }

  /// Get cached current weather
  Map<String, dynamic>? getCachedCurrentWeather() {
    final data = _weatherBox.get('currentWeather');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// Get cached forecast list
  List<dynamic>? getCachedForecast() {
    final data = _weatherBox.get('forecastList');
    if (data != null) {
      return List<dynamic>.from(data);
    }
    return null;
  }

  /// Get weather cache timestamp
  DateTime? getWeatherCacheTime() {
    final timestamp = _weatherBox.get('lastUpdated');
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// Check if weather cache is stale (older than specified minutes)
  bool isWeatherCacheStale({int maxAgeMinutes = 30}) {
    final cacheTime = getWeatherCacheTime();
    if (cacheTime == null) return true;
    return DateTime.now().difference(cacheTime).inMinutes > maxAgeMinutes;
  }

  // ==================== TIPS CACHE ====================

  Box get _tipsBox => Hive.box(_tipsBoxName);

  /// Save tips list to cache
  Future<void> saveTipsData(List<Map<String, dynamic>> tips) async {
    await _tipsBox.put('tips', tips);
    await _tipsBox.put('lastUpdated', DateTime.now().toIso8601String());
  }

  /// Get cached tips list
  List<Map<String, dynamic>>? getCachedTips() {
    final data = _tipsBox.get('tips');
    if (data != null) {
      return List<Map<String, dynamic>>.from(
          (data as List).map((item) => Map<String, dynamic>.from(item)));
    }
    return null;
  }

  /// Get tips cache timestamp
  DateTime? getTipsCacheTime() {
    final timestamp = _tipsBox.get('lastUpdated');
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  // ==================== LOCATION CACHE ====================

  Box get _locationBox => Hive.box(_locationBoxName);

  /// Save detailed location to cache
  Future<void> saveLocationData(
      String detailedLocation, double lat, double lon) async {
    await _locationBox.put('detailedLocation', detailedLocation);
    await _locationBox.put('latitude', lat);
    await _locationBox.put('longitude', lon);
    await _locationBox.put('lastUpdated', DateTime.now().toIso8601String());
  }

  /// Get cached detailed location
  String? getCachedDetailedLocation() {
    return _locationBox.get('detailedLocation');
  }

  /// Get cached coordinates
  Map<String, double>? getCachedCoordinates() {
    final lat = _locationBox.get('latitude');
    final lon = _locationBox.get('longitude');
    if (lat != null && lon != null) {
      return {'latitude': lat, 'longitude': lon};
    }
    return null;
  }

  // ==================== PESTS CACHE ====================

  /// Save pests list to cache (uses tipsBox for simplicity)
  Future<void> savePestsData(List<Map<String, dynamic>> pests) async {
    await _tipsBox.put('pests', pests);
    await _tipsBox.put('pestsLastUpdated', DateTime.now().toIso8601String());
  }

  /// Get cached pests list
  List<Map<String, dynamic>>? getCachedPests() {
    final data = _tipsBox.get('pests');
    if (data != null) {
      return List<Map<String, dynamic>>.from(
          (data as List).map((item) => Map<String, dynamic>.from(item)));
    }
    return null;
  }

  // ==================== UTILITY ====================

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _weatherBox.clear();
    await _tipsBox.clear();
    await _locationBox.clear();
  }

  // ==================== SETTINGS ====================

  Box get _settingsBox => Hive.box(_settingsBoxName);

  /// Set offline mode preference
  Future<void> setOfflineMode(bool value) async {
    await _settingsBox.put('offlineMode', value);
  }

  /// Get offline mode preference (default: false = online)
  bool getOfflineMode() {
    return _settingsBox.get('offlineMode', defaultValue: false) as bool;
  }

  // ==================== NOTIFICATION SETTINGS ====================

  /// Save notification settings
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    await _settingsBox.put('notificationSettings', settings.toJson());
  }

  /// Get notification settings (returns default if not set)
  NotificationSettings getNotificationSettings() {
    final data = _settingsBox.get('notificationSettings');
    if (data != null) {
      return NotificationSettings.fromJson(Map<String, dynamic>.from(data));
    }
    return const NotificationSettings();
  }

  /// Get last rain date for smart watering feature
  DateTime? getLastRainDate() {
    final timestamp = _settingsBox.get('lastRainDate');
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// Set last rain date
  Future<void> setLastRainDate(DateTime date) async {
    await _settingsBox.put('lastRainDate', date.toIso8601String());
  }
}
