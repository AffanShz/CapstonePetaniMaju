import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';

import 'package:petani_maju/data/datasources/weather_service.dart';
import 'package:petani_maju/utils/weather_utils.dart';
import 'package:petani_maju/features/home/widgets/forecast_list.dart';
import 'package:petani_maju/features/home/widgets/quick_access.dart';
import 'package:petani_maju/features/home/widgets/tips_list.dart';
import 'package:petani_maju/features/home/widgets/weather_alert.dart';
import 'package:petani_maju/widgets/custom_app_bar.dart';
import 'package:petani_maju/widgets/main_weather_card.dart';
import 'package:petani_maju/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? currentWeather;
  List<dynamic> forecastList = [];
  String? rainAlertMessage;
  bool isRainPredicted = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkLocationPermissionAndFetch();
      });
    });
  }

  Future<void> _checkLocationPermissionAndFetch() async {
    setState(() {
      isLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _fetchData();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _fetchData();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _fetchData();
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      _fetchData(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      // Fallback if location fails
      _fetchData();
    }
  }

  Future<void> _fetchData({double? lat, double? lon}) async {
    try {
      final current =
          await _weatherService.fetchCurrentWeather(lat: lat, lon: lon);
      final forecast = await _weatherService.fetchForecast(lat: lat, lon: lon);

      List<dynamic> rawList = forecast['list'];
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

      setState(() {
        currentWeather = current;
        forecastList = rawList;
        rainAlertMessage = foundRainAlert;
        isRainPredicted = foundRainAlert != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Gagal memuat data: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomAppBar(),
                          SizedBox(height: 20),
                          MainWeatherCard(
                            weatherData: currentWeather,
                            onRefresh: _checkLocationPermissionAndFetch,
                          ),
                          SizedBox(height: 20),
                          if (isRainPredicted) ...[
                            WeatherAlert(message: rainAlertMessage!),
                            SizedBox(height: 20),
                          ],
                          SectionHeader(title: 'Prediksi Cuaca (Per 3 Jam)'),
                          SizedBox(height: 20),
                          ForecastList(forecastData: forecastList),
                          SizedBox(height: 20),
                          SectionHeader(title: 'Tips Pertanian'),
                          SizedBox(height: 16),
                          TipsList(),
                          SizedBox(height: 20),
                          QuickAccess(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
