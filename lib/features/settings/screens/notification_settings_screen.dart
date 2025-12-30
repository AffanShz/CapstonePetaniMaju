// lib/features/settings/screens/notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:petani_maju/core/constants/colors.dart';
import 'package:petani_maju/core/services/cache_service.dart';
import 'package:petani_maju/core/services/notification_scheduler.dart';
import 'package:petani_maju/data/models/notification_settings.dart';
import 'package:petani_maju/widgets/custom_time_picker.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final CacheService _cacheService = CacheService();
  final NotificationScheduler _scheduler = NotificationScheduler();
  late NotificationSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _settings = _cacheService.getNotificationSettings();
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _scheduler.saveSettings(_settings);

    // Reschedule morning briefing if enabled
    if (_settings.morningBriefingEnabled) {
      await _scheduler.scheduleMorningBriefing();
    } else {
      await _scheduler.cancelMorningBriefing();
    }
  }

  void _updateSettings(NotificationSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Pengaturan Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Morning Briefing Section
              _buildSectionTitle('CUACA HARIAN'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Cuaca Pagi',
                  subtitle: 'Info cuaca setiap pagi',
                  value: _settings.morningBriefingEnabled,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(morningBriefingEnabled: value));
                  },
                ),
                if (_settings.morningBriefingEnabled) ...[
                  _buildDivider(),
                  _buildTimePicker(
                    title: 'Waktu Notifikasi',
                    hour: _settings.morningBriefingHour,
                    minute: _settings.morningBriefingMinute,
                    onChanged: (hour, minute) {
                      _updateSettings(_settings.copyWith(
                        morningBriefingHour: hour,
                        morningBriefingMinute: minute,
                      ));
                    },
                  ),
                ],
              ]),
              const SizedBox(height: 24),

              // Weather Alerts Section
              _buildSectionTitle('PERINGATAN CUACA'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.water_drop_outlined,
                  title: 'Hujan Deras',
                  subtitle: 'Peringatan saat hujan deras',
                  value: _settings.heavyRainAlertEnabled,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(heavyRainAlertEnabled: value));
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.air_outlined,
                  title: 'Angin Kencang',
                  subtitle: 'Peringatan angin >10 m/s',
                  value: _settings.strongWindAlertEnabled,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(strongWindAlertEnabled: value));
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.flash_on_outlined,
                  title: 'Petir',
                  subtitle: 'Peringatan hujan petir',
                  value: _settings.thunderstormAlertEnabled,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(thunderstormAlertEnabled: value));
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // Farming Reminders Section
              _buildSectionTitle('PENGINGAT PERTANIAN'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.science_outlined,
                  title: 'Pemupukan',
                  subtitle: 'Pengingat jadwal pupuk',
                  value: _settings.fertilizationReminderEnabled,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(
                        fertilizationReminderEnabled: value));
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.opacity_outlined,
                  title: 'Penyiraman Cerdas',
                  subtitle: 'Pengingat jika tidak hujan 2+ hari',
                  value: _settings.smartWateringEnabled,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(smartWateringEnabled: value));
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Peringatan Hama',
                  subtitle: 'Waspada hama berdasarkan cuaca',
                  value: _settings.pestWarningEnabled,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(pestWarningEnabled: value));
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // Calendar Reminders Section
              _buildSectionTitle('PENGINGAT KALENDER'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.event_outlined,
                  title: '1 Hari Sebelum',
                  subtitle: 'Pengingat H-1 kegiatan',
                  value: _settings.reminder1DayBefore,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(reminder1DayBefore: value));
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.schedule_outlined,
                  title: '1 Jam Sebelum',
                  subtitle: 'Pengingat 1 jam sebelum',
                  value: _settings.reminder1HourBefore,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(reminder1HourBefore: value));
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Saat Waktu Kegiatan',
                  subtitle: 'Notifikasi tepat waktu',
                  value: _settings.reminderAtTime,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(reminderAtTime: value));
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // Quiet Mode Section
              _buildSectionTitle('MODE TENANG'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.do_not_disturb_on_outlined,
                  title: 'Mode Tenang',
                  subtitle: 'Nonaktifkan notifikasi sementara',
                  value: _settings.quietModeEnabled,
                  onChanged: (value) {
                    _updateSettings(
                        _settings.copyWith(quietModeEnabled: value));
                  },
                ),
                if (_settings.quietModeEnabled) ...[
                  _buildDivider(),
                  _buildQuietHoursPicker(),
                ],
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primaryGreen.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primaryGreen : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primaryGreen,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String title,
    required int hour,
    required int minute,
    required Function(int, int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () async {
              TimeOfDay tempTime = TimeOfDay(hour: hour, minute: minute);
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pilih Waktu'),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CustomTimePicker(
                          initialTime: tempTime,
                          onTimeChanged: (newTime) {
                            tempTime = newTime;
                          },
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        onChanged(tempTime.hour, tempTime.minute);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bedtime_outlined,
                  color: Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Jam Tenang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHourSelector(
                label: 'Dari',
                hour: _settings.quietStartHour,
                onTap: () async {
                  TimeOfDay tempTime =
                      TimeOfDay(hour: _settings.quietStartHour, minute: 0);
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Mulai Jam Tenang'),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: CustomTimePicker(
                              initialTime: tempTime,
                              onTimeChanged: (newTime) {
                                tempTime = newTime;
                              },
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _updateSettings(_settings.copyWith(
                                quietStartHour: tempTime.hour));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward, color: Colors.grey),
              ),
              _buildHourSelector(
                label: 'Sampai',
                hour: _settings.quietEndHour,
                onTap: () async {
                  TimeOfDay tempTime =
                      TimeOfDay(hour: _settings.quietEndHour, minute: 0);
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Akhir Jam Tenang'),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: CustomTimePicker(
                              initialTime: tempTime,
                              onTimeChanged: (newTime) {
                                tempTime = newTime;
                              },
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _updateSettings(_settings.copyWith(
                                quietEndHour: tempTime.hour));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourSelector({
    required String label,
    required int hour,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }
}
