import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrikey/l10n/app_localizations.dart';
import 'package:agrikey/models/scheme.dart';
import 'package:agrikey/screens/alerts_screen.dart';
import 'package:agrikey/screens/schemes_screen.dart';
import 'package:agrikey/widgets/scheme_card.dart';
import 'package:agrikey/widgets/voice_companion_bar.dart';

Widget buildResponsiveWrapper({
  required Widget child,
  required double textScale,
  Locale locale = const Locale('ml'),
}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child,
          );
        },
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testViewports = [
    const Size(320, 640), // Ultra compact
    const Size(360, 800), // Standard Android
    const Size(412, 915), // Large Android
  ];

  final textScales = [1.0, 1.3, 2.0];

  final sampleScheme = GovernmentScheme(
    id: 1,
    code: 'PM-KISAN-LONG-TITLE-CODE',
    name: 'പ്രധാൻ മന്ത്രി കിസാൻ സമ്മാൻ നിധി യോജന ദീർഘകാല പദ്ധതി',
    level: 'CENTRAL',
    category: 'FINANCIAL-SUPPORT-LONG',
    sector: 'CROP',
    description: 'കർഷകർക്ക് വർഷത്തിൽ മൂന്ന് തുല്യ ഗഡുക്കളായി ആറായിരം രൂപ നേരിട്ട് ബാങ്ക് അക്കൗണ്ടിലേക്ക് നൽകുന്ന കേന്ദ്ര പദ്ധതി.',
    benefits: ['പ്രതിവർഷം 6000 രൂപ അക്കൗണ്ടിലേക്ക് നേരിട്ട് ലഭിക്കുന്നു'],
    translations: {
      'ml': {
        'name': 'പ്രധാൻ മന്ത്രി കിസാൻ സമ്മാൻ നിധി യോജന ദീർഘകാല പദ്ധതി',
        'description': 'കർഷകർക്ക് വർഷത്തിൽ മൂന്ന് തുല്യ ഗഡുക്കളായി ആറായിരം രൂപ നേരിട്ട് ബാങ്ക് അക്കൗണ്ടിലേക്ക് നൽകുന്ന കേന്ദ്ര പദ്ധതി.',
      }
    },
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Responsive Layout & No-Overflow Verification across Viewports & TextScales', () {
    for (final size in testViewports) {
      for (final scale in textScales) {
        testWidgets('SchemeCard in ListView renders without overflow at ${size.width}x${size.height} @ scale $scale', (tester) async {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            buildResponsiveWrapper(
              textScale: scale,
              child: Scaffold(
                body: ListView(
                  children: [
                    SchemeCard(scheme: sampleScheme),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });

        testWidgets('VoiceCompanionBar renders without overflow at ${size.width}x${size.height} @ scale $scale', (tester) async {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            buildResponsiveWrapper(
              textScale: scale,
              child: const Scaffold(
                bottomNavigationBar: SafeArea(
                  child: VoiceCompanionBar(
                    customHint: 'അഗ്രി-കീ AI · സംസാരിക്കാൻ മൈക്രോഫോൺ അമർത്തുക',
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull);
        });

        testWidgets('SchemesScreen empty/filter state renders without overflow at ${size.width}x${size.height} @ scale $scale', (tester) async {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            buildResponsiveWrapper(
              textScale: scale,
              child: const SchemesScreen(),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
        });

        testWidgets('AlertsScreen renders without overflow at ${size.width}x${size.height} @ scale $scale', (tester) async {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            buildResponsiveWrapper(
              textScale: scale,
              child: const AlertsScreen(),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
