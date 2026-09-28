class GovernmentScheme {
  final int id;
  final String code;
  final String name;
  final String level;
  final String? state;
  final String category;
  final String sector;
  final String description;
  final List<String> benefits;
  final List<String> eligibility;
  final List<String> applicationProcess;
  final List<String> documents;
  final String? officialUrl;
  final bool isActive;

  GovernmentScheme({
    required this.id,
    required this.code,
    required this.name,
    required this.level,
    this.state,
    required this.category,
    this.sector = 'ALL',
    required this.description,
    this.benefits = const [],
    this.eligibility = const [],
    this.applicationProcess = const [],
    this.documents = const [],
    this.officialUrl,
    this.isActive = true,
  });

  factory GovernmentScheme.fromJson(Map<String, dynamic> json) {
    return GovernmentScheme(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? 'CENTRAL',
      state: json['state'] as String?,
      category: json['category'] as String? ?? 'GENERAL',
      sector: json['sector'] as String? ?? 'ALL',
      description: json['description'] as String? ?? '',
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      eligibility: (json['eligibility'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      applicationProcess: (json['application_process'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      documents: (json['documents'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      officialUrl: json['official_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'level': level,
      if (state != null) 'state': state,
      'category': category,
      'sector': sector,
      'description': description,
      'benefits': benefits,
      'eligibility': eligibility,
      'application_process': applicationProcess,
      'documents': documents,
      if (officialUrl != null) 'official_url': officialUrl,
      'is_active': isActive,
    };
  }
}
