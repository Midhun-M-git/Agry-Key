import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/api_config.dart';
import '../widgets/update_dialog.dart';

class UpdateInfo {
  final bool hasUpdate;
  final String latestVersion;
  final String currentVersion;
  final String title;
  final String notes;
  final String downloadUrl;

  const UpdateInfo({
    required this.hasUpdate,
    required this.latestVersion,
    required this.currentVersion,
    required this.title,
    required this.notes,
    required this.downloadUrl,
  });
}

class UpdateService {
  static bool _hasPromptedThisSession = false;

  /// Compares two version strings (e.g. "v1.0.10" vs "v1.0.9").
  /// Returns true if latest > current.
  static bool isNewerVersion(String latestRaw, String currentRaw) {
    try {
      // If current is default placeholder, always treat any real release as newer
      final cleanCurrent = currentRaw.toLowerCase().replaceAll('v', '').trim();
      if (cleanCurrent == '1.0.0' || cleanCurrent == '0.0.0') {
        // Any tag from GitHub is newer than our default placeholder
        final latestParts = _parseVersion(latestRaw);
        return latestParts.isNotEmpty && latestParts.any((p) => p > 0);
      }

      final latestParts = _parseVersion(latestRaw);
      final currentParts = _parseVersion(currentRaw);

      final maxLen = latestParts.length > currentParts.length
          ? latestParts.length
          : currentParts.length;

      for (int i = 0; i < maxLen; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (_) {
      return latestRaw.trim() != currentRaw.trim();
    }
  }

  static List<int> _parseVersion(String v) {
    final cleaned = v.toLowerCase().replaceAll('v', '').trim();
    final parts = cleaned.split(RegExp(r'[\.\+\-_]'));
    final nums = <int>[];
    for (final p in parts) {
      final n = int.tryParse(p.replaceAll(RegExp(r'\D'), ''));
      if (n != null) nums.add(n);
    }
    return nums.isNotEmpty ? nums : [0];
  }

  /// Fetches update metadata using both zero-rate-limit GitHub redirect and backend/API proxy.
  static Future<UpdateInfo?> checkUpdate() async {
    final currentVersion = ApiConfig.appVersion;

    String? redirectLatestTag;
    // 1. Direct GitHub redirect check (Zero rate limits, instantaneous)
    try {
      final client = http.Client();
      final request = http.Request(
        'GET',
        Uri.parse('https://github.com/Midhun-M-git/Agry-Key/releases/latest'),
      )..followRedirects = false;
      final streamed = await client.send(request).timeout(const Duration(seconds: 4));
      final location = streamed.headers['location'];
      if (location != null && location.contains('/releases/tag/')) {
        redirectLatestTag = location.split('/releases/tag/').last.trim();
      }
    } catch (_) {}

    // 2. Try Backend Proxy
    Map<String, dynamic>? backendData;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/services/app-update');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        backendData = jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    // Determine the truly latest tag among redirect and backend
    String latest = redirectLatestTag ?? '';
    if (backendData != null) {
      final backendTag = (backendData['latest_version'] as String? ?? '').trim();
      if (latest.isEmpty || isNewerVersion(backendTag, latest)) {
        latest = backendTag;
      }
    }

    // 3. Fallback to GitHub Releases API if we still don't have a newer version
    if (latest.isEmpty || !isNewerVersion(latest, currentVersion)) {
      try {
        final ghUri = Uri.parse(
            'https://api.github.com/repos/Midhun-M-git/Agry-Key/releases/latest');
        final res = await http.get(
          ghUri,
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final ghTag = (data['tag_name'] as String? ?? '').trim();
          if (isNewerVersion(ghTag, latest)) {
            latest = ghTag;
          }
        }
      } catch (_) {}
    }

    if (latest.isNotEmpty) {
      final hasUpdate = isNewerVersion(latest, currentVersion);
      final title = backendData?['release_title'] as String? ??
          'AgriKey Release $latest';
      final notes = backendData?['release_notes'] as String? ??
          'A new version of AgriKey is available with bug fixes and new features.';
      final downloadUrl = backendData?['download_url'] as String? ??
          'https://github.com/Midhun-M-git/Agry-Key/releases/download/$latest/agrikey-latest.apk';

      return UpdateInfo(
        hasUpdate: hasUpdate,
        latestVersion: latest,
        currentVersion: currentVersion,
        title: title,
        notes: notes,
        downloadUrl: downloadUrl,
      );
    }

    return null;
  }

  /// Automatically or manually checks and prompts the user with the update popup.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool manual = false,
  }) async {
    // Auto check: skip if already prompted this session
    if (!manual && _hasPromptedThisSession) return;

    if (manual) {
      // Reset session flag so manual check always works
      _hasPromptedThisSession = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Checking for updates..."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    final info = await checkUpdate();
    if (!context.mounted) return;

    if (info != null && info.hasUpdate) {
      _hasPromptedThisSession = true;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => UpdateDialog(info: info),
      );
    } else if (manual) {
      final currentVer = ApiConfig.appVersion;
      final latestVer = info?.latestVersion ?? 'unknown';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            info == null
              ? "Could not connect to update server. Check your internet connection."
              : "You are already using the latest version ($currentVer) — Latest: $latestVer",
          ),
          backgroundColor: info == null ? Colors.orange.shade700 : Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Launches the APK download URL in phone's browser with on-screen guidance
  static Future<void> launchDownload(BuildContext context, String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.downloading_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Downloading update... Tap the completed download in your notification bar to install.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 7),
      ),
    );

    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }
  }
}
