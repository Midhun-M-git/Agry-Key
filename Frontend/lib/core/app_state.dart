import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String selectedRole;
  final String phoneNumber;
  final String accessToken;
  final String refreshToken;

  const AuthState({
    this.selectedRole = '',
    this.phoneNumber = '',
    this.accessToken = '',
    this.refreshToken = '',
  });

  AuthState copyWith({
    String? selectedRole,
    String? phoneNumber,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      selectedRole: selectedRole ?? this.selectedRole,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setRole(String value) {
    state = state.copyWith(selectedRole: value);
    AppState.selectedRole = value;
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
    AppState.phoneNumber = value;
  }

  void setTokens({required String accessToken, required String refreshToken}) {
    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    AppState.accessToken = accessToken;
    AppState.refreshToken = refreshToken;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class UserState {
  final String userName;
  final String userOccupation;
  final String farmName;
  final String mainCrop;
  final String userCrop;
  final String selectedTheme;
  final Map<String, dynamic> farmPayload;

  const UserState({
    this.userName = '',
    this.userOccupation = '',
    this.farmName = '',
    this.mainCrop = '',
    this.userCrop = '',
    this.selectedTheme = 'Green Harvest',
    this.farmPayload = const {},
  });

  UserState copyWith({
    String? userName,
    String? userOccupation,
    String? farmName,
    String? mainCrop,
    String? userCrop,
    String? selectedTheme,
    Map<String, dynamic>? farmPayload,
  }) {
    return UserState(
      userName: userName ?? this.userName,
      userOccupation: userOccupation ?? this.userOccupation,
      farmName: farmName ?? this.farmName,
      mainCrop: mainCrop ?? this.mainCrop,
      userCrop: userCrop ?? this.userCrop,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      farmPayload: farmPayload ?? this.farmPayload,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  void update({
    String? userName,
    String? userOccupation,
    String? farmName,
    String? mainCrop,
    String? userCrop,
    String? selectedTheme,
    Map<String, dynamic>? farmPayload,
  }) {
    state = state.copyWith(
      userName: userName,
      userOccupation: userOccupation,
      farmName: farmName,
      mainCrop: mainCrop,
      userCrop: userCrop,
      selectedTheme: selectedTheme,
      farmPayload: farmPayload,
    );
    AppState.userName = userName ?? AppState.userName;
    AppState.userOccupation = userOccupation ?? AppState.userOccupation;
    AppState.farmName = farmName ?? AppState.farmName;
    AppState.mainCrop = mainCrop ?? AppState.mainCrop;
    AppState.userCrop = userCrop ?? AppState.userCrop;
    AppState.selectedTheme = selectedTheme ?? AppState.selectedTheme;
    AppState.farmPayload = farmPayload ?? AppState.farmPayload;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('English');

  void setLanguage(String value) {
    state = value;
    AppState.selectedLanguage = value;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);

class LocationState {
  final String userLocation;
  final double latitude;
  final double longitude;
  final String state;
  final String district;

  const LocationState({
    this.userLocation = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.state = '',
    this.district = '',
  });

  LocationState copyWith({
    String? userLocation,
    double? latitude,
    double? longitude,
    String? state,
    String? district,
  }) {
    return LocationState(
      userLocation: userLocation ?? this.userLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      state: state ?? this.state,
      district: district ?? this.district,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  void update({
    String? userLocation,
    double? latitude,
    double? longitude,
    String? regionState,
    String? district,
  }) {
    state = this.state.copyWith(
      userLocation: userLocation,
      latitude: latitude,
      longitude: longitude,
      state: regionState,
      district: district,
    );
    AppState.userLocation = userLocation ?? AppState.userLocation;
    AppState.latitude = latitude ?? AppState.latitude;
    AppState.longitude = longitude ?? AppState.longitude;
    AppState.state = regionState ?? AppState.state;
    AppState.district = district ?? AppState.district;
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);

class AppState {
  static String selectedLanguage = 'English';
  static String selectedRole = '';
  static String selectedTheme = 'Green Harvest';
  static String userName = '';
  static String userLocation = '';
  static String userOccupation = '';
  static String phoneNumber = '';
  static String farmName = '';
  static String mainCrop = '';
  static String userCrop = '';
  static double latitude = 0.0;
  static double longitude = 0.0;
  static String state = '';
  static String district = '';
  static String accessToken = '';
  static String refreshToken = '';
  static Map<String, dynamic> farmPayload = {};

  static String get language => selectedLanguage;
  static set language(String val) => selectedLanguage = val;

  static String get userState => state;
  static set userState(String val) => state = val;

  static String get userDistrict => district;
  static set userDistrict(String val) => district = val;

  static double get userLatitude => latitude;
  static set userLatitude(double val) => latitude = val;

  static double get userLongitude => longitude;
  static set userLongitude(double val) => longitude = val;

  static void watchAll(WidgetRef ref) {
    ref.watch(authProvider);
    ref.watch(userProvider);
    ref.watch(languageProvider);
    ref.watch(locationProvider);
  }
}