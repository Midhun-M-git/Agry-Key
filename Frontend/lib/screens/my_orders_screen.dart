import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/orders_service.dart';
import '../utils/localization.dart';
import 'invoice_screen.dart';
import 'track_order_screen.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  final bool isFarmerView;

  const MyOrdersScreen({super.key, this.isFarmerView = false});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await OrdersService.getOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Colors.green;
      case 'SHIPPED':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateOrderStatus(OrderModel order, String nextStatus) async {
    final updated = await OrdersService.updateStatus(order.id, nextStatus);
    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order #${order.id} status updated to $nextStatus"),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update status. Transition may not be allowed."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.isFarmerView
              ? L10n.get("Incoming Orders", "ലഭിച്ച ഓർഡറുകൾ", "आने वाले ऑर्डर", "வந்த ஆர்டர்கள்")
              : L10n.get("My Orders", "എന്റെ ഓർഡറുകൾ", "मेरे ऑर्डर", "என் ஆர்டர்கள்"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                L10n.get(
                                  "No orders placed yet.",
                                  "ഓർഡറുകൾ ലഭ്യമല്ല.",
                                  "अभी तक कोई ऑर्डर नहीं है।",
                                  "ஆர்டர்கள் எதுவும் இல்லை.",
                                ),
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                L10n.get(
                                  "Orders from the marketplace will appear here.",
                                  "വിപണിയിലെ ഓർഡറുകൾ ഇവിടെ കാണാം.",
                                  "मार्केटप्लेस से ऑर्डर यहां दिखाई देंगे।",
                                  "சந்தையிலிருந்து வரும் ஆர்டர்கள் இங்கே தோன்றும்.",
                                ),
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final statusColor = _getStatusColor(order.status);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Order #${order.id}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: BorderSide(color: statusColor.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  order.productName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      "${order.quantity} ${order.unit} @ ₹${order.pricePerUnit}/${order.unit}",
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "₹${order.totalAmount}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          order.deliveryAddress!,
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 20),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TrackOrderScreen(orderId: order.id),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.local_shipping_outlined, size: 16),
                                      label: Text(
                                        L10n.get("Track", "ട്രാക്ക്", "ट्रैक", "தடமறி"),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green,
                                        side: const BorderSide(color: Colors.green),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => InvoiceScreen(orderId: order.id),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.receipt_long, size: 16),
                                      label: Text(
                                        L10n.get("Invoice", "ഇൻവോയ്സ്", "रसीद", "விலைப்பட்டியல்"),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.teal,
                                        side: const BorderSide(color: Colors.teal),
                                      ),
                                    ),
                                    const Spacer(),
                                    // Status Advance Action for Farmer
                                    if (widget.isFarmerView) ...[
                                      if (order.status.toUpperCase() == 'PENDING')
                                        ElevatedButton(
                                          onPressed: () => _updateOrderStatus(order, 'CONFIRMED'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          child: const Text("Confirm", style: TextStyle(fontSize: 12)),
                                        )
                                      else if (order.status.toUpperCase() == 'CONFIRMED')
                                        ElevatedButton(
                                          onPressed: () => _updateOrderStatus(order, 'SHIPPED'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.purple,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          child: const Text("Ship", style: TextStyle(fontSize: 12)),
                                        )
                                      else if (order.status.toUpperCase() == 'SHIPPED')
                                        ElevatedButton(
                                          onPressed: () => _updateOrderStatus(order, 'DELIVERED'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          child: const Text("Deliver", style: TextStyle(fontSize: 12)),
                                        ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}