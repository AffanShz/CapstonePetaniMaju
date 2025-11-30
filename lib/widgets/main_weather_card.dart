import 'package:flutter/material.dart';
import 'package:petani_maju/utils/weather_utils.dart';

class MainWeatherCard extends StatelessWidget {
  final Map<String, dynamic>? weatherData;

  const MainWeatherCard({super.key, this.weatherData});

  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) return const SizedBox();
    var main = weatherData!['main'];
    var weather = weatherData!['weather'][0];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff1B5E20),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            weatherData!['name'] ?? '-',
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${main['temp'].toStringAsFixed(0)}°',
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(
                      WeatherUtils.translateWeather(weather['description']),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Image.network(getIconUrl(weather['icon']),
                  width: 100, fit: BoxFit.cover),
            ],
          ),
        ],
      ),
    );
  }
}
