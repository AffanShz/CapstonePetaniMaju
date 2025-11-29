import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage(
                                'assets/images/profiles.jpg',
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Petani Maju',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Last Sync: 2025-11-28'),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.notifications, size: 20),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.person, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
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
                            Icon(Icons.water_drop_outlined,
                                color: Colors.white),
                            Text(
                              '65%',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.wind_power_outlined,
                                color: Colors.white),
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
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEE), // Light red background
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red, // Red border
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ALERT CUACA EKSTREM!',
                                  style: TextStyle(
                                    color: Colors.red[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Hujan lebat diprediksi 2 hari ke depan. Pastikan drainase sawah optimal.',
                              style: TextStyle(
                                color: Colors.red[900],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
