// lib/features/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:petani_maju/data/datasources/planting_schedule_service.dart';
import 'package:petani_maju/core/services/notification_service.dart';

// ==========================================
// 1. WIDGET PICKER JAM KHUSUS LANSIA (REVISI)
// ==========================================

class ElderlyTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const ElderlyTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<ElderlyTimePicker> createState() => _ElderlyTimePickerState();
}

class _ElderlyTimePickerState extends State<ElderlyTimePicker> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
  }

  // PENTING: Update state jika parent widget mengirim waktu baru
  @override
  void didUpdateWidget(covariant ElderlyTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      setState(() {
        _hour = widget.initialTime.hour;
        _minute = widget.initialTime.minute;
      });
    }
  }

  void _notifyParent() {
    widget.onTimeChanged(TimeOfDay(hour: _hour, minute: _minute));
  }

  void _changeHour(int delta) {
    setState(() {
      _hour += delta;
      if (_hour > 23) _hour = 0;
      if (_hour < 0) _hour = 23;
    });
    _notifyParent();
  }

  void _changeMinute(int delta) {
    setState(() {
      // Bulatkan ke kelipatan 10 terdekat dulu jika angka ganjil
      if (_minute % 10 != 0) {
        _minute = ((_minute / 10).round() * 10);
      }

      _minute += delta;

      if (_minute >= 60) {
        _minute = 0;
        _changeHour(1); // Otomatis nambah jam jika menit lewat 60
      } else if (_minute < 0) {
        _minute = 50;
        _changeHour(-1); // Otomatis kurang jam jika menit kurang dari 0
      }
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // A. TOMBOL PRESET (Pagi / Sore)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPresetButton("Pagi ☀️", 7, 0),
            _buildPresetButton("Sore 🌤️", 16, 0),
          ],
        ),
        const SizedBox(height: 16),

        // B. KONTROL UTAMA
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // JAM
            _buildControl(
              value: _hour,
              label: "JAM",
              onUp: () => _changeHour(1),
              onDown: () => _changeHour(-1),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(":",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            ),

            // MENIT
            _buildControl(
              value: _minute,
              label: "MENIT",
              onUp: () => _changeMinute(10),
              onDown: () => _changeMinute(-10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, int h, int m) {
    bool isSelected = _hour == h;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _hour = h;
          _minute = m;
        });
        _notifyParent();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }

  Widget _buildControl({
    required int value,
    required String label,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onUp,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.keyboard_arrow_up_rounded,
                size: 40, color: Colors.green),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onDown,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 40, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. MAIN SCREEN
// ==========================================

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

                                  // Parse Jam
                                  String timeString = '-';
                                  try {
                                    final dt =
                                        DateTime.parse(event['tanggal_tanam']);
                                    timeString = DateFormat('HH:mm').format(dt);
                                  } catch (_) {}

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
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Pukul: $timeString WIB",
                                              style: TextStyle(
                                                  color: Colors.green[800],
                                                  fontWeight: FontWeight.w600)),
                                          Text(event['catatan'] ?? '-',
                                              maxLines: 1),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                _showScheduleDialog(context,
                                                    isEdit: true, event: event),
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

  // ==========================================
  // 3. DIALOG INPUT JADWAL (FIXED STATE)
  // ==========================================

  void _showScheduleDialog(BuildContext context,
      {required bool isEdit, Map<String, dynamic>? event}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    // Default 07:00 Pagi
    TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);

    if (isEdit && event != null) {
      nameController.text = event['nama_tanaman'];
      noteController.text = event['catatan'] ?? '';
      try {
        DateTime dt = DateTime.parse(event['tanggal_tanam']);
        selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder digunakan untuk merubah teks jam di bawah picker ketika picker berubah
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(isEdit ? 'Ubah Jadwal' : 'Tambah Jadwal',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tanam apa?',
                        hintText: 'Contoh: Padi',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Catatan',
                        hintText: 'Contoh: Pupuk',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // LABEL JAM
                    const Text("Pilih Jam Kegiatan:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // PICKER JAM LANSIA
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.2)),
                      ),
                      child: ElderlyTimePicker(
                        initialTime: selectedTime,
                        onTimeChanged: (newTime) {
                          // Update variabel lokal
                          selectedTime = newTime;
                          // PENTING: Update UI Dialog agar teks di bawah ikut berubah
                          setStateDialog(() {});
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // INDIKATOR JAM TERPILIH (Agar user yakin jam sudah berubah)
                    Text(
                      "Waktu Terpilih: ${selectedTime.format(context)}",
                      style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isNotEmpty) {
                            // GABUNG TANGGAL + JAM
                            final DateTime finalDateTime = DateTime(
                              _selectedDay!.year,
                              _selectedDay!.month,
                              _selectedDay!.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            if (isEdit && event != null) {
                              await _scheduleService.updateSchedule(
                                id: event['id'],
                                namaTanaman: nameController.text,
                                tanggalTanam: finalDateTime,
                                catatan: noteController.text,
                              );
                            } else {
                              await _scheduleService.addSchedule(
                                namaTanaman: nameController.text,
                                tanggalTanam: finalDateTime,
                                catatan: noteController.text,
                              );

                              // NOTIFIKASI
                              int baseId =
                                  DateTime.now().millisecondsSinceEpoch ~/ 1000;
                              // H-16 Jam
                              await NotificationService().scheduleNotification(
                                id: baseId + 1,
                                title: 'Persiapan: ${nameController.text}',
                                body:
                                    'Besok jam ${selectedTime.format(context)} ada kegiatan.',
                                scheduledDate: finalDateTime
                                    .subtract(const Duration(hours: 16)),
                              );
                              // H-8 Jam
                              await NotificationService().scheduleNotification(
                                id: baseId + 2,
                                title: 'Ingat: ${nameController.text}',
                                body:
                                    'Nanti jam ${selectedTime.format(context)} ke sawah.',
                                scheduledDate: finalDateTime
                                    .subtract(const Duration(hours: 8)),
                              );
                            }

                            if (mounted) {
                              Navigator.pop(context);
                              _loadSchedules();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isEdit ? 'Simpan' : 'Simpan',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
