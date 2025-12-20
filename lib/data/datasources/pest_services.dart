import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PestService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPests({String? query}) async {
    try {
      debugPrint('PestService: Fetching pests from Supabase...');

      var dbQuery = _supabase.from('hama').select();

      if (query != null && query.isNotEmpty) {
        dbQuery = dbQuery.ilike('nama', '%$query%');
      }

      final response = await dbQuery.order('nama', ascending: true);

      debugPrint('PestService: Successfully fetched ${response.length} pests');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('PestService Error: $e');
      rethrow;
    }
  }

  /// Fetch a single pest by ID
  Future<Map<String, dynamic>?> fetchPestById(int id) async {
    try {
      final response =
          await _supabase.from('hama').select().eq('id', id).maybeSingle();

      return response;
    } catch (e) {
      debugPrint('PestService Error fetching pest by ID: $e');
      rethrow;
    }
  }
}
