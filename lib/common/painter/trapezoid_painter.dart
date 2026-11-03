

import 'package:flutter/material.dart';

class TrapezoidPainter extends CustomPainter {

  /// 梯形的斜度
  final double angle;

  final Color color;

  // 自定义画笔绘制梯形顶部
  TrapezoidPainter({
    this.angle = 30,
    required this.color,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.8), // 顶部更亮
          color.withValues(alpha: 0.5), // 底部稍暗
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 绘制梯形路径 (上窄下宽的梯形)
    path.moveTo(angle, 0); // 左上角
    path.lineTo(size.width - angle, 0); // 右上角
    path.lineTo(size.width, size.height); // 右下角
    path.lineTo(0, size.height); // 左下角
    path.close();

    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}