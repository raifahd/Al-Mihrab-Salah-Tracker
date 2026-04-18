import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC69C6D),
                ),
              ),
            );
          case AuthStatus.onboarding:
            return const OnboardingScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
          case AuthStatus.authenticating:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFC69C6D)),
                    SizedBox(height: 16),
                    Text(
                      'Authenticating...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          case AuthStatus.authenticated:
            return const MainScreen();
        }
      },
    );
  }
}
