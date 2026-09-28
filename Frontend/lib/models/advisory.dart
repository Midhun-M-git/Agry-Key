class AdvisoryAlternative {
  final int rank;
  final String cropName;
  final double projectedYieldQuintal;
  final double estimatedRevenueInr;
  final double inputCostInr;
  final double netProfitInr;
  final double riskScore;
  final String reasoningText;
  final String? spokenAudioUrl;

  AdvisoryAlternative({
    required this.rank,
    required this.cropName,
    required this.projectedYieldQuintal,
    required this.estimatedRevenueInr,
    required this.inputCostInr,
    required this.netProfitInr,
    required this.riskScore,
    required this.reasoningText,
    this.spokenAudioUrl,
  });

  factory AdvisoryAlternative.fromJson(Map<String, dynamic> json) {
    return AdvisoryAlternative(
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      cropName: json['crop_name'] as String? ?? '',
      projectedYieldQuintal: (json['projected_yield_quintal'] as num?)?.toDouble() ?? 0.0,
      estimatedRevenueInr: (json['estimated_revenue_inr'] as num?)?.toDouble() ?? 0.0,
      inputCostInr: (json['input_cost_inr'] as num?)?.toDouble() ?? 0.0,
      netProfitInr: (json['net_profit_inr'] as num?)?.toDouble() ?? 0.0,
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
      reasoningText: json['reasoning_text'] as String? ?? '',
      spokenAudioUrl: json['spoken_audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'crop_name': cropName,
      'projected_yield_quintal': projectedYieldQuintal,
      'estimated_revenue_inr': estimatedRevenueInr,
      'input_cost_inr': inputCostInr,
      'net_profit_inr': netProfitInr,
      'risk_score': riskScore,
      'reasoning_text': reasoningText,
      if (spokenAudioUrl != null) 'spoken_audio_url': spokenAudioUrl,
    };
  }
}

class AdvisoryRequest {
  final int farmerProfileId;
  final String district;
  final String state;
  final String queryText;
  final String preferredLanguage;

  AdvisoryRequest({
    required this.farmerProfileId,
    required this.district,
    required this.state,
    required this.queryText,
    this.preferredLanguage = 'ml',
  });

  factory AdvisoryRequest.fromJson(Map<String, dynamic> json) {
    return AdvisoryRequest(
      farmerProfileId: json['farmer_profile_id'] as int? ?? 0,
      district: json['district'] as String? ?? 'Palakkad',
      state: json['state'] as String? ?? 'Kerala',
      queryText: json['query_text'] as String? ?? '',
      preferredLanguage: json['preferred_language'] as String? ?? 'ml',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmer_profile_id': farmerProfileId,
      'district': district,
      'state': state,
      'query_text': queryText,
      'preferred_language': preferredLanguage,
    };
  }
}

class AdvisoryResponse {
  final String primaryRecommendation;
  final List<AdvisoryAlternative> alternatives;
  final List<String> synergies;
  final String? weatherAlert;
  final bool auditPassed;
  final String? spokenAudioUrl;
  final DateTime? generatedAt;

  AdvisoryResponse({
    required this.primaryRecommendation,
    this.alternatives = const [],
    this.synergies = const [],
    this.weatherAlert,
    this.auditPassed = true,
    this.spokenAudioUrl,
    this.generatedAt,
  });

  factory AdvisoryResponse.fromJson(Map<String, dynamic> json) {
    final rawAlts = json['alternatives'] as List<dynamic>? ?? [];
    final rawSynergies = json['synergies'] as List<dynamic>? ?? [];

    return AdvisoryResponse(
      primaryRecommendation: json['primary_recommendation'] as String? ?? '',
      alternatives: rawAlts
          .map((a) => AdvisoryAlternative.fromJson(a as Map<String, dynamic>))
          .toList(),
      synergies: rawSynergies.map((s) => s.toString()).toList(),
      weatherAlert: json['weather_alert'] as String?,
      auditPassed: json['audit_passed'] as bool? ?? true,
      spokenAudioUrl: json['spoken_audio_url'] as String?,
      generatedAt: json['generated_at'] != null ? DateTime.tryParse(json['generated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_recommendation': primaryRecommendation,
      'alternatives': alternatives.map((a) => a.toJson()).toList(),
      'synergies': synergies,
      if (weatherAlert != null) 'weather_alert': weatherAlert,
      'audit_passed': auditPassed,
      if (spokenAudioUrl != null) 'spoken_audio_url': spokenAudioUrl,
      if (generatedAt != null) 'generated_at': generatedAt!.toIso8601String(),
    };
  }
}
