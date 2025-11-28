class WeatherModel {
  final String location;
  final int temp;
  final String condition;
  final int humidity;
  final int windSpeed;

  WeatherModel({
    required this.location,
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });
}

class ForecastModel {
  final String day;
  final int maxTemp;
  final int minTemp;
  final String iconType; // 'rain' or 'sunny'

  ForecastModel(this.day, this.maxTemp, this.minTemp, this.iconType);
}

class TipsModel {
  final String category;
  final String title;
  final String imageAsset; // Bisa diganti URL jika pakai NetworkImage

  TipsModel(this.category, this.title, this.imageAsset);
}
