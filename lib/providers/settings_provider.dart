import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _is24HourFormat = false;

  bool get is24HourFormat => _is24HourFormat;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _is24HourFormat = prefs.getBool('is24HourFormat') ?? false;
    notifyListeners();
  }

  Future<void> set24HourFormat(bool value) async {
    _is24HourFormat = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is24HourFormat', value);
  }
}
