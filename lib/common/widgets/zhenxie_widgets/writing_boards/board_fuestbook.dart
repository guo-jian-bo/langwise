
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'writing_boards.dart';

class BoardFuestbookWidget extends StatefulWidget {
  /// 留言板内容
  final Widget? child;

  /// 是否显示入场动画
  final bool showAnimation;

  /// 留言板
  const BoardFuestbookWidget({super.key, this.child, this.showAnimation = true});

  @override
  State<BoardFuestbookWidget> createState() => _BoardFuestbookWidgetState();
}

class _BoardFuestbookWidgetState extends State<BoardFuestbookWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BoardStickInAnimation(
        showAnimation: widget.showAnimation,
        beginOffsetY: -24.wMin,
        beginScale: 1.04,
        middleScale: 0.985,
        beginRotationAngle: 3.2 * pi / 180,
        endRotationAngle: 1.0 * pi / 180,
        builder: (context, rotationAngle) {
          return Container(
            padding: EdgeInsets.only(top: 16.wMin, bottom: 16.wMin, left: 16.wMin, right: 14.wMin),
            child: Transform.rotate(
              angle: rotationAngle,
              child: CustomPaint(
                painter: _BoardFuestbookPainter(
                  borderWidth: 24.wMin,
                  borderRadius: 40.wMin,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(24.wMin),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      scrollbars: false, // 隐藏滚动条
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.wMin),
                      child: SizedBox(child: widget.child),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoardFuestbookPainter extends CustomPainter {
  /// 留言板背景画笔
  const _BoardFuestbookPainter({
    required this.borderWidth,
    required this.borderRadius,
  });

  /// 边框厚度
  final double borderWidth;

  /// 外层圆角
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect outerRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    final Rect innerRect = Rect.fromLTWH(
      borderWidth,
      borderWidth,
      size.width - borderWidth * 2,
      size.height - borderWidth * 2,
    );
    final RRect innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(max(0, borderRadius - borderWidth * 0.65)),
    );
    final Paint borderPaint = Paint()..color = const Color(0xffFDBA74);
    final Paint paperPaint = Paint()..color = const Color(0xffFFFCF8);
    canvas.drawRRect(outerRRect, borderPaint);
    canvas.drawRRect(innerRRect, paperPaint);
    _paintNoise(canvas, outerRRect, innerRRect, size);
  }

  /// 绘制留言板上的纸屑噪点
  void _paintNoise(Canvas canvas, RRect outerRRect, RRect innerRRect, Size size) {
    final Random random = Random(size.width.floor() * 37 + size.height.floor() * 19);
    final Path borderPath = Path()
      ..addRRect(outerRRect)
      ..addRRect(innerRRect)
      ..fillType = PathFillType.evenOdd;
    final Path paperPath = Path()..addRRect(innerRRect);
    final Paint borderNoisePaint = Paint()
      ..color = const Color(0xffC26C2A).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3.wMin;
    final Paint paperNoisePaint = Paint()
      ..color = const Color(0xff8F7C72).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.35.wMin;
    final int borderNoiseCount = max(52, (size.width * size.height / 3600).floor());
    final int paperNoiseCount = max(180, (size.width * size.height / 900).floor());
    _paintNoiseFragments(
      canvas: canvas,
      clipPath: borderPath,
      bounds: outerRRect.outerRect,
      random: random,
      count: borderNoiseCount,
      paint: borderNoisePaint,
      minRadius: 0.22.wMin,
      maxRadius: 0.7.wMin,
    );
    _paintNoiseFragments(
      canvas: canvas,
      clipPath: paperPath,
      bounds: innerRRect.outerRect,
      random: random,
      count: paperNoiseCount,
      paint: paperNoisePaint,
      minRadius: 0.16.wMin,
      maxRadius: 0.52.wMin,
    );
  }

  /// 绘制随机小碎屑，避免太像规则圆点
  void _paintNoiseFragments({
    required Canvas canvas,
    required Path clipPath,
    required Rect bounds,
    required Random random,
    required int count,
    required Paint paint,
    required double minRadius,
    required double maxRadius,
  }) {
    canvas.save();
    canvas.clipPath(clipPath);
    for (int i = 0; i < count; i++) {
      final Offset center = Offset(
        bounds.left + random.nextDouble() * bounds.width,
        bounds.top + random.nextDouble() * bounds.height,
      );
      final int pointCount = 3 + random.nextInt(4);
      final double radius = minRadius + random.nextDouble() * (maxRadius - minRadius);
      final Path path = Path();
      for (int pointIndex = 0; pointIndex < pointCount; pointIndex++) {
        final double angle = (pi * 2 / pointCount) * pointIndex + random.nextDouble() * 0.45;
        final double distance = radius * (0.55 + random.nextDouble() * 0.8);
        final Offset point = Offset(
          center.dx + cos(angle) * distance,
          center.dy + sin(angle) * distance,
        );
        if (pointIndex == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoardFuestbookPainter oldDelegate) {
    return oldDelegate.borderWidth != borderWidth || oldDelegate.borderRadius != borderRadius;
  }
}
