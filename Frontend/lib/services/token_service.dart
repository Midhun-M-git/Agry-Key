import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoredSession {
  final String? accessToken;
  final String? refreshToken;
  final String language;
  final String role;
  final String phoneNumber;
  final String userName;
  final String userLocation;
  final String userOccupation;
  final String farmName;
  final String mainCrop;
  final String userCrop;
  final double latitude;
  final double longitude;
  final String state;
  final String district;
  final Map<String, dynamic> farmPayload;

  const StoredSession({
    this.accessToken,
    this.refreshToken,
    this.language = 'English',
    this.role = '',
    this.phoneNumber = '',
    this.userName = '',
    this.userLocation = '',
    this.userOccupation = '',
    this.farmName = '',
    this.mainCrop = '',
    this.userCrop = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.state = '',
    this.district = '',
    this.farmPayload = const {},
  });

  bool get isAuthenticated =>
      accessToken != null && TokenService.isTokenValid(accessToken!);
}

class TokenService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _languageKey = 'selected_language';
  static const _roleKey = 'selected_role';
  static const _phoneNumberKey = 'phone_number';
  static const _userNameKey = 'user_name';
  static const _userLocationKey = 'user_location';
  static const _userOccupationKey = 'user_occupation';
  static const _farmNameKey = 'farm_name';
  static const _mainCropKey = 'main_crop';
  static const _userCropKey = 'user_crop';
  static const _latitudeKey = 'latitude';
  static const _longitudeKey = 'longitude';
  static const _stateKey = 'state';
  static const _districtKey = 'district';
  static const _farmPayloadKey = 'farm_payload';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<void> saveUserDetails({
    String? userName,
    String? userLocation,
    String? userOccupation,
    String? farmName,
    String? mainCrop,
    String? userCrop,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    String? state,
    String? district,
    Map<String, dynamic>? farmPayload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, Object>{};
    if (userName != null) values[_userNameKey] = userName;
    if (userLocation != null) values[_userLocationKey] = userLocation;
    if (userOccupation != null) values[_userOccupationKey] = userOccupation;
    if (farmName != null) values[_farmNameKey] = farmName;
    if (mainCrop != null) values[_mainCropKey] = mainCrop;
    if (userCrop != null) values[_userCropKey] = userCrop;
    if (phoneNumber != null) values[_phoneNumberKey] = phoneNumber;
    if (latitude != null) values[_latitudeKey] = latitude;
    if (longitude != null) values[_longitudeKey] = longitude;
    if (state != null) values[_stateKey] = state;
    if (district != null) values[_districtKey] = district;
    for (final entry in values.entries) {
      if (entry.value is String) {
        await prefs.setString(entry.key, entry.value as String);
      } else if (entry.value is double) {
        await prefs.setDouble(entry.key, entry.value as double);
      }
    }
    if (farmPayload != null) {
      await prefs.setString(_farmPayloadKey, jsonEncode(farmPayload));
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<StoredSession> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (accessToken != null && !isTokenValid(accessToken)) {
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      accessToken = null;
    }
    final payloadText = prefs.getString(_farmPayloadKey);
    Map<String, dynamic> farmPayload = {};
    if (payloadText != null) {
      try {
        farmPayload = Map<String, dynamic>.from(jsonDecode(payloadText));
      } catch (_) {
        farmPayload = {};
      }
    }
    return StoredSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      language: prefs.getString(_languageKey) ?? 'English',
      role: prefs.getString(_roleKey) ?? '',
      phoneNumber: prefs.getString(_phoneNumberKey) ?? '',
      userName: prefs.getString(_userNameKey) ?? '',
      userLocation: prefs.getString(_userLocationKey) ?? '',
      userOccupation: prefs.getString(_userOccupationKey) ?? '',
      farmName: prefs.getString(_farmNameKey) ?? '',
      mainCrop: prefs.getString(_mainCropKey) ?? '',
      userCrop: prefs.getString(_userCropKey) ?? '',
      latitude: prefs.getDouble(_latitudeKey) ?? 0.0,
      longitude: prefs.getDouble(_longitudeKey) ?? 0.0,
      state: prefs.getString(_stateKey) ?? '',
      district: prefs.getString(_districtKey) ?? '',
      farmPayload: farmPayload,
    );
  }

  static bool isTokenValid(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return false;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final expiry = payload['exp'];
      if (expiry is! num) return false;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 < expiry;
    } catch (_) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
