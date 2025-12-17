import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';

import 'package:petani_maju/data/datasources/weather_service.dart';
import 'package:petani_maju/data/datasources/location_service.dart';
import 'package:petani_maju/data/datasources/cache_service.dart';
import 'package:petani_maju/utils/weather_utils.dart';
import 'package:petani_maju/features/home/widgets/forecast_list.dart';
import 'package:petani_maju/features/home/widgets/quick_access.dart';
import 'package:petani_maju/features/home/widgets/tips_list.dart';
import 'package:petani_maju/features/home/widgets/weather_alert.dart';
import 'package:petani_maju/widgets/custom_app_bar.dart';
import 'package:petani_maju/widgets/main_weather_card.dart';
import 'package:petani_maju/widgets/section_header.dart';
import 'package:petani_maju/features/weather/screens/weather_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final CacheService _cacheService = CacheService();

  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? currentWeather;
  List<dynamic> forecastList = [];
  String? rainAlertMessage;
  bool isRainPredicted = false;
  String? detailedLocation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    });
  }

  /// Load data: cache first (instant), then fetch API (background)
  Future<void> _loadData() async {
    // 1. Load from cache first for instant display
    _loadFromCache();

    // 2. Then fetch fresh data from API
    await _checkLocationPermissionAndFetch();
  }

  /// Load cached data for instant display
  void _loadFromCache() {
    final cachedWeather = _cacheService.getCachedCurrentWeather();
    final cachedForecast = _cacheService.getCachedForecast();
    final cachedLocation = _cacheService.getCachedDetailedLocation();

    if (cachedWeather != null) {
      setState(() {
        currentWeather = cachedWeather;
        forecastList = cachedForecast ?? [];
        detailedLocation = cachedLocation;
        isLoading = false;

        // Check for rain alert in cached forecast
        _checkRainAlert(forecastList);
      });
    }
  }

  Future<void> _checkLocationPermissionAndFetch() async {
    if (currentWeather == null) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _fetchData();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _fetchData();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _fetchData();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      _fetchData(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      _fetchData();
    }
  }

  Future<void> _fetchData({double? lat, double? lon}) async {
    try {
      final current =
          await _weatherService.fetchCurrentWeather(lat: lat, lon: lon);
      final forecast = await _weatherService.fetchForecast(lat: lat, lon: lon);

      // Get detailed location if we have coordinates
      String? locationStr;
      if (lat != null && lon != null) {
        final locationData =
            await _locationService.getDetailedLocation(lat, lon);
        locationStr = locationData['full'];

        // Save location to cache
        if (locationStr != null && locationStr.isNotEmpty) {
          await _cacheService.saveLocationData(locationStr, lat, lon);
        }
      }

      List<dynamic> rawList = forecast['list'];

      // Save to cache
      await _cacheService.saveWeatherData(
        currentWeather: current,
        forecastList: rawList,
      );

      // Check for rain alert
      _checkRainAlert(rawList);

      if (mounted) {
        setState(() {
          currentWeather = current;
          forecastList = rawList;
          detailedLocation =
              locationStr ?? _cacheService.getCachedDetailedLocation();
          isLoading = false;
          errorMessage = "";
        });
      }
    } catch (e) {
      // Only show error if we don't have cached data
      if (currentWeather == null) {
        if (mounted) {
          setState(() {
            errorMessage = "Gagal memuat data: $e";
            isLoading = false;
          });
        }
      } else {
        // We have cached data, just continue showing it
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _checkRainAlert(List<dynamic> rawList) {
    String? foundRainAlert;

    for (var item in rawList) {
      DateTime date = DateTime.parse(item['dt_txt']);
      String weatherMain = item['weather'][0]['main'];
      String description = item['weather'][0]['description'];

      if (foundRainAlert == null &&
          date.isBefore(DateTime.now().add(const Duration(hours: 24))) &&
          (weatherMain == 'Rain' ||
              weatherMain == 'Thunderstorm' ||
              weatherMain == 'Drizzle')) {
        String timeStr = DateFormat('HH:mm').format(date);
        String translatedDesc = WeatherUtils.translateWeather(description);
        foundRainAlert =
            "Hujan ($translatedDesc) diprediksi pukul $timeStr. Cek drainase.";
      }
    }

    if (mounted) {
      setState(() {
        rainAlertMessage = foundRainAlert;
        isRainPredicted = foundRainAlert != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 64, color: Colors.grey),
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
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const CustomAppBar(),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const WeatherDetailScreen(),
                                  ),
                                );
                              },
                              child: MainWeatherCard(
                                weatherData: currentWeather,
                                detailedLocation: detailedLocation,
                                onRefresh: _loadData,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (isRainPredicted) ...[
                              WeatherAlert(message: rainAlertMessage!),
                              const SizedBox(height: 20),
                            ],
                            const SectionHeader(
                                title: 'Prediksi Cuaca (Per 4 Jam)'),
                            const SizedBox(height: 20),
                            ForecastList(forecastData: forecastList),
                            const SizedBox(height: 20),
                            const SectionHeader(title: 'Tips Pertanian'),
                            const SizedBox(height: 16),
                            const TipsList(),
                            const SizedBox(height: 20),
                            const QuickAccess(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
