import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../model/mission_model.dart';

class MissionControlCenterDottedLinePaint extends CustomPainter{
  final Color lineColor;
  final double lineWidth;
  final List<MissionModel> missionList;

  // 画布（CustomPaint/容器）的 GlobalKey，用于做全局坐标到本地坐标的转换
  final GlobalKey rootKey;

  // 虚线配置
  final double dashWidth;
  final double dashSpace;

  MissionControlCenterDottedLinePaint({
    this.lineColor = Colors.white,
    this.lineWidth = 2.0,
    required this.missionList,
    required this.rootKey,
    this.dashWidth = 18.0,
    this.dashSpace = 10.0,
    Listenable? repaint,
  }) : super(repaint: repaint);


  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? rootBox = rootKey.currentContext?.findRenderObject() as RenderBox?;
    if (rootBox == null) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 收集所有任务项的本地矩形（相对于 CustomPaint）
    final List<Rect> rects = [];
    try {
      for (int i = 0; i < missionList.length; i++) {
        final RenderBox? childBox = missionList[i].missionKey.currentContext?.findRenderObject() as RenderBox?;
        if (childBox == null) continue;

        final Offset globalTopLeft = childBox.localToGlobal(Offset.zero);
        final Offset localTopLeft = rootBox.globalToLocal(globalTopLeft);
        rects.add(localTopLeft & childBox.size);
      }
    } catch (_) {}

    // 仅在两个矩形边缘之间绘制虚线
    for (int i = 0; i < rects.length - 1; i++) {
      final Rect a = rects[i];
      final Rect b = rects[i + 1];
      final Offset centerA = a.center;
      final Offset centerB = b.center;

      final Offset? edgeA = _nearestExitPoint(centerA, centerB, a);
      final Offset? edgeB = _nearestEntryPoint(centerA, centerB, b);

      if (edgeA == null || edgeB == null) continue;
      _drawDashedLine(canvas, edgeA, edgeB, paint);
    }
  }

  // 计算线段与矩形边的所有交点（使用参数 t ∈ [0,1]）
  List<MapEntry<double, Offset>> _segmentRectIntersections(Offset a, Offset b, Rect r) {
    final List<MapEntry<double, Offset>> list = [];
    final double dx = b.dx - a.dx;
    final double dy = b.dy - a.dy;

    if (dx != 0) {
      // 与左边、右边相交
      final double tL = (r.left - a.dx) / dx;
      final double yL = a.dy + tL * dy;
      if (tL >= 0 && tL <= 1 && yL >= r.top && yL <= r.bottom) {
        list.add(MapEntry(tL, Offset(r.left, yL)));
      }

      final double tR = (r.right - a.dx) / dx;
      final double yR = a.dy + tR * dy;
      if (tR >= 0 && tR <= 1 && yR >= r.top && yR <= r.bottom) {
        list.add(MapEntry(tR, Offset(r.right, yR)));
      }
    }

    if (dy != 0) {
      // 与上边、下边相交
      final double tT = (r.top - a.dy) / dy;
      final double xT = a.dx + tT * dx;
      if (tT >= 0 && tT <= 1 && xT >= r.left && xT <= r.right) {
        list.add(MapEntry(tT, Offset(xT, r.top)));
      }

      final double tB = (r.bottom - a.dy) / dy;
      final double xB = a.dx + tB * dx;
      if (tB >= 0 && tB <= 1 && xB >= r.left && xB <= r.right) {
        list.add(MapEntry(tB, Offset(xB, r.bottom)));
      }
    }

    return list;
  }

  // 从 A 到 B 的线段与 A 矩形的最近“出界点”（边缘）
  Offset? _nearestExitPoint(Offset a, Offset b, Rect rectA) {
    final intersections = _segmentRectIntersections(a, b, rectA)
        .where((e) => e.key > 0) // 出界点在 t>0
        .toList()
      ..sort((x, y) => x.key.compareTo(y.key));
    return intersections.isNotEmpty ? intersections.first.value : null;
  }

  // 从 A 到 B 的线段与 B 矩形的最近“入界点”（边缘）
  Offset? _nearestEntryPoint(Offset a, Offset b, Rect rectB) {
    final intersections = _segmentRectIntersections(a, b, rectB)
        .where((e) => e.key < 1) // 入界点在 t<1
        .toList()
      ..sort((x, y) => y.key.compareTo(x.key)); // 取最接近 1 的那个
    return intersections.isNotEmpty ? intersections.first.value : null;
  }

  // 在两点间绘制虚线
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double total = (p2 - p1).distance;
    if (total <= 0) return;

    final Offset dir = (p2 - p1) / total;
    double start = 0.0;

    while (start < total) {
      final double end = math.min(start + dashWidth, total);
      final Offset a = p1 + dir * start;
      final Offset b = p1 + dir * end;
      canvas.drawLine(a, b, paint);
      start = end + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant MissionControlCenterDottedLinePaint oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
           oldDelegate.lineWidth != lineWidth ||
           oldDelegate.missionList != missionList ||
           oldDelegate.rootKey != rootKey ||
           oldDelegate.dashWidth != dashWidth ||
           oldDelegate.dashSpace != dashSpace;
  }
}