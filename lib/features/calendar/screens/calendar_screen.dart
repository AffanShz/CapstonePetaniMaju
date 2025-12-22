// lib/features/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:petani_maju/data/datasources/planting_schedule_service.dart';
import 'package:petani_maju/core/services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final PlantingScheduleService _scheduleService = PlantingScheduleService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final data = await _scheduleService.fetchSchedules();
      final newEvents = <DateTime, List<dynamic>>{};

      for (var item in data) {
        final date = DateTime.parse(item['tanggal_tanam']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Tanam')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(context, isEdit: false),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                  color: Colors.greenAccent, shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              markerDecoration:
                  BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 16.0),
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
                            ? const Center(
                                child: Text('Tidak ada jadwal tanam.',
                                    style: TextStyle(color: Colors.grey)))
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
                                      subtitle: Text(event['catatan'] ?? '-'),
                                      // Mengganti trailing icon delete dengan Row isi Edit & Delete
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              // Panggil dialog Edit dengan data event yang diklik
                                              _showScheduleDialog(context,
                                                  isEdit: true, event: event);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _confirmDelete(event['id']),
                                          ),
                                        ],
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

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _scheduleService.deleteSchedule(id);
              _loadSchedules();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialog yang digabung untuk Tambah (isEdit=false) dan Edit (isEdit=true)
  void _showScheduleDialog(BuildContext context,
      {required bool isEdit, Map<String, dynamic>? event}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    // Jika Edit, isi text field dengan data lama
    if (isEdit && event != null) {
      nameController.text = event['nama_tanaman'];
      noteController.text = event['catatan'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Ubah Jadwal Tanam' : 'Tambah Jadwal Tanam'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Nama Tanaman', hintText: 'Contoh: Padi'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                      labelText: 'Catatan', hintText: 'Contoh: Pupuk NPK'),
                ),
                const SizedBox(height: 12),
                Text(
                    'Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDay!)}',
                    style: const TextStyle(color: Colors.grey)),
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
                  if (isEdit && event != null) {
                    // Logika UPDATE
                    await _scheduleService.updateSchedule(
                      id: event['id'], // ID diperlukan untuk update
                      namaTanaman: nameController.text,
                      tanggalTanam:
                          _selectedDay!, // Tanggal tetap sesuai kalender yg dipilih, atau bisa dibuat picker sendiri
                      catatan: noteController.text,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Jadwal berhasil diperbarui!')));
                    }
                  } else {
                    // Logika TAMBAH BARU
                    await _scheduleService.addSchedule(
                      namaTanaman: nameController.text,
                      tanggalTanam: _selectedDay!,
                      catatan: noteController.text,
                    );

                    // Jadwalkan notifikasi (opsional)
                    NotificationService.scheduleNotification(
                      id: DateTime.now().millisecond,
                      title: 'Jadwal Tanam: ${nameController.text}',
                      body: 'Cek jadwal tanam kamu hari ini!',
                      scheduledDate:
                          DateTime.now().add(const Duration(seconds: 5)),
                    );
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _loadSchedules(); // Refresh list
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
