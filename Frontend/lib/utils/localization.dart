import '../core/app_state.dart';

class L10n {
  const L10n._();

  static String _activeLocaleCode = 'en';

  static void setActiveLocale(String code) {
    _activeLocaleCode = code.toLowerCase();
    if (_activeLocaleCode == 'ml') {
      AppState.selectedLanguage = 'Malayalam';
    } else {
      AppState.selectedLanguage = 'English';
    }
  }

  static String get(
    String en,
    String ml, [
    String? hi,
    String? ta,
  ]) {
    final lang = AppState.selectedLanguage.toLowerCase();
    if (_activeLocaleCode == 'ml' || lang == 'malayalam' || lang == 'ml') {
      return ml.isNotEmpty ? ml : en;
    }
    if (lang == 'hindi' || lang == 'hi') {
      return (hi != null && hi.isNotEmpty) ? hi : en;
    }
    if (lang == 'tamil' || lang == 'ta') {
      return (ta != null && ta.isNotEmpty) ? ta : en;
    }
    return en;
  }
}
