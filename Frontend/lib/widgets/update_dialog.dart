import 'package:flutter/material.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo info;

  const UpdateDialog({
    super.key,
    required this.info,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String? _errorMessage;

  void _startInternalUpdate() {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
    });

    UpdateService.downloadAndInstallApk(
      downloadUrl: widget.info.downloadUrl,
      onProgress: (progress, received, total) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _receivedBytes = received;
            _totalBytes = total;
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _errorMessage = err;
          });
        }
      },
    );
  }

  String _formatMB(int bytes) {
    if (bytes <= 0) return '0 MB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: _isDownloading ? _buildDownloadingView() : _buildPromptView(),
      ),
    );
  }

  Widget _buildDownloadingView() {
    final percentText = _progress >= 0 ? '${(_progress * 100).toInt()}%' : 'Downloading...';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Updating AgriKey...",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _progress >= 0.99
              ? "Download complete! Opening package installer..."
              : "Downloading update package directly in app...",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress >= 0 ? _progress : null,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 12),

        // Metrics row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              percentText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
            ),
            if (_totalBytes > 0)
              Text(
                "${_formatMB(_receivedBytes)} / ${_formatMB(_totalBytes)}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              )
            else
              Text(
                _formatMB(_receivedBytes),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Please do not close the app while the update is downloading.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildPromptView() {
    return Column(
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
          "New Update Available",
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
            _buildBadge(widget.info.currentVersion, Colors.grey.shade200, Colors.grey.shade800),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.green),
            ),
            _buildBadge(widget.info.latestVersion, Colors.green.shade100, Colors.green.shade800, isHighlight: true),
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
              widget.info.notes.isNotEmpty
                  ? _cleanNotes(widget.info.notes)
                  : "A newer and faster version of AgriKey is available with updated crop features, community discussions, and bug fixes.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 12, color: Colors.red.shade800),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Action Buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.system_update_alt_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "Update Directly in App",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _startInternalUpdate,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                TextButton.icon(
                  icon: const Icon(Icons.open_in_browser, size: 16, color: Colors.grey),
                  label: Text(
                    "Open Browser",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    UpdateService.launchDownload(context, widget.info.downloadUrl);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
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
