import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/update_service.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Check for updates after permissions are handled
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissions();
      UpdateService.updateAppForTester();
    });
  }

  Future<void> _requestPermissions() async {
    // Request permissions required for WiFi scanning and nearby device discovery
    // On Android 13+ (API 33+), NEARBY_WIFI_DEVICES is specifically required for WiFi tasks
    // On older Android versions and iOS, Location permissions are necessary to access SSID/BSSID
    final statuses = await [
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
      Permission.notification, // Recommended for a complete onboarding experience
    ].request();
    
    debugPrint('[Permissions] Statuses: $statuses');
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Atmospheric Elements
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: CustomPaint(
                painter: _GeometricOverlayPainter(),
              ),
            ),
          ),

          // Ambient Light Bloom
          Center(
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // Corner Decorative Accents
          Positioned(
            top: 48,
            right: 48,
            child: Opacity(
              opacity: 0.10,
              child: Transform.rotate(
                angle: 45 * 3.14159 / 180,
                child: const Icon(
                  Icons.star,
                  size: 144, // 9xl
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 48,
            left: 48,
            child: Opacity(
              opacity: 0.05,
              child: const Icon(
                Icons.auto_awesome_mosaic,
                size: 192, // 12rem
                color: AppColors.primary,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Center Emblem
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative Rings
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.05), width: 1),
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.10), width: 1),
                          ),
                        ),
                        // Icon Wrapper
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceContainerLow,
                                border: Border.all(color: AppColors.primary.withOpacity(0.20), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.08),
                                    blurRadius: 80,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary.withOpacity(0.10),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Center(
                                    child: Icon(
                                      Icons.mosque,
                                      size: 64,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Identity Section
                  Text(
                    'Al-Mihrab',
                    style: AppTextStyles.headline(context).copyWith(
                      fontSize: 48,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 1,
                        width: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, AppColors.primary.withOpacity(0.3)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'SALAH TRACKER',
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 1,
                        width: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.3), Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 192,
                    height: 1,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            Positioned(
                              left: -192 + (_controller.value * 384),
                              top: 0,
                              bottom: 0,
                              width: 64,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primary.withOpacity(0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'A SANCTUARY FOR YOUR SOUL',
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant.withOpacity(0.4),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeometricOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    // A simple tessellation of repeating diamond stars
    const double spacing = 60.0;
    
    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        final path = Path();
        path.moveTo(x, y - 10);
        path.lineTo(x + 2.5, y - 2.5);
        path.lineTo(x + 10, y);
        path.lineTo(x + 2.5, y + 2.5);
        path.lineTo(x, y + 10);
        path.lineTo(x - 2.5, y + 2.5);
        path.lineTo(x - 10, y);
        path.lineTo(x - 2.5, y - 2.5);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
