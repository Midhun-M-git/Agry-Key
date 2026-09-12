import '../core/app_state.dart';

class L10n {
  const L10n._();

  static String get(
    String en,
    String ml,
    String hi,
    String ta,
  ) {
    switch (AppState.selectedLanguage) {
      case 'Malayalam':
        return ml;
      case 'Hindi':
        return hi;
      case 'Tamil':
        return ta;
      default:
        return en;
    }
  }
}
