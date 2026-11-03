import 'package:flutter/widgets.dart';

class EllipsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff0078B3).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}