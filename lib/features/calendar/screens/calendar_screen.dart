// lib/features/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:petani_maju/features/calendar/bloc/calendar_bloc.dart';
import 'package:petani_maju/core/services/notification_service.dart';

// ==========================================
// 1. WIDGET PICKER JAM KHUSUS LANSIA
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
      if (_minute % 10 != 0) {
        _minute = ((_minute / 10).round() * 10);
      }
      _minute += delta;
      if (_minute >= 60) {
        _minute = 0;
        _changeHour(1);
      } else if (_minute < 0) {
        _minute = 50;
        _changeHour(-1);
      }
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPresetButton("Pagi ☀️", 7, 0),
            _buildPresetButton("Sore 🌤️", 16, 0),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControl(
              value: _hour,
              label: "JAM",
              onUp: () => _changeHour(1),
              onDown: () => _changeHour(-1),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(":",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54)),
            ),
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
        backgroundColor: isSelected ? Colors.green : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        side: BorderSide(color: isSelected ? Colors.green : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.keyboard_arrow_up_rounded,
                size: 32, color: Colors.green),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onDown,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 32, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. MAIN SCREEN - REFACTORED WITH BLOC
// ==========================================

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(context, isEdit: false),
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is CalendarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CalendarInitial || state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarLoaded) {
            return _buildContent(context, state);
          }

          if (state is CalendarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CalendarBloc>().add(LoadSchedules());
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CalendarLoaded state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Kalender Tanam',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 24),

            // 2. CALENDAR CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(bottom: 12),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: state.focusedDate,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) =>
                    isSameDay(state.selectedDate, day),
                eventLoader: (day) => state.getEventsForDay(day),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, size: 20),
                  rightChevronIcon: Icon(Icons.chevron_right, size: 20),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  context
                      .read<CalendarBloc>()
                      .add(SelectDate(date: selectedDay));
                },
                onPageChanged: (focusedDay) {
                  // Just update local format, bloc handles date state
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  outsideDaysVisible: false,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. KEGIATAN HARI INI
            const Text(
              'Kegiatan Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildEventsList(context, state),

            const SizedBox(height: 24),

            // 4. REKOMENDASI AKTIVITAS
            const Text(
              'Rekomendasi Aktivitas Bulan Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildRecommendationCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, CalendarLoaded state) {
    final events = state.getEventsForDay(state.selectedDate);

    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Tidak ada jadwal tanam.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        String timeString = '-';
        try {
          final dt = DateTime.parse(event['tanggal_tanam']);
          timeString = DateFormat('HH:mm').format(dt);
        } catch (_) {}

        Color accentColor = index % 2 == 0 ? Colors.green : Colors.orange;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event['nama_tanaman'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                timeString,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['catatan'] ?? '-',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size: 20, color: Colors.blue),
                      onPressed: () => _showScheduleDialog(context,
                          isEdit: true, event: event),
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      onPressed: () => _confirmDelete(context, event['id']),
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.spa, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Persiapan Musim Tanam',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationItem(
              'Pengolahan lahan untuk musim tanam berikutnya'),
          const SizedBox(height: 8),
          _buildRecommendationItem('Persiapan bibit unggul'),
          const SizedBox(height: 8),
          _buildRecommendationItem('Perbaikan sistem irigasi'),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Icon(Icons.circle, size: 6, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, int id) {
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

              // Delete via BLoC
              context.read<CalendarBloc>().add(DeleteSchedule(id: id));

              // Cancel notifications
              final notif = NotificationService();
              await notif.cancelNotification(id * 10 + 0);
              await notif.cancelNotification(id * 10 + 1);
              await notif.cancelNotification(id * 10 + 2);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. DIALOG INPUT JADWAL
  // ==========================================

  void _showScheduleDialog(BuildContext scaffoldContext,
      {required bool isEdit, Map<String, dynamic>? event}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);

    if (isEdit && event != null) {
      nameController.text = event['nama_tanaman'];
      noteController.text = event['catatan'] ?? '';
      try {
        DateTime dt = DateTime.parse(event['tanggal_tanam']);
        selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isEdit ? 'Ubah Jadwal' : 'Tambah Jadwal Baru',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildModernInput(
                      controller: nameController,
                      label: 'Tanam apa?',
                      icon: Icons.eco_outlined,
                      hint: 'Misal: Padi, Jagung',
                    ),
                    const SizedBox(height: 16),
                    _buildModernInput(
                      controller: noteController,
                      label: 'Catatan tambahan',
                      icon: Icons.note_alt_outlined,
                      hint: 'Misal: Pupuk kandang',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Pilih Waktu Kegiatan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ElderlyTimePicker(
                        initialTime: selectedTime,
                        onTimeChanged: (newTime) {
                          selectedTime = newTime;
                          setStateModal(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: Colors.grey[600],
                            ),
                            child: const Text('Batal',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isNotEmpty) {
                                // Get selected date from BLoC state
                                final blocState =
                                    scaffoldContext.read<CalendarBloc>().state;
                                DateTime selectedDate = DateTime.now();
                                if (blocState is CalendarLoaded) {
                                  selectedDate = blocState.selectedDate;
                                }

                                final DateTime finalDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );

                                if (isEdit && event != null) {
                                  int scheduleId = event['id'];

                                  // Update via BLoC
                                  scaffoldContext.read<CalendarBloc>().add(
                                        UpdateSchedule(
                                          id: scheduleId,
                                          namaTanaman: nameController.text,
                                          tanggalTanam: finalDateTime,
                                          catatan: noteController.text,
                                        ),
                                      );

                                  // Cancel old notifications
                                  final notif = NotificationService();
                                  await notif
                                      .cancelNotification(scheduleId * 10 + 0);
                                  await notif
                                      .cancelNotification(scheduleId * 10 + 1);
                                  await notif
                                      .cancelNotification(scheduleId * 10 + 2);

                                  // Schedule new notifications
                                  await _scheduleNotifications(
                                    scheduleId,
                                    nameController.text,
                                    finalDateTime,
                                    selectedTime,
                                  );
                                } else {
                                  // Add via BLoC
                                  scaffoldContext.read<CalendarBloc>().add(
                                        AddSchedule(
                                          namaTanaman: nameController.text,
                                          tanggalTanam: finalDateTime,
                                          catatan: noteController.text,
                                        ),
                                      );

                                  // Note: For new schedules, we'd need the ID from bloc
                                  // For now, notifications for new items need manual handling
                                }

                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Simpan Jadwal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _scheduleNotifications(
    int scheduleId,
    String plantName,
    DateTime dateTime,
    TimeOfDay time,
  ) async {
    final notif = NotificationService();

    await notif.scheduleNotification(
      id: scheduleId * 10 + 0,
      title: 'Waktunya: $plantName',
      body: 'Sekarang saatnya kegiatan $plantName.',
      scheduledDate: dateTime,
    );

    await notif.scheduleNotification(
      id: scheduleId * 10 + 1,
      title: 'Persiapan: $plantName',
      body:
          'Besok jam ${time.hour}:${time.minute.toString().padLeft(2, '0')} ada kegiatan.',
      scheduledDate: dateTime.subtract(const Duration(hours: 16)),
    );

    await notif.scheduleNotification(
      id: scheduleId * 10 + 2,
      title: 'Ingat: $plantName',
      body:
          'Nanti jam ${time.hour}:${time.minute.toString().padLeft(2, '0')} ke sawah.',
      scheduledDate: dateTime.subtract(const Duration(hours: 8)),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
