import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CustomCourseTipWidget extends StatelessWidget {
  final String text;

  const CustomCourseTipWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding:  EdgeInsets.only(left: 12.wMin, right: 12.wMin, top: 8.wMin, bottom: 8.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgQuaternary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.cTextTertiary,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: -12,
          child: Align(
            alignment: const Alignment(-1, -0.5),
            child: CustomPaint(
              size: const Size(12, 12),
              painter: CustomCourseTipTrianglePainter(const Color(0xFF424242)),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomCourseTipTrianglePainter extends CustomPainter {
  final Color color;

  CustomCourseTipTrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
