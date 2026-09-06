import 'package:flutter/material.dart';
import '../services/voice_navigation_service.dart';

class VoiceAssistantFab extends StatefulWidget {
  const VoiceAssistantFab({super.key});

  @override
  State<VoiceAssistantFab> createState() => _VoiceAssistantFabState();
}

class _VoiceAssistantFabState extends State<VoiceAssistantFab> {
  bool _isListening = false;
  String _spokenText = "";

  void _toggleListening() {
    if (_isListening) {
      VoiceNavigationService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      VoiceNavigationService.listenAndNavigate(
        context,
        onResultText: (text) {
          setState(() {
            _spokenText = text;
          });
        },
        onListeningState: (listening) {
          setState(() {
            _isListening = listening;
          });
        },
      );
    }
  }

  void _showVoiceNavigationModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.mic, color: Colors.green, size: 28),
                          SizedBox(width: 10),
                          Text(
                            "Agry-Key Voice Assistant",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _isListening
                        ? "Listening... Speak your command..."
                        : _spokenText.isNotEmpty
                            ? "I heard: \"$_spokenText\""
                            : "Tap mic or select a voice command below:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _isListening ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _toggleListening();
                      setModalState(() {});
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: _isListening ? Colors.red : Colors.green.shade700,
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Voice Shortcuts / നയിക്കാനുള്ള ശബ്ദ കമാൻഡുകൾ:",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildVoiceShortcutChip("Market / വില", "market"),
                      _buildVoiceShortcutChip("Weather / കാലാവസ്ഥ", "weather"),
                      _buildVoiceShortcutChip("Disease / രോഗം", "disease"),
                      _buildVoiceShortcutChip("Advisory / ഉപദേശം", "advisory"),
                      _buildVoiceShortcutChip("Schemes / പദ്ധതി", "schemes"),
                      _buildVoiceShortcutChip("Soil Health / മണ്ണ്", "soil"),
                      _buildVoiceShortcutChip("AI Assistant / എഐ", "assistant"),
                      _buildVoiceShortcutChip("Farmer / കർഷകൻ", "farmer"),
                      _buildVoiceShortcutChip("Buyer / ഉപഭോക്താവ്", "buyer"),
                      _buildVoiceShortcutChip("Orders / ഓർഡർ", "order"),
                      _buildVoiceShortcutChip("Profile / പ്രൊഫൈൽ", "profile"),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVoiceShortcutChip(String label, String command) {
    return ActionChip(
      avatar: const Icon(Icons.volume_up, size: 16, color: Colors.green),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.green.shade50,
      side: BorderSide(color: Colors.green.shade300),
      onPressed: () {
        Navigator.pop(context);
        VoiceNavigationService.processVoiceCommand(context, command);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "global_voice_assistant_fab",
      onPressed: _showVoiceNavigationModal,
      backgroundColor: _isListening ? Colors.red : Colors.green.shade700,
      icon: Icon(
        _isListening ? Icons.mic : Icons.graphic_eq,
        color: Colors.white,
      ),
      label: Text(
        _isListening ? "Listening..." : "Voice",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
