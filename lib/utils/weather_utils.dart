class WeatherUtils {
  static String translateWeather(String description) {
    description = description.toLowerCase();
    if (description.contains('thunderstorm')) return 'Hujan Petir';
    if (description.contains('drizzle')) return 'Hujan Rintik-rintik';
    if (description.contains('rain')) {
      if (description.contains('heavy')) return 'Hujan Deras';
      if (description.contains('light')) return 'Hujan Ringan';
      return 'Hujan';
    }
    if (description.contains('cloud')) {
      if (description.contains('scattered') || description.contains('broken')) {
        return 'Cerah Berawan';
      }
      return 'Berawan';
    }
    if (description.contains('clear')) return 'Cerah';
    if (description.contains('mist') || description.contains('fog')) {
      return 'Berkabut';
    }

    // Default fallback: capitalize first letter
    return description.split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
}
