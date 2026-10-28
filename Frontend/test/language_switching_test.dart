import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrikey/core/locale_provider.dart';
import 'package:agrikey/l10n/app_localizations.dart';
import 'package:agrikey/models/scheme.dart';
import 'package:agrikey/widgets/scheme_card.dart';

Widget createLocalizedApp({required Widget child, ProviderContainer? container}) {
  return UncontrolledProviderScope(
    container: container ?? ProviderContainer(),
    child: Consumer(
      builder: (context, ref, _) {
        final currentLocale = ref.watch(localeProvider);
        return MaterialApp(
          locale: currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: child),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleNotifier & Persistence Tests', () {
    test('Defaults to English when no prior preference exists', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = LocaleNotifier();
      await Future.delayed(Duration.zero);

      expect(notifier.state.languageCode, 'en');
      expect(notifier.hasExplicitSelection, false);
    });

    test('Persists explicit language choice in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('ml'), isExplicit: true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_preferred_locale'), 'ml');
      expect(prefs.getBool('has_explicit_language_selection'), true);
      expect(notifier.hasExplicitSelection, true);
      expect(notifier.state.languageCode, 'ml');
    });

    test('Restores persisted preference upon restart', () async {
      SharedPreferences.setMockInitialValues({
        'user_preferred_locale': 'ml',
        'has_explicit_language_selection': true,
      });

      final notifier = LocaleNotifier();
      // Wait for async _loadPersistedLocale
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.languageCode, 'ml');
      expect(notifier.hasExplicitSelection, true);
    });

    test('Regional suggestion suggests Malayalam for Kerala when no explicit choice exists', () {
      SharedPreferences.setMockInitialValues({});
      final notifier = LocaleNotifier();

      final suggestion = notifier.checkLocationLanguageSuggestion(
        regionState: 'Kerala',
        district: 'Palakkad',
      );

      expect(suggestion, const Locale('ml'));
    });

    test('Regional suggestion respects explicit preference and does not override it', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('en'), isExplicit: true);

      final suggestion = notifier.checkLocationLanguageSuggestion(
        regionState: 'Kerala',
        district: 'Palakkad',
      );

      expect(suggestion, isNull);
    });
  });

  group('Dynamic Screen Rebuild on Locale Change', () {
    testWidgets('Scheme card updates immediately when language switches from EN to ML', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();

      final scheme = GovernmentScheme(
        id: 1,
        code: 'PM-KISAN',
        name: 'PM-Kisan Samman Nidhi',
        level: 'CENTRAL',
        category: 'FINANCIAL',
        sector: 'CROP',
        description: 'Direct income support of 6000 per year.',
        benefits: ['Direct income transfer'],
        translations: {
          'ml': {
            'name': 'പിഎം-കിസാൻ സമ്മാൻ നിധി',
            'description': 'വർഷത്തിൽ 6000 രൂപയുടെ വരുമാന സഹായം.',
          }
        },
      );

      await tester.pumpWidget(
        createLocalizedApp(
          container: container,
          child: SchemeCard(scheme: scheme),
        ),
      );
      await tester.pumpAndSettle();

      // Initially in English
      expect(find.text('Central Scheme'), findsOneWidget);
      expect(find.text('PM-Kisan Samman Nidhi'), findsOneWidget);
      expect(find.text('Direct income support of 6000 per year.'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);

      // Switch language to Malayalam on the already-open screen
      await container.read(localeProvider.notifier).setLocale(const Locale('ml'));
      await tester.pumpAndSettle();

      // Immediately reflects Malayalam without restarting
      expect(find.text('കേന്ദ്ര പദ്ധതി'), findsOneWidget);
      expect(find.text('പിഎം-കിസാൻ സമ്മാൻ നിധി'), findsOneWidget);
      expect(find.text('വർഷത്തിൽ 6000 രൂപയുടെ വരുമാന സഹായം.'), findsOneWidget);
      expect(find.text('വിശദാംശങ്ങൾ കാണുക'), findsOneWidget);
    });

    testWidgets('Untranslated scheme displays original text with honest in-review note in Malayalam', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();

      final untranslatedScheme = GovernmentScheme(
        id: 2,
        code: 'MIDH',
        name: 'Mission for Integrated Development of Horticulture',
        level: 'CENTRAL',
        category: 'HORTICULTURE',
        sector: 'CROP',
        description: 'Promotes holistic growth of horticulture sector.',
        benefits: ['Subsidies for saplings'],
        translations: null, // No translation
      );

      await tester.pumpWidget(
        createLocalizedApp(
          container: container,
          child: SchemeCard(scheme: untranslatedScheme),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Malayalam
      await container.read(localeProvider.notifier).setLocale(const Locale('ml'));
      await tester.pumpAndSettle();

      // Preserves original name and description honestly
      expect(find.text('Mission for Integrated Development of Horticulture'), findsOneWidget);
      expect(find.text('Promotes holistic growth of horticulture sector.'), findsOneWidget);

      // Shows honest note that translation is in review
      expect(find.text('ഇംഗ്ലീഷ് പതിപ്പ് (പരിഭാഷ അവലോകനത്തിലാണ്)'), findsOneWidget);
    });
  });
}

