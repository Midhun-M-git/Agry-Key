import 'dart:io';
import '../utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
class DiseaseDetectionScreen extends ConsumerStatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  _DiseaseDetectionScreenState createState() =>
      _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState
  extends ConsumerState<DiseaseDetectionScreen> {

  final TextEditingController symptomController =
      TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  String detectedDisease =
      "No disease detected";

  String confidence = "--";

  String recommendation =
      "Upload image or describe symptoms for analysis.";
Future<void> pickFromCamera() async {

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);

        detectedDisease =
            "Possible Leaf Spot";

        confidence = "92%";

        recommendation =
            "Apply fungicide and monitor crop health.";
      });
    }
  }

  Future<void> pickFromGallery() async {

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);

        detectedDisease =
            "Possible Leaf Spot";

        confidence = "92%";

        recommendation =
            "Apply fungicide and monitor crop health.";
      });
    }
  }

  void analyzeSymptoms() {

    if (symptomController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            L10n.get(
              "Please describe crop symptoms.",
              "വിളയുടെ ലക്ഷണങ്ങൾ വിവരിക്കുക.",
              "कृपया फसल के लक्षण बताएं।",
              "பயிர் அறிகுறிகளை விவரிக்கவும்.",
            ),
          ),
        ),
      );

      return;
    }

    setState(() {

      detectedDisease =
          "Possible Leaf Spot";

      confidence = "90%";

      recommendation =
          "AI backend integration pending. This is a sample advisory result.";
    });
  }

  @override
  void dispose() {
    symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  AppState.watchAll(ref);

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Disease Detection",
            "രോഗ നിർണയം",
            "रोग पहचान",
            "நோய் கண்டறிதல்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            Container(
              height: 220,

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                ),
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: selectedImage == null
                  ? const Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.green,
                      ),
                    )
                  : ClipRRect(
                      borderRadius:
                          BorderRadius.circular(15),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: pickFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                L10n.get(
                  "Take Photo",
                  "ഫോട്ടോ എടുക്കുക",
                  "फोटो लें",
                  "புகைப்படம் எடுக்கவும்",
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: pickFromGallery,
              icon: const Icon(Icons.upload),
              label: Text(
                L10n.get(
                  "Upload Image",
                  "ചിത്രം അപ്‌ലോഡ് ചെയ്യുക",
                  "छवि अपलोड करें",
                  "படத்தை பதிவேற்றவும்",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              L10n.get(
                "Describe Symptoms",
                "ലക്ഷണങ്ങൾ വിവരിക്കുക",
                "लक्षण बताएं",
                "அறிகுறிகளை விவரிக்கவும்",
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            VoiceTextField(
              controller:
                  symptomController,
              hintText: L10n.get(
                "Describe crop symptoms...",
                "വിളയുടെ ലക്ഷണങ്ങൾ വിവരിക്കുക...",
                "फसल के लक्षण बताएं...",
                "பயிர் அறிகுறிகளை விவரிக்கவும்...",
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    analyzeSymptoms,

                icon: const Icon(
                  Icons.search,
                ),

                label: Text(
                  L10n.get(
                    "Analyze Symptoms",
                    "ലക്ഷണങ്ങൾ പരിശോധിക്കുക",
                    "लक्षणों का विश्लेषण करें",
                    "அறிகுறிகளை பகுப்பாய்வு செய்யவும்",
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 3,
              color:
                  Colors.green.shade50,

              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  children: [

                    Text(
                      L10n.get(
                        "Detected Disease",
                        "കണ്ടെത്തിയ രോഗം",
                        "पहचानी गई बीमारी",
                        "கண்டறியப்பட்ட நோய்",
                      ),
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      detectedDisease,
                      style:
                          const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${L10n.get(
                        "Confidence",
                        "കൃത്യത",
                        "विश्वास स्तर",
                        "நம்பகத்தன்மை",
                      )}: $confidence",
                    ),

                    const SizedBox(height: 10),

                    Text(
                      recommendation,
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}