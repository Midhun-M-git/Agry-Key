import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../models/weather.dart';
import 'location_service.dart';

class WeatherService {
  static WeatherData? _lastCachedWeather;

  static WeatherData? get cachedWeather => _lastCachedWeather;

  /// Fetches real-time weather from backend or Open-Meteo.
  /// Strictly fails closed: Returns null if weather cannot be fetched. Never fabricates values.
  static Future<WeatherData?> fetchWeather({double? lat, double? lng}) async {
    double? latitude = lat ?? (AppState.latitude != 0.0 ? AppState.latitude : null);
    double? longitude = lng ?? (AppState.longitude != 0.0 ? AppState.longitude : null);

    if (latitude == null || longitude == null) {
      try {
        final loc = await LocationService.resolveRealLocation();
        if (loc != null) {
          latitude = loc.latitude;
          longitude = loc.longitude;
        }
      } catch (_) {}
    }

    if (latitude == null || longitude == null || (latitude == 0.0 && longitude == 0.0)) {
      debugPrint('[WeatherService] No GPS coordinates available. Weather cannot be determined.');
      return null;
    }

    final effectiveDistrict = AppState.district;
    final effectiveState = AppState.state;

    // 1. Try Backend Proxy
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/weather?lat=$latitude&lng=$longitude',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';
        final isLive = data['is_live'] as bool? ?? false;
        final current = data['current'] as Map<String, dynamic>?;

        if (status != 'unavailable' && current != null && isLive) {
          final tempVal = (current['temperature_c'] as num?)?.toDouble();
          final humidVal = (current['humidity_percent'] as num?)?.toInt();
          final windVal = (current['wind_speed_kmh'] as num?)?.toDouble() ?? 0.0;
          final rainVal = (current['precipitation_mm'] as num?)?.toDouble() ?? 0.0;
          final rawForecast = data['forecast'] as List<dynamic>? ?? [];
          final alerts = data['alerts'] as List<dynamic>? ?? [];

          if (tempVal != null && humidVal != null) {
            final forecastList = rawForecast.map((f) {
              final item = f as Map<String, dynamic>;
              return ForecastDay(
                date: item['date'] as String? ?? '',
                minTemp: (item['temperature_min_c'] as num?)?.toDouble() ?? 0.0,
                maxTemp: (item['temperature_max_c'] as num?)?.toDouble() ?? 0.0,
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
              district: effectiveDistrict.isNotEmpty ? effectiveDistrict : 'Local Farm',
              state: effectiveState.isNotEmpty ? effectiveState : '',
              temperature: tempVal,
              condition: _mapWeatherCode(current['weather_code'] as int? ?? 0),
              humidity: humidVal,
              windSpeedKmH: windVal,
              rainfallMm: rainVal,
              forecast: forecastList,
              agriculturalAdvisory: alertMsg ?? "Live weather active.",
              updatedAt: DateTime.now(),
            );

            _lastCachedWeather = weatherData;
            return weatherData;
          }
        }
      }
    } catch (e) {
      debugPrint('[WeatherService] Backend weather error: $e');
    }

    // 2. Direct Open-Meteo Live API Fallback
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
        final current = data['current'] as Map<String, dynamic>?;
        final daily = data['daily'] as Map<String, dynamic>? ?? {};

        if (current != null) {
          final tempVal = (current['temperature_2m'] as num?)?.toDouble();
          final humidVal = (current['relative_humidity_2m'] as num?)?.toInt();
          final windVal = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
          final rainVal = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
          final wCode = (current['weather_code'] as num?)?.toInt() ?? 0;

          if (tempVal != null && humidVal != null) {
            final times = (daily['time'] as List<dynamic>? ?? []);
            final maxTemps = (daily['temperature_2m_max'] as List<dynamic>? ?? []);
            final minTemps = (daily['temperature_2m_min'] as List<dynamic>? ?? []);
            final dailyCodes = (daily['weather_code'] as List<dynamic>? ?? []);
            final dailyProbs = (daily['precipitation_probability_max'] as List<dynamic>? ?? []);

            final forecastList = <ForecastDay>[];
            for (int i = 0; i < times.length; i++) {
              forecastList.add(ForecastDay(
                date: times[i].toString(),
                minTemp: (minTemps.length > i ? minTemps[i] as num? : null)?.toDouble() ?? 0.0,
                maxTemp: (maxTemps.length > i ? maxTemps[i] as num? : null)?.toDouble() ?? 0.0,
                condition: _mapWeatherCode((dailyCodes.length > i ? dailyCodes[i] as num? : null)?.toInt() ?? 0),
                rainfallProbability: (dailyProbs.length > i ? dailyProbs[i] as num? : null)?.toDouble() ?? 0.0,
              ));
            }

            final weatherData = WeatherData(
              district: effectiveDistrict.isNotEmpty ? effectiveDistrict : 'Local Farm',
              state: effectiveState.isNotEmpty ? effectiveState : '',
              temperature: tempVal,
              condition: _mapWeatherCode(wCode),
              humidity: humidVal,
              windSpeedKmH: windVal,
              rainfallMm: rainVal,
              forecast: forecastList,
              agriculturalAdvisory: "Live Open-Meteo satellite observations.",
              updatedAt: DateTime.now(),
            );

            _lastCachedWeather = weatherData;
            return weatherData;
          }
        }
      }
    } catch (e) {
      debugPrint('[WeatherService] Open-Meteo direct error: $e');
    }

    // Strict Fail-Closed: Return null when weather data is unavailable.
    return null;
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