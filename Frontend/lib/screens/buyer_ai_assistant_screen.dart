import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../utils/localization.dart';
import '../widgets/voice_text_field.dart';

class BuyerAIAssistantScreen extends ConsumerStatefulWidget {
  const BuyerAIAssistantScreen({super.key});

  @override
  _BuyerAIAssistantScreenState createState() => _BuyerAIAssistantScreenState();
}

class _BuyerAIAssistantScreenState extends ConsumerState<BuyerAIAssistantScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> messages = [
    {
      'isUser': false,
      'text': 'Hello! I am your AGRI KEY Buyer Assistant. Ask me about crops, farm produce prices, sourcing, quality grades, or agricultural market trends.',
    },
  ];

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();

    setState(() {
      messages.add({'isUser': true, 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/advisory/chat');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': text,
          'state': AppState.userState.isNotEmpty ? AppState.userState : 'India',
          'district': AppState.userDistrict.isNotEmpty ? AppState.userDistrict : '',
          'language': 'en',
        }),
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final answer = response.statusCode == 200
          ? (jsonDecode(response.body)['answer'] as String? ?? 'No answer received.')
          : 'The AI assistant is temporarily unavailable. Please try again shortly.';

      setState(() {
        messages.add({'isUser': false, 'text': answer});
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        messages.add({
          'isUser': false,
          'text': 'Unable to reach Agry-Key AI. Please check your internet connection.',
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
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

  Widget chatBubble({required bool isUser, required String text}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? Colors.green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get('AI Assistant', 'AI സഹായി', 'AI सहायक', 'AI உதவியாளர்'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Text(
              L10n.get(
                'Ask about crops, prices, sourcing, or farming.',
                'വിളകൾ, വിലകൾ, ഉറവിടം എന്നിവ ചോദിക്കൂ.',
                'फसल, मूल्य, सोर्सिंग के बारे में पूछें।',
                'பயிர்கள், விலைகள், ஆதாரம் பற்றி கேளுங்கள்.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green.shade700),
                          ),
                          const SizedBox(width: 8),
                          Text('Thinking...', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }
                final msg = messages[index];
                return chatBubble(isUser: msg['isUser'] as bool, text: msg['text'] as String);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: VoiceTextField(
                    controller: messageController,
                    hintText: L10n.get(
                      'Ask something...',
                      'ചോദിക്കൂ...',
                      'कुछ पूछें...',
                      'ஏதாவது கேளுங்கள்...',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    onPressed: _isLoading ? null : sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}