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
// Import Service Notifikasi
import 'package:petani_maju/core/constants/services/notification_service.dart';

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

  // Flag untuk mencegah notifikasi muncul berulang kali saat refresh
  bool _hasShownNotification = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) {
        // Minta izin notifikasi segera setelah aplikasi dibuka
        NotificationService.requestPermissions();
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    // Load data cache dulu agar tampilan tidak kosong
    _loadFromCache();
    // Kemudian ambil data baru dari internet
    await _checkLocationPermissionAndFetch();
  }

  void _loadFromCache() {
    try {
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

            // Cek hujan dari data cache (Notifikasi bisa muncul instan dari sini)
            _checkRainAlertSafely(forecastList);
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading cache: $e");
    }
  }

  Future<void> _checkLocationPermissionAndFetch() async {
    // Tampilkan loading hanya jika benar-benar tidak ada data (cache kosong)
    if (currentWeather == null && mounted) {
      setState(() => isLoading = true);
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Jika GPS mati, coba fetch dengan lokasi default/terakhir
        await _fetchData();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _fetchData();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await _fetchData();
        return;
      }

      // Gunakan akurasi Medium agar lebih cepat mengunci lokasi
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ));

      await _fetchData(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      debugPrint("Location error: $e");
      await _fetchData(); // Fallback fetch tanpa koordinat baru
    }
  }

  Future<void> _fetchData({double? lat, double? lon}) async {
    try {
      final current =
          await _weatherService.fetchCurrentWeather(lat: lat, lon: lon);
      final forecast = await _weatherService.fetchForecast(lat: lat, lon: lon);

      String? locationStr;
      if (lat != null && lon != null) {
        try {
          final locationData =
              await _locationService.getDetailedLocation(lat, lon);
          locationStr = locationData['full'];
          // Simpan lokasi ke cache
          if (locationStr != null && locationStr.isNotEmpty) {
            await _cacheService.saveLocationData(locationStr, lat, lon);
          }
        } catch (_) {
          // Abaikan error lokasi detil, tetap lanjut cuaca
        }
      }

      List<dynamic> rawList = forecast['list'] ?? [];

      // Simpan data cuaca ke cache
      await _cacheService.saveWeatherData(
        currentWeather: current,
        forecastList: rawList,
      );

      // Cek hujan pada data baru
      _checkRainAlertSafely(rawList);

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
      debugPrint("Fetch data error: $e");
      // Jika error tapi sudah ada cache, jangan tampilkan error screen
      if (currentWeather == null && mounted) {
        setState(() {
          errorMessage = "Gagal memuat data. Periksa koneksi internet.";
          isLoading = false;
        });
      } else if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _checkRainAlertSafely(List<dynamic> rawList) {
    if (rawList.isEmpty) return;

    try {
      String? foundRainAlert;

      for (var item in rawList) {
        // Validasi null safety yang ketat
        if (item == null || item['dt_txt'] == null || item['weather'] == null) {
          continue;
        }

        List<dynamic> weatherList = item['weather'];
        if (weatherList.isEmpty) continue;

        DateTime date = DateTime.parse(item['dt_txt']);
        String weatherMain = weatherList[0]['main'] ?? '';
        String description = weatherList[0]['description'] ?? '';

        // Deteksi hujan dalam 24 jam ke depan
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

      // --- LOGIKA NOTIFIKASI OTOMATIS ---
      // Jika ditemukan hujan DAN notifikasi belum pernah ditampilkan di sesi ini
      if (foundRainAlert != null && !_hasShownNotification) {
        NotificationService.showNotification(
          id: 888, // ID unik untuk weather alert
          title: 'Peringatan Hujan!',
          body: foundRainAlert,
        );
        // Set flag agar tidak spam notifikasi saat user refresh layar
        _hasShownNotification = true;
      }
      // ----------------------------------

      if (mounted) {
        setState(() {
          rainAlertMessage = foundRainAlert;
          isRainPredicted = foundRainAlert != null;
        });
      }
    } catch (e) {
      debugPrint("Check rain alert error: $e");
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
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.signal_wifi_off,
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

                            // Widget Alert Merah di Layar (selain notifikasi bar)
                            if (isRainPredicted &&
                                rainAlertMessage != null) ...[
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
