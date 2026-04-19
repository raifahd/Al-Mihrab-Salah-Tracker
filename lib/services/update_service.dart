import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_distribution/firebase_app_distribution.dart' as ad;

class UpdateService {
  /// Checks for any new updates using Firebase App Distribution.
  /// Note: This is specifically for testers who are registered in Firebase
  /// App Distribution, not for regular production users.
  static Future<void> checkForUpdate() async {
    // Only supported on Android for direct OTA downloads in Flutter via App Distribution.
    // iOS requires testers to accept the test flight or use Firebase App Distribution web interface.
    if (!kIsWeb && Platform.isAndroid) {
      try {
        // Check if an update is available
        bool updateAvailable = await ad.isNewReleaseAvailable();
        
        if (updateAvailable) {
          // You could display an alert dialog asking the user whether to update
          // Here we just update it automatically when available
          await ad.updateIfNewReleaseAvailable();
        }
      } catch (e) {
        debugPrint('Error checking for Firebase App Distribution updates: $e');
      }
    }
  }

  /// Triggers a dialog allowing a new tester to sign in using their Google
  /// account, verify tester access, and then download the new app build.
  static Future<void> updateAppForTester() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await ad.updateIfNewReleaseAvailable();
      } catch (e) {
        debugPrint('Error updating app for tester: $e');
      }
    }
  }
}
