import 'package:flutter/material.dart';
import 'package:petani_maju/features/home/widgets/quick_access_item.dart';
import 'package:petani_maju/features/weather/screens/weather_detail_screen.dart';
import 'package:petani_maju/features/pests/screens/pest_screen.dart';

class QuickAccess extends StatelessWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickAccessItem(
                icon: Icons.cloud_outlined,
                title: 'Cuaca',
                subtitle: 'Prakiraan 7 hari',
                iconColor: const Color(0xFF2196F3), // Blue
                backgroundColor: const Color(0xFFE3F2FD), // Light blue
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeatherDetailScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickAccessItem(
                icon: Icons.bug_report_outlined,
                title: 'Info Hama',
                subtitle: 'Penyakit tanaman',
                iconColor: Colors.red, // Red
                backgroundColor: Colors.red.shade50, // Light red
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PestScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
