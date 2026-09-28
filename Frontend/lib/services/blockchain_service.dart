import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'api_service.dart';

class BlockchainService {
  const BlockchainService();

  /// Verifies statutory MRP and authenticity of fertilizer by batch number
  Future<Map<String, dynamic>> verifyFertilizer(
    String batchNumber, {
    double? dealerAskingPrice,
  }) async {
    final payload = {
      'batch_number': batchNumber.trim(),
      if (dealerAskingPrice != null) 'dealer_asking_price': dealerAskingPrice,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/blockchain/verify-fertilizer');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Fertilizer verification failed: ${response.statusCode} - ${response.body}',
    );
  }

  /// Verifies produce batch provenance and anti-hoarding status
  Future<Map<String, dynamic>> verifyProduce(String identifier) async {
    final payload = {'identifier': identifier.trim()};
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/blockchain/verify-produce');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Produce verification failed: ${response.statusCode} - ${response.body}',
    );
  }

  /// Two-tier sale recording (PLATFORM_VERIFIED or SELF_REPORTED)
  Future<Map<String, dynamic>> recordSale({
    required String produceBatchId,
    required double quantitySold,
    required double salePriceTotal,
    required String verificationTier,
    String? buyerDetails,
  }) async {
    final payload = {
      'produce_batch_id': produceBatchId.trim(),
      'quantity_sold': quantitySold,
      'sale_price_total': salePriceTotal,
      'verification_tier': verificationTier,
      if (buyerDetails != null) 'buyer_details': buyerDetails,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/blockchain/record-sale');
    final response = await ApiService.requestWithAuth(
      method: 'POST',
      uri: uri,
      body: payload,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Sale recording failed: ${response.statusCode} - ${response.body}',
    );
  }

  /// Fetches recent public blockchain ledger blocks
  Future<List<Map<String, dynamic>>> getLedgerBlocks({int limit = 20}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/blockchain/ledger?limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return [];
  }
}
