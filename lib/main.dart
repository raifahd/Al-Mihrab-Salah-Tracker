import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';

import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';

import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth_wrapper.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Al-Mihrab: Salah Tracker',
      theme: buildAppTheme(),
      home: const AuthWrapper(),
    );
  }
}

