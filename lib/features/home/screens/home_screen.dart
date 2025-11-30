import 'package:flutter/material.dart';
import 'package:petani_maju/features/home/widgets/forecast_list.dart';
import 'package:petani_maju/features/home/widgets/quick_access.dart';
import 'package:petani_maju/features/home/widgets/tips_list.dart';
import 'package:petani_maju/features/home/widgets/weather_alert.dart';
import 'package:petani_maju/widgets/custom_app_bar.dart';
import 'package:petani_maju/widgets/main_weather_card.dart';
import 'package:petani_maju/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomAppBar(),
                SizedBox(height: 20),
                MainWeatherCard(),
                SizedBox(height: 20),
                WeatherAlert(),
                SizedBox(height: 20),
                SectionHeader(title: 'Prediksi 7 Hari'),
                SizedBox(height: 20),
                ForecastList(),
                SizedBox(height: 20),
                SectionHeader(title: 'Tips Pertanian'),
                SizedBox(height: 16),
                TipsList(),
                SizedBox(height: 20),
                QuickAccess(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
