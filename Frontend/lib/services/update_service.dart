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

  /// Fetches update metadata from backend (or fallback to GitHub directly).
  static Future<UpdateInfo?> checkUpdate() async {
    final currentVersion = ApiConfig.appVersion;

    // 1. Try Backend Proxy first
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/services/app-update');
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final latest = (data['latest_version'] as String? ?? '').trim();
        final hasUpdate = isNewerVersion(latest, currentVersion);

        return UpdateInfo(
          hasUpdate: hasUpdate,
          latestVersion: latest.isNotEmpty ? latest : currentVersion,
          currentVersion: currentVersion,
          title: data['release_title'] as String? ?? 'AgriKey Update',
          notes: data['release_notes'] as String? ?? 'New version available.',
          downloadUrl: data['download_url'] as String? ??
              'https://github.com/Midhun-M-git/Agry-Key/releases/latest',
        );
      }
    } catch (_) {}

    // 2. Direct GitHub Releases Fallback
    try {
      final ghUri = Uri.parse(
          'https://api.github.com/repos/Midhun-M-git/Agry-Key/releases/latest');
      final res = await http.get(
        ghUri,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final latest = (data['tag_name'] as String? ?? '').trim();
        final hasUpdate = isNewerVersion(latest, currentVersion);

        String downloadUrl =
            'https://github.com/Midhun-M-git/Agry-Key/releases/latest';
        final assets = data['assets'] as List<dynamic>? ?? [];
        for (final asset in assets) {
          if (asset['name'] == 'agrikey-latest.apk') {
            downloadUrl = asset['browser_download_url'] as String? ?? downloadUrl;
            break;
          }
        }

        return UpdateInfo(
          hasUpdate: hasUpdate,
          latestVersion: latest.isNotEmpty ? latest : currentVersion,
          currentVersion: currentVersion,
          title: data['name'] as String? ?? 'AgriKey Release $latest',
          notes: data['body'] as String? ?? 'New updates and bug fixes.',
          downloadUrl: downloadUrl,
        );
      }
    } catch (_) {}

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
