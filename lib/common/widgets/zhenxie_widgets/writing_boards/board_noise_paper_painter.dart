import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'board_paper_noise_layer.dart';

class BoardNoisePaperPainter extends CustomPainter {
  /// 纸张底色
  const BoardNoisePaperPainter({
    required this.baseColor,
    required this.lineSpacing,
    required this.showRuleLines,
    this.lineColor = const Color(0x0D000000),
  });

  /// 纸张底色
  final Color baseColor;

  /// 横线间距
  final double lineSpacing;

  /// 是否显示横线
  final bool showRuleLines;

  /// 横线颜色
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintPaperBase(canvas, size);
    if (showRuleLines) _paintRuleLines(canvas, size);
    _paintNoiseDots(canvas, size);
  }

  /// 绘制纸张底色和轻微明暗变化
  void _paintPaperBase(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()..color = baseColor;
    canvas.drawRect(rect, paint);
  }

  /// 绘制信纸横线
  void _paintRuleLines(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.wMin;
    double dy = lineSpacing;

    while (dy < size.height) {
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
      dy += lineSpacing;
    }
  }

  /// 绘制很轻的细小噪点，避免背景过平
  void _paintNoiseDots(Canvas canvas, Size size) {
    BoardPaperNoisePainter.paintNoise(
      canvas,
      size,
      darkColor: const Color(0xff8D7B68),
      lightColor: const Color(0xffffffff),
      darkAlpha: 0.035,
      lightAlpha: 0.03,
      density: 320,
      minRadius: 0.25,
      maxRadius: 1.1,
      seedSalt: 11,
    );
  }

  @override
  bool shouldRepaint(covariant BoardNoisePaperPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.lineSpacing != lineSpacing ||
        oldDelegate.showRuleLines != showRuleLines ||
        oldDelegate.lineColor != lineColor;
  }
}
