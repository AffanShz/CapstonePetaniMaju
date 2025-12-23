import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class TipsService {
  final _supabase = Supabase.instance.client;

  // Timeout for requests
  static const Duration _timeout = Duration(seconds: 10);

  // Fungsi mengambil semua tips
  Future<List<Map<String, dynamic>>> fetchTips() async {
    try {
      // Select semua kolom dari tabel 'tips', urutkan dari yang terbaru
      final response = await _supabase
          .from('tips')
          .select()
          .order('created_at', ascending: false)
          .timeout(_timeout);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat tips: $e');
    }
  }
}
