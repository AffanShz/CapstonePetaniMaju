import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "51a0edeeaa973f9fccfe1049ae9fc1f2";
  final double lat = -6.5716;
  final double lon = 107.7587;

  Future<Map<String, dynamic>> fetchCurrentWeather(
      {double? lat, double? lon}) async {
    final latitude = lat ?? this.lat;
    final longitude = lon ?? this.lon;
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather');
    }
  }

  Future<Map<String, dynamic>> fetchForecast({double? lat, double? lon}) async {
    final latitude = lat ?? this.lat;
    final longitude = lon ?? this.lon;
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast');
    }
  }
}
