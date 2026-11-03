
import 'dart:math' as math;
import 'package:flutter/material.dart';

class MissionControlCenterHexagonPaint extends CustomPainter {
  final double cornerRatio;       // 圆角相对半径比例，如 0.16
  final Color outerColor;         // 外层填充色
  final Color innerColor;         // 内层填充色
  final Color trackColor;         // 外圈进度颜色
  final double borderWidth;       // 外圈进度线宽
  final Animation<double>? progressAnimation; // 动画驱动进度

  MissionControlCenterHexagonPaint({
    this.cornerRatio = 0.16,
    this.outerColor = const Color(0xFF38BDF8),
    this.innerColor = const Color(0xFF0284C7),
    this.trackColor = const Color(0xFFE0F2FE),
    this.borderWidth = 6,
    this.progressAnimation,
  }) : super(repaint: progressAnimation); // 绑定动画为重绘源

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = math.min(size.width, size.height) / 2 - borderWidth;
    final cornerOuter = radius * cornerRatio;

    // 外圈进度轨道（淡白底）
    final ringRadius = radius + borderWidth * 0.08;
    final ringCorner = ringRadius * cornerRatio;
    final ringPath = _roundedHexagonPath(center, ringRadius, ringCorner);
    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(ringPath, trackPaint);

    // 外圈进度
    // 定义并裁剪进度值，避免空和越界
    final double p = (progressAnimation?.value ?? 0)
        .clamp(0.0, 1.0)
        .toDouble();
    final metric = ringPath.computeMetrics().first;
    final progressPath = metric.extractPath(0, metric.length * p);
    final progressPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(progressPath, progressPaint);

    // 外层六边形（圆角）
    final outerPath = _roundedHexagonPath(center, radius, cornerOuter);
    final outerPaint = Paint()..color = outerColor;
    canvas.drawPath(outerPath, outerPaint);

    // 内层六边形（缩小并保持圆角比例）
    final innerRadius = radius * 0.88;
    final innerCorner = innerRadius * cornerRatio;
    final innerPath = _roundedHexagonPath(center, innerRadius, innerCorner);
    final innerPaint = Paint()..color = innerColor;
    canvas.drawPath(innerPath, innerPaint);

    
  }

  // 圆角六边形路径
  Path _roundedHexagonPath(Offset center, double radius, double cornerRadius) {
    final points = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3; // 顶点在上方
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    final path = Path();
    final n = points.length;
    for (int i = 0; i < n; i++) {
      final prev = points[(i - 1 + n) % n];
      final cur = points[i];
      final next = points[(i + 1) % n];

      final d1 = (prev - cur);
      final d2 = (next - cur);
      final p1 = cur + d1 / d1.distance * cornerRadius; // 顶点往前一边偏移
      final p2 = cur + d2 / d2.distance * cornerRadius; // 顶点往后一边偏移

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      // 用 cur 作为控制点，连接成圆滑角
      path.quadraticBezierTo(cur.dx, cur.dy, p2.dx, p2.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant MissionControlCenterHexagonPaint oldDelegate) {
    return oldDelegate.cornerRatio != cornerRatio ||
        oldDelegate.outerColor != outerColor ||
        oldDelegate.innerColor != innerColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.progressAnimation != progressAnimation;
  }
  
}
