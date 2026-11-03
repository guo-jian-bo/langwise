import 'package:flutter/material.dart';

/// 中心垂直虚线绘制器
/// 绘制一条垂直居中的虚线
class AdvanceCenterDottedLinePainter extends CustomPainter {
  /// 起始Y坐标
  final double startY;
  
  /// 结束Y坐标
  final double endY;
  
  /// 虚线颜色，默认为蓝色 0x0EA5E9
  final Color lineColor;
  
  /// 线宽
  final double strokeWidth;
  
  /// 虚线段长度
  final double dashWidth;
  
  /// 虚线间隔长度
  final double dashSpace;

  AdvanceCenterDottedLinePainter({
    required this.startY,
    required this.endY,
    this.lineColor = const Color(0xFF0EA5E9),
    this.strokeWidth = 3,
    this.dashWidth = 20,
    this.dashSpace = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算中心X坐标
    final centerX = size.width / 2;
    
    // 设置画笔
    final dashPaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
      
    // 绘制虚线
    _drawDashedLine(
      canvas: canvas,
      x: centerX,
      startY: startY,
      endY: endY,
      paint: dashPaint,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );
  }

  /// 绘制虚线
  /// 
  /// [canvas] 画布
  /// [x] X坐标
  /// [startY] 起始Y坐标
  /// [endY] 结束Y坐标
  /// [paint] 画笔
  /// [dashWidth] 虚线段长度
  /// [dashSpace] 虚线间隔长度
  void _drawDashedLine({
    required Canvas canvas,
    required double x,
    required double startY,
    required double endY,
    required Paint paint,
    double dashWidth = 10.0,
    double dashSpace = 5.0,
  }) {
    final path = Path();
    bool draw = true;
    double currentY = startY;

    while (currentY < endY) {
      if (draw) {
        path.moveTo(x, currentY);
        path.lineTo(x, currentY + dashWidth);
      }
      currentY += draw ? dashWidth : dashSpace;
      draw = !draw;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AdvanceCenterDottedLinePainter oldDelegate) =>
      oldDelegate.startY != startY ||
      oldDelegate.endY != endY ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}
