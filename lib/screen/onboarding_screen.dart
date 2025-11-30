import 'package:flutter/material.dart';
import 'package:petani_maju/screen/homescreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Data konten onboarding (Text dan Gambar)
  List<OnboardingContent> contents = [
    OnboardingContent(
      title: 'Prediksi Cuaca Akurat',
      description:
          'Dapatkan prediksi cuaca akurat untuk panen optimal Anda. Data real-time dan forecast 7 hari.',
      image:
          'https://images.unsplash.com/photo-1534274988754-84542387130f?auto=format&fit=crop&q=80&w=600', // Gambar Langit/Awan
    ),
    OnboardingContent(
      title: 'Tips Pertanian Praktis',
      description:
          'Tips pertanian praktis langsung di genggaman. Panduan lengkap dari ahli.',
      image:
          'https://images.unsplash.com/photo-1625246333195-551e512c9148?auto=format&fit=crop&q=80&w=600', // Gambar Tanaman Jagung
    ),
    OnboardingContent(
      title: 'Video Tutorial Tani',
      description:
          'Pelajari teknik pertanian modern melalui video tutorial interaktif.',
      image:
          'https://images.unsplash.com/photo-1492496913980-501348b61469?auto=format&fit=crop&q=80&w=600', // Gambar Petani Membajak
    ),
    OnboardingContent(
      title: 'Komunitas Petani',
      description:
          'Bergabunglah dengan komunitas petani se-Indonesia. Berbagi pengalaman dan solusi.',
      image:
          'https://images.unsplash.com/photo-1591035897819-f4bdf739f446?auto=format&fit=crop&q=80&w=600', // Gambar Orang/Komunitas
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Warna background cream/putih
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gambar dengan sudut melengkung
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(contents[i].image),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Judul
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1B5E20), // Hijau Gelap
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Deskripsi
                        Text(
                          contents[i].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indikator Titik (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => buildDot(index, context),
              ),
            ),

            // Bagian Tombol Bawah
            Container(
              height: 60,
              margin: const EdgeInsets.all(40),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (currentIndex == contents.length - 1) {
                    // Jika halaman terakhir, pindah ke HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  } else {
                    // Jika belum, geser ke halaman berikutnya
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1B5E20), // Warna Hijau
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  currentIndex == contents.length - 1
                      ? "Mulai Sekarang"
                      : "Lanjut",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Tombol Lewati (Hanya muncul jika bukan halaman terakhir)
            if (currentIndex != contents.length - 1)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Lewati",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat titik indikator
  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 8,
      width: currentIndex == index
          ? 20
          : 8, // Jika aktif jadi panjang (pill shape)
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index
            ? const Color(0xff1B5E20)
            : Colors.grey.shade300,
      ),
    );
  }
}

// Model Data Sederhana untuk Konten
class OnboardingContent {
  String image;
  String title;
  String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
