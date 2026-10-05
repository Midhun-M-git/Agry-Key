import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../services/api_service.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/tts_service.dart';

class FarmerOnboardingScreen extends ConsumerStatefulWidget {
  const FarmerOnboardingScreen({super.key});

  @override
  _FarmerOnboardingScreenState createState() =>
      _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState
  extends ConsumerState<FarmerOnboardingScreen> {

  late stt.SpeechToText _speech;
  bool _isProcessingVoice = false;

  final stateController =
      TextEditingController();

  final districtController =
      TextEditingController();

  final farmNameController =
      TextEditingController();

  final cropController =
      TextEditingController();

  final acreageController =
      TextEditingController();
      final soilTypeController = TextEditingController();
final waterSourceController = TextEditingController();

final animalTypeController = TextEditingController();
final breedController = TextEditingController();
final headCountController = TextEditingController();

final birdTypeController = TextEditingController();
final birdCountController = TextEditingController();

final pondNameController = TextEditingController();
final pondSizeController = TextEditingController();
final fishSpeciesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    stateController.dispose();
    districtController.dispose();
    farmNameController.dispose();
    cropController.dispose();
    acreageController.dispose();
    soilTypeController.dispose();
waterSourceController.dispose();

animalTypeController.dispose();
breedController.dispose();
headCountController.dispose();

birdTypeController.dispose();
birdCountController.dispose();

pondNameController.dispose();
pondSizeController.dispose();
fishSpeciesController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> saveFarmDetails() async {
    if (stateController.text.isEmpty ||
        districtController.text.isEmpty ||
        farmNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
        ),
      );
      return;
    }

    final location = "${districtController.text}, ${stateController.text}";
    final payload = {
      "state": stateController.text.trim(),
      "district": districtController.text.trim(),
      "latitude": ref.read(locationProvider).latitude,
      "longitude": ref.read(locationProvider).longitude,
      "plots": [
        {
          "plot_name": farmNameController.text.trim(),
          "acreage": double.tryParse(acreageController.text) ?? 1.0,
          "soil_type": soilTypeController.text.trim().isNotEmpty
              ? soilTypeController.text.trim()
              : "RED_LOAMY",
          "water_source": waterSourceController.text.trim().isNotEmpty
              ? waterSourceController.text.trim()
              : "Well / Canal",
          "crops_currently_grown": [
            cropController.text.trim().isNotEmpty
                ? cropController.text.trim()
                : "Paddy"
          ],
        }
      ],
      "livestock": animalTypeController.text.trim().isEmpty
          ? []
          : [
              {
                "animal_type": animalTypeController.text.trim(),
                "breed": breedController.text.trim().isNotEmpty
                    ? breedController.text.trim()
                    : "Desi",
                "head_count": int.tryParse(headCountController.text) ?? 1,
                "purpose": "DAIRY"
              }
            ],
      "poultry": birdTypeController.text.trim().isEmpty
          ? []
          : [
              {
                "bird_type": birdTypeController.text.trim(),
                "bird_count": int.tryParse(birdCountController.text) ?? 10,
                "purpose": "EGGS"
              }
            ],
      "aquaculture": pondNameController.text.trim().isEmpty
          ? []
          : [
              {
                "pond_name": pondNameController.text.trim(),
                "pond_size_acres": double.tryParse(pondSizeController.text) ?? 0.5,
                "fish_species": fishSpeciesController.text.trim().isNotEmpty
                    ? fishSpeciesController.text.trim()
                    : "Carp"
              }
            ],
    };

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/onboarding/farm');
      await ApiService.requestWithAuth(method: 'POST', uri: uri, body: payload);
    } catch (_) {}

    ref.read(userProvider.notifier).update(
      farmName: farmNameController.text,
      userCrop: cropController.text,
      farmPayload: payload,
    );
    ref.read(locationProvider.notifier).update(userLocation: location);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Farm Portfolio Configured Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  void _startVoiceInterview() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VoiceInterviewDialog(
        speech: _speech,
        onCompleted: (transcript) async {
          if (transcript.isEmpty) return;
          setState(() => _isProcessingVoice = true);
          await _fillFromTranscript(transcript);
          if (mounted) setState(() => _isProcessingVoice = false);
        },
      ),
    );
  }

  /// Sends transcript to backend AI and parses the JSON response to fill fields,
  /// with an instant local NLP fallback if backend is unreachable or unconfigured.
  Future<void> _fillFromTranscript(String transcript) async {
    Map<String, dynamic>? parsedData;

    try {
      final prompt = """
      Extract farm details from this spoken text and respond ONLY with a JSON object.
      If a field is not mentioned, use an empty string or 0.

      Spoken text: \"$transcript\"

      Required JSON format:
      {
        \"state\": \"\",
        \"district\": \"\",
        \"farm_name\": \"\",
        \"crop\": \"\",
        \"acreage\": \"\",
        \"soil_type\": \"\",
        \"water_source\": \"\",
        \"animal_type\": \"\",
        \"breed\": \"\",
        \"head_count\": \"\",
        \"bird_type\": \"\",
        \"bird_count\": \"\",
        \"pond_name\": \"\",
        \"pond_size\": \"\",
        \"fish_species\": \"\"
      }
      """;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/advisory/chat');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': prompt,
          'state': AppState.userState.isNotEmpty ? AppState.userState : 'Kerala',
          'district': AppState.userDistrict,
          'language': 'en',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final rawAnswer = jsonDecode(response.body)['answer'] as String? ?? '';
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(rawAnswer);
        if (jsonMatch != null) {
          parsedData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        }
      }
    } catch (_) {}

    // Fallback to local NLP rule-based extraction if backend did not yield JSON
    if (parsedData == null || parsedData.values.every((v) => v == null || v.toString().trim().isEmpty)) {
      parsedData = _extractFarmDetailsLocally(transcript);
    }

    if (parsedData.isNotEmpty) {
      setState(() {
        _setIfNotEmpty(stateController, parsedData!['state']);
        _setIfNotEmpty(districtController, parsedData!['district']);
        _setIfNotEmpty(farmNameController, parsedData!['farm_name']);
        _setIfNotEmpty(cropController, parsedData!['crop']);
        _setIfNotEmpty(acreageController, parsedData!['acreage']);
        _setIfNotEmpty(soilTypeController, parsedData!['soil_type']);
        _setIfNotEmpty(waterSourceController, parsedData!['water_source']);
        _setIfNotEmpty(animalTypeController, parsedData!['animal_type']);
        _setIfNotEmpty(breedController, parsedData!['breed']);
        _setIfNotEmpty(headCountController, parsedData!['head_count']);
        _setIfNotEmpty(birdTypeController, parsedData!['bird_type']);
        _setIfNotEmpty(birdCountController, parsedData!['bird_count']);
        _setIfNotEmpty(pondNameController, parsedData!['pond_name']);
        _setIfNotEmpty(pondSizeController, parsedData!['pond_size']);
        _setIfNotEmpty(fishSpeciesController, parsedData!['fish_species']);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Voice interview auto-filled your farm details!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not detect farm details in speech. Please speak clearly or fill manually."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Map<String, dynamic> _extractFarmDetailsLocally(String text) {
    final t = text.toLowerCase();
    final data = <String, dynamic>{};

    // Acreage
    final acMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:acres?|acre|ac|cents?|hectares?|ha)\b').firstMatch(t);
    if (acMatch != null) data['acreage'] = acMatch.group(1)!;

    // States
    const states = [
      "kerala", "tamil nadu", "karnataka", "andhra pradesh", "telangana",
      "maharashtra", "punjab", "haryana", "uttar pradesh", "gujarat",
      "rajasthan", "madhya pradesh", "bihar", "west bengal", "odisha"
    ];
    for (final s in states) {
      if (t.contains(s)) {
        data['state'] = s.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
        break;
      }
    }

    // Districts
    const districts = [
      "palakkad", "thrissur", "ernakulam", "malappuram", "kozhikode", "wayanad",
      "kannur", "kasaragod", "idukki", "kottayam", "alappuzha", "pathanamthitta",
      "kollam", "thiruvananthapuram", "coimbatore", "madurai", "salem", "erode",
      "mysore", "mandya", "vellore", "tiruchirappalli", "tanjore", "shimoga"
    ];
    for (final d in districts) {
      if (t.contains(d)) {
        data['district'] = d[0].toUpperCase() + d.substring(1);
        break;
      }
    }

    // Crops
    const crops = [
      "paddy", "rice", "wheat", "cotton", "sugarcane", "maize", "corn",
      "tomato", "potato", "onion", "chilli", "pepper", "cardamom", "ginger",
      "turmeric", "tea", "coffee", "rubber", "coconut", "banana", "arecanut",
      "mango", "cashew", "tapioca", "groundnut", "mustard"
    ];
    for (final c in crops) {
      if (t.contains(c)) {
        data['crop'] = c[0].toUpperCase() + c.substring(1);
        break;
      }
    }

    // Soil
    if (t.contains("red")) data['soil_type'] = "Red Loamy";
    else if (t.contains("black")) data['soil_type'] = "Black Clay";
    else if (t.contains("alluvial")) data['soil_type'] = "Alluvial";
    else if (t.contains("sandy")) data['soil_type'] = "Sandy Loam";
    else if (t.contains("laterite")) data['soil_type'] = "Laterite";
    else if (t.contains("clay")) data['soil_type'] = "Clayey Soil";

    // Water
    if (t.contains("borewell") || t.contains("bore well")) data['water_source'] = "Borewell";
    else if (t.contains("canal")) data['water_source'] = "Canal Irrigation";
    else if (t.contains("well")) data['water_source'] = "Open Well";
    else if (t.contains("river")) data['water_source'] = "River Water";
    else if (t.contains("rain")) data['water_source'] = "Rainfed";
    else if (t.contains("drip")) data['water_source'] = "Drip Irrigation";

    // Livestock
    final cowMatch = RegExp(r'(\d+)\s*(?:cows?|cattle|buffalos?|goats?)').firstMatch(t);
    if (t.contains("cow") || t.contains("cattle")) {
      data['animal_type'] = "Cow";
      if (cowMatch != null) data['head_count'] = cowMatch.group(1)!;
    } else if (t.contains("buffalo")) {
      data['animal_type'] = "Buffalo";
      if (cowMatch != null) data['head_count'] = cowMatch.group(1)!;
    } else if (t.contains("goat")) {
      data['animal_type'] = "Goat";
      if (cowMatch != null) data['head_count'] = cowMatch.group(1)!;
    }
    // Extract breed if specifically spoken
    const knownBreeds = ["jersey", "gir", "sahiwal", "hf", "holstein", "murrah", "jafrabadi", "malabari", "boer", "jamnapari", "desi", "cross"];
    for (final b in knownBreeds) {
      if (t.contains(b)) {
        data['breed'] = b[0].toUpperCase() + b.substring(1);
        break;
      }
    }

    // Poultry
    final henMatch = RegExp(r'(\d+)\s*(?:hens?|chickens?|birds?|ducks?|poultry)').firstMatch(t);
    if (t.contains("hen") || t.contains("chicken") || t.contains("poultry")) {
      data['bird_type'] = "Hen";
      if (henMatch != null) data['bird_count'] = henMatch.group(1)!;
    } else if (t.contains("duck")) {
      data['bird_type'] = "Duck";
      if (henMatch != null) data['bird_count'] = henMatch.group(1)!;
    }

    // Aquaculture
    if (t.contains("pond") || t.contains("fish") || t.contains("aquaculture")) {
      for (final f in ["tilapia", "carp", "catla", "rohu", "prawn", "shrimp"]) {
        if (t.contains(f)) {
          data['fish_species'] = f[0].toUpperCase() + f.substring(1);
          break;
        }
      }
    }

    // Farm Name: only if spoken
    final farmNameMatch = RegExp(r'(?:farm name is|called|named)\s+([a-zA-Z\s]+?)(?:farm|\.|$)', caseSensitive: false).firstMatch(t);
    if (farmNameMatch != null && farmNameMatch.group(1) != null) {
      data['farm_name'] = "${farmNameMatch.group(1)!.trim()} Farm";
    }

    return data;
  }

  void _setIfNotEmpty(TextEditingController ctrl, dynamic value) {
    final str = value?.toString().trim() ?? '';
    if (str.isNotEmpty && str != '0' && str != 'null') {
      ctrl.text = str;
    }
  }


  @override
  Widget build(BuildContext context) {
  AppState.watchAll(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Farmer Onboarding",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              child: ElevatedButton.icon(
                onPressed: _startVoiceInterview,
                icon: const Icon(Icons.mic, color: Colors.white),
                label: Text(
                  L10n.get(
                    "AI Voice Assisted Farm Setup",
                    "AI വോയ്സ് അസിസ്റ്റഡ് ഫാം സെറ്റപ്പ്",
                    "AI वॉयस फार्म सेटअप",
                    "AI குரல் வழி பண்ணை அமைப்பு",
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Reassuring Confidentiality Banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.get(
                            "100% Confidential Farm Profile",
                            "100% സുരക്ഷിതവും രഹസ്യവുമായ വിവരങ്ങൾ",
                            "100% गोपनीय फार्म प्रोफाइल",
                            "100% பாதுகாப்பான பண்ணை சுயவிவரம்",
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          L10n.get(
                            "Your land and financial details remain strictly private and are used only to calculate your custom crop profit plan.",
                            "നിങ്ങളുടെ കൃഷി വിവരങ്ങൾ രഹസ്യമായി സൂക്ഷിക്കുകയും ലാഭവിളകൾ കണ്ടെത്താൻ മാത്രം ഉപയോഗിക്കുകയും ചെയ്യുന്നു.",
                            "आपकी जानकारी पूरी तरह सुरक्षित है और केवल आपके फसल लाभ की गणना के लिए उपयोग की जाती है।",
                            "உங்கள் பண்ணை தகவல்கள் முற்றிலும் ரகசியமாக வைக்கப்பட்டு லாப ஆலோசனைக்கு மட்டுமே பயன்படும்.",
                          ),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade800, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            TextField(
              controller: stateController,
              decoration:
                  const InputDecoration(
                labelText: "State",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  districtController,
              decoration:
                  const InputDecoration(
                labelText: "District",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  farmNameController,
              decoration:
                  const InputDecoration(
                labelText: "Farm Name",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: cropController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Main Crop",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  acreageController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    "Land Area (Acres)",
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

TextField(
  controller: soilTypeController,
  decoration: const InputDecoration(
    labelText: "Soil Type",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: waterSourceController,
  decoration: const InputDecoration(
    labelText: "Water Source",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 25),

const Text(
  "Livestock (Optional)",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

TextField(
  controller: animalTypeController,
  decoration: const InputDecoration(
    labelText: "Animal Type",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: breedController,
  decoration: const InputDecoration(
    labelText: "Breed",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: headCountController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "Head Count",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 25),

const Text(
  "Poultry (Optional)",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

TextField(
  controller: birdTypeController,
  decoration: const InputDecoration(
    labelText: "Bird Type",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: birdCountController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "Bird Count",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 25),

const Text(
  "Aquaculture (Optional)",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

TextField(
  controller: pondNameController,
  decoration: const InputDecoration(
    labelText: "Pond Name",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: pondSizeController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "Pond Size (Acres)",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: fishSpeciesController,
  decoration: const InputDecoration(
    labelText: "Fish Species",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 30),

            const SizedBox(height: 30),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveFarmDetails,
                child: const Text("Save & Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A self-contained dialog widget that manages the voice interview UI and STT lifecycle.
class _VoiceInterviewDialog extends StatefulWidget {
  final stt.SpeechToText speech;
  final Future<void> Function(String transcript) onCompleted;

  const _VoiceInterviewDialog({required this.speech, required this.onCompleted});

  @override
  State<_VoiceInterviewDialog> createState() => _VoiceInterviewDialogState();
}

class _VoiceInterviewDialogState extends State<_VoiceInterviewDialog> {
  bool _isListening = false;
  bool _isProcessing = false;
  String _transcript = '';
  String _statusMessage = 'Tap the mic and speak about your farm';

  @override
  void initState() {
    super.initState();
    final prompt = L10n.get(
      "Hello! Your farm details remain 100% confidential. Please tell me about your land: acreage, soil type, and main crops.",
      "നമസ്കാരം! നിങ്ങളുടെ വിവരങ്ങൾ തികച്ചും രഹസ്യമായിരിക്കും. കൃഷിസ്ഥലത്തിന്റെ വിസ്തീർണം, മണ്ണ്, വിളകൾ എന്നിവ പറയൂ.",
      "नमस्ते! आपकी जानकारी पूरी तरह सुरक्षित है। कृपया अपनी जमीन का आकार, मिट्टी का प्रकार और फसलें बताएं।",
      "வணக்கம்! உங்கள் பண்ணை தகவல்கள் முற்றிலும் பாதுகாப்பானது. நில அளவு, மண் வகை மற்றும் பயிர்களை கூறுங்கள்.",
    );
    TTSService.speak(prompt);
  }

  Future<void> _startListening() async {
    final available = await widget.speech.initialize(
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusMessage = 'Error: ${error.errorMsg}. Try again.';
          });
        }
      },
    );
    if (!available) {
      if (mounted) {
        setState(() => _statusMessage = 'Microphone not available. Check permissions.');
      }
      return;
    }
    setState(() {
      _isListening = true;
      _statusMessage = 'Listening... Speak about your farm now';
      _transcript = '';
    });
    widget.speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _transcript = result.recognizedWords;
          });
        }
      },
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 4),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  Future<void> _stopListening() async {
    await widget.speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _statusMessage = _transcript.isEmpty
            ? 'Nothing heard. Tap mic to try again.'
            : 'Got it! Tap "Auto-Fill" to apply.';
      });
    }
  }

  Future<void> _submitTranscript() async {
    if (_transcript.isEmpty) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'AI is analyzing your speech...';
    });
    Navigator.of(context).pop();
    await widget.onCompleted(_transcript);
  }

  @override
  void dispose() {
    widget.speech.stop();
    TTSService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.agriculture, color: Colors.green),
          SizedBox(width: 8),
          Text('AI Voice Farm Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Say something like: "I have 3 acres of paddy in Kerala, Palakkad district. Red soil, borewell water. I keep 2 cows and 20 hens."',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : Colors.green).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _isListening ? Colors.red : Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Text(
                  '"$_transcript"',
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black87),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_transcript.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: _isProcessing
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Auto-Fill'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: _isProcessing ? null : _submitTranscript,
          ),
      ],
    );
  }
}
