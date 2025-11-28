import 'package:flutter/material.dart';
import 'package:petani_maju/screen/homescreen.dart';

void main() {
  // Tidak perlu async atau WidgetsFlutterBinding jika tidak ada inisialisasi berat di awal
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petani Maju',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
