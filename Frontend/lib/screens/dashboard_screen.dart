import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/weather_service.dart';
import 'all_services_screen.dart';
import 'market_screen.dart';
import 'crop_advisory_screen.dart';
import 'blockchain_verify_screen.dart';
import 'soil_health_screen.dart';
import 'schemes_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'weather_screen.dart';
import 'notifications_screen.dart';
import 'ai_assistant_screen.dart';
import 'settings_screen.dart';
import 'alerts_screen.dart';
import 'farmer_products_screen.dart';
import 'farmer_orders_screen.dart';
import '../services/update_service.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _temperature = WeatherService.temperature;
  String _humidity = WeatherService.humidity;

  @override
  void initState() {
    super.initState();
    _fetchLiveWeather();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkForUpdate(context);
      }
    });
  }

  Future<void> _fetchLiveWeather() async {
    try {
      final lat = AppState.latitude != 0.0 ? AppState.latitude : null;
      final lng = AppState.longitude != 0.0 ? AppState.longitude : null;
      final data = await WeatherService.fetchWeather(lat: lat, lng: lng);
      if (mounted) {
        setState(() {
          _temperature = "${data.temperature.toStringAsFixed(1)}°C";
          _humidity = "${data.humidity}%";
        });
      }
    } catch (_) {}
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return L10n.get(
        "Good Morning",
        "സുപ്രഭാതം",
        "सुप्रभात",
        "காலை வணக்கம்",
      );
    } else if (hour < 17) {
      return L10n.get(
        "Good Afternoon",
        "ശുഭ ഉച്ചതിരിഞ്ഞ്",
        "शुभ दोपहर",
        "மதிய வணக்கம்",
      );
    } else {
      return L10n.get(
        "Good Evening",
        "ശുഭ സായാഹ്നം",
        "शुभ संध्या",
        "மாலை வணக்கம்",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: const Text(
          "AGRI KEY",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Greeting
            Text(
              AppState.userName.isEmpty
                  ? _getGreeting()
                  : "${_getGreeting()}, ${AppState.userName}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            /// Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 18,
                ),

                const SizedBox(width: 5),

                Text(
                  AppState.userLocation.isEmpty
                      ? L10n.get(
                          "Location Not Set",
                          "സ്ഥലം നൽകിയിട്ടില്ല",
                          "स्थान सेट नहीं है",
                          "இருப்பிடம் அமைக்கப்படவில்லை",
                        )
                      : AppState.userLocation,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(
                  Icons.work,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 5),

                Text(
                  AppState.userOccupation.isEmpty
                      ? L10n.get(
                          "Occupation Not Set",
                          "തൊഴിൽ നൽകിയിട്ടില്ല",
                          "पेशा सेट नहीं है",
                          "தொழில் அமைக்கப்படவில்லை",
                        )
                      : AppState.userOccupation,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Weather Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WeatherScreen(),
                    ),
                  ).then((_) => _fetchLiveWeather());
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                L10n.get(
                                  "Today's Weather",
                                  "ഇന്നത്തെ കാലാവസ്ഥ",
                                  "आज का मौसम",
                                  "இன்றைய வானிலை",
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.open_in_new,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            _temperature,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          Text(
                            "${L10n.get("Humidity", "ആർദ്രത", "आर्द्रता", "ஈரப்பதம்")}: $_humidity",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          const Icon(
                            Icons.wb_sunny,
                            size: 56,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L10n.get("Tap for details", "കൂടുതൽ വിവരങ്ങൾ", "विवरण देखें", "விவரங்களை பார்க்க"),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
  child: ListTile(
    leading: const Icon(
      Icons.campaign,
      color: Colors.green,
    ),
    title: Text(
  L10n.get(
    "Farmer Alerts",
    "കർഷക അറിയിപ്പുകൾ",
    "किसान अलर्ट",
    "விவசாயி எச்சரிக்கைகள்",
  ),
),

subtitle: Text(
  L10n.get(
    "Weather, Schemes & Farm Updates",
    "കാലാവസ്ഥ, പദ്ധതികൾ, കൃഷി വിവരങ്ങൾ",
    "मौसम, योजनाएँ और कृषि अपडेट",
    "வானிலை, திட்டங்கள் மற்றும் பண்ணை தகவல்கள்",
  ),
),
    trailing: const Icon(
      Icons.arrow_forward_ios,
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AlertsScreen(),
        ),
      );
    },
  ),
),

            /// Voice Assistant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.green,
                    Color(0xFF4CAF50),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 50,
                  ),

                  const SizedBox(height: 10),

                  Text(
  L10n.get(
    "Ask AGRI KEY",
    "AGRI KEYനോട് ചോദിക്കൂ",
    "AGRI KEY से पूछें",
    "AGRI KEY-யிடம் கேளுங்கள்",
  ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
  L10n.get(
    "Weather • Market • Crops • AI Advice",
    "കാലാവസ്ഥ • മാർക്കറ്റ് • വിളകൾ • AI ഉപദേശം",
    "मौसम • बाजार • फसल • AI सलाह",
    "வானிலை • சந்தை • பயிர்கள் • AI ஆலோசனை",
  ),
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: Colors.white,
  ),
),

                  const SizedBox(height: 15),

                 ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AIAssistantScreen(),
      ),
    );
  },
  icon: const Icon(Icons.mic),
  label: Text(
    L10n.get(
      "Start Speaking",
      "സംസാരം ആരംഭിക്കുക",
      "बोलना शुरू करें",
      "பேசத் தொடங்குங்கள்",
    ),
  ),
),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
  L10n.get(
    "Quick Actions",
    "ദ്രുത സേവനങ്ങൾ",
    "त्वरित सेवाएँ",
    "விரைவு சேவைகள்",
  ),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),

  crossAxisCount: 3,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 1.0,

 children: [

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FarmerProductsScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.inventory_2,
      L10n.get(
        "Products",
        "ഉൽപ്പന്നങ്ങൾ",
        "उत्पाद",
        "பொருட்கள்",
      ),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WeatherScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.cloud,
      L10n.get(
        "Weather",
        "കാലാവസ്ഥ",
        "मौसम",
        "வானிலை",
      ),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MarketScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.trending_up,
      L10n.get(
        "Market",
        "മാർക്കറ്റ്",
        "बाज़ार",
        "சந்தை",
      ),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SoilHealthScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.water_drop,
      L10n.get(
        "Soil",
        "മണ്ണ്",
        "मिट्टी",
        "மண்",
      ),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CropAdvisoryScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.grass,
      L10n.get(
        "Crop",
        "വിള",
        "फसल",
        "பயிர்",
      ),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BlockchainVerifyScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.verified_user,
      L10n.get(
        "Anti-Fraud",
        "വ്യാജവിരുദ്ധം",
        "धोखाधड़ी रोधी",
        "மோசடி தடுப்பு",
      ),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SchemesScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.account_balance,
      L10n.get(
        "Schemes",
        "പദ്ധതികൾ",
        "योजनाएँ",
        "திட்டங்கள்",
      ),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CommunityScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.people,
      L10n.get(
        "Community",
        "സമൂഹം",
        "समुदाय",
        "சமூகம்",
      ),
    ),
  ),
  GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const FarmerOrdersScreen(),
      ),
    );
  },

  child: actionCard(
    Icons.shopping_bag,
    L10n.get(
      "Orders",
      "ഓർഡറുകൾ",
      "ऑर्डर",
      "ஆர்டர்கள்",
    ),
  ),
),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AIAssistantScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.smart_toy,
      L10n.get(
        "AI Assistant",
        "AI സഹായി",
        "AI सहायक",
        "AI உதவியாளர்",
      ),
    ),
  ),
],
            ),

           const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const AllServicesScreen(),
    ),
  );
},
    icon: const Icon(Icons.grid_view),
   label: Text(
  L10n.get(
    "View All Services",
    "എല്ലാ സേവനങ്ങളും കാണുക",
    "सभी सेवाएँ देखें",
    "அனைத்து சேவைகளையும் காண்க",
  ),
),
  ),
),
             const SizedBox(height: 25),

            Text(
  L10n.get(
    "AI Recommendation",
    "AI ശുപാർശ",
    "AI सिफारिश",
    "AI பரிந்துரை",
  ),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  L10n.get(
  "Based on today's weather forecast, irrigation can be postponed until evening.",
  "ഇന്നത്തെ കാലാവസ്ഥ പ്രവചനപ്രകാരം ജലസേചനം വൈകുന്നേരത്തേക്ക് മാറ്റാം.",
  "आज के मौसम पूर्वानुमान के अनुसार सिंचाई शाम तक टाली जा सकती है।",
  "இன்றைய வானிலை முன்னறிவிப்பின் அடிப்படையில் நீர்ப்பாசனத்தை மாலை வரை ஒத்திவைக்கலாம்.",
),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              L10n.get(
                "Nearby Veterinary Services",
                "അടുത്തുള്ള മൃഗാശുപത്രികൾ",
                "निकटतम पशु चिकित्सा सेवाएं",
                "அருகிலுள்ள கால்நடை சேவைகள்",
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.green.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            L10n.get(
                              "Emergency Veterinary Support",
                              "അടിയന്തിര വെറ്ററിനറി സഹായം",
                              "आपातकालीन पशु चिकित्सा सहायता",
                              "அவசர கால்நடை உதவி",
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // Service row — properly laid out with Expanded text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.local_hospital, color: Colors.green.shade800),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "District Veterinary Polyclinic",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Government Hospital, Emergency & Mobile Ambulance Unit",
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Calling Veterinary Helpline: +91 9447012345 / 1962"),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.call, size: 16),
                                  label: const Text("Call 1962"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
  currentIndex: 0,

 onTap: (index) {

  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MarketScreen(),
      ),
    );
  }

  if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SchemesScreen(),
      ),
    );
  }

  if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityScreen(),
      ),
    );
  }
  if (index == 4) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ProfileScreen(),
    ),
  );
}
},
  selectedItemColor: Colors.green,
  type: BottomNavigationBarType.fixed,

  items: [
  BottomNavigationBarItem(
    icon: const Icon(Icons.home),
    label: L10n.get(
      "Home",
      "ഹോം",
      "होम",
      "முகப்பு",
    ),
  ),

  BottomNavigationBarItem(
    icon: const Icon(Icons.store),
    label: L10n.get(
      "Market",
      "മാർക്കറ്റ്",
      "बाज़ार",
      "சந்தை",
    ),
  ),

  BottomNavigationBarItem(
  icon: const Icon(Icons.account_balance),
  label: L10n.get(
    "Schemes",
    "പദ്ധതികൾ",
    "योजनाएँ",
    "திட்டங்கள்",
  ),
),

  BottomNavigationBarItem(
    icon: const Icon(Icons.people),
    label: L10n.get(
      "Community",
      "സമൂഹം",
      "समुदाय",
      "சமூகம்",
    ),
  ),

  BottomNavigationBarItem(
    icon: const Icon(Icons.person),
    label: L10n.get(
      "Profile",
      "പ്രൊഫൈൽ",
      "प्रोफ़ाइल",
      "சுயவிவரம்",
    ),
  ),
],
      ),
    );
  }

  static Widget actionCard(
    IconData icon,
    String title,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 40,
          ),

          const SizedBox(height: 10),

         Text(
  title,
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
  ),
),
        ],
      ),
    );
  }
}