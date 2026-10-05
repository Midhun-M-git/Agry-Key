import 'package:flutter/material.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo info;

  const UpdateDialog({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header icon badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Colors.green,
                size: 44,
              ),
            ),

            const SizedBox(height: 18),

            // Title
            const Text(
              "New Update Available! 🌾",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // Version tags comparison
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBadge(info.currentVersion, Colors.grey.shade200, Colors.grey.shade800),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.green),
                ),
                _buildBadge(info.latestVersion, Colors.green.shade100, Colors.green.shade800, isHighlight: true),
              ],
            ),

            const SizedBox(height: 16),

            // Description / Release notes container
            Container(
              constraints: const BoxConstraints(maxHeight: 140),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: SingleChildScrollView(
                child: Text(
                  info.notes.isNotEmpty
                      ? _cleanNotes(info.notes)
                      : "A newer and faster version of AgriKey is available with updated crop features and performance enhancements.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      "Update Now",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      UpdateService.launchDownload(context, info.downloadUrl);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Maybe Later",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isHighlight ? Border.all(color: Colors.green, width: 1.2) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  String _cleanNotes(String raw) {
    // Strip markdown links and markdown formatting for cleaner dialog display
    var cleaned = raw
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'\1')
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll('**', '')
        .replaceAll('`', '')
        .trim();
    if (cleaned.length > 250) {
      cleaned = '${cleaned.substring(0, 250)}...';
    }
    return cleaned;
  }
}
