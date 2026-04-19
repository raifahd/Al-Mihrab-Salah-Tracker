import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String _versionUrl =
      'https://raw.githubusercontent.com/raifahd/Al-Mihrab-Salah-Tracker/main/version.json';

  // Compare version strings e.g. "1.0.1" > "1.0.0"
  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map(int.parse).toList();
    final c = current.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }

  static Future<void> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      // Get current app version
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      // Fetch latest version from GitHub
      final dio = Dio();
      final response = await dio.get(_versionUrl);
      final data = response.data;

      final latestVersion = data['version'];
      final apkUrl = data['url'];
      final releaseNotes = data['releaseNotes'];

      if (_isNewer(latestVersion, currentVersion)) {
        // Show update dialog
        if (context.mounted) {
          await _showUpdateDialog(
            context,
            latestVersion,
            apkUrl,
            releaseNotes,
          );
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static Future<void> _showUpdateDialog(
    BuildContext context,
    String version,
    String apkUrl,
    String releaseNotes,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // user MUST update
      builder: (context) => _UpdateDialog(
        version: version,
        apkUrl: apkUrl,
        releaseNotes: releaseNotes,
      ),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  final String version;
  final String apkUrl;
  final String releaseNotes;

  const _UpdateDialog({
    required this.version,
    required this.apkUrl,
    required this.releaseNotes,
  });

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double _progress = 0;
  bool _isDownloading = false;
  String _statusText = '';

  Future<void> _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Starting download...';
    });

    try {
      OtaUpdate()
          .execute(widget.apkUrl, destinationFilename: 'mihrab_update.apk')
          .listen((event) {
        switch (event.status) {
          case OtaStatus.DOWNLOADING:
            setState(() {
              _progress = double.parse(event.value ?? '0') / 100;
              _statusText = 'Downloading... ${event.value}%';
            });
            break;
          case OtaStatus.INSTALLING:
            setState(() {
              _statusText = 'Installing...';
            });
            break;
          case OtaStatus.ALREADY_RUNNING_ERROR:
          case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
          case OtaStatus.INTERNAL_ERROR:
            setState(() {
              _statusText = 'Error: ${event.value}';
              _isDownloading = false;
            });
            break;
          default:
            break;
        }
      });
    } catch (e) {
      setState(() {
        _statusText = 'Update failed. Try again.';
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent back button
      child: AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.system_update, color: Color(0xFF1B5E20)),
            const SizedBox(width: 10),
            Text(
              'Update Available',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${widget.version} is available',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              widget.releaseNotes,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          if (!_isDownloading)
            TextButton(
              onPressed: _startUpdate,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Update Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}