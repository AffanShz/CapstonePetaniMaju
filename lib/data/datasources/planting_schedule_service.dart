import 'package:supabase_flutter/supabase_flutter.dart';

class PlantingScheduleService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchSchedules() async {
    try {
      final response = await _supabase
          .from('jadwal_tanam')
          .select()
          .order('tanggal_tanam', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil jadwal: $e');
    }
  }

  Future<void> addSchedule({
    required String namaTanaman,
    required DateTime tanggalTanam,
    String? catatan,
  }) async {
    try {
      await _supabase.from('jadwal_tanam').insert({
        'nama_tanaman': namaTanaman,
        'tanggal_tanam': tanggalTanam.toIso8601String(),
        'catatan': catatan,
      });
    } catch (e) {
      throw Exception('Gagal menambahkan jadwal: $e');
    }
  }

  Future<void> updateSchedule({
    required int id,
    required String namaTanaman,
    required DateTime tanggalTanam,
    String? catatan,
  }) async {
    try {
      await _supabase.from('jadwal_tanam').update({
        'nama_tanaman': namaTanaman,
        'tanggal_tanam': tanggalTanam.toIso8601String(),
        'catatan': catatan,
      }).eq('id', id); 
    } catch (e) {
      throw Exception('Gagal mengupdate jadwal: $e');
    }
  }

  // 3. Hapus jadwal (kode lama tetap)
  Future<void> deleteSchedule(int id) async {
    try {
      await _supabase.from('jadwal_tanam').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus jadwal: $e');
    }
  }
}
