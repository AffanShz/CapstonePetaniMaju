import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petani_maju/core/services/cache_service.dart';
import 'package:petani_maju/widgets/navbaar.dart';
import 'package:petani_maju/core/services/notification_service.dart';

// Global flag to track if app started offline
bool appStartedOffline = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive for local caching
  await CacheService.init();

  // PERBAIKAN: Gunakan NotificationService() dengan tanda kurung karena sekarang Singleton
  await NotificationService().init();

  // Initialize Supabase with timeout to prevent hanging when offline
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    ).timeout(const Duration(seconds: 10));
    appStartedOffline = false;
  } on TimeoutException {
    debugPrint('Supabase initialization timeout - continuing offline');
    appStartedOffline = true;
    // Set offline mode automatically when no internet
    CacheService().setOfflineMode(true);
  } catch (e) {
    debugPrint('Supabase initialization error: $e - continuing offline');
    appStartedOffline = true;
    CacheService().setOfflineMode(true);
  }

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
      home: const _AppWrapper(),
    );
  }
}

// Wrapper to show offline message on startup
class _AppWrapper extends StatefulWidget {
  const _AppWrapper();

  @override
  State<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<_AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Show offline message after build completes
    if (appStartedOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOfflineMessage();
      });
    }
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada koneksi internet. Aplikasi berjalan dalam mode offline.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}
