class ApiConfig {
  /// Base URL configured dynamically via dart-define, e.g.:
  /// flutter build apk --dart-define=BACKEND_URL=https://agry-key.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://agry-key.onrender.com',
  );

  /// App Version injected at build time, e.g. v1.0.9
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'v1.0.0',
  );

  /// Distribution channel: 'github' (default, standalone APK with in-app updater)
  /// or 'play' (Google Play Store compliant without REQUEST_INSTALL_PACKAGES or direct APK self-updating).
  static const String distribution = String.fromEnvironment(
    'DISTRIBUTION',
    defaultValue: 'github',
  );

  static bool get isPlayStore => distribution.toLowerCase() == 'play';
  static bool get isGitHubDistribution => distribution.toLowerCase() == 'github';
}
