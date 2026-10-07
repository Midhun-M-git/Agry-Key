import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/voice_text_field.dart';

class ChatFarmerScreen extends StatefulWidget {
  final String? farmerName;
  final String? farmerPhone;
  final String? productName;
  final String? farmerLocation;

  const ChatFarmerScreen({
    super.key,
    this.farmerName,
    this.farmerPhone,
    this.productName,
    this.farmerLocation,
  });

  @override
  State<ChatFarmerScreen> createState() => _ChatFarmerScreenState();
}

class _ChatFarmerScreenState extends State<ChatFarmerScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _farmerName;
  late String _productName;
  late String _farmerPhone;
  late String _farmerLocation;
  bool _isTyping = false;

  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();
    _farmerName = widget.farmerName ?? "Suresh Menon";
    _productName = widget.productName ?? "Agricultural Produce";
    _farmerPhone = widget.farmerPhone ?? "+91 94471 23456";
    _farmerLocation = widget.farmerLocation ?? "Palakkad, Kerala";

    messages = [
      {
        "message": "Namaskaram! Thank you for inquiring about $_productName.",
        "isBuyer": false,
        "time": "Just now",
      },
      {
        "message": "Hello $_farmerName, I am interested in placing an order for $_productName.",
        "isBuyer": true,
        "time": "Just now",
      },
      {
        "message": "Our latest lot in $_farmerLocation is ready and freshly harvested. How much quantity do you require?",
        "isBuyer": false,
        "time": "Just now",
      },
    ];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage([String? presetText]) {
    final text = presetText ?? messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "message": text,
        "isBuyer": true,
        "time": "Just now",
      });
      _isTyping = true;
    });

    if (presetText == null) {
      messageController.clear();
    }
    _scrollToBottom();

    // Intelligent agronomic / farmer response simulation
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final lower = text.toLowerCase();
      String reply;

      if (lower.contains("price") || lower.contains("rate") || lower.contains("cost") || lower.contains("discount")) {
        reply = "For bulk orders of $_productName, we can offer an additional ₹2-3/unit rebate directly, zero middleman cuts!";
      } else if (lower.contains("pickup") || lower.contains("delivery") || lower.contains("transport") || lower.contains("ship")) {
        reply = "We have direct truck access to our farm in $_farmerLocation. Agry-Key inter-district logistics can also deliver right to your warehouse.";
      } else if (lower.contains("quality") || lower.contains("grade") || lower.contains("organic") || lower.contains("certif")) {
        reply = "This lot is Grade A certified by the local Krishi Bhavan cluster with zero chemical ripening additives.";
      } else if (lower.contains("harvest") || lower.contains("when") || lower.contains("fresh")) {
        reply = "Harvested within the last 48 hours and stored under optimal ventilated conditions.";
      } else if (lower.contains("kg") || lower.contains("quintal") || lower.contains("quantity") || RegExp(r'\d+').hasMatch(lower)) {
        reply = "We can weigh and prepare that quantity for dispatch immediately upon order confirmation!";
      } else {
        reply = "Understood! You can place the order directly on Agry-Key or reach out directly at $_farmerPhone.";
      }

      setState(() {
        _isTyping = false;
        messages.add({
          "message": reply,
          "isBuyer": false,
          "time": "Just now",
        });
      });
      _scrollToBottom();
    });
  }

  Future<void> _callFarmer() async {
    final clean = _farmerPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Producer Helpline"),
        content: Text("Direct Phone: $_farmerPhone\nLocation: $_farmerLocation"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget chatBubble(String text, bool isBuyer) {
    return Align(
      alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: isBuyer ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isBuyer ? const Radius.circular(14) : const Radius.circular(2),
            bottomRight: isBuyer ? const Radius.circular(2) : const Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBuyer ? Colors.white : Colors.black87,
            fontSize: 14.5,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F3),
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.person, color: Colors.green, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _farmerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$_productName • $_farmerLocation",
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: "Call Farmer",
            onPressed: _callFarmer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick suggestion chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickActionChip("What is the bulk price?"),
                  const SizedBox(width: 8),
                  _quickActionChip("Can you deliver to my location?"),
                  const SizedBox(width: 8),
                  _quickActionChip("What is the harvest date?"),
                  const SizedBox(width: 8),
                  _quickActionChip("Is Grade A certificate included?"),
                ],
              ),
            ),
          ),

          // Message Thread
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return chatBubble(
                  messages[index]["message"],
                  messages[index]["isBuyer"],
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "$_farmerName is typing...",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                ),
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: VoiceTextField(
                      controller: messageController,
                      hintText: "Inquire about quantity, harvest, price...",
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: IconButton(
                      onPressed: () => sendMessage(),
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.green.shade50,
      side: BorderSide(color: Colors.green.shade200),
      onPressed: () => sendMessage(label),
    );
  }
}