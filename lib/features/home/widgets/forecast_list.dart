import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petani_maju/utils/weather_utils.dart';

class ForecastList extends StatelessWidget {
  final List<dynamic> forecastData;

  const ForecastList({super.key, required this.forecastData});

  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: forecastData.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          var item = forecastData[index];
          DateTime date = DateTime.parse(item['dt_txt']);

          String dayName = DateFormat('EEE', 'id_ID').format(date);
          String timeText = DateFormat('HH:mm').format(date);
          String temp = item['main']['temp'].toStringAsFixed(0);
          String iconCode = item['weather'][0]['icon'];
          String description = item['weather'][0]['description'];

          return Container(
            width: 100,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(timeText,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Image.network(getIconUrl(iconCode), width: 40, height: 40),
                const SizedBox(height: 2),
                Text('$temp°',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  WeatherUtils.translateWeather(description),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[600], height: 1.1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
