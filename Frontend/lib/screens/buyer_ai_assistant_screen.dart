import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

class BuyerAIAssistantScreen extends StatefulWidget {
  const BuyerAIAssistantScreen({super.key});

  @override
  State<BuyerAIAssistantScreen> createState() =>
      _BuyerAIAssistantScreenState();
}

class _BuyerAIAssistantScreenState
    extends State<BuyerAIAssistantScreen> {

  final TextEditingController messageController =
      TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "isUser": false,
      "text":
          "Hello! I am your AGRI KEY Buyer Assistant. Ask me about crops, prices, farmers or agriculture."
    }
  ];

  String getText(
    String english,
    String malayalam,
    String hindi,
    String tamil,
  ) {
    switch (AppState.selectedLanguage) {
      case "Malayalam":
        return malayalam;
      case "Hindi":
        return hindi;
      case "Tamil":
        return tamil;
      default:
        return english;
    }
  }

  void sendMessage() {

    if (messageController.text.trim().isEmpty) {
      return;
    }

    String userMessage =
        messageController.text.trim();

    setState(() {

      messages.add({
        "isUser": true,
        "text": userMessage,
      });

      messages.add({
        "isUser": false,
        "text":
            "AI backend connection will be added later. This is a sample AGRI KEY response.",
      });
    });

    messageController.clear();
  }

  Widget chatBubble({
    required bool isUser,
    required String text,
  }) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 6,
        ),

        padding: const EdgeInsets.all(12),

        constraints: const BoxConstraints(
          maxWidth: 300,
        ),

        decoration: BoxDecoration(
          color: isUser
              ? Colors.green
              : Colors.white,

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color: Colors.green.shade200,
          ),
        ),

        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,

        title: Text(
          getText(
            "AI Assistant",
            "AI സഹായി",
            "AI सहायक",
            "AI உதவியாளர்",
          ),
        ),
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),

            color: Colors.green.shade50,

            child: Text(
              getText(
                "Ask questions using text or voice.",
                "ടെക്സ്റ്റ് അല്ലെങ്കിൽ ശബ്ദം ഉപയോഗിച്ച് ചോദിക്കാം.",
                "टेक्स्ट या आवाज़ से प्रश्न पूछें।",
                "உரை அல்லது குரல் மூலம் கேள்வி கேளுங்கள்.",
              ),

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(12),

              itemCount: messages.length,

              itemBuilder: (context, index) {

                return chatBubble(
                  isUser:
                      messages[index]["isUser"],
                  text:
                      messages[index]["text"],
                );
              },
            ),
          ),

          Container(
            padding:
                const EdgeInsets.all(12),

            decoration: const BoxDecoration(
              color: Colors.white,
            ),

            child: Row(
              children: [

                Expanded(
                  child: VoiceTextField(
                    controller:
                        messageController,

                    hintText: getText(
                      "Ask something...",
                      "ചോദിക്കൂ...",
                      "कुछ पूछें...",
                      "ஏதாவது கேளுங்கள்...",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  backgroundColor:
                      Colors.green,

                  child: IconButton(
                    onPressed: sendMessage,

                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
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