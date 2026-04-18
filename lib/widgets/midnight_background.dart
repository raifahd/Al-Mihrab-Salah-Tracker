import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';

enum BackgroundPattern { celestial, geometric, none }

class MidnightBackground extends StatelessWidget {
  final Widget child;
  final BackgroundPattern pattern;

  const MidnightBackground({
    super.key,
    required this.child,
    this.pattern = BackgroundPattern.celestial,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background
        Container(color: AppColors.background),

        // Background Pattern
        if (pattern != BackgroundPattern.none)
          Positioned.fill(
            child: CustomPaint(
              painter: pattern == BackgroundPattern.celestial
                  ? CelestialPainter()
                  : GeometricPainter(),
            ),
          ),

        // Ambient Glows
        Positioned(
          top: -MediaQuery.of(context).size.height * 0.1,
          right: -MediaQuery.of(context).size.width * 0.1,
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width * 0.6,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0DE9C349),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -MediaQuery.of(context).size.height * 0.05,
          left: -MediaQuery.of(context).size.width * 0.05,
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF005DB7).withOpacity(0.1), // Secondary/Blue glow
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A005DB7),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

class CelestialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const double spacing = 40.0;
    const double dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const double spacing = 80.0;
    
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawIslamicStar(canvas, Offset(x, y), 20.0, paint);
      }
    }
  }

  void _drawIslamicStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    // 8-pointed star (Rub el Hizb style/Geometric)
    for (int i = 0; i < 16; i++) {
      double angle = i * (math.pi / 8);
      double r = (i % 2 == 0) ? radius : radius * 0.5;
      double px = center.dx + r * math.cos(angle);
      double py = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
