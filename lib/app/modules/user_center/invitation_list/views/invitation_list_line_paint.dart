import 'package:flutter/material.dart';

import '../models/invitation_list_model.dart';

class InvitationListLinePaint extends CustomPainter{
  final Color defaultLneColor;
  final Color activeLneColor;
  final double lineWidth;

  // 画布（CustomPaint/容器）的 GlobalKey，用于做全局坐标到本地坐标的转换
  final GlobalKey rootKey;

  final List<InvitationListModel> invitationList;

   InvitationListLinePaint({
    this.defaultLneColor = Colors.white54,
    this.activeLneColor = Colors.white,
    this.lineWidth = 2.0,
    required this.rootKey,
    required this.invitationList,
    Listenable? repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? rootBox = rootKey.currentContext?.findRenderObject() as RenderBox?;
    if (rootBox == null) return;

    final defaultPaint = Paint()
      ..color = defaultLneColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeLneColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 找到最后一个激活节点的索引
    int lastActiveIndex = -1;
    for (int i = 0; i < invitationList.length; i++) {
      if (invitationList[i].isActive) {
        lastActiveIndex = i;
      }
    }

    // 收集所有任务项的本地矩形（相对于 CustomPaint）
    final List<Rect> rects = [];
    try {
      for (int i = 0; i < invitationList.length; i++) {
        final RenderBox? childBox = invitationList[i].key.currentContext?.findRenderObject() as RenderBox?;
        if (childBox == null) continue;

        final Offset globalTopLeft = childBox.localToGlobal(Offset.zero);
        final Offset localTopLeft = rootBox.globalToLocal(globalTopLeft);
        rects.add(localTopLeft & childBox.size);
      }
    } catch (_) {}

    // 仅在两个矩形边缘之间绘制线段
    for (int i = 0; i < rects.length - 1; i++) {
      final Rect a = rects[i];
      final Rect b = rects[i + 1];
      final Offset centerA = a.center;
      final Offset centerB = b.center;

      final Offset? edgeA = _nearestExitPoint(centerA, centerB, a);
      final Offset? edgeB = _nearestEntryPoint(centerA, centerB, b);

      if (edgeA == null || edgeB == null) continue;
      
      // 如果当前线段的终点节点索引 <= 最后激活节点索引，使用激活颜色
      final bool isActiveLine = i < lastActiveIndex;
      _drawLine(canvas, edgeA, edgeB, isActiveLine ? activePaint : defaultPaint);
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

  // 在两点间绘制线段
  void _drawLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final double total = (p2 - p1).distance;
    if (total <= 0) return;

    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant InvitationListLinePaint oldDelegate) {
    return true;
  }

}