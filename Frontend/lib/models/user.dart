class FarmerProfile {
  final int? id;
  final int? userId;
  final String state;
  final String district;
  final String? subDistrict;
  final String? village;
  final double? latitude;
  final double? longitude;
  final bool voicePreference;

  FarmerProfile({
    this.id,
    this.userId,
    required this.state,
    required this.district,
    this.subDistrict,
    this.village,
    this.latitude,
    this.longitude,
    this.voicePreference = true,
  });

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      subDistrict: json['sub_district'] as String?,
      village: json['village'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      voicePreference: json['voice_preference'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'state': state,
      'district': district,
      if (subDistrict != null) 'sub_district': subDistrict,
      if (village != null) 'village': village,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'voice_preference': voicePreference,
    };
  }
}

class User {
  final int id;
  final String phoneNumber;
  final String? fullName;
  final String role;
  final String preferredLanguage;
  final bool isActive;
  final DateTime? createdAt;
  final FarmerProfile? profile;

  User({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    required this.role,
    this.preferredLanguage = 'ml',
    this.isActive = true,
    this.createdAt,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      phoneNumber: json['phone_number'] as String? ?? '',
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? 'FARMER',
      preferredLanguage: json['preferred_language'] as String? ?? 'ml',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      profile: json['profile'] != null ? FarmerProfile.fromJson(json['profile'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      if (fullName != null) 'full_name': fullName,
      'role': role,
      'preferred_language': preferredLanguage,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (profile != null) 'profile': profile!.toJson(),
    };
  }
}
