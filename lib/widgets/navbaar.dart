import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

// Screens
import 'package:petani_maju/features/home/screens/home_screen.dart';
import 'package:petani_maju/features/calendar/screens/calendar_screen.dart';
import 'package:petani_maju/features/tips/screens/tips_screen.dart';
import 'package:petani_maju/features/settings/screens/settings_screen.dart';

// BLoCs
import 'package:petani_maju/features/home/bloc/home_bloc.dart';
import 'package:petani_maju/features/calendar/bloc/calendar_bloc.dart';
import 'package:petani_maju/features/tips/bloc/tips_bloc.dart';

// Repositories
import 'package:petani_maju/data/repositories/weather_repository.dart';
import 'package:petani_maju/data/repositories/calendar_repository.dart';
import 'package:petani_maju/data/repositories/tips_repository.dart';

// Services
import 'package:petani_maju/core/services/cache_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Screen dengan BlocProvider - now using WeatherRepository
          BlocProvider(
            create: (context) => HomeBloc(
              weatherRepository: context.read<WeatherRepository>(),
              cacheService: CacheService(),
            )..add(LoadHomeData()),
            child: HomeScreen(
              onTabChange: _onItemTapped,
            ),
          ),

          // Calendar Screen dengan BlocProvider
          BlocProvider(
            create: (context) => CalendarBloc(
              calendarRepository: context.read<CalendarRepository>(),
            )..add(LoadSchedules()),
            child: const CalendarScreen(),
          ),

          // Tips Screen dengan BlocProvider
          BlocProvider(
            create: (context) => TipsBloc(
              tipsRepository: context.read<TipsRepository>(),
            )..add(LoadTips()),
            child: const TipsScreen(),
          ),

          // Settings Screen (tanpa BLoC untuk sekarang)
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'home.nav_home'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: 'home.nav_calendar'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.lightbulb_outline),
            selectedIcon: const Icon(Icons.lightbulb),
            label: 'home.nav_tips'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: 'home.nav_settings'.tr(),
          ),
        ],
      ),
    );
  }
}
