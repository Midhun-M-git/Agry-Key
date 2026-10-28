# Agry-Key: Language & Localization Status

## 1. Overview
The localization framework in Agry-Key has been upgraded from ad-hoc inline maps to a typed, reactive Flutter localization architecture supporting the pilot languages: **English (`en`)** and **Malayalam (`ml`)**.

## 2. Architecture & State Management
- **Single Source of Truth:** `LocaleNotifier` (`Frontend/lib/core/locale_provider.dart`), provided via Riverpod's `localeProvider`.
- **MaterialApp Binding:** `AgriKeyApp` (`Frontend/lib/main.dart`) is a `ConsumerWidget` binding `MaterialApp.router(locale: ref.watch(localeProvider), ...)` with `AppLocalizations.delegate` and `GlobalMaterialLocalizations.delegate`.
- **Zero-Restart Rebuilds:** Calling `ref.read(localeProvider.notifier).setLocale(Locale('ml'))` immediately rebuilds the active widget tree across all open screens without requiring logout or app restart.
- **Persistence:** Selected locale and explicit choice flags are stored in `SharedPreferences` under `user_preferred_locale` and `has_explicit_language_selection`. Restored automatically on app initialization.

## 3. First-Run Onboarding Journey
1. **Initial Default:** Begins in English when no explicit preference exists.
2. **Location Rationale:** A prominent modal explains why location is requested ("We request your location to suggest regional market prices, local weather advisories, and the most relevant language for your district. Location suggests a language; it never overrides your personal choice.").
3. **Bilingual Regional Suggestion:** When GPS/district resolution detects Kerala, a bilingual suggestion dialog is presented:
   - "Switch to Malayalam / അതെ, മലയാളം"
   - "Keep English / ഇംഗ്ലീഷിൽ തുടരുക"
   - "Choose another language / മറ്റൊരു ഭാഷ"
4. **Explicit Confirmation Only:** Language is switched only when confirmed by the farmer.
5. **No Silent Switching on Travel:** `checkLocationLanguageSuggestion()` checks `hasExplicitSelection`. If true, location never overrides farmer choice during subsequent travels.
6. **Denied Permission Graceful Fallback:** If location permission is denied or coordinates are unavailable, manual selection is offered directly without blocking app usage.

## 4. Screen-by-Screen Coverage
- **Dashboard & Navigation:** All bottom bar labels, navigation titles, and section headers localized.
- **Market & Mandi:** Mandi rates, source badges (Agmarknet), unit labels, empty states, and error recovery localized.
- **Schemes:** Central/state tags, benefit headers, eligibility guidelines, and translation review disclaimer.
  - *Reviewed Localized Content:* When `scheme.translations['ml']` exists, displays Malayalam name and description.
  - *Untranslated Content:* Displays original title/description along with honest tag: `ഇംഗ്ലീഷ് പതിപ്പ് (പരിഭാഷ അവലോകനത്തിലാണ്)` and localized translation note.
- **Community:** Post creation forms, reply counts, empty states, and author labels localized. Farmer-authored posts are preserved in their original entered text.
- **Weather & Alerts:** Temperature, humidity, wind, rainfall units, and Open-Meteo gridded model disclaimer localized.
- **Crop Income Planner:** Farmland input (acres), estimated income, production cost, net margin, and calculation formulas localized.
- **Voice Controls:** States (listening, processing, speaking, clarification, failed) and stop/repeat action buttons fully localized.

## 5. Native Review Status
- **Automated Validation:** 100% verified via unit and widget tests (`test/language_switching_test.dart` and `test/responsive_layout_test.dart`).
- **Native-Speaker Review:** Marked as **PENDING native Malayalam speaker and agronomic terminology review** on production hardware.

