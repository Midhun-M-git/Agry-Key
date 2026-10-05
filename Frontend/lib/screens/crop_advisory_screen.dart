import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/ai_service.dart';
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
  String _activeSpeakingCropId = '';

  @override
  void initState() {
    super.initState();
    // Default acreage from profile if configured
    if (AppState.farmPayload.containsKey('plots')) {
      final plots = AppState.farmPayload['plots'] as List?;
      if (plots != null && plots.isNotEmpty) {
        final ac = double.tryParse(plots[0]['acreage']?.toString() ?? '1.0') ?? 1.0;
        _selectedAcreage = ac;
      }
    }
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String soil = 'RED_LOAMY';
      String water = 'BOREWELL';

      if (AppState.farmPayload.containsKey('plots')) {
        final plots = AppState.farmPayload['plots'] as List?;
        if (plots != null && plots.isNotEmpty) {
          soil = plots[0]['soil_type']?.toString() ?? 'RED_LOAMY';
          water = plots[0]['water_source']?.toString() ?? 'BOREWELL';
        }
      }

      final state = AppState.userState.isNotEmpty ? AppState.userState : 'Kerala';
      final district = AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'Palakkad';

      final res = await AIService.getCropRecommendations(
        state: state,
        district: district,
        acreage: _selectedAcreage,
        soilType: soil,
        waterSource: water,
        latitude: AppState.userLatitude != 0.0 ? AppState.userLatitude : 10.7867,
        longitude: AppState.userLongitude != 0.0 ? AppState.userLongitude : 76.6547,
      );

      if (mounted) {
        setState(() {
          _recommendations = res;
          _isLoading = false;
        });
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

  Widget _buildContextBar() {
    final profile = _recommendations?['farmer_profile'] as Map<String, dynamic>?;
    final district = profile?['district'] ?? AppState.userDistrict;
    final state = profile?['state'] ?? AppState.userState;
    final soil = profile?['soil_type'] ?? 'Red Loamy';
    final water = profile?['water_source'] ?? 'Borewell';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L10n.get(
                    "Multi-Variable AI Agronomic Engine",
                    "AI മൾട്ടി-വേരിയബിൾ അഗ്രോണമിക് എഞ്ചിൻ",
                    "AI मल्टी-वेरिएबल एग्रोनॉमिक इंजन",
                    "AI பல்வகை விவசாய உகப்பாக்கம்",
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  L10n.get("LIVE MODEL", "തത്സമയം", "लाइव", "நேரலை"),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(Icons.location_on, "$district, $state"),
              _buildBadge(Icons.terrain, soil.toString()),
              _buildBadge(Icons.water_drop, water.toString()),
              _buildBadge(Icons.cloud, "28°C · Moderate Rain Forecast"),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                L10n.get("Cultivation Land Area:", "കൃഷിഭൂമി വിസ്തീർണം:", "कृषि भूमि क्षेत्र:", "சாகுபடி நிலப்பரப்பு:"),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                "$_selectedAcreage ${L10n.get('Acres', 'ഏക്കർ', 'एकड़', 'ஏக்கர்')}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          Slider(
            value: _selectedAcreage,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            activeColor: Colors.green,
            label: "$_selectedAcreage Acres",
            onChanged: (val) {
              setState(() => _selectedAcreage = double.parse(val.toStringAsFixed(1)));
            },
            onChangeEnd: (_) {
              _fetchRecommendations();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _buildStrategyCard(Map<String, dynamic> strategyData, Color accentColor) {
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
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 12,
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
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    badge.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        "$days ${L10n.get('Days', 'ദിവസം', 'दिन', 'நாட்கள்')}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                // Crop Name & Voice Speaker
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cropName.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSpeaking ? Icons.volume_off : Icons.volume_up,
                        color: isSpeaking ? Colors.red : Colors.green,
                      ),
                      tooltip: 'Listen to Audio Strategy',
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
                              color: Colors.green.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₹$netProfit",
                            style: TextStyle(
                              fontSize: 24,
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

                // Financial & Market Breakdown Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildMetricRow(
                        L10n.get("Expected Yield:", "പ്രതീക്ഷിക്കുന്ന വിളവ്:", "संभावित उपज:", "எதிர்பார்க்கப்படும் மகசூல்:"),
                        "$yieldQ Quintals",
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        L10n.get("Mandi Price at Harvest:", "വിളവെടുപ്പ് വിപണി വില:", "कटाई पर मंडी भाव:", "அறுவடை சந்தை விலை:"),
                        "₹$harvestPrice / Q (Now: ₹$currentPrice)",
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        L10n.get("Gross Revenue:", "മൊത്തം വരുമാനം:", "सकल राजस्व:", "மொத்த வருமானம்:"),
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
                        L10n.get("APMC Mandi Transport:", "മണ്ടി ചരക്കുകൂലി:", "मंडी परिवहन:", "மண்டி போக்குவரத்து:"),
                        "₹$transportCost ($transportKm km)",
                      ),
                      const Divider(height: 14),
                      _buildMetricRow(
                        L10n.get("Total Investment:", "ആകെ മുടക്കുമുതൽ:", "कुल निवेश:", "மொத்த முதலீடு:"),
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
                          height: 1.3,
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
            color: isBold ? Colors.black87 : Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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
        backgroundColor: Colors.green,
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
            onPressed: _fetchRecommendations,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(
              message: 'Synthesizing Soil, Weather, Fertilizer Rates, Mandi Logistics & Harvest Price Forecasts...',
            )
          : _errorMessage != null && strategies == null
              ? AppErrorWidget(
                  message: _errorMessage!,
                  onRetry: _fetchRecommendations,
                )
              : RefreshIndicator(
                  onRefresh: _fetchRecommendations,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContextBar(),
                        const SizedBox(height: 20),
                        Text(
                          L10n.get(
                            "Alternative Crop Options for Maximum Profit",
                            "കൂടുതൽ ലാഭം തരുന്ന ഇതര വിളകൾ",
                            "अधिकतम लाभ के लिए वैकल्पिक फसलें",
                            "அதிகபட்ச லாபத்திற்கான மாற்றுப் பயிர்கள்",
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          L10n.get(
                            "Choose an option that best matches your water access, budget, and risk tolerance.",
                            "നിങ്ങളുടെ ജലലഭ്യതയ്ക്കും ബജറ്റിനും അനുയോജ്യമായ വിള തിരഞ്ഞെടുക്കുക.",
                            "अपनी पानी की उपलब्धता और बजट के अनुसार फसल चुनें।",
                            "உங்கள் நீர் வசதி மற்றும் பட்ஜெட்டுக்கு ஏற்ற பயிரைத் தேர்ந்தெடுக்கவும்.",
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        if (strategies != null) ...[
                          if (strategies.containsKey('option_a_max_profit'))
                            _buildStrategyCard(strategies['option_a_max_profit'], Colors.green.shade800),
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
        child: VoiceCompanionBar(),
      ),
    );
  }
}