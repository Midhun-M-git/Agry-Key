import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "message":
          "Hello, I am interested in your rice.",
      "isMe": false,
    },
    {
      "message":
          "Sure. How much quantity do you need?",
      "isMe": true,
    },
  ];

  void sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      messages.add({
        "message": messageController.text,
        "isMe": true,
      });
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Chat"),
        backgroundColor: Colors.green,
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isMe =
                    messages[index]["isMe"];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(
                      vertical: 5,
                    ),

                    padding:
                        const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.green
                          : Colors.grey.shade300,

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),

                    child: Text(
                      messages[index]["message"],
                      style: TextStyle(
                        color: isMe
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller:
                        messageController,

                    decoration:
                        const InputDecoration(
                      hintText:
                          "Type message...",
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                FloatingActionButton(
                  mini: true,
                  backgroundColor:
                      Colors.green,

                  onPressed: sendMessage,

                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
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