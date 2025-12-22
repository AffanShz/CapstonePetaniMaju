import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'package:petani_maju/core/services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // State untuk tanggal yang sedang dilihat (Bulan/Tahun di header)
  DateTime _focusedDate = DateTime.now();

  // State untuk tanggal yang dipilih user (Default: hari ini)
  DateTime _selectedDate = DateTime.now();

  // Data rekomendasi tanam (Contoh: Key string "yyyy-MM-dd")
  final Map<String, String> _rekomendasiTanam = {
    '2025-11-05': 'Jagung',
    '2025-11-12': 'Padi',
    '2025-11-25': 'Cabai',
    // Tambahkan data dinamis di sini nantinya
  };

  @override
  Widget build(BuildContext context) {
    // Menghitung jumlah hari dalam bulan yang sedang dilihat
    final int daysInMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;

    // Menghitung hari pertama bulan ini jatuh pada hari apa (1=Senin, ... 7=Minggu)
    // Kita asumsikan Grid dimulai dari Senin. Offset menyesuaikan posisi tanggal 1.
    final int firstDayWeekday =
        DateTime(_focusedDate.year, _focusedDate.month, 1).weekday;
    final int offset = firstDayWeekday - 1; // Offset kotak kosong di awal bulan

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Tanam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
            onPressed: () => _showAddScheduleDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER BULAN & TAHUN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    DateFormat('MMMM yyyy')
                        .format(_focusedDate), // Format Real-time
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- LABEL HARI (Sen, Sel, Rab...) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(day,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600])),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),

              // --- LEGENDA ---
              Row(
                children: [
                  _buildLegendMarker(Colors.blue, 'Rekomendasi'),
                  const SizedBox(width: 16),
                  _buildLegendMarker(Colors.green, 'Terpilih'),
                  const SizedBox(width: 16),
                  _buildLegendMarker(
                      Colors.orange.withOpacity(0.5), 'Hari Ini'),
                ],
              ),
              const SizedBox(height: 16),

              // --- GRID KALENDER ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.9,
                ),
                // Total item = hari dalam bulan + kotak kosong di awal (offset)
                itemCount: daysInMonth + offset,
                itemBuilder: (context, index) {
                  // Jika index kurang dari offset, render kotak kosong
                  if (index < offset) {
                    return Container();
                  }

                  // Menghitung tanggal asli berdasarkan index
                  final int day = index - offset + 1;
                  final DateTime currentDate =
                      DateTime(_focusedDate.year, _focusedDate.month, day);

                  // Key string untuk cek rekomendasi
                  final String dateKey =
                      DateFormat('yyyy-MM-dd').format(currentDate);

                  // Logika Cek Status Tanggal
                  final bool isToday = _isSameDay(currentDate, DateTime.now());
                  final bool isSelected =
                      _isSameDay(currentDate, _selectedDate);
                  final bool hasRecommendation =
                      _rekomendasiTanam.containsKey(dateKey);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = currentDate;
                      });
                      if (hasRecommendation) {
                        _showRecommendationInfo(
                            day, _rekomendasiTanam[dateKey]!);
                      }
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              // Warna Background
                              color: isSelected
                                  ? Colors.green
                                  : (isToday
                                      ? Colors.orange.withOpacity(0.3)
                                      : Colors.transparent),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isToday
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                width: isToday ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: (isToday || isSelected)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Dot Marker jika ada rekomendasi
                          if (hasRecommendation)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              // Menampilkan tanggal yang dipilih di bagian bawah
              Text(
                'Kegiatan Tanggal ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Contoh Card Kegiatan (Bisa dibuat dinamis nanti)
              _buildActivityCard(
                title: 'Pemupukan Tahap 2',
                subtitle: 'Lahan A - Padi varietas IR64',
                time: '08:00',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIKA NAVIGASI BULAN ---
  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }

  // Helper membandingkan dua tanggal (abaikan jam/menit)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Widget Legenda
  Widget _buildLegendMarker(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Dialog Tambah Jadwal
  void _showAddScheduleDialog(BuildContext context) {
    // Controller untuk input
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Jadwal Tanam'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Nama Kegiatan'),
            ),
            const SizedBox(height: 12),
            const TextField(
                decoration: InputDecoration(hintText: 'Waktu (contoh: 08:00)')),
            const SizedBox(height: 10),
            Text('Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Menjadwalkan notifikasi menggunakan tanggal yang dipilih (_selectedDate)
              // Logika jam bisa diambil dari text field waktu, disini kita hardcode +5 detik untuk demo

              NotificationService.scheduleNotification(
                id: DateTime.now().millisecond,
                title: 'Pengingat Petani Maju',
                body: 'Kegiatan: ${titleController.text} besok!',
                // Contoh: Notifikasi H-1 atau sesuai waktu input
                scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Jadwal disimpan & Pengingat aktif!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Sheet Info Rekomendasi
  void _showRecommendationInfo(int day, String tanaman) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rekomendasi Tanggal $day',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text('Waktu tepat menanam: $tanaman',
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          Text(time,
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
