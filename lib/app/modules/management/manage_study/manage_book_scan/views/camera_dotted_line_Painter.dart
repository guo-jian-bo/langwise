import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect cropRect;
  final double splitPosition;
  final double imageScale;
  final Offset imageOffset; // 新增关键参数

  ImagePainter(
    this.image,
    this.cropRect,
    this.splitPosition,
    this.imageScale,
    this.imageOffset, // 接收外部计算的偏移量
  );

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制参数计算
    final scaledWidth = image.width * imageScale;
    final scaledHeight = image.height * imageScale;

    // 使用外部传入的偏移量
    final imageRect = Rect.fromLTWH(
      imageOffset.dx,
      imageOffset.dy,
      scaledWidth,
      scaledHeight,
    );

    // 绘制图片
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      imageRect,
      Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true,
    );

    // 绘制分割线（基于实际显示区域）
    final splitX = imageRect.left + scaledWidth * splitPosition;
    final dashPaint = Paint()
      ..color = const Color(0xff2388FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas: canvas,
      x: splitX,
      startY: imageRect.top,
      endY: imageRect.bottom,
      paint: dashPaint,
      dashWidth: 20,
      dashSpace: 10,
    );

    // 转换裁剪区域坐标（优化计算方式）
    final displayedCropRect = Rect.fromLTWH(
      imageRect.left + cropRect.left * imageScale,
      imageRect.top + cropRect.top * imageScale,
      cropRect.width * imageScale,
      cropRect.height * imageScale,
    );

    // 绘制裁剪框
    final borderPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(displayedCropRect, borderPaint);

    // 优化手柄绘制
    _drawInteractiveHandles(canvas, displayedCropRect);
  }

  void _drawInteractiveHandles(Canvas canvas, Rect rect) {
    const innerRadius = 10.0; // 内圈半径
    const outerRadius = 11.0; // 外圈半径（点击区域）
    const borderWidth = 2.0; // 外圈边框粗细

    // 预定义画笔
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final outerPaint = Paint()
      ..color = const Color(0xFF2388FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..isAntiAlias = true;

    // 绘制四个可交互顶点
    final handles = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    for (final point in handles) {
      // 外圈（点击区域+边框）
      canvas.drawCircle(point, outerRadius, outerPaint);

      // 内圈（操作手柄）
      canvas.drawCircle(point, innerRadius, innerPaint);
    }
  }

  // 将虚线绘制逻辑封装为独立方法
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
  bool shouldRepaint(covariant ImagePainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.cropRect != cropRect ||
      oldDelegate.splitPosition != splitPosition ||
      oldDelegate.imageScale != imageScale ||
      oldDelegate.imageOffset != imageOffset; // 新增比较条件
}

class CameraDottedLinePainter extends CustomPainter {
  final double startY;
  final double endY;
  final double splitPosition;

  CameraDottedLinePainter(
    this.startY,
    this.endY,
    this.splitPosition,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制分割线（基于实际显示区域）
    final splitX = size.width + size.width * splitPosition;
    final dashPaint = Paint()
      ..color = const Color(0xff2388FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas: canvas,
      x: splitX,
      startY: startY,
      endY: endY,
      paint: dashPaint,
      dashWidth: 20,
      dashSpace: 10,
    );
  }

  // 将虚线绘制逻辑封装为独立方法
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
  bool shouldRepaint(covariant CameraDottedLinePainter oldDelegate) =>
      oldDelegate.startY != startY || oldDelegate.splitPosition != splitPosition || oldDelegate.endY != endY;
}
