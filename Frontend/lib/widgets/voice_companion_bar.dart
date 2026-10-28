import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../services/tts_service.dart';
import '../services/voice_navigation_service.dart';

class VoiceCompanionBar extends ConsumerStatefulWidget {
  final bool showMuteControl;
  final String? customHint;
  final String? currentScreenName;

  const VoiceCompanionBar({
    super.key,
    this.showMuteControl = true,
    this.customHint,
    this.currentScreenName,
  });

  @override
  ConsumerState<VoiceCompanionBar> createState() => _VoiceCompanionBarState();
}

class _VoiceCompanionBarState extends ConsumerState<VoiceCompanionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

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

    VoiceNavigationService.stateNotifier.addListener(_onStateChanged);
    VoiceNavigationService.lastTranscriptNotifier.addListener(_onStateChanged);
    VoiceNavigationService.errorNotifier.addListener(_onStateChanged);
    TTSService.muteNotifier.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    VoiceNavigationService.stateNotifier.removeListener(_onStateChanged);
    VoiceNavigationService.lastTranscriptNotifier.removeListener(_onStateChanged);
    VoiceNavigationService.errorNotifier.removeListener(_onStateChanged);
    TTSService.muteNotifier.removeListener(_onStateChanged);
    super.dispose();
  }

  void _toggleMic() {
    final state = VoiceNavigationService.currentState;
    if (state == VoiceInteractionState.listening) {
      VoiceNavigationService.stopListening();
    } else if (state == VoiceInteractionState.speaking) {
      VoiceNavigationService.stopSpeaking();
    } else {
      VoiceNavigationService.startListening(
        context: context,
        ref: ref,
        currentScreenName: widget.currentScreenName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = VoiceNavigationService.currentState;
    final isMuted = TTSService.isMuted;
    final transcript = VoiceNavigationService.lastTranscriptNotifier.value;
    final error = VoiceNavigationService.errorNotifier.value;

    Color barBgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Widget leadingIcon;
    String displayPrompt;

    switch (state) {
      case VoiceInteractionState.listening:
        barBgColor = const Color(0xFFE8F5E9);
        borderColor = Colors.green;
        leadingIcon = ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 20),
          ),
        );
        displayPrompt = transcript.isNotEmpty
            ? '"$transcript"'
            : l10n.voiceStateListening;
        break;

      case VoiceInteractionState.processing:
        barBgColor = const Color(0xFFF1F8E9);
        borderColor = Colors.lightGreen;
        leadingIcon = const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
          ),
        );
        displayPrompt = l10n.voiceStateProcessing;
        break;

      case VoiceInteractionState.speaking:
        barBgColor = const Color(0xFFE3F2FD);
        borderColor = Colors.blue.shade300;
        leadingIcon = Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade100,
          ),
          child: Icon(Icons.volume_up, color: Colors.blue.shade800, size: 20),
        );
        displayPrompt = l10n.voiceStateSpeaking;
        break;

      case VoiceInteractionState.awaitingClarification:
        barBgColor = const Color(0xFFFFF8E1);
        borderColor = Colors.amber;
        leadingIcon = Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.shade100,
          ),
          child: Icon(Icons.hearing, color: Colors.amber.shade900, size: 20),
        );
        displayPrompt = l10n.voiceStateClarifying;
        break;

      case VoiceInteractionState.failed:
        barBgColor = const Color(0xFFFFEBEE);
        borderColor = Colors.red.shade200;
        leadingIcon = Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.shade100,
          ),
          child: Icon(Icons.mic_off, color: Colors.red.shade800, size: 20),
        );
        displayPrompt = error ?? l10n.voiceStateFailed;
        break;

      case VoiceInteractionState.idle:
        barBgColor = Colors.white;
        borderColor = Colors.grey.shade300;
        leadingIcon = Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.shade50,
          ),
          child: Icon(Icons.mic, color: Colors.green.shade800, size: 20),
        );
        displayPrompt = widget.customHint ??
            "${l10n.aiAssistantName} · ${l10n.voiceStateIdle}";
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: barBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleMic,
            child: leadingIcon,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _toggleMic,
              child: Text(
                displayPrompt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: state == VoiceInteractionState.listening ||
                          state == VoiceInteractionState.speaking
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: state == VoiceInteractionState.failed
                      ? Colors.red.shade800
                      : Colors.black87,
                ),
              ),
            ),
          ),
          if (state == VoiceInteractionState.speaking) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: VoiceNavigationService.stopSpeaking,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  l10n.voiceActionStop,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
            ),
          ],
          if (widget.showMuteControl) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: TTSService.toggleMute,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMuted ? Colors.red.shade50 : Colors.grey.shade100,
                  border: Border.all(
                    color: isMuted ? Colors.red.shade200 : Colors.grey.shade300,
                  ),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 16,
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
