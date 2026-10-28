import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
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
          if (data == null) {
            _errorMessage = context.l10n.weatherUnavailable;
          }
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          l10n.weatherTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadWeather,
            tooltip: l10n.actionRefresh,
          ),
        ],
      ),
      body: _isLoading
          ? LoadingWidget(message: l10n.isMalayalam ? 'കാലാവസ്ഥാ വിവരങ്ങൾ ശേഖരിക്കുന്നു...' : 'Fetching live meteorological data...')
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
                        // Open-Meteo Model Disclaimer Banner
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.cloud_outlined, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.weatherModelDisclaimer,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Card(
                          color: Colors.green.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.green),
                            title: Text(
                              AppState.userLocation.isEmpty
                                  ? '${_weatherData?.district ?? (AppState.district.isNotEmpty ? AppState.district : "Palakkad")}, ${_weatherData?.state ?? (AppState.state.isNotEmpty ? AppState.state : "Kerala")}'
                                  : AppState.userLocation,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              l10n.isMalayalam ? 'പ്രാദേശിക ജിയോ-കോർഡിനേറ്റുകൾ' : 'Regional Geo-Coordinates',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        VoiceTextField(
                          controller: locationSearchController,
                          onSubmitted: _onLocationSubmitted,
                          hintText: l10n.actionSearch,
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
                                _weatherData != null ? '${_weatherData!.temperature.toStringAsFixed(1)}°C' : '--°C',
                                style: const TextStyle(
                                  fontSize: 38,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _weatherData?.condition ?? (l10n.isMalayalam ? 'ലഭ്യമല്ല' : 'Unavailable'),
                                style: const TextStyle(color: Colors.white70, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildWeatherMetricCard(
                          Icons.thermostat,
                          l10n.weatherTemp,
                          _weatherData != null ? '${_weatherData!.temperature.toStringAsFixed(1)}°C' : '--°C',
                        ),
                        _buildWeatherMetricCard(
                          Icons.water_drop,
                          l10n.weatherHumidity,
                          _weatherData != null ? '${_weatherData!.humidity}%' : '--%',
                        ),
                        _buildWeatherMetricCard(
                          Icons.air,
                          l10n.weatherWind,
                          _weatherData != null ? '${_weatherData!.windSpeedKmH.toStringAsFixed(1)} km/h' : '-- km/h',
                        ),
                        _buildWeatherMetricCard(
                          Icons.umbrella_outlined,
                          l10n.weatherPrecipitation,
                          _weatherData != null ? '${_weatherData!.rainfallMm.toStringAsFixed(1)} mm' : '-- mm',
                        ),
                        const SizedBox(height: 20),
                        Card(
                          color: Colors.orange.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: const Icon(Icons.agriculture, color: Colors.orange),
                            title: Text(
                              l10n.isMalayalam ? 'കാർഷിക നിർദ്ദേശം' : 'Farming Advisory',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _weatherData?.agriculturalAdvisory ??
                                  (l10n.isMalayalam
                                      ? 'കാലാവസ്ഥ പ്രവചനം വിലയിരുത്തി അനുയോജ്യമായ ജലസേചനവും പരിചരണവും നൽകുക.'
                                      : 'Monitor crop condition and adjust irrigation according to forecast.'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              l10n.isMalayalam ? '7 ദിവസത്തെ പ്രവചനം' : '7-Day Forecast',
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
                                l10n.isMalayalam
                                    ? 'ഓപ്പൺ-മെറ്റിയോ കാലാവസ്ഥ പ്രവചനം ലഭ്യമല്ല'
                                    : 'Forecast data currently unavailable',
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
