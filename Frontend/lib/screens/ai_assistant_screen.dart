import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/localization.dart';
import '../core/app_state.dart';
import '../core/api_config.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText speech;
  bool isListening = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    // Welcome message
    _messages.add({
      'isUser': false,
      'text':
          'Welcome to AGRI KEY AI Assistant.\n\nAsk me anything about farming, weather, crops, soil health, fertilizer prices, market rates, or government schemes.',
    });
  }

  @override
  void dispose() {
    questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (result) {
          setState(() {
            questionController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  Future<void> stopListening() async {
    await speech.stop();
    setState(() => isListening = false);
  }

  Future<void> _sendQuestion(String text) async {
    final question = text.trim();
    if (question.isEmpty) return;
    questionController.clear();

    setState(() {
      _messages.add({'isUser': true, 'text': question});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/advisory/chat');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'state': AppState.userState.isNotEmpty ? AppState.userState : 'Kerala',
          'district': AppState.userDistrict.isNotEmpty ? AppState.userDistrict : '',
          'language': AppState.language,
        }),
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final answer = response.statusCode == 200
          ? (jsonDecode(response.body)['answer'] as String? ?? 'No response received.')
          : 'The AI assistant is temporarily unavailable. Please try again.';

      setState(() {
        _messages.add({'isUser': false, 'text': answer});
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'isUser': false,
          'text': 'Unable to connect to Agry-Key AI. Please check your internet connection.',
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

  Widget _chatBubble(Map<String, dynamic> msg) {
    final isUser = msg['isUser'] as bool;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
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
          msg['text'] as String,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  Widget _quickChip(String title, String question) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: Colors.green.shade100,
        label: Text(title, style: TextStyle(color: Colors.green.shade900, fontSize: 13)),
        onPressed: () => _sendQuestion(question),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Clear chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  'isUser': false,
                  'text': 'Chat cleared. Ask me anything about farming!',
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action chips
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickChip(
                    L10n.get('Weather', 'കാലാവസ്ഥ', 'मौसम', 'வானிலை'),
                    'Will it rain tomorrow in ${AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'my region'}?',
                  ),
                  _quickChip(
                    L10n.get('Market', 'വിപണി', 'बाज़ार', 'சந்தை'),
                    'What is the current mandi price for paddy in ${AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'Kerala'}?',
                  ),
                  _quickChip(
                    L10n.get('Crop', 'വിള', 'फसल', 'பயிர்'),
                    'What is the best crop to grow now in ${AppState.userState.isNotEmpty ? AppState.userState : 'Kerala'}?',
                  ),
                  _quickChip(
                    L10n.get('Soil', 'മണ്ണ്', 'मिट्टी', 'மண்'),
                    'How do I improve soil health and reduce fertilizer costs?',
                  ),
                  _quickChip(
                    L10n.get('Schemes', 'പദ്ധതി', 'योजना', 'திட்டம்'),
                    'What government schemes am I eligible for as a farmer?',
                  ),
                ],
              ),
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            L10n.get('Thinking...', 'ചിന്തിക്കുന്നു...', 'सोच रहा है...', 'யோசிக்கிறது...'),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _chatBubble(_messages[index]);
              },
            ),
          ),

          // Input area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: questionController,
                    maxLines: 2,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendQuestion,
                    decoration: InputDecoration(
                      hintText: L10n.get(
                        'Ask your farming question...',
                        'നിങ്ങളുടെ ചോദ്യം ചോദിക്കൂ...',
                        'अपना सवाल पूछें...',
                        'உங்கள் கேள்வி கேளுங்கள்...',
                      ),
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.green.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.green.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: isListening ? Colors.red : Colors.green.shade100,
                  child: IconButton(
                    icon: Icon(
                      isListening ? Icons.mic_off : Icons.mic,
                      color: isListening ? Colors.white : Colors.green,
                    ),
                    onPressed: () async {
                      if (isListening) {
                        await stopListening();
                      } else {
                        await startListening();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : () => _sendQuestion(questionController.text),
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