import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';

import 'package:petani_maju/data/datasources/weather_service.dart';
import 'package:petani_maju/data/datasources/location_service.dart';
import 'package:petani_maju/core/services/cache_service.dart';
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
import 'package:petani_maju/core/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final CacheService _cacheService = CacheService();
  // Opsional: Anda bisa membuat instance di sini juga agar lebih rapi
  // final NotificationService _notificationService = NotificationService();

  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? currentWeather;
  List<dynamic> forecastList = [];

  // Variabel untuk Alert Dinamis (Rekomendasi Tanaman)
  String? alertMessage;
  bool isAlertVisible = false;

  String? detailedLocation;

  // Sync status
  DateTime? lastSyncTime;
  bool isOnline = true;

  // Flag untuk mencegah notifikasi muncul berulang kali saat refresh
  bool _hasShownNotification = false;

  @override
  void initState() {
    super.initState();
    // Defer ALL initialization to after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        initializeDateFormatting('id_ID', null).then((_) {
          if (mounted) {
            // PERBAIKAN: Gunakan NotificationService()
            NotificationService().requestPermissions();
            _loadData();
          }
        });
      }
    });
  }

  Future<void> _loadData() async {
    // Check if offline mode is enabled
    final offlineMode = _cacheService.getOfflineMode();

    // Load data cache dulu agar tampilan tidak kosong
    _loadFromCache();

    // Jika offline mode aktif, hanya gunakan cache
    if (offlineMode) {
      if (mounted) {
        setState(() {
          isOnline = false;
          isLoading = false;
        });
      }
      return;
    }

    // Kemudian ambil data baru dari internet
    await _checkLocationPermissionAndFetch();
  }

  void _loadFromCache() {
    try {
      final cachedWeather = _cacheService.getCachedCurrentWeather();
      final cachedForecast = _cacheService.getCachedForecast();
      final cachedLocation = _cacheService.getCachedDetailedLocation();
      final cacheTime = _cacheService.getWeatherCacheTime();

      if (cachedWeather != null) {
        if (mounted) {
          setState(() {
            currentWeather = cachedWeather;
            forecastList = cachedForecast ?? [];
            detailedLocation = cachedLocation;
            lastSyncTime = cacheTime;
            isLoading = false;

            // Generate rekomendasi dari cache
            _generateRecommendation(cachedWeather);
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading cache: $e");
    }
  }

  Future<void> _checkLocationPermissionAndFetch() async {
    // Skip if offline mode is enabled
    final offlineMode = _cacheService.getOfflineMode();
    if (offlineMode) {
      if (mounted) {
        setState(() {
          isOnline = false;
          isLoading = false;
        });
      }
      return;
    }

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

      // Gunakan akurasi Low agar lebih cepat mengunci lokasi
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      ));

      await _fetchData(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      debugPrint("Location error: $e");
      // Check offline mode again before fallback fetch
      if (!_cacheService.getOfflineMode()) {
        await _fetchData(); // Fallback fetch tanpa koordinat baru
      } else {
        if (mounted) {
          setState(() {
            isOnline = false;
            isLoading = false;
          });
        }
      }
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

      if (mounted) {
        setState(() {
          currentWeather = current;
          forecastList = rawList;
          detailedLocation =
              locationStr ?? _cacheService.getCachedDetailedLocation();
          lastSyncTime = DateTime.now();
          isOnline = true;
          isLoading = false;
          errorMessage = "";
        });

        // Panggil fungsi rekomendasi (Sesuai request sebelumnya: Alert Dinamis)
        _generateRecommendation(current);
      }
    } catch (e) {
      debugPrint("Fetch data error: $e");
      // Jika error tapi sudah ada cache, jangan tampilkan error screen
      if (currentWeather == null && mounted) {
        setState(() {
          errorMessage = "Gagal memuat data. Periksa koneksi internet.";
          isLoading = false;
          isOnline = false;
        });
      } else if (mounted) {
        setState(() {
          isLoading = false;
          isOnline = false;
        });
      }
    }
  }

  // --- LOGIKA UTAMA: ALERT BERISI REKOMENDASI ---
  void _generateRecommendation(Map<String, dynamic>? current) {
    if (current == null || current['weather'] == null) return;

    final List<dynamic> weatherList = current['weather'];
    if (weatherList.isEmpty) return;

    final int conditionId = weatherList[0]['id'];

    // Menggunakan WeatherUtils yang sudah diupdate untuk rekomendasi
    final String? recommendation = WeatherUtils.getRecommendation(conditionId);

    if (recommendation != null) {
      if (mounted) {
        setState(() {
          alertMessage = recommendation;
          isAlertVisible = true;
        });
      }

      // Notifikasi (Opsional: agar user tau ada rekomendasi baru)
      if (!_hasShownNotification) {
        // PERBAIKAN: Gunakan NotificationService()
        NotificationService().showNotification(
          id: 101,
          title: 'Info Tanaman',
          body: recommendation,
        );
        _hasShownNotification = true;
      }
    } else {
      if (mounted) setState(() => isAlertVisible = false);
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
                            CustomAppBar(
                              lastSyncTime: lastSyncTime,
                              isOnline: isOnline,
                            ),
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

                            // --- WIDGET ALERT MERAH (ISI REKOMENDASI) ---
                            // Tampil hanya jika ada rekomendasi
                            if (isAlertVisible && alertMessage != null) ...[
                              WeatherAlert(message: alertMessage!),
                              const SizedBox(height: 20),
                            ],
                            // --------------------------------------------

                            const SectionHeader(
                                title: 'Prediksi Cuaca (Per 3 Jam)'),
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
