import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/ai_service.dart';
import '../services/location_service.dart';
import '../services/tts_service.dart';
import '../utils/localization.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/voice_companion_bar.dart';

class CropAdvisoryScreen extends ConsumerStatefulWidget {
  const CropAdvisoryScreen({super.key});

  @override
  ConsumerState<CropAdvisoryScreen> createState() => _CropAdvisoryScreenState();
}

class _CropAdvisoryScreenState extends ConsumerState<CropAdvisoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _recommendations;
  double _selectedAcreage = 1.0;
  String _selectedSoilType = 'RED_LOAMY';
  String _selectedWaterSource = 'BOREWELL';
  String _plotName = 'AgriStack Verified Plot #1';
  String _activeSpeakingCropId = '';
  bool _hasSpokenInitialSummary = false;

  final List<Map<String, String>> _soilOptions = [
    {'value': 'RED_LOAMY', 'label': 'Red Loamy', 'label_ml': 'ചെമ്മണ്ണ്', 'label_hi': 'लाल दोमट', 'label_ta': 'செம்மண்'},
    {'value': 'BLACK_CLAY', 'label': 'Black Clay', 'label_ml': 'കരിമണ്ണ്', 'label_hi': 'काली मिट्टी', 'label_ta': 'கரிசல் மண்'},
    {'value': 'ALLUVIAL', 'label': 'Alluvial', 'label_ml': 'എക്കൽ മണ്ണ്', 'label_hi': 'जलोढ़ मिट्टी', 'label_ta': 'வண்டல் மண்'},
    {'value': 'LATERITE', 'label': 'Laterite', 'label_ml': 'വെട്ടുകല്ല് മണ്ണ്', 'label_hi': 'लेटराइट', 'label_ta': 'செம்புரை மண்'},
    {'value': 'SANDY_LOAM', 'label': 'Sandy Loam', 'label_ml': 'മണൽ മണ്ണ്', 'label_hi': 'बलुई दोमट', 'label_ta': 'மணல் பாங்கான மண்'},
  ];

  final List<Map<String, String>> _waterOptions = [
    {'value': 'BOREWELL', 'label': 'Borewell', 'label_ml': 'കുഴൽക്കിണർ', 'label_hi': 'बोरवेल', 'label_ta': 'ஆழ்துளை கிணறு'},
    {'value': 'CANAL', 'label': 'Canal', 'label_ml': 'കനാൽ ജലം', 'label_hi': 'नहर', 'label_ta': 'கால்வாய்'},
    {'value': 'OPEN_WELL', 'label': 'Open Well', 'label_ml': 'തുറന്ന കിണർ', 'label_hi': 'खुला कुआं', 'label_ta': 'திறந்த கிணறு'},
    {'value': 'DRIP', 'label': 'Drip Irrigation', 'label_ml': 'തുള്ളിനന', 'label_hi': 'ड्रिप सिंचाई', 'label_ta': 'சொட்டு நீர்'},
    {'value': 'RAINFED', 'label': 'Rainfed', 'label_ml': 'മഴാശ്രയം', 'label_hi': 'वर्षा आधारित', 'label_ta': 'மானாவாரி'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAgriStackDetails();
    _fetchRecommendations();
  }

  void _loadAgriStackDetails() {
    // Read farmer's digital AgriStack parcel specifications
    if (AppState.farmPayload.containsKey('plots')) {
      final plots = AppState.farmPayload['plots'] as List?;
      if (plots != null && plots.isNotEmpty) {
        final firstPlot = plots[0] as Map<String, dynamic>;
        _plotName = firstPlot['plot_name']?.toString() ?? 'AgriStack Verified Plot #1';
        _selectedAcreage = double.tryParse(firstPlot['acreage']?.toString() ?? '1.0') ?? 1.0;
        final rawSoil = firstPlot['soil_type']?.toString().toUpperCase().replaceAll(' ', '_') ?? 'RED_LOAMY';
        if (_soilOptions.any((s) => s['value'] == rawSoil)) {
          _selectedSoilType = rawSoil;
        }
        final rawWater = firstPlot['water_source']?.toString().toUpperCase().replaceAll(' ', '_') ?? 'BOREWELL';
        if (_waterOptions.any((w) => w['value'] == rawWater)) {
          _selectedWaterSource = rawWater;
        }
      }
    }
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ensure real GPS/IP location is synchronized
      if (AppState.userDistrict.isEmpty || AppState.userLatitude == 0.0) {
        await LocationService.resolveRealLocation();
      }

      final state = AppState.userState.isNotEmpty ? AppState.userState : 'Kerala';
      final district = AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'Kochi';
      final lat = AppState.userLatitude != 0.0 ? AppState.userLatitude : 9.9406;
      final lng = AppState.userLongitude != 0.0 ? AppState.userLongitude : 76.2653;

      final res = await AIService.getCropRecommendations(
        state: state,
        district: district,
        acreage: _selectedAcreage,
        soilType: _selectedSoilType,
        waterSource: _selectedWaterSource,
        latitude: lat,
        longitude: lng,
      );

      if (mounted) {
        setState(() {
          _recommendations = res;
          _isLoading = false;
        });

        // Automatically speak friendly voice advice on initial load
        if (!_hasSpokenInitialSummary) {
          _speakInitialSummary(res);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _speakInitialSummary(Map<String, dynamic> res) {
    if (TTSService.isMuted) return;

    final strategies = res['strategies'] as Map<String, dynamic>?;
    if (strategies == null) return;
    final bestStrategy = strategies['option_a_max_profit'] ?? strategies['option_b_low_risk'];
    if (bestStrategy == null) return;
    final crop = bestStrategy['crop'] as Map<String, dynamic>?;
    if (crop == null) return;

    final lang = AppState.selectedLanguage;
    final name = lang == 'Malayalam'
        ? (crop['name_ml'] ?? crop['name_en'])
        : (lang == 'Hindi'
            ? (crop['name_hi'] ?? crop['name_en'])
            : (lang == 'Tamil' ? (crop['name_ta'] ?? crop['name_en']) : crop['name_en']));

    final netProfit = (crop['net_profit'] as num?)?.toInt() ?? 0;
    final days = crop['duration_days'] ?? 75;

    String speech = "";
    if (lang == 'Malayalam') {
      speech = "നമസ്കാരം! നിങ്ങളുടെ അഗ്രിസ്റ്റാക്ക് കൃഷിഭൂമി വിവരങ്ങളും വിപണി വില പ്രവചനങ്ങളും വിശകലനം ചെയ്തതിൽ, ഏറ്റവും ഉയർന്ന ലാഭം നൽകുന്ന വിള $name ആണ്. $days ദിവസത്തിനുള്ളിൽ ഏകദേശം $netProfit രൂപ അറ്റാദായം പ്രതീക്ഷിക്കാം.";
    } else if (lang == 'Hindi') {
      speech = "नमस्ते! आपके एग्रीस्टैक खेत विवरण और मंडी भाव पूर्वानुमान के आधार पर, सबसे अधिक लाभ देने वाली फसल $name है। $days दिनों में लगभग $netProfit रुपये शुद्ध लाभ का अनुमान है।";
    } else if (lang == 'Tamil') {
      speech = "வணக்கம்! உங்கள் அக்ரிஸ்டாக் நிலம் மற்றும் எதிர்கால சந்தை விலை கணிப்புகளின்படி, அதிக லாபம் தரும் பயிர் $name. $days நாட்களில் சுமார் $netProfit ரூபாய் நிகர லாபம் கிடைக்கும்.";
    } else {
      speech = "Hello! Based on your AgriStack parcel details and future mandi price forecasts, your top recommended crop is $name, projected to earn an estimated net profit of $netProfit rupees in $days days.";
    }

    _hasSpokenInitialSummary = true;
    TTSService.speak(speech);
  }

  void _playSpokenStrategy(Map<String, dynamic> crop, String badge) {
    final cropId = crop['crop_id']?.toString() ?? '';
    if (_activeSpeakingCropId == cropId) {
      TTSService.stop();
      setState(() => _activeSpeakingCropId = '');
      return;
    }

    setState(() => _activeSpeakingCropId = cropId);

    final lang = AppState.selectedLanguage;
    final name = lang == 'Malayalam'
        ? (crop['name_ml'] ?? crop['name_en'])
        : (lang == 'Hindi'
            ? (crop['name_hi'] ?? crop['name_en'])
            : (lang == 'Tamil' ? (crop['name_ta'] ?? crop['name_en']) : crop['name_en']));

    final netProfit = (crop['net_profit'] as num?)?.toInt() ?? 0;
    final days = crop['duration_days'] ?? 75;
    final harvestPrice = crop['harvest_price_per_quintal'] ?? 0;

    String speech = "";
    if (lang == 'Malayalam') {
      speech = "നിങ്ങൾക്കായി നിർദ്ദേശിക്കുന്ന വിള $name ആണ്. വിളവെടുപ്പ് കാലാവധി $days ദിവസമാണ്. പ്രതീക്ഷിക്കുന്ന വിപണി വില ക്വിന്റലിന് $harvestPrice രൂപയാണ്. വളവും ഗതാഗത ചെലവും കഴിഞ്ഞ് ഏകദേശം $netProfit രൂപ ലാഭം പ്രതീക്ഷിക്കാം.";
    } else if (lang == 'Hindi') {
      speech = "आपके लिए सुझाई गई फसल $name है। फसल चक्र $days दिनों का है। संभावित मंडी भाव $harvestPrice रुपये प्रति क्विंटल है। खाद और परिवहन खर्च के बाद अनुमानित शुद्ध लाभ $netProfit रुपये होगा।";
    } else if (lang == 'Tamil') {
      speech = "உங்களுக்கான பரிந்துரைக்கப்பட்ட பயிர் $name. அறுவடை காலம் $days நாட்கள். எதிர்பார்க்கப்படும் சந்தை விலை குவிண்டாலுக்கு $harvestPrice ரூபாய். உர மற்றும் போக்குவரத்து செலவு போக நிகர லாபம் $netProfit ரூபாய்.";
    } else {
      speech = "Recommended option is $name. Growth cycle is $days days. Forecasted harvest market price is $harvestPrice rupees per quintal. Estimated net profit after input and transportation costs is $netProfit rupees.";
    }

    TTSService.speak(speech);
  }

  @override
  void dispose() {
    TTSService.stop();
    super.dispose();
  }

  Widget _buildAgriStackContextCard() {
    final profile = _recommendations?['farmer_profile'] as Map<String, dynamic>?;
    final district = profile?['district'] ?? (AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'Kochi');
    final state = profile?['state'] ?? (AppState.userState.isNotEmpty ? AppState.userState : 'Kerala');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AgriStack Header & Live Sync Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified, color: Color(0xFF1B5E20), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          L10n.get(
                            "AgriStack Digital Land Parcel",
                            "അഗ്രിസ്റ്റാക്ക് കൃഷിഭൂമി വിവരങ്ങൾ",
                            "एग्रीस्टैक डिजिटल भूमि विवरण",
                            "அக்ரிஸ்டாக் நில விவரங்கள்",
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B5E20)),
                        ),
                      ],
                    ),
                    Text(
                      _plotName,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  L10n.get("LIVE GPS SYNC", "ജി.പി.എസ്", "लाइव जीपीएस", "நேரலை"),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Location & Soil chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildContextBadge(Icons.location_on, "$district, $state"),
              _buildContextBadge(Icons.terrain, _selectedSoilType.replaceAll('_', ' ')),
              _buildContextBadge(Icons.water_drop, _selectedWaterSource.replaceAll('_', ' ')),
              _buildContextBadge(Icons.trending_up, L10n.get("Market Price Forecast Active", "വിപണി വില പ്രവചനം", "मंडी भाव पूर्वानुमान", "சந்தை விலை கணிப்பு")),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Land Area (Acreage) Controller
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                L10n.get("Cultivation Area (AgriStack Acreage):", "കൃഷിഭൂമി വിസ്തീർണം:", "कृषि भूमि क्षेत्र:", "சாகுபடி நிலப்பரப்பு:"),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$_selectedAcreage ${L10n.get('Acres', 'ഏക്കർ', 'एकड़', 'ஏக்கர்')}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
              ),
            ],
          ),
          Slider(
            value: _selectedAcreage,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            activeColor: Colors.green.shade700,
            inactiveColor: Colors.green.shade100,
            label: "$_selectedAcreage Acres",
            onChanged: (val) {
              setState(() => _selectedAcreage = double.parse(val.toStringAsFixed(1)));
            },
            onChangeEnd: (_) {
              _fetchRecommendations();
            },
          ),

          // Soil Type Selector
          Text(
            L10n.get("Select Soil Type:", "മണ്ണ് തിരഞ്ഞെടുക്കുക:", "मिट्टी का प्रकार चुनें:", "மண் வகை:"),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _soilOptions.map((soil) {
                final isSelected = _selectedSoilType == soil['value'];
                final label = AppState.selectedLanguage == 'Malayalam'
                    ? (soil['label_ml'] ?? soil['label']!)
                    : (AppState.selectedLanguage == 'Hindi'
                        ? (soil['label_hi'] ?? soil['label']!)
                        : (AppState.selectedLanguage == 'Tamil' ? (soil['label_ta'] ?? soil['label']!) : soil['label']!));
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(label),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    selected: isSelected,
                    selectedColor: Colors.green.shade700,
                    backgroundColor: Colors.grey.shade100,
                    checkmarkColor: Colors.white,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedSoilType = soil['value']!);
                        _fetchRecommendations();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Irrigation / Water Source Selector
          Text(
            L10n.get("Water & Irrigation Source:", "ജലസ്രോതസ്സ്:", "जल और सिंचाई स्रोत:", "நீர் ஆதாரம்:"),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _waterOptions.map((water) {
                final isSelected = _selectedWaterSource == water['value'];
                final label = AppState.selectedLanguage == 'Malayalam'
                    ? (water['label_ml'] ?? water['label']!)
                    : (AppState.selectedLanguage == 'Hindi'
                        ? (water['label_hi'] ?? water['label']!)
                        : (AppState.selectedLanguage == 'Tamil' ? (water['label_ta'] ?? water['label']!) : water['label']!));
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(label),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade700,
                    backgroundColor: Colors.grey.shade100,
                    checkmarkColor: Colors.white,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedWaterSource = water['value']!);
                        _fetchRecommendations();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green.shade800),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 11, color: Colors.green.shade900, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStrategyCard(Map<String, dynamic> strategyData, Color accentColor, {bool isHero = false}) {
    final lang = AppState.selectedLanguage;
    final badge = lang == 'Malayalam'
        ? (strategyData['badge_ml'] ?? strategyData['badge'])
        : (lang == 'Hindi'
            ? (strategyData['badge_hi'] ?? strategyData['badge'])
            : (lang == 'Tamil' ? (strategyData['badge_ta'] ?? strategyData['badge']) : strategyData['badge']));

    final crop = strategyData['crop'] as Map<String, dynamic>;
    final cropId = crop['crop_id']?.toString() ?? '';
    final isSpeaking = _activeSpeakingCropId == cropId;

    final cropName = lang == 'Malayalam'
        ? "${crop['name_ml']} (${crop['name_en']})"
        : (lang == 'Hindi'
            ? "${crop['name_hi']} (${crop['name_en']})"
            : (lang == 'Tamil' ? "${crop['name_ta']} (${crop['name_en']})" : crop['name_en']));

    final netProfit = (crop['net_profit'] as num?)?.toInt() ?? 0;
    final grossRevenue = (crop['gross_revenue'] as num?)?.toInt() ?? 0;
    final totalInvestment = (crop['total_investment'] as num?)?.toInt() ?? 0;
    final roi = crop['roi_percentage'] ?? 0;
    final days = crop['duration_days'] ?? 75;
    final yieldQ = crop['expected_yield_quintals'] ?? 0;
    final harvestPrice = crop['harvest_price_per_quintal'] ?? 0;
    final currentPrice = crop['current_price_per_quintal'] ?? 0;
    final transportCost = (crop['total_transport_cost'] as num?)?.toInt() ?? 0;
    final transportKm = crop['transport_mandi_distance_km'] ?? 30;
    final fertilizerCost = (crop['total_fertilizer_cost'] as num?)?.toInt() ?? 0;
    final seedCost = (crop['total_seed_cost'] as num?)?.toInt() ?? 0;
    final laborCost = (crop['total_labor_cost'] as num?)?.toInt() ?? 0;
    final why = crop['why_recommended'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isHero ? Colors.green.shade600 : accentColor.withOpacity(0.35), width: isHero ? 2.0 : 1.2),
        boxShadow: [
          BoxShadow(
            color: (isHero ? Colors.green : accentColor).withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHero ? Colors.green.shade800 : accentColor.withOpacity(0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isHero) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          badge.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isHero ? Colors.white : accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        "$days ${L10n.get('Days', 'ദിവസം', 'दिन', 'நாட்கள்')}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Name & Dedicated Voice Speaker Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cropName.toString(),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSpeaking ? Colors.red.shade600 : Colors.green.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up, size: 16),
                      label: Text(
                        isSpeaking ? L10n.get("Stop", "നിർത്തൂ", "रोकें", "நிறுத்து") : L10n.get("Listen", "കേൾക്കൂ", "सुनें", "கேட்க"),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _playSpokenStrategy(crop, badge.toString()),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Net Profit Banner Highlight
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.get(
                              "PROJECTED NET PROFIT",
                              "പ്രതീക്ഷിക്കുന്ന അറ്റാദായം",
                              "अनुमानित शुद्ध लाभ",
                              "எதிர்பார்க்கப்படும் நிகர லாபம்",
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₹$netProfit",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$roi% ROI",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Financial & Future Market Prediction Breakdown Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildMetricRow(
                        L10n.get("Expected Yield:", "പ്രതീക്ഷിക്കുന്ന വിളവ്:", "संभावित उपज:", "எதிர்பார்க்கப்படும் மகசூல்:"),
                        "$yieldQ Quintals",
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        L10n.get("Forecasted Mandi Price at Harvest:", "വിളവെടുപ്പ് വിപണി പ്രവചനം:", "कटाई पर संभावित मंडी भाव:", "அறுவடை சந்தை கணிப்பு:"),
                        "₹$harvestPrice / Q (Current: ₹$currentPrice)",
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        L10n.get("Gross Harvest Revenue:", "മൊത്തം വരുമാനം:", "सकल राजस्व:", "மொத்த வருமானம்:"),
                        "₹$grossRevenue",
                      ),
                      const Divider(height: 14),
                      _buildMetricRow(
                        L10n.get("Seed & Nursery Cost:", "വിത്ത് ചെലവ്:", "बीज लागत:", "விதை செலவு:"),
                        "₹$seedCost",
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        L10n.get("Subsidized Fertilizer:", "സബ്‌സിഡി വളം ചെലവ്:", "उर्वरक लागत:", "உர செலவு:"),
                        "₹$fertilizerCost",
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        L10n.get("Labor & Irrigation:", "കൂലി, ജലസേചനം:", "मजदूरी, सिंचाई:", "கூலி, பாசனம்:"),
                        "₹$laborCost",
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        L10n.get("APMC Mandi Transport Logistics:", "മണ്ടി ചരക്കുകൂലി:", "मंडी परिवहन:", "மண்டி போக்குவரத்து:"),
                        "₹$transportCost ($transportKm km)",
                      ),
                      const Divider(height: 14),
                      _buildMetricRow(
                        L10n.get("Total Required Investment:", "ആകെ മുടക്കുമുതൽ:", "कुल निवेश:", "மொத்த முதலீடு:"),
                        "₹$totalInvestment",
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Agronomic Rationale
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        why.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isBold ? Colors.black87 : Colors.grey.shade800,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: isBold ? Colors.green.shade900 : Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    final strategies = _recommendations?['strategies'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(
          L10n.get(
            "AI Crop Profit Maximizer",
            "AI വിള ലാഭ ഉപദേശം",
            "AI फसल लाभ सलाहकार",
            "AI பயிர் லாப ஆலோசகர்",
          ),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Predictions',
            onPressed: () {
              _hasSpokenInitialSummary = false;
              _fetchRecommendations();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(
              message: 'Synthesizing AgriStack soil chemistry, climate forecast, mandi logistics & future price predictions...',
            )
          : _errorMessage != null && strategies == null
              ? AppErrorWidget(
                  message: _errorMessage!,
                  onRetry: _fetchRecommendations,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _hasSpokenInitialSummary = false;
                    await _fetchRecommendations();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAgriStackContextCard(),
                        const SizedBox(height: 20),
                        Text(
                          L10n.get(
                            "Ranked Crop Alternatives for Maximum Return",
                            "കൂടുതൽ ലാഭം തരുന്ന ഇതര വിളകൾ",
                            "अधिकतम लाभ के लिए अनुशंसित फसलें",
                            "அதிகபட்ச லாபத்திற்கான மாற்றுப் பயிர்கள்",
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          L10n.get(
                            "Synthesized from your verified plot parameters and AI future price forecasts.",
                            "നിങ്ങളുടെ അഗ്രിസ്റ്റാക്ക് പ്ലോട്ടും ഭാവി വിപണി വിലകളും അടിസ്ഥാനമാക്കി നിർദ്ദേശിച്ചത്.",
                            "आपके एग्रीस्टैक खेत और भविष्य के मंडी भाव के आधार पर तैयार।",
                            "உங்கள் அக்ரிஸ்டாக் நிலம் மற்றும் எதிர்கால சந்தை விலை கணிப்புகளிலிருந்து பெறப்பட்டது.",
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 16),
                        if (strategies != null) ...[
                          if (strategies.containsKey('option_a_max_profit'))
                            _buildStrategyCard(strategies['option_a_max_profit'], Colors.green.shade800, isHero: true),
                          if (strategies.containsKey('option_b_low_risk'))
                            _buildStrategyCard(strategies['option_b_low_risk'], Colors.blue.shade800),
                          if (strategies.containsKey('option_c_quick_cash'))
                            _buildStrategyCard(strategies['option_c_quick_cash'], Colors.orange.shade800),
                        ],
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const SafeArea(
        child: VoiceCompanionBar(
          customHint: "Tap mic to ask questions about these crops",
        ),
      ),
    );
  }
}