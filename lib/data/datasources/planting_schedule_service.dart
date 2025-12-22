// lib/data/datasources/planting_schedule_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class PlantingScheduleService {
  final _supabase = Supabase.instance.client;

  // 1. Ambil semua jadwal tanam
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

  // 2. Tambah jadwal baru
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
        // Anda bisa menambahkan logika hitung estimasi panen di sini jika mau
      });
    } catch (e) {
      throw Exception('Gagal menambahkan jadwal: $e');
    }
  }

  // 3. Hapus jadwal (Opsional)
  Future<void> deleteSchedule(int id) async {
    try {
      await _supabase.from('jadwal_tanam').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus jadwal: $e');
    }
  }
}
