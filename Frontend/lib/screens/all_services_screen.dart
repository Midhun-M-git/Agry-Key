import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_state.dart';

import 'weather_screen.dart';
import 'market_screen.dart';
import 'crop_advisory_screen.dart';
import 'blockchain_verify_screen.dart';
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
class AllServicesScreen extends ConsumerWidget {
  const AllServicesScreen({super.key});
@override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get(
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
      L10n.get("Weather","കാലാവസ്ഥ","मौसम","வானிலை"),
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
      L10n.get("Market Prices","മാർക്കറ്റ് വിലകൾ","बाज़ार मूल्य","சந்தை விலைகள்"),
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
      L10n.get("Crop Advisory","വിള ഉപദേശം","फसल सलाह","பயிர் ஆலோசனை"),
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
    child: ServiceCard(
      Icons.verified_user,
      L10n.get(
        "Anti-Fraud MRP",
        "വ്യാജവിരുദ്ധ MRP",
        "धोखाधड़ी रोधी MRP",
        "மோசடி தடுப்பு MRP",
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
    child: ServiceCard(
      Icons.water_drop,
      L10n.get("Soil","മണ്ണ്","मिट्टी","மண்"),
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
      L10n.get("Schemes","പദ്ധതികൾ","योजनाएँ","திட்டங்கள்"),
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
      L10n.get("Equipment","ഉപകരണങ്ങൾ","उपकरण","உபகரணங்கள்"),
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
      L10n.get("Marketplace","മാർക്കറ്റ് പ്ലേസ്","मार्केटप्लेस","சந்தை"),
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
      L10n.get("Buyer","വാങ്ങുന്നവർ","खरीदार","வாங்குபவர்"),
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
      L10n.get("Community","സമൂഹം","समुदाय","சமூகம்"),
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
      L10n.get("Calendar","കലണ്ടർ","कैलेंडर","நாட்காட்டி"),
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
      L10n.get("Experts","വിദഗ്ധർ","विशेषज्ञ","நிபுணர்கள்"),
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
      L10n.get("AI Expert","AI വിദഗ്ധൻ","AI विशेषज्ञ","AI நிபுணர்"),
    ),
  ),

  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AlertsScreen(),
        ),
      );
    },
    child: ServiceCard(
      Icons.campaign,
      L10n.get("Updates","അപ്ഡേറ്റുകൾ","अपडेट्स","புதுப்பிப்புகள்"),
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