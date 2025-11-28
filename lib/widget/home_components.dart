import 'package:flutter/material.dart';
import 'package:petani_maju/models/petani_models.dart';

// --- Kartu Cuaca (Hijau Besar) ---
class WeatherCard extends StatelessWidget {
  final WeatherModel data;

  const WeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32), // Hijau PetaniMaju
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
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
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        data.location,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${data.temp}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    data.condition,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 70),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStat(Icons.water_drop_outlined, "${data.humidity}%"),
              const SizedBox(width: 20),
              _buildStat(Icons.air, "${data.windSpeed} km/h"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

// --- Banner Alert Merah ---
class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // Pink kemerahan
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ALERT CUACA EKSTREM!",
                  style: TextStyle(
                      color: Colors.red.shade900, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hujan lebat diprediksi 2 hari ke depan. Pastikan drainase sawah optimal.",
                  style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- Item Forecast (Prediksi Harian) ---
class ForecastItem extends StatelessWidget {
  final ForecastModel item;

  const ForecastItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(item.day, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Icon(
            item.iconType == 'rain'
                ? Icons.cloud_queue
                : Icons.wb_sunny_rounded,
            color: item.iconType == 'rain' ? Colors.blue : Colors.orange,
          ),
          const SizedBox(height: 12),
          Text("${item.maxTemp}",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text("°${item.minTemp}",
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// --- Item Tips Pertanian ---
class TipsCard extends StatelessWidget {
  final TipsModel data;

  const TipsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              // image: DecorationImage(...) // Gunakan NetworkImage jika ada URL
            ),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.category,
                  style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Tombol Akses Cepat ---
class QuickAccessBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const QuickAccessBtn(
      {super.key,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
