import 'package:flutter/material.dart';
import '../widgets/voice_text_field.dart';

class ChatFarmerScreen extends StatefulWidget {
  const ChatFarmerScreen({super.key});

  @override
  State<ChatFarmerScreen> createState() =>
      _ChatFarmerScreenState();
}

class _ChatFarmerScreenState
    extends State<ChatFarmerScreen> {

  final TextEditingController messageController =
      TextEditingController();

  List<Map<String, dynamic>> messages = [
    {
      "message":
          "Hello, I am interested in your rice.",
      "isBuyer": true,
    },
    {
      "message":
          "Sure, how much quantity do you need?",
      "isBuyer": false,
    },
  ];

  void sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      messages.add({
        "message": messageController.text,
        "isBuyer": true,
      });
    });

    messageController.clear();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Widget chatBubble(
    String text,
    bool isBuyer,
  ) {
    return Align(
      alignment: isBuyer
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
        ),

        padding: const EdgeInsets.all(12),

        constraints:
            const BoxConstraints(maxWidth: 280),

        decoration: BoxDecoration(
          color: isBuyer
              ? Colors.green
              : Colors.grey.shade300,

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Text(
          text,
          style: TextStyle(
            color: isBuyer
                ? Colors.white
                : Colors.black,
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

        title: const Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.person),
            ),
            SizedBox(width: 10),
            Text("Farmer Chat"),
          ],
        ),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(12),

              itemCount: messages.length,

              itemBuilder: (context, index) {
                return chatBubble(
                  messages[index]["message"],
                  messages[index]["isBuyer"],
                );
              },
            ),
          ),

          Container(
            padding:
                const EdgeInsets.all(10),

            color: Colors.white,

            child: Row(
              children: [

                Expanded(
                  child: VoiceTextField(
                    controller:
                        messageController,

                    hintText:
                        "Type or speak message",
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