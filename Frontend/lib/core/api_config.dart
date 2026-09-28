class ApiConfig {
  /// Base URL configured dynamically via dart-define, e.g.:
  /// flutter build apk --dart-define=BACKEND_URL=https://agry-key-api.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://agry-key.onrender.com',
  );
}