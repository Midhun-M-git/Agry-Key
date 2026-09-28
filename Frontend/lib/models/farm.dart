class Plot {
  final int? id;
  final String plotName;
  final double acreage;
  final String soilType;
  final String waterSource;
  final double? latitude;
  final double? longitude;
  final List<String> cropsCurrentlyGrown;

  Plot({
    this.id,
    required this.plotName,
    required this.acreage,
    required this.soilType,
    required this.waterSource,
    this.latitude,
    this.longitude,
    this.cropsCurrentlyGrown = const [],
  });

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'] as int?,
      plotName: json['plot_name'] as String? ?? 'Main Plot',
      acreage: (json['acreage'] as num?)?.toDouble() ?? 1.0,
      soilType: json['soil_type'] as String? ?? 'Clay Loam',
      waterSource: json['water_source'] as String? ?? 'Canal',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      cropsCurrentlyGrown: (json['crops_currently_grown'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'plot_name': plotName,
      'acreage': acreage,
      'soil_type': soilType,
      'water_source': waterSource,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'crops_currently_grown': cropsCurrentlyGrown,
    };
  }
}

class Livestock {
  final int? id;
  final String animalType;
  final String? breed;
  final int headCount;
  final String purpose;

  Livestock({
    this.id,
    required this.animalType,
    this.breed,
    required this.headCount,
    this.purpose = 'DAIRY',
  });

  factory Livestock.fromJson(Map<String, dynamic> json) {
    return Livestock(
      id: json['id'] as int?,
      animalType: json['animal_type'] as String? ?? 'Cow',
      breed: json['breed'] as String?,
      headCount: (json['head_count'] as num?)?.toInt() ?? 1,
      purpose: json['purpose'] as String? ?? 'DAIRY',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'animal_type': animalType,
      if (breed != null) 'breed': breed,
      'head_count': headCount,
      'purpose': purpose,
    };
  }
}

class Poultry {
  final int? id;
  final String birdType;
  final int birdCount;
  final String purpose;

  Poultry({
    this.id,
    required this.birdType,
    required this.birdCount,
    this.purpose = 'EGGS',
  });

  factory Poultry.fromJson(Map<String, dynamic> json) {
    return Poultry(
      id: json['id'] as int?,
      birdType: json['bird_type'] as String? ?? 'Hen',
      birdCount: (json['bird_count'] as num?)?.toInt() ?? 10,
      purpose: json['purpose'] as String? ?? 'EGGS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bird_type': birdType,
      'bird_count': birdCount,
      'purpose': purpose,
    };
  }
}

class Aquaculture {
  final int? id;
  final String pondName;
  final double pondSizeAcres;
  final String fishSpecies;
  final String waterType;

  Aquaculture({
    this.id,
    required this.pondName,
    required this.pondSizeAcres,
    required this.fishSpecies,
    this.waterType = 'FRESHWATER',
  });

  factory Aquaculture.fromJson(Map<String, dynamic> json) {
    return Aquaculture(
      id: json['id'] as int?,
      pondName: json['pond_name'] as String? ?? 'Main Pond',
      pondSizeAcres: (json['pond_size_acres'] as num?)?.toDouble() ?? 0.5,
      fishSpecies: json['fish_species'] as String? ?? 'Rohu',
      waterType: json['water_type'] as String? ?? 'FRESHWATER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'pond_name': pondName,
      'pond_size_acres': pondSizeAcres,
      'fish_species': fishSpecies,
      'water_type': waterType,
    };
  }
}

class FarmPortfolio {
  final List<Plot> plots;
  final List<Livestock> livestock;
  final List<Poultry> poultry;
  final List<Aquaculture> aquaculture;

  FarmPortfolio({
    this.plots = const [],
    this.livestock = const [],
    this.poultry = const [],
    this.aquaculture = const [],
  });

  factory FarmPortfolio.fromJson(Map<String, dynamic> json) {
    final rawPlots = json['plots'] as List<dynamic>? ?? [];
    final rawLivestock = json['livestock'] as List<dynamic>? ?? [];
    final rawPoultry = json['poultry'] as List<dynamic>? ?? [];
    final rawAqua = json['aquaculture'] as List<dynamic>? ?? [];

    return FarmPortfolio(
      plots: rawPlots.map((e) => Plot.fromJson(e as Map<String, dynamic>)).toList(),
      livestock: rawLivestock.map((e) => Livestock.fromJson(e as Map<String, dynamic>)).toList(),
      poultry: rawPoultry.map((e) => Poultry.fromJson(e as Map<String, dynamic>)).toList(),
      aquaculture: rawAqua.map((e) => Aquaculture.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plots': plots.map((e) => e.toJson()).toList(),
      'livestock': livestock.map((e) => e.toJson()).toList(),
      'poultry': poultry.map((e) => e.toJson()).toList(),
      'aquaculture': aquaculture.map((e) => e.toJson()).toList(),
    };
  }
}
