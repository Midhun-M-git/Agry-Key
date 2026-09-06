import 'package:flutter/material.dart';

import '../core/app_state.dart';

import 'weather_screen.dart';
import 'market_screen.dart';
import 'crop_advisory_screen.dart';
import 'disease_detection_screen.dart';
import 'soil_health_screen.dart';
import 'schemes_screen.dart';
import 'equipment_screen.dart';
import 'marketplace_screen.dart';
import 'buyer_screen.dart';
import 'community_screen.dart';
import 'crop_calendar_screen.dart';
import 'experts_screen.dart';
import 'ai_assistant_screen.dart';
import 'notifications_screen.dart';
class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

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
      appBar: AppBar(
        title: Text(
          getText(
            "All Services",
            "എല്ലാ സേവനങ്ങളും",
            "सभी सेवाएँ",
            "அனைத்து சேவைகள்",
          ),
        ),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,

          children: [

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WeatherScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.cloud,
      getText("Weather","കാലാവസ്ഥ","मौसम","வானிலை"),
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
    child: ServiceCard(
      Icons.trending_up,
      getText("Market Prices","മാർക്കറ്റ് വിലകൾ","बाज़ार मूल्य","சந்தை விலைகள்"),
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
    child: ServiceCard(
      Icons.grass,
      getText("Crop Advisory","വിള ഉപദേശം","फसल सलाह","பயிர் ஆலோசனை"),
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
    child: ServiceCard(
      Icons.bug_report,
      getText("Disease","രോഗം","रोग","நோய்"),
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
    child: ServiceCard(
      Icons.water_drop,
      getText("Soil","മണ്ണ്","मिट्टी","மண்"),
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
    child: ServiceCard(
      Icons.account_balance,
      getText("Schemes","പദ്ധതികൾ","योजनाएँ","திட்டங்கள்"),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EquipmentScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.agriculture,
      getText("Equipment","ഉപകരണങ്ങൾ","उपकरण","உபகரணங்கள்"),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MarketplaceScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.storefront,
      getText("Marketplace","മാർക്കറ്റ് പ്ലേസ്","मार्केटप्लेस","சந்தை"),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BuyerScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.shopping_cart,
      getText("Buyer","വാങ്ങുന്നവർ","खरीदार","வாங்குபவர்"),
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
    child: ServiceCard(
      Icons.groups,
      getText("Community","സമൂഹം","समुदाय","சமூகம்"),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CropCalendarScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.calendar_month,
      getText("Calendar","കലണ്ടർ","कैलेंडर","நாட்காட்டி"),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ExpertsScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.support_agent,
      getText("Experts","വിദഗ്ധർ","विशेषज्ञ","நிபுணர்கள்"),
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
    child: ServiceCard(
      Icons.smart_toy,
      getText("AI Expert","AI വിദഗ്ധൻ","AI विशेषज्ञ","AI நிபுணர்"),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NotificationScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.campaign,
      getText("Updates","അപ്ഡേറ്റുകൾ","अपडेट्स","புதுப்பிப்புகள்"),
    ),
  ),
],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const ServiceCard(
    this.icon,
    this.title, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.green,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}