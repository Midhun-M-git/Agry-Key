import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'all_services_screen.dart';
import 'market_screen.dart';
import 'crop_advisory_screen.dart';
import 'disease_detection_screen.dart';
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


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
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

  @override
  Widget build(BuildContext context) {
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
    ? getText(
        "Good Morning 🌱",
        "സുപ്രഭാതം 🌱",
        "सुप्रभात 🌱",
        "காலை வணக்கம் 🌱",
      )
    : "${getText(
        "Good Morning",
        "സുപ്രഭാതം",
        "सुप्रभात",
        "காலை வணக்கம்",
      )}, ${AppState.userName} 🌱",
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
                      ? getText(
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
          ? getText(
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
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child:  Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
  getText(
    "Today's Weather",
    "ഇന്നത്തെ കാലാവസ്ഥ",
    "आज का मौसम",
    "இன்றைய வானிலை",
  ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "28°C",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
  getText(
    "Humidity 72%",
    "ആർദ്രത 72%",
    "आर्द्रता 72%",
    "ஈரப்பதம் 72%",
  ),
),
                      ],
                    ),

                    Icon(
                      Icons.wb_sunny,
                      size: 60,
                      color: Colors.orange,
                    ),
                  ],
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
  getText(
    "Farmer Alerts",
    "കർഷക അറിയിപ്പുകൾ",
    "किसान अलर्ट",
    "விவசாயி எச்சரிக்கைகள்",
  ),
),

subtitle: Text(
  getText(
    "Weather, Schemes & Disease Updates",
    "കാലാവസ്ഥ, പദ്ധതികൾ, രോഗ മുന്നറിയിപ്പുകൾ",
    "मौसम, योजनाएँ और रोग अपडेट",
    "வானிலை, திட்டங்கள் மற்றும் நோய் புதுப்பிப்புகள்",
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
  getText(
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
  getText(
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
    getText(
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
  getText(
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
      getText(
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
      getText(
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
      getText(
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
      getText(
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
      getText(
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
          builder: (_) => const DiseaseDetectionScreen(),
        ),
      );
    },
    child: actionCard(
      Icons.bug_report,
      getText(
        "Disease",
        "രോഗം",
        "रोग",
        "நோய்",
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
      getText(
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
      getText(
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
    getText(
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
      getText(
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
  getText(
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
  getText(
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
                  getText(
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
    label: getText(
      "Home",
      "ഹോം",
      "होम",
      "முகப்பு",
    ),
  ),

  BottomNavigationBarItem(
    icon: const Icon(Icons.store),
    label: getText(
      "Market",
      "മാർക്കറ്റ്",
      "बाज़ार",
      "சந்தை",
    ),
  ),

  BottomNavigationBarItem(
  icon: const Icon(Icons.account_balance),
  label: getText(
    "Schemes",
    "പദ്ധതികൾ",
    "योजनाएँ",
    "திட்டங்கள்",
  ),
),

  BottomNavigationBarItem(
    icon: const Icon(Icons.people),
    label: getText(
      "Community",
      "സമൂഹം",
      "समुदाय",
      "சமூகம்",
    ),
  ),

  BottomNavigationBarItem(
    icon: const Icon(Icons.person),
    label: getText(
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