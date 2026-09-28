import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/weather.dart';
import 'location_service.dart';

class WeatherService {
  // Legacy string properties kept for backwards-compatibility
  static String temperature = "28°C";
  static String humidity = "72%";
  static String windSpeed = "10 km/h";
  static String rainChance = "20%";

  static WeatherData? _lastCachedWeather;

  static WeatherData? get cachedWeather => _lastCachedWeather;

  /// Fetches real-time weather from Open-Meteo backend proxy for GPS coordinates.
  static Future<WeatherData> fetchWeather({double? lat, double? lng}) async {
    double latitude = lat ?? 10.7867;
    double longitude = lng ?? 76.6547;

    if (lat == null || lng == null) {
      try {
        final position = await LocationService.getCurrentPosition();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
        }
      } catch (_) {}
    }

    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/weather?lat=$latitude&lng=$longitude',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>? ?? {};
        final rawForecast = data['forecast'] as List<dynamic>? ?? [];
        final alerts = data['alerts'] as List<dynamic>? ?? [];

        final tempVal = (current['temperature_c'] as num?)?.toDouble() ?? 28.0;
        final humidVal = (current['humidity_percent'] as num?)?.toInt() ?? 70;
        final windVal = (current['wind_speed_kmh'] as num?)?.toDouble() ?? 10.0;
        final rainVal = (current['precipitation_mm'] as num?)?.toDouble() ?? 0.0;

        // Update legacy static fields
        temperature = "${tempVal.toStringAsFixed(1)}°C";
        humidity = "$humidVal%";
        windSpeed = "${windVal.toStringAsFixed(1)} km/h";
        rainChance = "${rainVal > 0 ? (rainVal * 20).clamp(10, 95).toInt() : 15}%";

        final forecastList = rawForecast.map((f) {
          final item = f as Map<String, dynamic>;
          return ForecastDay(
            date: item['date'] as String? ?? '',
            minTemp: (item['temperature_min_c'] as num?)?.toDouble() ?? 24.0,
            maxTemp: (item['temperature_max_c'] as num?)?.toDouble() ?? 32.0,
            condition: _mapWeatherCode(item['weather_code'] as int? ?? 0),
            rainfallProbability: (item['precipitation_probability_percent'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        String? alertMsg;
        if (alerts.isNotEmpty) {
          final firstAlert = alerts.first as Map<String, dynamic>;
          alertMsg = "${firstAlert['title'] ?? 'Alert'}: ${firstAlert['description'] ?? ''}";
        }

        final weatherData = WeatherData(
          district: 'Palakkad',
          state: 'Kerala',
          temperature: tempVal,
          condition: _mapWeatherCode(current['weather_code'] as int? ?? 0),
          humidity: humidVal,
          windSpeedKmH: windVal,
          rainfallMm: rainVal,
          forecast: forecastList,
          agriculturalAdvisory: alertMsg ?? "Favorable conditions for routine agricultural activities.",
          updatedAt: DateTime.now(),
        );

        _lastCachedWeather = weatherData;
        return weatherData;
      }
    } catch (_) {}

    // Fallback if offline
    return _lastCachedWeather ?? _getFallbackWeather();
  }

  static WeatherData _getFallbackWeather({String district = '', String state = ''}) {
    // This data is only shown when the device is completely offline.
    // Values are generic — not location-specific.
    return WeatherData(
      district: district.isNotEmpty ? district : 'Your Location',
      state: state.isNotEmpty ? state : 'India',
      temperature: 28.5,
      condition: 'Offline – No Live Data',
      humidity: 70,
      windSpeedKmH: 10.0,
      rainfallMm: 0.0,
      forecast: [
        ForecastDay(date: 'Tomorrow', minTemp: 24.0, maxTemp: 32.0, condition: 'Unavailable', rainfallProbability: 0),
        ForecastDay(date: 'Day 2', minTemp: 24.0, maxTemp: 32.0, condition: 'Unavailable', rainfallProbability: 0),
        ForecastDay(date: 'Day 3', minTemp: 24.0, maxTemp: 32.0, condition: 'Unavailable', rainfallProbability: 0),
      ],
      agriculturalAdvisory: 'No live weather data available. Please connect to the internet for real-time forecasts.',
      updatedAt: DateTime.now(),
    );
  }

  static String _mapWeatherCode(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 55) return 'Drizzle';
    if (code <= 65) return 'Rain';
    if (code <= 82) return 'Rain Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Clear';
  }
}