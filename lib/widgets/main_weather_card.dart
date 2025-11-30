import 'package:flutter/material.dart';

class MainWeatherCard extends StatelessWidget {
  const MainWeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(26),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xff1B5E20),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        Text(
                          'Subang, Jawa Barat',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '32°C',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Cerah Berawan',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.wb_sunny,
                  color: Colors.orange,
                  size: 64,
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.white,
              thickness: 1,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.water_drop_outlined, color: Colors.white),
                Text(
                  '65%',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.wind_power_outlined, color: Colors.white),
                Text(
                  '12 km/h',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
