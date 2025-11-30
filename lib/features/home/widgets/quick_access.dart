import 'package:flutter/material.dart';
import 'package:petani_maju/features/home/widgets/quick_access_item.dart';

class QuickAccess extends StatelessWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            QuickAccessItem(
              icon: Icons.videocam_outlined,
              label: 'Video',
            ),
            QuickAccessItem(
              icon: Icons.calendar_today_outlined,
              label: 'Kalender',
            ),
            QuickAccessItem(
              icon: Icons.bug_report_outlined,
              label: 'Info Hama',
            ),
            QuickAccessItem(
              icon: Icons.people_outline,
              label: 'Forum',
            ),
          ],
        ),
      ],
    );
  }
}
