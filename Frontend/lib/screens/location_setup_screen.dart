import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';
import 'dashboard_screen.dart';
import 'buyer_dashboard_screen.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() =>
      _LocationSetupScreenState();
}

class _LocationSetupScreenState
    extends State<LocationSetupScreen> {

  final TextEditingController locationController =
      TextEditingController();

  bool isLoading = false;

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

  Future<void> getCurrentLocation() async {

    setState(() {
      isLoading = true;
    });

    try {

      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {

        setState(() {
          isLoading = false;
        });

        return;
      }

      Position position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      String detectedLocation =
          "${place.locality}, ${place.administrativeArea}, ${place.country}";

      setState(() {
        locationController.text =
            detectedLocation;
      });

      AppState.userLocation =
          detectedLocation;

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Location Error: $e",
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5FAF5),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(20),

          child: Column(

            children: [

              LinearProgressIndicator(
                value: 1,
                color: Colors.green,
                backgroundColor:
                    Colors.grey.shade300,
              ),

              const SizedBox(height: 25),

              Container(
                height: 100,
                width: 100,

                decoration: BoxDecoration(
                  color:
                      Colors.green.shade100,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 55,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                getText(
                  "Choose Your Location",
                  "നിങ്ങളുടെ സ്ഥലം തിരഞ്ഞെടുക്കുക",
                  "अपना स्थान चुनें",
                  "உங்கள் இருப்பிடத்தைத் தேர்ந்தெடுக்கவும்",
                ),

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                getText(
                  "Weather, market prices and AI recommendations need your location.",
                  "കാലാവസ്ഥ, മാർക്കറ്റ് വില, AI ശുപാർശകൾക്കായി നിങ്ങളുടെ സ്ഥലം ആവശ്യമാണ്.",
                  "मौसम, बाजार मूल्य और AI सिफारिशों के लिए आपका स्थान आवश्यक है।",
                  "வானிலை, சந்தை விலை மற்றும் AI பரிந்துரைகளுக்கு உங்கள் இருப்பிடம் தேவை.",
                ),

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              Card(

                elevation: 4,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(

                    children: [

                      SizedBox(
                        width:
                            double.infinity,
                        height: 55,

                        child:
                            ElevatedButton.icon(

                          onPressed:
                              isLoading
                                  ? null
                                  : getCurrentLocation,

                          icon: const Icon(
                            Icons.my_location,
                          ),

                          label: Text(
                            isLoading
                                ? "Loading..."
                                : getText(
                                    "Use GPS Location",
                                    "GPS സ്ഥലം ഉപയോഗിക്കുക",
                                    "GPS स्थान उपयोग करें",
                                    "GPS இருப்பிடத்தைப் பயன்படுத்தவும்",
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      VoiceTextField(
                        controller:
                            locationController,

                        hintText: getText(
                          "Enter Location",
                          "സ്ഥലം നൽകുക",
                          "स्थान दर्ज करें",
                          "இருப்பிடத்தை உள்ளிடவும்",
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Card(
                        color:
                            Colors.green
                                .shade50,

                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .all(12),

                          child: Row(
                            children: [

                              const Icon(
                                Icons.info,
                                color:
                                    Colors.green,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child: Text(
                                  getText(
                                    "Your location helps AGRI KEY provide accurate weather, market and crop recommendations.",
                                    "നിങ്ങളുടെ സ്ഥലം AGRI KEYയ്ക്ക് കൃത്യമായ കാലാവസ്ഥയും മാർക്കറ്റ് വിവരങ്ങളും നൽകാൻ സഹായിക്കുന്നു.",
                                    "आपका स्थान AGRI KEY को सटीक मौसम और बाजार जानकारी देने में मदद करता है।",
                                    "உங்கள் இருப்பிடம் AGRI KEYக்கு துல்லியமான தகவல்களை வழங்க உதவுகிறது.",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 55,

                        child:
                            ElevatedButton.icon(

                          onPressed: () {

  if (locationController.text.trim().isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          getText(
            "Please enter location",
            "ദയവായി സ്ഥലം നൽകുക",
            "कृपया स्थान दर्ज करें",
            "இருப்பிடத்தை உள்ளிடவும்",
          ),
        ),
      ),
    );

    return;
  }

  AppState.userLocation =
      locationController.text.trim();

  if (AppState.userOccupation == "Buyer") {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const BuyerDashboardScreen(),
      ),
    );

  } else {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DashboardScreen(),
      ),
    );

  }
},

                          icon: const Icon(
                            Icons.check,
                          ),

                          label: Text(
                            getText(
                              "Finish Setup",
                              "സജ്ജീകരണം പൂർത്തിയാക്കുക",
                              "सेटअप पूरा करें",
                              "அமைப்பை முடிக்கவும்",
                            ),
                          ),

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.green,
                            foregroundColor:
                                Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}