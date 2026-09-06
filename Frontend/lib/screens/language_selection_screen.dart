import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'role_selection_screen.dart';
import '../services/location_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {

  String? selectedLanguage;

  @override
 
void initState() {
  super.initState();

  LocationService.getCurrentLocation();

  if (AppState.selectedLanguage.isNotEmpty) {
    selectedLanguage =
        AppState.selectedLanguage;
  }
}

  Widget languageButton(
    String language,
    String displayText,
  ) {
    bool isSelected =
        selectedLanguage == language;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedLanguage = language;
            AppState.selectedLanguage =
                language;
          });
        },

        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: isSelected
              ? const Color(0xFFE8F5E9)
              : Colors.white,

          foregroundColor: isSelected
              ? Colors.green.shade800
              : Colors.black87,

          side: BorderSide(
            color: isSelected
                ? Colors.green
                : Colors.grey.shade300,
            width: 1.5,
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),

        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FBF5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 400,

              child: Padding(
                padding:
                    const EdgeInsets.all(24),

                child: Column(
                  children: [

                    const SizedBox(
                      height: 30,
                    ),

                    Container(
                      height: 130,
                      width: 130,

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      "AgriKey",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Your Farm. Our Intelligence.\nBetter Tomorrow.",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),

                    const Text(
                      "Choose Your Language",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Select your preferred language",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    languageButton(
                      "English",
                      "English",
                    ),

                    languageButton(
                      "Malayalam",
                      "മലയാളം (Malayalam)",
                    ),

                    languageButton(
                      "Hindi",
                      "हिन्दी (Hindi)",
                    ),

                    languageButton(
                      "Tamil",
                      "தமிழ் (Tamil)",
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed:
                            selectedLanguage ==
                                    null
                                ? null
                                : () {

                                    AppState
                                            .selectedLanguage =
                                        selectedLanguage!;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) =>
                                                const RoleSelectionScreen(),
                                      ),
                                    );
                                  },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors
                                  .green
                                  .shade700,

                          foregroundColor:
                              Colors.white,

                          elevation: 4,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),

                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}