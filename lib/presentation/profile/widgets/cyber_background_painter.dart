import 'dart:math';
import 'package:flutter/material.dart';

class CyberBackgroundPainter extends CustomPainter {
  final double animationValue;

  CyberBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    const double gridSpacing = 40.0;
    final double offset = (animationValue * gridSpacing) % gridSpacing;

    // Draw horizontal lines
    for (double i = -gridSpacing;
        i < size.height + gridSpacing;
        i += gridSpacing) {
      canvas.drawLine(
        Offset(0, i + offset),
        Offset(size.width, i + offset),
        paint,
      );
    }

    // Draw vertical lines
    for (double i = -gridSpacing;
        i < size.width + gridSpacing;
        i += gridSpacing) {
      canvas.drawLine(
        Offset(i + offset, 0),
        Offset(i + offset, size.height),
        paint,
      );
    }

    // Draw some glowing points
    final random = Random(42);
    final glowPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CyberBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
