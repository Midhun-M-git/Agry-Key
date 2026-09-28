class ForecastDay {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final double rainfallProbability;
  final String? icon;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    this.rainfallProbability = 0.0,
    this.icon,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'] as String? ?? '',
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 0.0,
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? 'Clear',
      rainfallProbability: (json['rainfall_probability'] as num?)?.toDouble() ?? 0.0,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'condition': condition,
      'rainfall_probability': rainfallProbability,
      if (icon != null) 'icon': icon,
    };
  }
}

class WeatherData {
  final String district;
  final String state;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeedKmH;
  final double rainfallMm;
  final List<ForecastDay> forecast;
  final String? agriculturalAdvisory;
  final DateTime? updatedAt;

  WeatherData({
    required this.district,
    required this.state,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeedKmH,
    this.rainfallMm = 0.0,
    this.forecast = const [],
    this.agriculturalAdvisory,
    this.updatedAt,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final rawForecast = json['forecast'] as List<dynamic>? ?? [];
    return WeatherData(
      district: json['district'] as String? ?? 'Palakkad',
      state: json['state'] as String? ?? 'Kerala',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
      condition: json['condition'] as String? ?? 'Clear',
      humidity: (json['humidity'] as num?)?.toInt() ?? 70,
      windSpeedKmH: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 12.0,
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      forecast: rawForecast
          .map((f) => ForecastDay.fromJson(f as Map<String, dynamic>))
          .toList(),
      agriculturalAdvisory: json['agricultural_advisory'] as String?,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'district': district,
      'state': state,
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
      'wind_speed_kmh': windSpeedKmH,
      'rainfall_mm': rainfallMm,
      'forecast': forecast.map((f) => f.toJson()).toList(),
      if (agriculturalAdvisory != null) 'agricultural_advisory': agriculturalAdvisory,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
