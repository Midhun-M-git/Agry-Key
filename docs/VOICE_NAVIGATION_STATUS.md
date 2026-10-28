# Agry-Key: Voice Navigation Implementation Status

## 1. Overview
Agry-Key provides push-to-talk voice navigation and contextual narration for farmers across both English and Malayalam, designed with safety, truthfulness, and strict allowlisting.

## 2. Interaction Model & Visible States
The companion bar (`Frontend/lib/widgets/voice_companion_bar.dart`) displays real-time state feedback:
- **`idle`**: "Push to talk / സംസാരിക്കാൻ അമർത്തുക" (Green microphone button)
- **`listening`**: Animated pulse circle, shows transcribed speech in quotes
- **`processing`**: Circular progress indicator while command is matched
- **`speaking`**: Audio wave indicator with prominent red "Stop Speaking / നിർത്തുക" button
- **`awaitingClarification`**: Amber prompt requesting farmer to repeat
- **`failed`**: Red error recovery state with clear guidance and text/touch fallback

## 3. Allowlisted Command Architecture
Voice navigation routes only through a deterministic parser (`Frontend/lib/services/voice_navigation_service.dart:parseCommand`). It strictly rejects non-allowlisted commands, code injections, URLs, and database operations.

Supported 11 Command Destinations (English & Malayalam):
1. **Open Market**: `open market`, `market prices`, `mandi`, `മാർക്കറ്റ്`, `വിപണി`, `ചന്ത` -> Navigates to `MarketScreen`
2. **Open Schemes**: `open schemes`, `government schemes`, `പദ്ധതികൾ`, `സർക്കാർ പദ്ധതികൾ`, `സബ്സിഡി` -> Navigates to `SchemesScreen`
3. **Open Community**: `open community`, `farmer community`, `കൂട്ടായ്മ`, `കർഷക കൂട്ടായ്മ` -> Navigates to `CommunityScreen`
4. **Open Weather**: `open weather`, `weather forecast`, `rain`, `കാലാവസ്ഥ`, `മഴ`, `പ്രവചനം` -> Navigates to `WeatherScreen`
5. **Open Alerts**: `open alerts`, `weather alerts`, `warnings`, `അറിയിപ്പുകൾ`, `മുന്നറിയിപ്പുകൾ` -> Navigates to `AlertsScreen`
6. **Open Crop Income Planner**: `open crop planner`, `crop income planner`, `വിള വരുമാന പ്ലാനർ`, `വരുമാന പ്ലാനർ` -> Navigates to `CropAdvisoryScreen`
7. **Go Back / Home**: `go back`, `home`, `dashboard`, `പിന്നോട്ട്`, `മടങ്ങുക`, `ഹോം` -> Pops navigation or routes to `DashboardScreen`
8. **Read Screen**: `read this screen`, `read out`, `വായിക്കുക`, `ഈ പേജ് വായിക്കുക` -> Speaks contextual screen summary
9. **Repeat**: `repeat`, `say again`, `once more`, `വീണ്ടും പറയുക`, `ഒന്നുകൂടി പറയുക` -> Repeats last spoken message
10. **Stop Speaking**: `stop`, `quiet`, `mute`, `നിർത്തുക`, `മിണ്ടരുത്` -> Immediately cancels speech via `TTSService.stop()`
11. **Change Language**: `change language`, `switch language`, `ഭാഷ മാറ്റുക`, `മലയാളം`, `english` -> Switches app locale between English and Malayalam

## 4. Spoken Narration Truthfulness Rules
- **No Fabricated Prices**: If mandi prices are missing, the assistant speaks "No market price available for this commodity in this district" / "വിപണി വില ലഭ്യമല്ല", never inventing a fallback number.
- **Model Attribution**: Spoken weather summaries describe forecasts as "Open-Meteo gridded forecast model" and explicitly clarify that they are not ground sensor observations.
- **Assistant Identity**: Assistant identifies itself explicitly as "Agry-Key AI", not a human operator.
- **Privacy & Storage**: Raw audio is processed through on-device STT services and is **never stored or retained**.

## 5. Test & Hardware Status
- **Automated Validation**: All 11 commands (English & Malayalam), rejection of arbitrary input, state transitions, and cancellation tested in `test/voice_navigation_test.dart` (6 / 6 passed).
- **Physical Device Quality**: Microphone noise-cancellation and real-world farm audio clarity marked as **PENDING physical device testing in field conditions**.

