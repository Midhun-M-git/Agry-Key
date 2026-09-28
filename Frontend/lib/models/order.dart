class OrderItem {
  final int? productId;
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalPrice;

  OrderItem({
    this.productId,
    required this.productName,
    required this.quantity,
    this.unit = 'kg',
    required this.pricePerUnit,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as int?,
      productName: json['product_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'kg',
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'total_price': totalPrice,
    };
  }
}

class Order {
  final int id;
  final int buyerId;
  final int sellerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String? deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    this.status = 'PENDING',
    this.deliveryAddress,
    this.paymentMethod = 'RAZORPAY',
    this.paymentStatus = 'PENDING',
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Order(
      id: json['id'] as int? ?? 0,
      buyerId: json['buyer_id'] as int? ?? 0,
      sellerId: json['seller_id'] as int? ?? 0,
      items: itemsList,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING',
      deliveryAddress: json['delivery_address'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'RAZORPAY',
      paymentStatus: json['payment_status'] as String? ?? 'PENDING',
      razorpayOrderId: json['razorpay_order_id'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'items': items.map((i) => i.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      if (razorpayOrderId != null) 'razorpay_order_id': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpay_payment_id': razorpayPaymentId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
