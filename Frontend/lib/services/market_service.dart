import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';

class MarketPrice {
	final String crop;
	final double price;
	final String unit;
	final double? changePercent;
	final String? mandi;

	const MarketPrice({
		required this.crop,
		required this.price,
		required this.unit,
		this.changePercent,
		this.mandi,
	});

	bool get isUp => (changePercent ?? 0) >= 0;

	factory MarketPrice.fromJson(Map<String, dynamic> json) {
		final rawPrice = json['price'] ??
				json['modal_price'] ??
				json['price_per_quintal'] ??
				json['price_per_unit'] ??
				0;
		final rawChange = json['change_percent'] ??
				json['change'] ??
				json['trend_percent'];
		return MarketPrice(
			crop: '${json['crop'] ?? json['commodity'] ?? json['name'] ?? 'Unknown crop'}',
			price: rawPrice is num ? rawPrice.toDouble() : double.tryParse('$rawPrice') ?? 0,
			unit: '${json['unit'] ?? json['price_unit'] ?? 'kg'}',
			changePercent: rawChange is num
					? rawChange.toDouble()
					: double.tryParse('${rawChange ?? ''}'),
			mandi: json['mandi']?.toString() ?? json['mandi_name']?.toString(),
		);
	}
}

class MarketServiceException implements Exception {
	final String message;

	const MarketServiceException(this.message);

	@override
	String toString() => message;
}

class MarketService {
	const MarketService();

	Future<List<MarketPrice>> fetchMandiPrices(
		String district,
		String crop,
	) async {
		final query = <String, String>{};
		if (district.trim().isNotEmpty) query['district'] = district.trim();
		if (crop.trim().isNotEmpty) query['crop'] = crop.trim();
		return _getList('/api/v1/market/prices', query);
	}

	Future<List<MarketPrice>> searchCrops(String query) async {
		if (query.trim().isEmpty) return const [];
		return _getList('/api/v1/market/search', {'query': query.trim()});
	}

	Future<List<Map<String, dynamic>>> getPriceHistory(String crop) async {
		if (crop.trim().isEmpty) return const [];
		final response = await _get('/api/v1/market/history', {'crop': crop.trim()});
		final decoded = jsonDecode(response.body);
		final values = decoded is List
				? decoded
				: decoded is Map<String, dynamic>
						? (decoded['history'] ?? decoded['items'] ?? [])
						: [];
		return values
				.whereType<Map>()
				.map((item) => Map<String, dynamic>.from(item))
				.toList();
	}

	Future<List<MarketPrice>> _getList(
		String path,
		Map<String, String> query,
	) async {
		final response = await _get(path, query);
		final decoded = jsonDecode(response.body);
		final values = decoded is List
				? decoded
				: decoded is Map<String, dynamic>
						? (decoded['prices'] ?? decoded['items'] ?? decoded['results'] ?? [])
						: [];
		if (values is! List) {
			throw const MarketServiceException('The market response was invalid.');
		}
		return values
				.whereType<Map>()
				.map((item) => MarketPrice.fromJson(Map<String, dynamic>.from(item)))
				.toList();
	}

	Future<http.Response> _get(String path, Map<String, String> query) async {
		final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
		try {
			final response = await http.get(uri).timeout(const Duration(seconds: 10));
			if (response.statusCode < 200 || response.statusCode >= 300) {
				throw MarketServiceException(
					'Market service returned status ${response.statusCode}.',
				);
			}
			return response;
		} on MarketServiceException {
			rethrow;
		} catch (_) {
			throw const MarketServiceException(
				'Unable to reach the market service. Check your connection and try again.',
			);
		}
	}
}