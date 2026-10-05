import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/soil_service.dart';
import '../services/token_service.dart';
import '../utils/localization.dart';

class SoilHealthScreen extends ConsumerStatefulWidget {
  const SoilHealthScreen({super.key});

  @override
  ConsumerState<SoilHealthScreen> createState() => _SoilHealthScreenState();
}

class _SoilHealthScreenState extends ConsumerState<SoilHealthScreen> {
  SoilHealthData? _data;
  bool _isLoading = true;
  String _selectedDistrict = "Palakkad";
  String _selectedSoilType = "RED_LOAMY";

  final List<String> _districts = [
    "Palakkad",
    "Thrissur",
    "Kannur",
    "Malappuram",
    "Ernakulam",
    "Kozhikode",
    "Wayanad",
    "Coimbatore",
    "Madurai",
    "Salem",
    "Thanjavur",
    "Tirunelveli",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final session = await TokenService.loadSession();
    if (session.district.isNotEmpty && _districts.contains(session.district)) {
      _selectedDistrict = session.district;
    }
    await _fetchSoilData();
  }

  Future<void> _fetchSoilData() async {
    setState(() => _isLoading = true);
    final data = await SoilService.getSoilHealth(
      district: _selectedDistrict,
      soilType: _selectedSoilType,
      farmerProfileId: AppState.farmerProfileId,
    );
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Soil Health & Recommendations",
            "മണ്ണിന്റെ ആരോഗ്യം & നിർദ്ദേശങ്ങൾ",
            "मिट्टी का स्वास्थ्य एवं सिफारिशें",
            "மண் ஆரோக்கியம் மற்றும் பரிந்துரைகள்",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSoilData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // District Selector Row
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(
                            L10n.get("District:", "ജില്ല:", "जिला:", "மாவட்டம்:"),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDistrict,
                                isExpanded: true,
                                items: _districts.map((d) {
                                  return DropdownMenuItem<String>(
                                    value: d,
                                    child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null && val != _selectedDistrict) {
                                    setState(() => _selectedDistrict = val);
                                    _fetchSoilData();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Official Soil Health Cards (if user has reports)
                  if (_data?.userReports.isNotEmpty == true) ...[
                    Text(
                      L10n.get(
                        "Your Lab Soil Health Cards",
                        "നിങ്ങളുടെ ലാബ് മണ്ണ് കാർഡുകൾ",
                        "आपके लैब मृदा स्वास्थ्य कार्ड",
                        "உங்கள் மண் சுகாதார அட்டை",
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._data!.userReports.map(
                      (r) => Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.shcNumber ?? "SHC-${r.id}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                  ),
                                  Chip(
                                    label: Text(r.plotName ?? "Main Plot", style: const TextStyle(fontSize: 12)),
                                    backgroundColor: Colors.green.shade50,
                                  ),
                                ],
                              ),
                              Text("${L10n.get("Lab:", "ലാബ്:", "प्रयोगशाला:", "ஆய்வகம்:")} ${r.testingLabName}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _metricColumn("pH", "${r.phLevel}", Colors.orange),
                                  _metricColumn("Organic C", "${r.organicCarbonPercent}%", Colors.brown),
                                  _metricColumn("Nitrogen", r.nitrogenStatus, Colors.blue),
                                  _metricColumn("Potash", r.potassiumStatus, Colors.purple),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Regional Survey Parameters
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.science, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                "${_data?.district} Regional Soil Survey",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metricBox("Soil Type", _data?.soilType.replaceAll('_', ' ') ?? "Loamy", Icons.landscape, Colors.brown),
                              _metricBox("Avg pH", "${_data?.averagePh ?? 6.5}", Icons.science, Colors.orange),
                              _metricBox("Organic C", "${_data?.averageOc ?? 0.65}%", Icons.grass, Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Suitable Crops Section
                  if (_data?.suitableCrops.isNotEmpty == true) ...[
                    Text(
                      L10n.get(
                        "Suitable Crops for this Soil",
                        "ഈ മണ്ണിന് അനുയോജ്യമായ വിളകൾ",
                        "इस मिट्टी के लिए उपयुक्त फसलें",
                        "இந்த மண்ணிற்கு ஏற்ற பயிர்கள்",
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _data!.suitableCrops.map((crop) {
                        return Chip(
                          avatar: const Icon(Icons.eco, size: 16, color: Colors.green),
                          label: Text(crop, style: const TextStyle(fontWeight: FontWeight.w600)),
                          backgroundColor: Colors.green.shade50,
                          side: BorderSide(color: Colors.green.shade200),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Agronomic Fertilizer Recommendations
                  Text(
                    L10n.get(
                      "Recommended Fertilizer & Soil Health Actions",
                      "വളം & മണ്ണ് പരിപാലന നിർദ്ദേശങ്ങൾ",
                      "उर्वरक एवं मृदा स्वास्थ्य सिफारिशें",
                      "உரம் மற்றும் மண் பராமரிப்பு ஆலோசனைகள்",
                    ),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ...(_data?.recommendations ?? []).map(
                    (rec) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    rec.inputName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rec.purpose,
                              style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      rec.applicationGuidance,
                                      style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Survey Authority Attribution
                  if (_data?.surveyAuthority != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        "Source: ${_data!.surveyAuthority}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _metricColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _metricBox(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}