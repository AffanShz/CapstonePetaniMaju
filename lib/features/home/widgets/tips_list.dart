import 'package:flutter/material.dart';
import 'package:petani_maju/features/home/widgets/tip_item.dart';
import 'package:petani_maju/data/datasources/tips_services.dart';

class TipsList extends StatefulWidget {
  const TipsList({super.key});

  @override
  State<TipsList> createState() => _TipsListState();
}

class _TipsListState extends State<TipsList> {
  final TipsService _tipsService = TipsService();
  late Future<List<Map<String, dynamic>>> _tipsFuture;

  @override
  void initState() {
    super.initState();
    _tipsFuture = _tipsService.fetchTips();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada tips tersedia"));
          }

          final tips = snapshot.data!;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4), // Biar rapi
            itemCount: tips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return TipItem(
                image: tip['image_url'] ??
                    'https://via.placeholder.com/300', // Gambar default jika null
                category: tip['category'] ?? 'Umum',
                title: tip['title'] ?? 'Tanpa Judul',
              );
            },
          );
        },
      ),
    );
  }
}
