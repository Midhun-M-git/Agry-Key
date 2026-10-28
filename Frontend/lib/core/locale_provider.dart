import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';
import '../utils/localization.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _prefLocaleKey = 'user_preferred_locale';
  static const String _prefExplicitKey = 'has_explicit_language_selection';

  bool _hasExplicitSelection = false;
  bool get hasExplicitSelection => _hasExplicitSelection;

  LocaleNotifier() : super(const Locale('en')) {
    _loadPersistedLocale();
  }

  Future<void> _loadPersistedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasExplicit = prefs.getBool(_prefExplicitKey) ?? false;
      final savedCode = prefs.getString(_prefLocaleKey);

      if (!_hasExplicitSelection) {
        _hasExplicitSelection = hasExplicit;
        if (savedCode != null && (savedCode == 'en' || savedCode == 'ml')) {
          state = Locale(savedCode);
          L10n.setActiveLocale(savedCode);
          TTSService.setLanguage(savedCode);
        } else {
          L10n.setActiveLocale('en');
        }
      }
    } catch (_) {}
  }

  /// Sets the application locale immediately and persists the farmer's explicit choice.
  Future<void> setLocale(Locale newLocale, {bool isExplicit = true}) async {
    if (newLocale.languageCode != 'en' && newLocale.languageCode != 'ml') {
      return;
    }

    state = newLocale;
    if (isExplicit) {
      _hasExplicitSelection = true;
    }

    L10n.setActiveLocale(newLocale.languageCode);
    TTSService.setLanguage(newLocale.languageCode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLocaleKey, newLocale.languageCode);
      if (isExplicit) {
        await prefs.setBool(_prefExplicitKey, true);
      }
    } catch (_) {}
  }

  /// Checks whether a confirmed location suggests Malayalam.
  /// Returns Locale('ml') if location suggests Malayalam AND user has not made an explicit choice.
  Locale? checkLocationLanguageSuggestion({
    required String? regionState,
    required String? district,
  }) {
    if (_hasExplicitSelection) return null;

    final s = (regionState ?? '').toLowerCase().trim();
    final d = (district ?? '').toLowerCase().trim();

    if (s.contains('kerala') ||
        d.contains('palakkad') ||
        d.contains('wayanad') ||
        d.contains('ernakulam') ||
        d.contains('thrissur') ||
        d.contains('malappuram') ||
        d.contains('kozhikode') ||
        d.contains('kannur') ||
        d.contains('kollam') ||
        d.contains('alappuzha') ||
        d.contains('idukki') ||
        d.contains('kottayam') ||
        d.contains('thiruvananthapuram') ||
        d.contains('pathanamthitta') ||
        d.contains('kasaragod')) {
      return const Locale('ml');
    }
    return null;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
