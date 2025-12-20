// lib/features/pests/screens/pest_detail_screen.dart

import 'package:flutter/material.dart';

class PestDetailScreen extends StatelessWidget {
  // 1. Terima data pest dari halaman sebelumnya
  final Map<String, dynamic> pest;

  const PestDetailScreen({super.key, required this.pest});

  @override
  Widget build(BuildContext context) {
    // Ambil data dengan fallback value jika null
    final String title = pest['nama'] ?? 'Detail Hama';
    final String category = pest['kategori'] ?? 'Umum';
    final String imageUrl = pest['gambar_url'] ?? '';
    final String characteristics = pest['ciri_ciri'] ??
        pest['deskripsi'] ??
        'Belum ada informasi ciri-ciri.';
    // Kita asumsikan data dampak dipisahkan baris baru (\n) di database
    final String rawDampak = pest['dampak'] ?? 'Belum ada informasi dampak.';
    final List<String> impactList = rawDampak.split('\n');
    final String solution =
        pest['cara_mengatasi'] ?? 'Belum ada informasi penanganan.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Judul Dinamis
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Dinamis
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Center(
                              child: Icon(Icons.broken_image, size: 50)),
                        )
                      : const Center(child: Icon(Icons.image, size: 50)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori Dinamis
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(category,
                            style: const TextStyle(color: Colors.green)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Bagian Ciri-ciri
                      _buildInfoSection('Ciri-ciri', characteristics),

                      const SizedBox(height: 16),

                      // Bagian Dampak (Looping Bullet Points)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dampak',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Generate bullet points dari data
                            ...impactList
                                .map((item) => _buildBulletPoint(item)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Cara Mengatasi
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Tampilkan cara mengatasi dalam BottomSheet
                  _showSolutionBottomSheet(context, solution);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cara Mengatasi',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(text.trim(),
                  style: TextStyle(color: Colors.grey[700], fontSize: 16))),
        ],
      ),
    );
  }

  void _showSolutionBottomSheet(BuildContext context, String solution) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cara Mengatasi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(solution, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
