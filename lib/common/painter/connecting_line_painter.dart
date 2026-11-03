import 'package:flutter/material.dart';

class ConnectingLinePainter extends CustomPainter {
  final int childCount;
  final double strokeWidth;
  final double cornerRadius;
  /// 分叉链接线
  ConnectingLinePainter({
    required this.childCount,
    this.strokeWidth = 1,
    this.cornerRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    // 渐变颜色
    paint.shader = const LinearGradient(
      colors: [Color(0xff390094), Color(0xff965FED)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final centerX = size.width / 2;
    const startY = 0.0;
    final splitY = size.height * 0.4; // 分叉起始高度

    // 主线：顶部到分叉点
    path.moveTo(centerX, startY);
    path.lineTo(centerX, splitY - cornerRadius); // 留出圆角空间

    // 动态计算子项位置
    final childWidth = size.width / childCount;
    final List<double> childCenters = [];
    for (int i = 0; i < childCount; i++) {
      childCenters.add(childWidth * i + childWidth / 2);
    }

    // 绘制每个分叉
    for (double childX in childCenters) {
      final dx = childX - centerX;
      final isRight = dx > 0;

      // 从主线到分叉点的圆角连接
      if (childX == centerX) {
        // 如果子项正好在中心，直接垂直连接
        path.moveTo(centerX, splitY - cornerRadius);
        path.lineTo(centerX, size.height);
        continue;
      }
      
      // 从主线到分叉点的圆角连接
      path.moveTo(centerX, splitY - cornerRadius);
      
      // 主线到分叉点的圆角
      path.arcToPoint(
        Offset(centerX + (isRight ? cornerRadius : -cornerRadius), splitY),
        radius: Radius.circular(cornerRadius),
        clockwise: !isRight,
      );
      
      if (dx.abs() > cornerRadius * 2) {
        // 有足够空间绘制水平线段和第二个圆角
        path.lineTo(childX + (isRight ? -cornerRadius : cornerRadius), splitY);
        
        // 水平线到垂直线的圆角
        path.arcToPoint(
          Offset(childX, splitY + cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: isRight,
        );
        
        // 垂直线到底部
        path.lineTo(childX, size.height);
      } else {
        // 空间不足时使用对角线连接，但保留起始圆角
        path.lineTo(childX, splitY + dx.abs() - cornerRadius);
        path.lineTo(childX, size.height);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
