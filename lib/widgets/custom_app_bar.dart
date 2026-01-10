import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petani_maju/core/constants/colors.dart';
import 'package:petani_maju/core/services/cache_service.dart';
import 'package:petani_maju/features/notifications/screens/notification_history_screen.dart';

class CustomAppBar extends StatefulWidget {
  final DateTime? lastSyncTime;
  final bool isOnline;

  const CustomAppBar({
    super.key,
    this.lastSyncTime,
    this.isOnline = true,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final CacheService _cacheService = CacheService();
  StreamSubscription<Map<String, String?>>? _profileSubscription;
  String _userName = 'Pak Tani';
  String? _userImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _profileSubscription = _cacheService.profileUpdateStream.listen((profile) {
      if (mounted) {
        setState(() {
          _userName = profile['name'] ?? 'Pak Tani';
          _userImagePath = profile['imagePath'];
        });
      }
    });
  }

  void _loadProfile() {
    final profile = _cacheService.getUserProfile();
    setState(() {
      _userName = profile['name'] ?? 'Pak Tani';
      _userImagePath = profile['imagePath'];
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  String _formatLastSync() {
    if (widget.lastSyncTime == null) return 'Belum tersinkronisasi';

    final now = DateTime.now();
    final diff = now.difference(widget.lastSyncTime!);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return '${diff.inDays} hari lalu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Row
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen,
                      image: DecorationImage(
                        image: _userImagePath != null
                            ? FileImage(File(_userImagePath!)) as ImageProvider
                            : const AssetImage(
                                'assets/images/user_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: _userImagePath == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Petani Maju',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Sync Status Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isOnline
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withAlpha(200),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isOnline
                    ? 'Online – Data terakhir: ${_formatLastSync()}'
                    : 'Mode Offline – Data terakhir: ${_formatLastSync()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
