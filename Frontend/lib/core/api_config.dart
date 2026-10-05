class ApiConfig {
  /// Base URL configured dynamically via dart-define, e.g.:
  /// flutter build apk --dart-define=BACKEND_URL=https://agry-key-api.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://agry-key.onrender.com',
  );

  /// App Version injected at build time, e.g. v1.0.9
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'v1.0.0',
  );
}