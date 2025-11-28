import 'package:flutter/material.dart';
import 'package:petani_maju/models/petani_models.dart';
import '../widget/home_components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Data Dummy ---
    final weatherNow = WeatherModel(
      location: "Subang, Jawa Barat",
      temp: 32,
      condition: "Cerah Berawan",
      humidity: 65,
      windSpeed: 12,
    );

    final forecasts = [
      ForecastModel("Sen", 30, 25, 'rain'),
      ForecastModel("Sel", 31, 26, 'rain'),
      ForecastModel("Rab", 32, 27, 'sunny'),
      ForecastModel("Kam", 33, 28, 'sunny'),
      ForecastModel("Jum", 31, 26, 'rain'),
    ];

    final tips = [
      TipsModel("Padi", "Cara Menanam Padi", ""),
      TipsModel("Nutrisi", "Pemupukan Efektif", ""),
      TipsModel("Hama", "Cegah Wereng", ""),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // --- AppBar Custom ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80, // Sedikit lebih tinggi
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wb_sunny, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "PetaniMaju",
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Last sync: 5 menit lalu",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 1. Weather Card
            WeatherCard(data: weatherNow),

            // 2. Alert Banner
            const AlertBanner(),

            // 3. Forecast Section
            _buildSectionHeader("Prediksi 7 Hari"),
            SizedBox(
              height: 155,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: forecasts.length,
                itemBuilder: (context, index) {
                  return ForecastItem(item: forecasts[index]);
                },
              ),
            ),

            // 4. Tips Pertanian
            const SizedBox(height: 24),
            _buildSectionHeader("Tips Pertanian"),
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  return TipsCard(data: tips[index]);
                },
              ),
            ),

            // 5. Akses Cepat
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Akses Cepat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      QuickAccessBtn(
                          label: "Video",
                          icon: Icons.videocam_rounded,
                          color: Color(0xFF2E7D32)),
                      QuickAccessBtn(
                          label: "Kalender",
                          icon: Icons.calendar_month_rounded,
                          color: Color(0xFF2E7D32)),
                      QuickAccessBtn(
                          label: "Info Hama",
                          icon: Icons.pest_control,
                          color: Color(0xFF2E7D32)),
                      QuickAccessBtn(
                          label: "Forum",
                          icon: Icons.people_alt_rounded,
                          color: Color(0xFF2E7D32)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: const [
              Text("Lihat Semua",
                  style: TextStyle(
                      color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, color: Color(0xFF2E7D32)),
            ],
          ),
        ],
      ),
    );
  }
}
