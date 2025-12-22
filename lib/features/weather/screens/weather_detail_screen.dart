import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';

import 'package:petani_maju/data/datasources/weather_service.dart';
import 'package:petani_maju/data/datasources/location_service.dart';
import 'package:petani_maju/core/services/cache_service.dart';
import 'package:petani_maju/utils/weather_utils.dart';

class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({super.key});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final CacheService _cacheService = CacheService();

  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? currentWeather;
  List<dynamic> forecastList = [];
  String? detailedLocation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 1. Load from cache first
    _loadFromCache();

    // 2. Fetch fresh data
    await _fetchWeatherData();
  }

  void _loadFromCache() {
    final cachedWeather = _cacheService.getCachedCurrentWeather();
    final cachedForecast = _cacheService.getCachedForecast();
    final cachedLocation = _cacheService.getCachedDetailedLocation();

    if (cachedWeather != null) {
      if (mounted) {
        setState(() {
          currentWeather = cachedWeather;
          forecastList = cachedForecast ?? [];
          detailedLocation = cachedLocation;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchWeatherData() async {
    if (currentWeather == null) {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = "";
        });
      }
    }

    try {
      double? lat;
      double? lon;

      // Try to get cached coordinates first
      final cachedCoords = _cacheService.getCachedCoordinates();
      if (cachedCoords != null) {
        lat = cachedCoords['latitude'];
        lon = cachedCoords['longitude'];
      }

      // Try to get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          try {
            Position position = await Geolocator.getCurrentPosition(
                locationSettings:
                    const LocationSettings(accuracy: LocationAccuracy.high));
            lat = position.latitude;
            lon = position.longitude;
          } catch (e) {
            // Use cached or default location
          }
        }
      }

      final current =
          await _weatherService.fetchCurrentWeather(lat: lat, lon: lon);
      final forecast = await _weatherService.fetchForecast(lat: lat, lon: lon);

      // Get detailed location
      String? locationStr;
      if (lat != null && lon != null) {
        final locationData =
            await _locationService.getDetailedLocation(lat, lon);
        locationStr = locationData['full'];

        if (locationStr != null && locationStr.isNotEmpty) {
          await _cacheService.saveLocationData(locationStr, lat, lon);
        }
      }

      // Save to cache
      await _cacheService.saveWeatherData(
        currentWeather: current,
        forecastList: forecast['list'] ?? [],
      );

      if (mounted) {
        setState(() {
          currentWeather = current;
          forecastList = forecast['list'] ?? [];
          detailedLocation =
              locationStr ?? _cacheService.getCachedDetailedLocation();
          isLoading = false;
          errorMessage = "";
        });
      }
    } catch (e) {
      if (currentWeather == null) {
        if (mounted) {
          setState(() {
            errorMessage = "Gagal memuat data cuaca: $e";
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  // Get theme colors based on weather condition
  List<Color> _getWeatherGradient(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return [const Color(0xFFFF8C00), const Color(0xFFFFD700)];
      case 'clouds':
        return [const Color(0xFF546E7A), const Color(0xFF90A4AE)];
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'thunderstorm':
        return [const Color(0xFF37474F), const Color(0xFF546E7A)];
      case 'snow':
        return [const Color(0xFFB3E5FC), const Color(0xFFE1F5FE)];
      case 'mist':
      case 'haze':
      case 'fog':
        return [const Color(0xFF78909C), const Color(0xFFB0BEC5)];
      default:
        return [const Color(0xff1B5E20), const Color(0xff4CAF50)];
    }
  }

  IconData _getWeatherIcon(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'haze':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  List<Map<String, dynamic>> _getDailyForecast() {
    Map<String, Map<String, dynamic>> dailyData = {};

    for (var item in forecastList) {
      DateTime date = DateTime.parse(item['dt_txt']);
      String dayKey = DateFormat('yyyy-MM-dd').format(date);

      double temp = (item['main']['temp'] as num).toDouble();
      String weatherMain = item['weather'][0]['main'];
      String icon = item['weather'][0]['icon'];

      if (!dailyData.containsKey(dayKey)) {
        dailyData[dayKey] = {
          'date': date,
          'minTemp': temp,
          'maxTemp': temp,
          'weatherMain': weatherMain,
          'icon': icon,
        };
      } else {
        if (temp < dailyData[dayKey]!['minTemp']) {
          dailyData[dayKey]!['minTemp'] = temp;
        }
        if (temp > dailyData[dayKey]!['maxTemp']) {
          dailyData[dayKey]!['maxTemp'] = temp;
        }
        if (date.hour >= 11 && date.hour <= 14) {
          dailyData[dayKey]!['weatherMain'] = weatherMain;
          dailyData[dayKey]!['icon'] = icon;
        }
      }
    }

    return dailyData.values.take(5).toList();
  }

  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cuaca'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading && currentWeather == null
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty && currentWeather == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() {
    if (currentWeather == null) return const SizedBox();

    final main = currentWeather!['main'];
    final weather = currentWeather!['weather'][0];
    final weatherMain = weather['main'] as String?;
    final gradientColors = _getWeatherGradient(weatherMain);
    final now = DateTime.now();

    String locationText = detailedLocation?.isNotEmpty == true
        ? detailedLocation!
        : currentWeather!['name'] ?? '-';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main Weather Box with Dynamic Theme
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  weather['icon'] != null
                      ? Image.network(
                          getIconUrl(weather['icon']),
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getWeatherIcon(weatherMain),
                            size: 80,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _getWeatherIcon(weatherMain),
                          size: 80,
                          color: Colors.white,
                        ),
                  const SizedBox(height: 16),
                  Text(
                    '${main['temp'].toStringAsFixed(0)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    WeatherUtils.translateWeather(weather['description']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoItem(Icons.water_drop, '${main['humidity']}%',
                          'Kelembaban'),
                      _buildInfoItem(Icons.air,
                          '${currentWeather!['wind']['speed']} m/s', 'Angin'),
                      _buildInfoItem(
                          Icons.thermostat,
                          '${main['feels_like'].toStringAsFixed(0)}°',
                          'Terasa'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Prediksi 5 Hari Kedepan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ..._getDailyForecast().map((day) => _buildDailyForecastItem(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDailyForecastItem(Map<String, dynamic> day) {
    DateTime date = day['date'];
    String dayName = DateFormat('EEEE', 'id_ID').format(date);
    String dateText = DateFormat('d MMM', 'id_ID').format(date);
    int minTemp = day['minTemp'].round();
    int maxTemp = day['maxTemp'].round();
    String? icon = day['icon'];
    String? weatherMain = day['weatherMain'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  dateText,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          icon != null
              ? Image.network(getIconUrl(icon), width: 40, height: 40)
              : Icon(_getWeatherIcon(weatherMain),
                  color: Colors.orange, size: 32),
          const SizedBox(width: 16),
          Text(
            '$maxTemp° / $minTemp°',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
