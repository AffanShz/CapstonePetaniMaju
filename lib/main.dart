import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petani_maju/data/datasources/cache_service.dart';
import 'package:petani_maju/widgets/navbaar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await CacheService.init();

  await Supabase.initialize(
    url: 'https://hlfkxflasywitfwbkrxu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsZmt4Zmxhc3l3aXRmd2Jrcnh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MDkyODksImV4cCI6MjA3OTI4NTI4OX0._gM2FcSnP_sAzOhd_2HDLo_zwIc1Y0KclZaNBkEDIy4',
  );

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
