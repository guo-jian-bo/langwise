import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 英语背景三线格
class TextLinePaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xffA4ABB8)
      ..strokeWidth = 0.5.wMin
      ..style = PaintingStyle.stroke;

    final dashWidth = 4.wMin;
    final dashSpace = 3.wMin;
      
      // 第一条横线
      canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
      // 第二条虚线
      double startX = 0;
      final maxWidth = size.width; // 确保不超过可用宽度
      while (startX < maxWidth) {
        // 绘制每一小段虚线
        canvas.drawLine(
          Offset(startX, size.height / 2.6), // 水平线在垂直居中位置
          Offset(startX + dashWidth, size.height / 2.6),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
      // 第三条虚线
      double startX1 = 0;
      final maxWidth1 = size.width; // 确保不超过可用宽度
      while (startX1 < maxWidth1) {
        // 绘制每一小段虚线
        canvas.drawLine(
          Offset(startX1, size.height / 1.4), // 水平线在垂直居中位置
          Offset(startX1 + dashWidth, size.height / 1.4),
          paint,
        );
        startX1 += dashWidth + dashSpace;
      }
      // 第四条横线
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);

 
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class HorizontalDashedLinePainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double dashWidth;
  final double dashGap;
  final BorderRadius? borderRadius;

  HorizontalDashedLinePainter({
    this.strokeWidth = 1,
    this.color = Colors.black,
    this.dashWidth = 5,
    this.dashGap = 5,
    this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // 圆角端点更美观
  
    _drawDashedLine(canvas, paint, size);
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Size size) {
    final startX = 0.0;
    final endX = size.width;
    final y = size.height / 2;

    double currentX = startX;
    final totalDashLength = dashWidth + dashGap;

    while (currentX < endX) {
      // 绘制实线部分
      final lineEndX = (currentX + dashWidth).clamp(startX, endX);
      canvas.drawLine(
        Offset(currentX, y),
        Offset(lineEndX, y),
        paint,
      );
      currentX += totalDashLength;
    }
  }

  void _drawDashedPath(Canvas canvas, Paint paint, RRect rrect) {
    // 创建圆角矩形路径
    final path = Path()..addRRect(rrect);
    
    // 使用 pathMetrics 绘制虚线路径
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      final length = metric.length;
      
      while (distance < length) {
        final start = distance / length;
        final end = ((distance + dashWidth) / length).clamp(0.0, 1.0);
        
        final extractPath = metric.extractPath(
          metric.length * start,
          metric.length * end,
        );
        canvas.drawPath(extractPath, paint);
        
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}