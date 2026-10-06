import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../utils/localization.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/voice_text_field.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final TextEditingController locationSearchController = TextEditingController();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  static const Map<String, List<double>> _knownLocations = {
    'palakkad': [10.7867, 76.6547],
    'coimbatore': [11.0168, 76.9558],
    'thrissur': [10.5276, 76.2144],
    'ernakulam': [9.9816, 76.2999],
    'kozhikode': [11.2588, 75.7804],
    'wayanad': [11.6854, 76.1320],
    'kannur': [11.8745, 75.3704],
    'malappuram': [11.0510, 76.0711],
    'madurai': [9.9252, 78.1198],
    'salem': [11.6643, 78.1460],
    'thanjavur': [10.7870, 79.1378],
    'tirunelveli': [8.7139, 77.7567],
  };

  void _onLocationSubmitted(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return;

    for (final entry in _knownLocations.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        AppState.userLatitude = entry.value[0];
        AppState.userLongitude = entry.value[1];
        AppState.userLocation = query.trim();
        _loadWeather(lat: entry.value[0], lng: entry.value[1]);
        return;
      }
    }
    AppState.userLocation = query.trim();
    _loadWeather();
  }

  Future<void> _loadWeather({double? lat, double? lng}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final effectiveLat = lat ?? (AppState.userLatitude != 0.0 ? AppState.userLatitude : null);
      final effectiveLng = lng ?? (AppState.userLongitude != 0.0 ? AppState.userLongitude : null);

      final data = await WeatherService.fetchWeather(
        lat: effectiveLat,
        lng: effectiveLng,
      );
      if (mounted) {
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildWeatherMetricCard(IconData icon, String title, String value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildForecastCard(ForecastDay forecast) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
        title: Text(forecast.date, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(forecast.condition, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Text(
          '${forecast.minTemp.toStringAsFixed(0)}° - ${forecast.maxTemp.toStringAsFixed(0)}°C',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    locationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get("Weather", "കാലാവസ്ഥ", "मौसम", "வானிலை"),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadWeather,
            tooltip: 'Refresh Weather',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Fetching live meteorological data...')
          : _errorMessage != null && _weatherData == null
              ? AppErrorWidget(
                  message: _errorMessage!,
                  onRetry: _loadWeather,
                )
              : RefreshIndicator(
                  onRefresh: _loadWeather,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Card(
                          color: Colors.green.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.green),
                            title: Text(
                              AppState.userLocation.isEmpty
                                  ? '${_weatherData?.district ?? (AppState.district.isNotEmpty ? AppState.district : "Your Location")}, ${_weatherData?.state ?? (AppState.state.isNotEmpty ? AppState.state : "Kerala")}'
                                  : AppState.userLocation,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Live GPS Synchronized', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        VoiceTextField(
                          controller: locationSearchController,
                          onSubmitted: _onLocationSubmitted,
                          hintText: L10n.get(
                            "Search Location",
                            "സ്ഥലം തിരയുക",
                            "स्थान खोजें",
                            "இருப்பிடத்தை தேடுங்கள்",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade700, Colors.teal.shade800],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.wb_sunny, color: Colors.white, size: 60),
                              const SizedBox(height: 10),
                              Text(
                                '${_weatherData?.temperature.toStringAsFixed(1) ?? "28.0"}°C',
                                style: const TextStyle(
                                  fontSize: 38,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _weatherData?.condition ?? 'Clear Sky',
                                style: const TextStyle(color: Colors.white70, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildWeatherMetricCard(
                          Icons.thermostat,
                          L10n.get("Temperature", "താപനില", "तापमान", "வெப்பநிலை"),
                          '${_weatherData?.temperature.toStringAsFixed(1) ?? "28.0"}°C',
                        ),
                        _buildWeatherMetricCard(
                          Icons.water_drop,
                          L10n.get("Humidity", "ഈർപ്പം", "नमी", "ஈரப்பதம்"),
                          '${_weatherData?.humidity ?? 72}%',
                        ),
                        _buildWeatherMetricCard(
                          Icons.air,
                          L10n.get("Wind Speed", "കാറ്റിന്റെ വേഗത", "हवा की गति", "காற்றின் வேகம்"),
                          '${_weatherData?.windSpeedKmH.toStringAsFixed(1) ?? "12.0"} km/h',
                        ),
                        _buildWeatherMetricCard(
                          Icons.umbrella_outlined,
                          L10n.get("Rainfall", "മഴ സാധ്യത", "बारिश की संभावना", "மழை வாய்ப்பു"),
                          '${_weatherData?.rainfallMm.toStringAsFixed(1) ?? "0.0"} mm',
                        ),
                        const SizedBox(height: 20),
                        Card(
                          color: Colors.orange.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: const Icon(Icons.agriculture, color: Colors.orange),
                            title: Text(
                              L10n.get("Farming Advisory", "കാർഷിക നിർദ്ദേശം", "कृषि सलाह", "விவசாய ஆலோசனை"),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _weatherData?.agriculturalAdvisory ??
                                  L10n.get(
                                    "Good weather for irrigation and crop monitoring.",
                                    "ജലസേചനത്തിനും വിള നിരീക്ഷണത്തിനും അനുയോജ്യമായ കാലാവസ്ഥ.",
                                    "सिंचाई और फसल निगरानी के लिए अच्छा मौसम।",
                                    "நீர்ப்பாசனம் மற்றும் பயிர் கண்காணிப்புக்கு நல்ல வானிலை.",
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              L10n.get("7-Day Forecast", "7 ദിവസത്തെ പ്രവചനം", "7 दिन का पूर्वानुमान", "7 நாள் முன்னறிவிப்பு"),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_weatherData != null && _weatherData!.forecast.isNotEmpty)
                          ..._weatherData!.forecast.map(_buildForecastCard)
                        else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Forecast synchronizing with Open-Meteo...',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}