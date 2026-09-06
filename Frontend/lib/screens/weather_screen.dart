import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../services/weather_service.dart';
import '../widgets/voice_text_field.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() =>
      _WeatherScreenState();
}

class _WeatherScreenState
    extends State<WeatherScreen> {

  final TextEditingController
      locationSearchController =
          TextEditingController();

  String getText(
    String english,
    String malayalam,
    String hindi,
    String tamil,
  ) {
    switch (AppState.selectedLanguage) {
      case "Malayalam":
        return malayalam;
      case "Hindi":
        return hindi;
      case "Tamil":
        return tamil;
      default:
        return english;
    }
  }

  Widget weatherCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget forecastCard(
    String day,
    IconData icon,
    String temp,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.orange,
        ),
        title: Text(day),
        trailing: Text(temp),
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

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Weather",
            "കാലാവസ്ഥ",
            "मौसम",
            "வானிலை",
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                title: Text(
                  AppState.userLocation
                          .isEmpty
                      ? getText(
                          "Location Not Set",
                          "സ്ഥലം സജ്ജമാക്കിയിട്ടില്ല",
                          "स्थान सेट नहीं है",
                          "இருப்பிடம் அமைக்கப்படவில்லை",
                        )
                      : AppState
                          .userLocation,
                ),
              ),
            ),

            const SizedBox(height: 15),

            VoiceTextField(
              controller:
                  locationSearchController,
              hintText: getText(
                "Search Location",
                "സ്ഥലം തിരയുക",
                "स्थान खोजें",
                "இருப்பிடத்தை தேடுங்கள்",
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),

              child: Column(
                children: [

                  const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 60,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    WeatherService
                        .temperature,
                    style:
                        const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    getText(
                      "Sunny",
                      "വെയിൽ",
                      "धूप",
                      "வெயில்",
                    ),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            weatherCard(
              Icons.thermostat,
              getText(
                "Temperature",
                "താപനില",
                "तापमान",
                "வெப்பநிலை",
              ),
              WeatherService.temperature,
            ),

            weatherCard(
              Icons.water_drop,
              getText(
                "Humidity",
                "ഈർപ്പം",
                "नमी",
                "ஈரப்பதம்",
              ),
              WeatherService.humidity,
            ),

            weatherCard(
              Icons.air,
              getText(
                "Wind Speed",
                "കാറ്റിന്റെ വേഗത",
                "हवा की गति",
                "காற்றின் வேகம்",
              ),
              WeatherService.windSpeed,
            ),

            weatherCard(
              Icons.cloud,
              getText(
                "Rain Chance",
                "മഴ സാധ്യത",
                "बारिश की संभावना",
                "மழை வாய்ப்பு",
              ),
              WeatherService.rainChance,
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(
                  Icons.agriculture,
                  color: Colors.orange,
                ),
                title: Text(
                  getText(
                    "Farming Advisory",
                    "കാർഷിക നിർദ്ദേശം",
                    "कृषि सलाह",
                    "விவசாய ஆலோசனை",
                  ),
                ),
                subtitle: Text(
                  getText(
                    "Good weather for irrigation and crop monitoring.",
                    "ജലസേചനത്തിനും വിള നിരീക്ഷണത്തിനും അനുയോജ്യമായ കാലാവസ്ഥ.",
                    "सिंचाई और फसल निगरानी के लिए अच्छा मौसम।",
                    "நீர்ப்பாசனம் மற்றும் பயிர் கண்காணிப்புக்கு நல்ல வானிலை.",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                title: Text(
                  getText(
                    "Weather Alert",
                    "കാലാവസ്ഥ മുന്നറിയിപ്പ്",
                    "मौसम चेतावनी",
                    "வானிலை எச்சரிக்கை",
                  ),
                ),
                subtitle: Text(
                  getText(
                    "No severe alerts currently.",
                    "ഇപ്പോൾ ഗുരുതര മുന്നറിയിപ്പുകളില്ല.",
                    "फिलहाल कोई गंभीर चेतावनी नहीं।",
                    "தற்போது கடுமையான எச்சரிக்கை இல்லை.",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              getText(
                "5-Day Forecast",
                "5 ദിവസത്തെ പ്രവചനം",
                "5 दिन का पूर्वानुमान",
                "5 நாள் முன்னறிவிப்பு",
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            forecastCard(
              getText(
                "Tomorrow",
                "നാളെ",
                "कल",
                "நாளை",
              ),
              Icons.wb_sunny,
              "29°C",
            ),

            forecastCard(
              getText(
                "Day 2",
                "ദിവസം 2",
                "दिन 2",
                "நாள் 2",
              ),
              Icons.cloud,
              "27°C",
            ),

            forecastCard(
              getText(
                "Day 3",
                "ദിവസം 3",
                "दिन 3",
                "நாள் 3",
              ),
              Icons.cloud_queue,
              "28°C",
            ),

            forecastCard(
              getText(
                "Day 4",
                "ദിവസം 4",
                "दिन 4",
                "நாள் 4",
              ),
              Icons.thunderstorm,
              "26°C",
            ),

            forecastCard(
              getText(
                "Day 5",
                "ദിവസം 5",
                "दिन 5",
                "நாள் 5",
              ),
              Icons.wb_cloudy,
              "27°C",
            ),
          ],
        ),
      ),
    );
  }
}