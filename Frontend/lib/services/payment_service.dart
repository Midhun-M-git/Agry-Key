import 'dart:convert';
import 'dart:typed_data';
import '../core/api_config.dart';
import 'api_service.dart';

class PaymentService {
  const PaymentService();

  /// Initiates a payment order with backend Razorpay gateway
  Future<Map<String, dynamic>> createPaymentOrder(int orderId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/payment/create-order');
    final response = await ApiService.requestWithAuth(
      method: 'POST',
      uri: uri,
      body: {'order_id': orderId},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Failed to initiate payment.');
  }

  /// Verifies payment cryptographic signature and marks order CONFIRMED
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/payment/verify');
    final response = await ApiService.requestWithAuth(
      method: 'POST',
      uri: uri,
      body: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Payment verification failed.');
  }

  /// Retrieves order details and invoice information
  Future<Map<String, dynamic>> getOrder(int orderId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/orders/$orderId');
    final response = await ApiService.requestWithAuth(
      method: 'GET',
      uri: uri,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch order details.');
  }

  /// Downloads official tax invoice PDF bytes
  Future<Uint8List> downloadInvoicePdf(int orderId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/orders/$orderId/invoice');
    final response = await ApiService.requestWithAuth(
      method: 'GET',
      uri: uri,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw Exception('Failed to download invoice PDF.');
  }
}
