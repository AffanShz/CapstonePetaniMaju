import 'package:flutter/material.dart';
import 'package:petani_maju/features/home/widgets/forecast_item.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ForecastItem(
              day: 'Sen',
              icon: Icons.thunderstorm,
              iconColor: Colors.blue,
              maxTemp: '30',
              minTemp: '25'),
          ForecastItem(
              day: 'Sel',
              icon: Icons.wb_cloudy_outlined,
              iconColor: Colors.blue,
              maxTemp: '31',
              minTemp: '26'),
          ForecastItem(
              day: 'Rab',
              icon: Icons.wb_sunny,
              iconColor: Colors.orange,
              maxTemp: '32',
              minTemp: '27'),
          ForecastItem(
              day: 'Kam',
              icon: Icons.wb_sunny,
              iconColor: Colors.orange,
              maxTemp: '33',
              minTemp: '28'),
          ForecastItem(
              day: 'Jum',
              icon: Icons.wb_sunny,
              iconColor: Colors.orange,
              maxTemp: '34',
              minTemp: '29'),
          ForecastItem(
              day: 'Sab',
              icon: Icons.wb_sunny,
              iconColor: Colors.orange,
              maxTemp: '34',
              minTemp: '29'),
          ForecastItem(
            day: 'Min',
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            maxTemp: '34',
            minTemp: '29',
          ),
        ],
      ),
    );
  }
}
