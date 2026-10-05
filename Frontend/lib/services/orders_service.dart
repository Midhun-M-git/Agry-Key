import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'token_service.dart';

class OrderModel {
  final int id;
  final int buyerId;
  final String? buyerName;
  final int farmerId;
  final String? farmerName;
  final int productId;
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String? deliveryAddress;
  final String? notes;
  final String status;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    this.buyerName,
    required this.farmerId,
    this.farmerName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    this.deliveryAddress,
    this.notes,
    required this.status,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int? ?? 0,
      buyerId: json['buyer_id'] as int? ?? 0,
      buyerName: json['buyer_name'] as String?,
      farmerId: json['farmer_id'] as int? ?? 0,
      farmerName: json['farmer_name'] as String?,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? 'Agricultural Produce',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'kg',
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['delivery_address'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class OrdersService {
  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<OrderModel>> getOrders() async {
    try {
      final headers = await _headers();
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/v1/orders'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        return decoded.map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<OrderModel?> getOrder(int orderId) async {
    try {
      final headers = await _headers();
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/v1/orders/$orderId'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return OrderModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  static Future<OrderModel?> updateStatus(int orderId, String newStatus) async {
    try {
      final headers = await _headers();
      final res = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/v1/orders/$orderId/status'),
            headers: headers,
            body: jsonEncode({'status': newStatus}),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return OrderModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}
