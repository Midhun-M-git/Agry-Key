import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrikey/core/api_config.dart';
import 'package:agrikey/services/update_service.dart';

void main() {
  group('Distribution Flavors and Manifest Separation', () {
    test('Main AndroidManifest.xml does not declare REQUEST_INSTALL_PACKAGES', () {
      final mainManifest = File('android/app/src/main/AndroidManifest.xml');
      expect(mainManifest.existsSync(), isTrue);
      final content = mainManifest.readAsStringSync();
      expect(
        content.contains('REQUEST_INSTALL_PACKAGES'),
        isFalse,
        reason: 'Base manifest must be Play-Store compliant without direct installer permissions.',
      );
    });

    test('GitHub flavor manifest declares REQUEST_INSTALL_PACKAGES for direct self-updates', () {
      final githubManifest = File('android/app/src/github/AndroidManifest.xml');
      expect(githubManifest.existsSync(), isTrue);
      final content = githubManifest.readAsStringSync();
      expect(
        content.contains('android.permission.REQUEST_INSTALL_PACKAGES'),
        isTrue,
        reason: 'GitHub flavor must contain REQUEST_INSTALL_PACKAGES for in-app APK installer.',
      );
    });

    test('Play Store flavor manifest strictly excludes REQUEST_INSTALL_PACKAGES', () {
      final playManifest = File('android/app/src/play/AndroidManifest.xml');
      expect(playManifest.existsSync(), isTrue);
      final content = playManifest.readAsStringSync();
      expect(
        content.contains('REQUEST_INSTALL_PACKAGES'),
        isFalse,
        reason: 'Play flavor must never request APK installation permissions.',
      );
    });

    test('UpdateService disables direct APK check when in Play distribution', () async {
      expect(ApiConfig.distribution, isNotEmpty);
      if (ApiConfig.isPlayStore) {
        final updateInfo = await UpdateService.checkUpdate();
        expect(updateInfo, isNull);
      }
    });
  });
}
