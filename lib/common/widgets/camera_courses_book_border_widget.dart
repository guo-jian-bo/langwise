import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CameraCoursesBookBorderWidget extends StatefulWidget {
  final bool isCoursesBookFront;
  const CameraCoursesBookBorderWidget(
      {super.key, required this.isCoursesBookFront});

  @override
  State<CameraCoursesBookBorderWidget> createState() =>
      _CameraCoursesBookBorderWidgetState();
}

class _CameraCoursesBookBorderWidgetState
    extends State<CameraCoursesBookBorderWidget> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double tipWidth;
    double tipHeight;
    if (Platform.isAndroid || Platform.isIOS) {
      tipWidth = width - 50.wMin;
      tipHeight = 5 * tipWidth / 3;
      if (tipHeight > height - 400.wMin) {
        tipHeight = height - 400.wMin;
        tipWidth = 3 * tipHeight / 5;
      }
    } else {
      tipHeight = height * 0.9;
      tipWidth = 3.5 * tipHeight / 5;
    }

    return Stack(
      children: [
        CustomPaint(
          painter: TransparentHolePainter(),
          size: Size(width, height),
        ),
        Center(
          child: Container(
            width: tipWidth,
            height: tipHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: CornerPainter(),
              child: Stack(
                children: [
                  Positioned(
                    top: 40.wMin,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.wMin,
                          vertical: 8.wMin,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.5),
                          borderRadius: BorderRadius.circular(24.wMin),
                        ),
                        child: Text(
                          widget.isCoursesBookFront ? '请框住教材封面' : '请框住教材封底',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerSize = 40.wMin;
    final radius = 12.wMin;

    // 左上角
    canvas.drawPath(
      Path()
        ..moveTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0)
        ..lineTo(cornerSize, 0)
        ..moveTo(0, radius)
        ..lineTo(0, cornerSize),
      paint,
    );

    // 右上角
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, cornerSize),
      paint,
    );

    // 左下角
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerSize)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(cornerSize, size.height),
      paint,
    );

    // 右下角
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, size.height)
        ..lineTo(size.width - radius, size.height)
        ..quadraticBezierTo(
            size.width, size.height, size.width, size.height - radius)
        ..lineTo(size.width, size.height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TransparentHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.5)
      ..style = PaintingStyle.fill;

    double width = size.width;
    double height = size.height;
    double tipWidth;
    double tipHeight;
    if (Platform.isAndroid || Platform.isIOS) {
      tipWidth = width - 50.wMin;
      tipHeight = 5 * tipWidth / 3;
      if (tipHeight > height - 400.wMin) {
        tipHeight = height - 400.wMin;
        tipWidth = 3 * tipHeight / 5;
      }
    } else {
      tipHeight = height * 0.9;
      tipWidth = 3.5 * tipHeight / 5;
    }

    final centerX = width / 2;
    final centerY = height / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: tipWidth,
          height: tipHeight,
        ),
        Radius.circular(12.wMin),
      ));

    // 设置路径填充规则为evenOdd，这样绘制的部分会被"挖空"
    path.fillType = PathFillType.evenOdd;

    // 绘制带有透明区域的遮罩
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
