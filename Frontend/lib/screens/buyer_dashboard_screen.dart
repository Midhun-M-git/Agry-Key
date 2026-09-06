import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

import 'browse_products_screen.dart';
import 'find_farmers_screen.dart';
import 'buyer_orders_screen.dart';
import 'buyer_ai_assistant_screen.dart';
import 'buyer_profile_screen.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() =>
      _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState
    extends State<BuyerDashboardScreen> {

  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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

  Widget statCard(
    String value,
    String title,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            icon,
            color: Colors.green,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    String userName =
        AppState.userName.isEmpty
            ? "Buyer"
            : AppState.userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Buyer Dashboard",
            "വാങ്ങുന്നയാളുടെ ഡാഷ്ബോർഡ്",
            "खरीदार डैशबोर्ड",
            "வாங்குபவர் டாஷ்போர்டு",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // Welcome Card

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Column(
                children: [

                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 55,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${getText(
                      "Welcome",
                      "സ്വാഗതം",
                      "स्वागत है",
                      "வரவேற்கிறோம்",
                    )} $userName",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    AppState.userLocation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Quick Statistics

            Row(
              children: [

                statCard(
                  "12",
                  "Orders",
                  Icons.shopping_bag,
                ),

                statCard(
                  "8",
                  "Farmers",
                  Icons.agriculture,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Voice Search

            VoiceTextField(
              controller: searchController,
              hintText: getText(
                "Search crops using voice...",
                "വോയ്സ് ഉപയോഗിച്ച് വിളകൾ തിരയുക...",
                "आवाज़ से फसल खोजें...",
                "குரல் மூலம் பயிர்களை தேடுங்கள்...",
              ),
            ),

            const SizedBox(height: 20),

            dashboardCard(
              context,
              Icons.search,
              getText(
                "Find Farmers",
                "കർഷകരെ കണ്ടെത്തുക",
                "किसानों को खोजें",
                "விவசாயிகளை கண்டறியுங்கள்",
              ),
              getText(
                "Search nearby farmers",
                "സമീപത്തെ കർഷകരെ കണ്ടെത്തുക",
                "नजदीकी किसानों को खोजें",
                "அருகிலுள்ள விவசாயிகளை கண்டறியுங்கள்",
              ),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const FindFarmersScreen(),
                  ),
                );
              },
            ),

            dashboardCard(
              context,
              Icons.store,
              getText(
                "Browse Products",
                "ഉൽപ്പന്നങ്ങൾ കാണുക",
                "उत्पाद देखें",
                "பொருட்களை பார்வையிடுங்கள்",
              ),
              getText(
                "View available crops",
                "ലഭ്യമായ വിളകൾ കാണുക",
                "उपलब्ध फसलें देखें",
                "கிடைக்கும் பயிர்களை காண்க",
              ),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BrowseProductsScreen(),
                  ),
                );
              },
            ),

            dashboardCard(
              context,
              Icons.shopping_bag,
              getText(
                "My Orders",
                "എന്റെ ഓർഡറുകൾ",
                "मेरे ऑर्डर",
                "என் ஆர்டர்கள்",
              ),
              getText(
                "Track purchases",
                "വാങ്ങലുകൾ നിരീക്ഷിക്കുക",
                "खरीदारी ट्रैक करें",
                "கொள்முதல்களை கண்காணிக்கவும்",
              ),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BuyerOrdersScreen(),
                  ),
                );
              },
            ),

            dashboardCard(
              context,
              Icons.smart_toy,
              getText(
                "AI Assistant",
                "AI സഹായി",
                "AI सहायक",
                "AI உதவியாளர்",
              ),
              getText(
                "Ask agriculture questions",
                "കൃഷി ചോദ്യങ്ങൾ ചോദിക്കുക",
                "कृषि प्रश्न पूछें",
                "விவசாய கேள்விகளை கேளுங்கள்",
              ),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BuyerAIAssistantScreen(),
                  ),
                );
              },
            ),

            dashboardCard(
              context,
              Icons.person,
              getText(
                "My Profile",
                "എന്റെ പ്രൊഫൈൽ",
                "मेरी प्रोफ़ाइल",
                "என் சுயவிவரம்",
              ),
              getText(
                "View profile details",
                "പ്രൊഫൈൽ വിവരങ്ങൾ കാണുക",
                "प्रोफ़ाइल देखें",
                "சுயவிவரத்தை காண்க",
              ),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BuyerProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}