class PriceTrend {
  final String date;
  final double price;

  PriceTrend({
    required this.date,
    required this.price,
  });

  factory PriceTrend.fromJson(Map<String, dynamic> json) {
    return PriceTrend(
      date: json['date'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'price': price,
    };
  }
}

class MarketPrice {
  final int id;
  final String commodityName;
  final String sector;
  final String state;
  final String district;
  final String mandiName;
  final double modalPrice;
  final double minPrice;
  final double maxPrice;
  final String priceUnit;
  final String officialSource;
  final double? priceChangePercent;
  final List<PriceTrend> historicalTrends;
  final DateTime? fetchedAt;

  MarketPrice({
    required this.id,
    required this.commodityName,
    required this.sector,
    required this.state,
    required this.district,
    required this.mandiName,
    required this.modalPrice,
    required this.minPrice,
    required this.maxPrice,
    this.priceUnit = 'quintal',
    this.officialSource = 'Agmarknet',
    this.priceChangePercent,
    this.historicalTrends = const [],
    this.fetchedAt,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    final rawTrends = json['historical_trends'] as List<dynamic>? ?? [];
    return MarketPrice(
      id: json['id'] as int? ?? 0,
      commodityName: json['commodity_name'] as String? ?? '',
      sector: json['sector'] as String? ?? 'CROP',
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      mandiName: json['mandi_name'] as String? ?? '',
      modalPrice: (json['modal_price'] as num?)?.toDouble() ?? 0.0,
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0.0,
      priceUnit: json['price_unit'] as String? ?? 'quintal',
      officialSource: json['official_source'] as String? ?? 'Agmarknet',
      priceChangePercent: (json['price_change_percent'] as num?)?.toDouble(),
      historicalTrends: rawTrends
          .map((t) => PriceTrend.fromJson(t as Map<String, dynamic>))
          .toList(),
      fetchedAt: json['fetched_at'] != null ? DateTime.tryParse(json['fetched_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commodity_name': commodityName,
      'sector': sector,
      'state': state,
      'district': district,
      'mandi_name': mandiName,
      'modal_price': modalPrice,
      'min_price': minPrice,
      'max_price': maxPrice,
      'price_unit': priceUnit,
      'official_source': officialSource,
      if (priceChangePercent != null) 'price_change_percent': priceChangePercent,
      'historical_trends': historicalTrends.map((t) => t.toJson()).toList(),
      if (fetchedAt != null) 'fetched_at': fetchedAt!.toIso8601String(),
    };
  }
}
