import 'package:supabase_flutter/supabase_flutter.dart';

class PestService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPests({String? query}) async {
    try {
      var dbQuery = _supabase.from('hama').select();

      if (query != null && query.isNotEmpty) {
        dbQuery = dbQuery.ilike('nama', '%$query%');
      }

      final response = await dbQuery.order('nama', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat data hama: $e');
    }
  }
}
