import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';

class CropCalendarScreen extends ConsumerWidget {
  const CropCalendarScreen({super.key});
Widget taskCard(
    IconData icon,
    String task,
    String date,
  ) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
        ),
        title: Text(task),
        subtitle: Text(date),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Crop Calendar",
            "വിള കലണ്ടർ",
            "फसल कैलेंडर",
            "பயிர் நாட்காட்டி",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(
                  Icons.grass,
                  color: Colors.green,
                ),
                title: Text(
                  AppState.userCrop.isEmpty
                      ? L10n.get(
                          "No Crop Selected",
                          "വിള തിരഞ്ഞെടുക്കപ്പെട്ടിട്ടില്ല",
                          "कोई फसल चयनित नहीं",
                          "பயிர் தேர்வு செய்யப்படவில்லை",
                        )
                      : AppState.userCrop,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              L10n.get(
                "Upcoming Activities",
                "വരാനിരിക്കുന്ന പ്രവർത്തനങ്ങൾ",
                "आगामी गतिविधियाँ",
                "வரவிருக்கும் செயல்கள்",
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            taskCard(
              Icons.eco,
              L10n.get(
                "Sowing",
                "വിത്തിടൽ",
                "बुवाई",
                "விதைப்பு",
              ),
              "01 Sep 2026",
            ),

            taskCard(
              Icons.water_drop,
              L10n.get(
                "Irrigation",
                "ജലസേചനം",
                "सिंचाई",
                "நீர்ப்பாசனம்",
              ),
              "05 Sep 2026",
            ),

            taskCard(
              Icons.science,
              L10n.get(
                "Fertilizer Application",
                "വളപ്രയോഗം",
                "उर्वरक उपयोग",
                "உரம் பயன்பாடு",
              ),
              "15 Sep 2026",
            ),

            taskCard(
              Icons.bug_report,
              L10n.get(
                "Pest Inspection",
                "കീട പരിശോധന",
                "कीट निरीक्षण",
                "பூச்சி ஆய்வு",
              ),
              "25 Sep 2026",
            ),

            taskCard(
              Icons.agriculture,
              L10n.get(
                "Harvest",
                "വിളവെടുപ്പ്",
                "कटाई",
                "அறுவடை",
              ),
              "15 Dec 2026",
            ),
          ],
        ),
      ),
    );
  }
}