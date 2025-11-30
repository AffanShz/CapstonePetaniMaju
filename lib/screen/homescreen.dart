import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  // --- KONFIGURASI API ---
  // GANTI DENGAN API KEY OPENWEATHERMAP ANDA
  final String apiKey = "51a0edeeaa973f9fccfe1049ae9fc1f2";

  // Koordinat (Default: Subang)
  final double lat = -6.5716;
  final double lon = 107.7587;

  // --- STATE ---
  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? currentWeather;
  List<dynamic> forecastList = [];
  String? rainAlertMessage;
  bool isRainPredicted = false;

  // --- DATA DUMMY UNTUK TIPS PERTANIAN ---
  final List<Map<String, String>> farmingTips = [
    {
      'category': 'Padi',
      'title': 'Cara Menanam Padi',
      'image':
          'https://images.unsplash.com/photo-1536617621572-1d5f1e6269a0?auto=format&fit=crop&q=80&w=600',
    },
    {
      'category': 'Nutrisi',
      'title': 'Pemupukan Efektif',
      'image':
          'https://images.unsplash.com/photo-1625246333195-551e512c9148?auto=format&fit=crop&q=80&w=600',
    },
    {
      'category': 'Pengairan',
      'title': 'Irigasi Modern',
      'image':
          'https://images.unsplash.com/photo-1563514227147-6d2ff665a6a0?auto=format&fit=crop&q=80&w=600',
    },
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      fetchWeatherData();
    });
  }

  Future<void> fetchWeatherData() async {
    try {
      final urlCurrent = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id');
      final urlForecast = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id');

      final responseCurrent = await http.get(urlCurrent);
      final responseForecast = await http.get(urlForecast);

      if (responseCurrent.statusCode == 200 &&
          responseForecast.statusCode == 200) {
        final currentData = json.decode(responseCurrent.body);
        final forecastData = json.decode(responseForecast.body);

        List<dynamic> rawList = forecastData['list'];
        List<dynamic> filteredList = [];
        String? foundRainAlert;

        for (var item in rawList) {
          DateTime date = DateTime.parse(item['dt_txt']);
          String weatherMain = item['weather'][0]['main'];
          String description = item['weather'][0]['description'];

          // LOGIKA ALERT: Cek Hujan dalam 24 jam ke depan
          if (foundRainAlert == null &&
              date.isBefore(DateTime.now().add(const Duration(hours: 24))) &&
              (weatherMain == 'Rain' ||
                  weatherMain == 'Thunderstorm' ||
                  weatherMain == 'Drizzle')) {
            String timeStr = DateFormat('HH:mm').format(date);
            foundRainAlert =
                "Hujan ($description) diprediksi pukul $timeStr. Cek drainase.";
          }

          // --- PERBAIKAN DI SINI ---
          // Kita menghapus filter "date.hour % 4 == 0".
          // Kita langsung masukkan semua data karena API defaultnya sudah per 3 Jam.
          // (00:00, 03:00, 06:00, 09:00, 12:00, dst...)
          filteredList.add(item);
        }

        setState(() {
          currentWeather = currentData;
          forecastList = filteredList;
          rainAlertMessage = foundRainAlert;
          isRainPredicted = foundRainAlert != null;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Gagal Connect API (Code: ${responseCurrent.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileHeader(formattedDate),

                          const SizedBox(height: 20),
                          _buildMainWeatherCard(),

                          const SizedBox(height: 20),
                          _buildAlertBox(),

                          const SizedBox(height: 24),

                          // --- PREDIKSI CUACA ---
                          _buildSectionTitle(
                              'Prediksi Cuaca (Per 3 Jam)', 'Lihat Semua'),
                          const SizedBox(height: 12),
                          _buildForecastList(),

                          const SizedBox(height: 24),

                          // --- TIPS PERTANIAN ---
                          _buildSectionTitle('Tips Pertanian', 'Lihat Semua'),
                          const SizedBox(height: 12),
                          _buildFarmingTips(),

                          const SizedBox(height: 24),

                          // --- AKSES CEPAT ---
                          const Text(
                            'Akses Cepat',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildQuickAccess(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Komunitas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_library), label: 'Video'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Lainnya'),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Text(actionText,
                  style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Icon(Icons.chevron_right, color: Colors.green[700], size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastList() {
    return SizedBox(
      height: 170, // Tinggi disesuaikan
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: forecastList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          var item = forecastList[index];
          DateTime date = DateTime.parse(item['dt_txt']);

          String dayName = DateFormat('EEE', 'id_ID').format(date); // Sen, Sel
          String timeText = DateFormat('HH:mm').format(date); // 09:00, 12:00
          String temp = item['main']['temp'].toStringAsFixed(0);
          String iconCode = item['weather'][0]['icon'];
          String description = item['weather'][0]['description'];

          return Container(
            width: 100, // Lebar kartu
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
                // Hari
                Text(dayName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),

                // JAM (Per 3 Jam)
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
                // Deskripsi Cuaca (Hujan sedang, Awan pecah, dll)
                Text(
                  description,
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

  Widget _buildFarmingTips() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: farmingTips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          var tip = farmingTips[index];
          return Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    tip['image']!,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                        color: Colors.grey[300],
                        height: 90,
                        child: const Icon(Icons.image)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['category']!,
                        style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAccess() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.videocam,
        'label': 'Video',
        'color': Colors.green[100],
        'iconColor': Colors.green[800]
      },
      {
        'icon': Icons.calendar_today,
        'label': 'Kalender',
        'color': Colors.green[100],
        'iconColor': Colors.green[800]
      },
      {
        'icon': Icons.pest_control,
        'label': 'Info Hama',
        'color': Colors.green[100],
        'iconColor': Colors.green[800]
      },
      {
        'icon': Icons.people_outline,
        'label': 'Forum',
        'color': Colors.green[100],
        'iconColor': Colors.green[800]
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item['color'],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item['icon'], color: item['iconColor'], size: 28),
            ),
            const SizedBox(height: 8),
            Text(item['label'],
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProfileHeader(String date) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/profiles.jpg'),
            backgroundColor: Colors.grey,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Petani Maju',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    if (currentWeather == null) return const SizedBox();
    var main = currentWeather!['main'];
    var weather = currentWeather!['weather'][0];

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(currentWeather!['name'] ?? '-',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${main['temp'].toStringAsFixed(0)}°',
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(weather['description'].toString().toUpperCase(),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
              Image.network(getIconUrl(weather['icon']),
                  width: 100, fit: BoxFit.cover),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBox() {
    if (!isRainPredicted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_active_outlined,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERINGATAN CUACA!',
                  style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  rainAlertMessage ?? "Hujan diprediksi turun.",
                  style: TextStyle(color: Colors.red[900], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
