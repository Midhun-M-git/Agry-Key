import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/voice_text_field.dart';

class ChatScreen extends StatefulWidget {
  final String? peerName;
  final String? peerRole;

  const ChatScreen({
    super.key,
    this.peerName,
    this.peerRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _peerName;
  late String _peerRole;
  bool _isTyping = false;

  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();
    _peerName = widget.peerName ?? "Kisan Officer Sreekumar";
    _peerRole = widget.peerRole ?? "Krishi Bhavan Agronomist";

    messages = [
      {
        "message": "Namaskaram! Welcome to the Agry-Key direct field consultation channel. How can I assist your crop today?",
        "isMe": false,
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
        "isMe": true,
      });
      _isTyping = true;
    });

    if (presetText == null) {
      messageController.clear();
    }
    _scrollToBottom();

    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final lower = text.toLowerCase();
      String reply;

      if (lower.contains("pest") || lower.contains("insect") || lower.contains("disease")) {
        reply = "For pest/disease management, immediately inspect the underside of leaves. Prepare Neem oil spray (5ml/L) or Trichoderma viride biological culture.";
      } else if (lower.contains("fertilizer") || lower.contains("urea") || lower.contains("npk")) {
        reply = "Recommended split: apply balanced NPK 17:17:17 at vegetative stage and potash during flowering. Avoid excess urea before heavy monsoon rains.";
      } else if (lower.contains("price") || lower.contains("market") || lower.contains("mandi")) {
        reply = "Current APMC mandi arrivals show steady demand. Check the Live Market tab for real-time district auction trends.";
      } else if (lower.contains("weather") || lower.contains("rain")) {
        reply = "Review the Satellite Weather tab on your Agry-Key dashboard before scheduling spraying or foliar fertilization.";
      } else {
        reply = "Noted your query regarding your field operations. For immediate emergency ag-support, you can also dial 1800-180-1551 (Kisan Call Centre).";
      }

      setState(() {
        _isTyping = false;
        messages.add({
          "message": reply,
          "isMe": false,
        });
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_peerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(_peerRole, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isMe = messages[index]["isMe"];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 290),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.green.shade700 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messages[index]["message"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
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
                  "$_peerName is responding...",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: VoiceTextField(
                      controller: messageController,
                      hintText: "Type or speak agronomy query...",
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => sendMessage(),
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
}