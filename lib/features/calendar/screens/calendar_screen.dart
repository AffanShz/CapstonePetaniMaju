// lib/features/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:petani_maju/data/datasources/planting_schedule_service.dart';
import 'package:petani_maju/core/services/notification_service.dart'; // Import Notifikasi

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Service Supabase
  final PlantingScheduleService _scheduleService = PlantingScheduleService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Data Event dari Supabase
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSchedules(); // Ambil data dari Supabase saat buka layar
  }

  // --- LOGIKA SUPABASE ---

  Future<void> _loadSchedules() async {
    try {
      final data = await _scheduleService.fetchSchedules();
      final newEvents = <DateTime, List<dynamic>>{};

      for (var item in data) {
        final date = DateTime.parse(item['tanggal_tanam']);
        // Normalisasi tanggal (hilangkan jam/menit)
        final dateKey = DateTime(date.year, date.month, date.day);

        if (newEvents[dateKey] == null) {
          newEvents[dateKey] = [];
        }
        newEvents[dateKey]!.add(item);
      }

      if (mounted) {
        setState(() {
          _events = newEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Tanam'),
      ),

      // Tombol Tambah dengan Dialog
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // 1. WIDGET KALENDER (Table Calendar)
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            // Menampilkan titik marker jika ada event
            eventLoader: _getEventsForDay,

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            // Styling Kalender
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.orange, // Warna titik event
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 16.0),

          // 2. LIST KEGIATAN DI BAWAH
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Kegiatan: ${DateFormat('dd MMM yyyy').format(_selectedDay!)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _getEventsForDay(_selectedDay!).isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.event_note,
                                        size: 50, color: Colors.grey[300]),
                                    const SizedBox(height: 8),
                                    const Text('Tidak ada jadwal tanam.',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    _getEventsForDay(_selectedDay!).length,
                                itemBuilder: (context, index) {
                                  final event =
                                      _getEventsForDay(_selectedDay!)[index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green[100],
                                        child: const Icon(Icons.grass,
                                            color: Colors.green),
                                      ),
                                      title: Text(event['nama_tanaman'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          event['catatan'] ?? 'Tanpa catatan'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _confirmDelete(event['id']),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG & ACTIONS ---

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Hapus dari Supabase
              await _scheduleService.deleteSchedule(id);
              // Refresh tampilan
              _loadSchedules();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController timeController =
        TextEditingController(); // Controller Waktu

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Jadwal Tanam'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan / Tanaman',
                    hintText: 'Contoh: Pupuk Padi',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    hintText: 'Contoh: Gunakan NPK',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Waktu (Opsional)',
                    hintText: '08:00',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                        'Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDay!)}'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  // 1. Simpan ke Supabase
                  await _scheduleService.addSchedule(
                    namaTanaman: nameController.text,
                    tanggalTanam: _selectedDay!,
                    catatan: noteController.text,
                  );

                  // 2. Jadwalkan Notifikasi (Fitur dari kode Anda sebelumnya)
                  NotificationService.scheduleNotification(
                    id: DateTime.now().millisecond,
                    title: 'Pengingat Petani Maju',
                    body: 'Kegiatan: ${nameController.text} hari ini!',
                    // Demo: 5 detik dari sekarang, realitanya bisa diset H-1
                    scheduledDate:
                        DateTime.now().add(const Duration(seconds: 5)),
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Jadwal disimpan & Pengingat aktif!')),
                    );
                    _loadSchedules(); // Refresh kalender
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
