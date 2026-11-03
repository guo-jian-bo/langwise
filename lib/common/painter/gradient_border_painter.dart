import 'package:flutter/widgets.dart';

class GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final BorderRadiusGeometry radius;
  final Gradient gradient;

  GradientBorderPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path.combine(
        PathOperation.difference,
        Path()..addRRect(radius.resolve(TextDirection.ltr).toRRect(rect)),
        Path()..addRRect(radius.resolve(TextDirection.ltr).toRRect(rect.deflate(strokeWidth / 2)))
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}