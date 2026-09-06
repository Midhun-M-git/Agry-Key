import 'package:flutter/material.dart';
import '../core/app_state.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() =>
      _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState
    extends State<ThemeSelectionScreen> {

  String selectedTheme = AppState.selectedTheme;

  Widget themeCard(
    String themeName,
    Color color,
    IconData icon,
  ) {
    bool isSelected = selectedTheme == themeName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTheme = themeName;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? color
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 40,
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Text("🌦️ Weather"),
                  Text("💹 Market"),
                  Text("🎤 AI"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              themeName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Theme"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            const SizedBox(height: 10),

            const Text(
              "Choose Your Theme",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.9,

                children: [

                  themeCard(
                    "Green Harvest",
                    Colors.green,
                    Icons.agriculture,
                  ),

                  themeCard(
                    "Golden Field",
                    Colors.orange,
                    Icons.grass,
                  ),

                  themeCard(
                    "Sky Weather",
                    Colors.blue,
                    Icons.cloud,
                  ),

                  themeCard(
                    "Organic Nature",
                    Colors.teal,
                    Icons.eco,
                  ),

                  themeCard(
                    "Night Mode",
                    Colors.black87,
                    Icons.dark_mode,
                  ),

                  themeCard(
                    "Bharat Theme",
                    Colors.deepOrange,
                    Icons.flag,
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  AppState.selectedTheme =
                      selectedTheme;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        "$selectedTheme Selected",
                      ),
                    ),
                  );

                  // Dashboard navigation here later
                },
                child: const Text("Continue"),
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}