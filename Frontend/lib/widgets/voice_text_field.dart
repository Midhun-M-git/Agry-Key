import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const VoiceTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  State<VoiceTextField> createState() =>
      _VoiceTextFieldState();
}

class _VoiceTextFieldState
    extends State<VoiceTextField> {

  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  Future<void> startListening() async {
    bool available =
        await speech.initialize();

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            widget.controller.text =
                result.recognizedWords;
          });
        },
      );
    }
  }

  Future<void> stopListening() async {
    await speech.stop();

    setState(() {
      isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,

      decoration: InputDecoration(
        hintText: widget.hintText,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        suffixIcon: IconButton(
          icon: Icon(
            isListening
                ? Icons.mic_off
                : Icons.mic,
            color: Colors.green,
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
    );
  }
}