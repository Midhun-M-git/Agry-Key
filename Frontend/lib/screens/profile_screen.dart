import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import 'edit_profile_screen.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
@override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Profile",
            "പ്രൊഫൈൽ",
            "प्रोफ़ाइल",
            "சுயவிவரம்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 65,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              AppState.userName.isEmpty
                  ? L10n.get(
                      "User",
                      "ഉപയോക്താവ്",
                      "उपयोगकर्ता",
                      "பயனர்",
                    )
                  : AppState.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppState.selectedRole.isEmpty
                    ? L10n.get(
                        "Role Not Selected",
                        "പങ്ക് തിരഞ്ഞെടുത്തിട്ടില്ല",
                        "भूमिका चयनित नहीं",
                        "பங்கு தேர்ந்தெடுக்கப்படவில்லை",
                      )
                    : AppState.selectedRole,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.work),
                title: Text(
                  AppState.userOccupation.isEmpty
                      ? L10n.get(
                          "Occupation Not Set",
                          "തൊഴിൽ നൽകിയിട്ടില്ല",
                          "पेशा सेट नहीं है",
                          "தொழில் அமைக்கப்படவில்லை",
                        )
                      : AppState.userOccupation,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  AppState.userLocation.isEmpty
                      ? L10n.get(
                          "Location Not Set",
                          "സ്ഥലം നൽകിയിട്ടില്ല",
                          "स्थान सेट नहीं है",
                          "இருப்பிடம் அமைக்கப்படவில்லை",
                        )
                      : AppState.userLocation,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.agriculture),
                title: Text(
                  AppState.farmName.isEmpty
                      ? L10n.get(
                          "Farm Name Not Set",
                          "ഫാം നാമം നൽകിയിട്ടില്ല",
                          "फार्म नाम सेट नहीं है",
                          "பண்ணை பெயர் அமைக்கப்படவில்லை",
                        )
                      : AppState.farmName,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.grass),
                title: Text(
                  AppState.userCrop.isEmpty
                      ? L10n.get(
                          "Crop Not Set",
                          "വിള നൽകിയിട്ടില്ല",
                          "फसल सेट नहीं है",
                          "பயிர் அமைக்கப்படவில்லை",
                        )
                      : AppState.userCrop,
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  AppState.selectedLanguage.isEmpty
                      ? L10n.get(
                          "Language Not Selected",
                          "ഭാഷ തിരഞ്ഞെടുത്തിട്ടില്ല",
                          "भाषा चयनित नहीं",
                          "மொழி தேர்ந்தெடுக்கப்படவில்லை",
                        )
                      : AppState.selectedLanguage,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MyOrdersScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_shipping),
                label: Text(
                  L10n.get(
                    "My Orders",
                    "എന്റെ ഓർഡറുകൾ",
                    "मेरे ऑर्डर",
                    "என் ஆர்டர்கள்",
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EditProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: Text(
                  L10n.get(
                    "Edit Profile",
                    "പ്രൊഫൈൽ തിരുത്തുക",
                    "प्रोफ़ाइल संपादित करें",
                    "சுயவிவரத்தை திருத்து",
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}