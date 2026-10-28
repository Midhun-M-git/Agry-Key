import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_state.dart';
import '../core/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';
import '../services/tts_service.dart';
import 'role_selection_screen.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  bool _hasPromptedLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRunLocationJourney();
    });
  }

  Future<void> _checkFirstRunLocationJourney() async {
    final notifier = ref.read(localeProvider.notifier);
    if (notifier.hasExplicitSelection) return;

    final prefs = await SharedPreferences.getInstance();
    final hasPrompted = prefs.getBool('has_prompted_regional_language') ?? false;
    if (hasPrompted || _hasPromptedLocation || !mounted) return;

    _showLocationRationaleDialog();
  }

  void _showLocationRationaleDialog() {
    _hasPromptedLocation = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Location & Language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            "We request your location to suggest regional market prices, local weather advisories, and the most relevant language for your district.\n\nLocation suggests a language; it never overrides your personal choice.",
            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_prompted_regional_language', true);
            },
            child: const Text("Choose Manually"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_prompted_regional_language', true);
              _detectLocationAndPrompt();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Allow & Detect"),
          ),
        ],
      ),
    );
  }

  Future<void> _detectLocationAndPrompt() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (!mounted || position == null) return;

      ref.read(locationProvider.notifier).update(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      String detectedState = "Kerala";
      String detectedDistrict = "Palakkad";

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          if (p.administrativeArea != null) detectedState = p.administrativeArea!;
          if (p.subAdministrativeArea != null) {
            detectedDistrict = p.subAdministrativeArea!;
          } else if (p.locality != null) {
            detectedDistrict = p.locality!;
          }
        }
      } catch (_) {
        if (position.latitude >= 8.1 &&
            position.latitude <= 12.8 &&
            position.longitude >= 74.8 &&
            position.longitude <= 77.5) {
          detectedState = "Kerala";
          detectedDistrict = "Palakkad";
        }
      }

      final suggested = ref.read(localeProvider.notifier).checkLocationLanguageSuggestion(
        regionState: detectedState,
        district: detectedDistrict,
      );

      if (suggested != null && mounted) {
        _showBilingualLanguageSuggestionDialog();
      }
    } catch (_) {}
  }

  void _showBilingualLanguageSuggestionDialog() {
    TTSService.speak(
      "നമസ്കാരം! നിങ്ങൾ കേരളത്തിലാണെന്ന് കാണുന്നു. അഗ്രി കീ മലയാളത്തിൽ ഉപയോഗിക്കാൻ താല്പര്യമുണ്ടോ?",
      language: "Malayalam",
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Switch to Malayalam?\nമലയാളത്തിലേക്ക് മാറ്റണോ?",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, height: 1.3),
        ),
        content: const SingleChildScrollView(
          child: Text(
            "We noticed your farm location is in Kerala. Would you like to use Agry-Key in Malayalam?\n\nനിങ്ങൾ കേരളത്തിലാണെന്ന് കാണുന്നു. അഗ്രി-കീ മലയാളത്തിൽ ഉപയോഗിക്കാൻ താല്പര്യമുണ്ടോ?",
            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              TTSService.stop();
              Navigator.pop(ctx);
              ref.read(localeProvider.notifier).setLocale(const Locale('en'), isExplicit: true);
            },
            child: const Text("Keep English\nഇംഗ്ലീഷിൽ തുടരുക", textAlign: TextAlign.center),
          ),
          ElevatedButton(
            onPressed: () {
              TTSService.stop();
              Navigator.pop(ctx);
              ref.read(localeProvider.notifier).setLocale(const Locale('ml'), isExplicit: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Switch to Malayalam\nമലയാളം തിരഞ്ഞെടുക്കുക", textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required String code,
    required String title,
    required String nativeSubtitle,
    required bool isSelected,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          ref.read(localeProvider.notifier).setLocale(Locale(code), isExplicit: true);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          foregroundColor: isSelected ? Colors.green.shade900 : Colors.black87,
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nativeSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.green.shade800 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Icon(Icons.eco, size: 50, color: Colors.green.shade800),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.appTitle,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.appSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        l10n.langPromptTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.langPromptLocationRationale,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                      ),
                      const SizedBox(height: 20),
                      _buildLanguageTile(
                        code: 'en',
                        title: 'English',
                        nativeSubtitle: 'Default application language',
                        isSelected: currentLocale.languageCode == 'en',
                      ),
                      _buildLanguageTile(
                        code: 'ml',
                        title: 'മലയാളം',
                        nativeSubtitle: 'Malayalam (കേരളം)',
                        isSelected: currentLocale.languageCode == 'ml',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RoleSelectionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n.actionConfirm,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
