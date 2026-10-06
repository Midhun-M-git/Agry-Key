import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/voice_navigation_service.dart';
import '../utils/localization.dart';

class VoiceCompanionBar extends StatefulWidget {
  final bool showMuteControl;
  final String? customHint;

  const VoiceCompanionBar({
    super.key,
    this.showMuteControl = true,
    this.customHint,
  });

  @override
  State<VoiceCompanionBar> createState() => _VoiceCompanionBarState();
}

class _VoiceCompanionBarState extends State<VoiceCompanionBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  String _statusText = "";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    VoiceNavigationService.isListeningNotifier.addListener(_onListeningChanged);
    VoiceNavigationService.lastTranscriptNotifier.addListener(_onTranscriptChanged);
    TTSService.muteNotifier.addListener(_onMuteChanged);
  }

  void _onListeningChanged() {
    if (mounted) {
      setState(() {
        if (VoiceNavigationService.isListening) {
          _statusText = L10n.get(
            "Listening... Speak any command or question",
            "കേൾക്കുന്നു... എങ്ങോട്ട് പോകണമെന്ന് പറയൂ",
            "सुन रहा हूँ... कोई आदेश या प्रश्न बोलें",
            "கேட்கிறது... எங்கு செல்ல வேண்டும் என்று சொல்லுங்கள்",
          );
        } else {
          _statusText = "";
        }
      });
    }
  }

  void _onTranscriptChanged() {
    final t = VoiceNavigationService.lastTranscriptNotifier.value;
    if (mounted && t.isNotEmpty) {
      setState(() {
        _statusText = '"$t"';
      });
    }
  }

  void _onMuteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    VoiceNavigationService.isListeningNotifier.removeListener(_onListeningChanged);
    VoiceNavigationService.lastTranscriptNotifier.removeListener(_onTranscriptChanged);
    TTSService.muteNotifier.removeListener(_onMuteChanged);
    super.dispose();
  }

  void _toggleMic() {
    if (VoiceNavigationService.isListening) {
      VoiceNavigationService.stopListening();
    } else {
      VoiceNavigationService.startListening(
        context: context,
        onStarted: () {
          if (mounted) setState(() {});
        },
        onStopped: () {
          if (mounted) setState(() {});
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isListening = VoiceNavigationService.isListening;
    final isMuted = TTSService.isMuted;

    final defaultHint = widget.customHint ??
        L10n.get(
          "Voice Companion active · Tap mic to command",
          "വോയ്സ് അസിസ്റ്റന്റ് സജീവം · സംസാരിക്കാൻ മൈക്ക് തൊടൂ",
          "वॉयस असिस्टेंट सक्रिय · बोलने के लिए माइक दबाएं",
          "குரல் வழிகாட்டி தயார் · பேச மைக்கை தொடவும்",
        );

    final displayPrompt = _statusText.isNotEmpty ? _statusText : defaultHint;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isListening ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isListening ? Colors.green : Colors.grey.shade300,
          width: isListening ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isListening ? Colors.green : Colors.black).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Animated Microphone
          GestureDetector(
            onTap: _toggleMic,
            child: ScaleTransition(
              scale: isListening ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening ? Colors.green : Colors.green.shade50,
                ),
                child: Icon(
                  Icons.mic,
                  color: isListening ? Colors.white : Colors.green.shade800,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Status & Command prompt
          Expanded(
            child: GestureDetector(
              onTap: _toggleMic,
              child: Text(
                displayPrompt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isListening ? FontWeight.bold : FontWeight.w500,
                  color: isListening ? Colors.green.shade900 : Colors.grey.shade800,
                ),
              ),
            ),
          ),

          // Mute / Unmute Speaker Toggle Button
          if (widget.showMuteControl) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: TTSService.toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMuted ? Colors.red.shade50 : Colors.grey.shade100,
                  border: Border.all(
                    color: isMuted ? Colors.red.shade200 : Colors.grey.shade300,
                  ),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 18,
                  color: isMuted ? Colors.red.shade700 : Colors.green.shade800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
