import 'dart:async';
import 'package:flutter/material.dart';
import 'package:petani_maju/screen/homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animasi Logo (Muncul perlahan dan membesar sedikit)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // 2. Timer untuk pindah halaman setelah 3 detik
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        // Custom Route untuk Transisi yang Halus (Fade Transition)
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration:
              const Duration(milliseconds: 800), // Durasi transisi perpindahan
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff1B5E20), // Warna Hijau Gelap sesuai referensi
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                );
              },
              child: _buildLogo(), // Widget Logo Custom
            ),

            const SizedBox(height: 24),

            // Teks Judul (Muncul dengan Fade)
            FadeTransition(
              opacity: _opacityAnimation,
              child: const Text(
                'PetaniMaju',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Teks Slogan
            FadeTransition(
              opacity: _opacityAnimation,
              child: const Text(
                'Solusi Pertanian Modern Indonesia',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat Logo mirip gambar referensi (Tanpa file aset)
  Widget _buildLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran Kuning Besar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange[400], // Warna Oranye/Kuning
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_outlined,
                color: Colors.white, size: 50),
          ),
          // Lingkaran Putih Kecil di Pojok Kanan Bawah
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xff1B5E20), // Hijau senada background
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
