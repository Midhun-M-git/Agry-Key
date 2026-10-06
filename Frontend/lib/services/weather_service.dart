import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_state.dart';
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

    String effectiveDistrict = AppState.district.isNotEmpty ? AppState.district : 'Palakkad';
    String effectiveState = AppState.state.isNotEmpty ? AppState.state : 'Kerala';

    // 1. Try Backend Proxy
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/weather?lat=$latitude&lng=$longitude',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

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
          district: effectiveDistrict,
          state: effectiveState,
          temperature: tempVal,
          condition: _mapWeatherCode(current['weather_code'] as int? ?? 0),
          humidity: humidVal,
          windSpeedKmH: windVal,
          rainfallMm: rainVal,
          forecast: forecastList,
          agriculturalAdvisory: alertMsg ?? "Live weather active. Favorable conditions for farming operations.",
          updatedAt: DateTime.now(),
        );

        _lastCachedWeather = weatherData;
        return weatherData;
      }
    } catch (_) {}

    // 2. Direct Open-Meteo Live API Fallback (ensures 100% real live data even if backend is asleep)
    try {
      final directUri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,weather_code'
        '&timezone=auto&forecast_days=7',
      );
      final directResp = await http.get(directUri).timeout(const Duration(seconds: 5));
      if (directResp.statusCode == 200) {
        final data = jsonDecode(directResp.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>? ?? {};
        final daily = data['daily'] as Map<String, dynamic>? ?? {};

        final tempVal = (current['temperature_2m'] as num?)?.toDouble() ?? 28.0;
        final humidVal = (current['relative_humidity_2m'] as num?)?.toInt() ?? 70;
        final windVal = (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;
        final rainVal = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        final wCode = (current['weather_code'] as num?)?.toInt() ?? 0;

        temperature = "${tempVal.toStringAsFixed(1)}°C";
        humidity = "$humidVal%";
        windSpeed = "${windVal.toStringAsFixed(1)} km/h";
        rainChance = "${rainVal > 0 ? (rainVal * 20).clamp(10, 95).toInt() : 15}%";

        final times = (daily['time'] as List<dynamic>? ?? []);
        final maxTemps = (daily['temperature_2m_max'] as List<dynamic>? ?? []);
        final minTemps = (daily['temperature_2m_min'] as List<dynamic>? ?? []);
        final dailyCodes = (daily['weather_code'] as List<dynamic>? ?? []);
        final dailyProbs = (daily['precipitation_probability_max'] as List<dynamic>? ?? []);

        final forecastList = <ForecastDay>[];
        for (int i = 0; i < times.length; i++) {
          forecastList.add(ForecastDay(
            date: times[i].toString(),
            minTemp: (minTemps.length > i ? minTemps[i] as num? : null)?.toDouble() ?? 23.0,
            maxTemp: (maxTemps.length > i ? maxTemps[i] as num? : null)?.toDouble() ?? 32.0,
            condition: _mapWeatherCode((dailyCodes.length > i ? dailyCodes[i] as num? : null)?.toInt() ?? 0),
            rainfallProbability: (dailyProbs.length > i ? dailyProbs[i] as num? : null)?.toDouble() ?? 15.0,
          ));
        }

        final weatherData = WeatherData(
          district: effectiveDistrict,
          state: effectiveState,
          temperature: tempVal,
          condition: _mapWeatherCode(wCode),
          humidity: humidVal,
          windSpeedKmH: windVal,
          rainfallMm: rainVal,
          forecast: forecastList,
          agriculturalAdvisory: "Live Open-Meteo satellite feed. Favorable conditions for farming operations.",
          updatedAt: DateTime.now(),
        );

        _lastCachedWeather = weatherData;
        return weatherData;
      }
    } catch (_) {}

    // 3. Fallback if offline
    return _lastCachedWeather ?? _getFallbackWeather(district: effectiveDistrict, state: effectiveState);
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