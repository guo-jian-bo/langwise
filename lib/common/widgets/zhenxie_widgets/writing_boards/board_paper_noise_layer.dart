import 'dart:math';

import 'package:flutter/material.dart';

/// 纸张噪点层
class BoardPaperNoiseLayer extends StatelessWidget {
  /// 需要承载的内容
  final Widget? child;

  /// 深色噪点颜色
  final Color darkColor;

  /// 浅色噪点颜色
  final Color lightColor;

  /// 深色噪点透明度
  final double darkAlpha;

  /// 浅色噪点透明度
  final double lightAlpha;

  /// 噪点密度系数
  final double density;

  /// 噪点最小半径
  final double minRadius;

  /// 噪点最大半径
  final double maxRadius;

  /// 稳定随机种子偏移
  final int seedSalt;

  /// 纸张噪点层
  const BoardPaperNoiseLayer({
    super.key,
    this.child,
    this.darkColor = const Color(0xff8D7B68),
    this.lightColor = const Color(0xffffffff),
    this.darkAlpha = 0.03,
    this.lightAlpha = 0.025,
    this.density = 320,
    this.minRadius = 0.25,
    this.maxRadius = 0.85,
    this.seedSalt = 11,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BoardPaperNoisePainter(
        darkColor: darkColor,
        lightColor: lightColor,
        darkAlpha: darkAlpha,
        lightAlpha: lightAlpha,
        density: density,
        minRadius: minRadius,
        maxRadius: maxRadius,
        seedSalt: seedSalt,
      ),
      child: child,
    );
  }
}

/// 纸张噪点画笔
class BoardPaperNoisePainter extends CustomPainter {
  /// 深色噪点颜色
  final Color darkColor;

  /// 浅色噪点颜色
  final Color lightColor;

  /// 深色噪点透明度
  final double darkAlpha;

  /// 浅色噪点透明度
  final double lightAlpha;

  /// 噪点密度系数
  final double density;

  /// 噪点最小半径
  final double minRadius;

  /// 噪点最大半径
  final double maxRadius;

  /// 稳定随机种子偏移
  final int seedSalt;

  /// 纸张噪点画笔
  const BoardPaperNoisePainter({
    required this.darkColor,
    required this.lightColor,
    required this.darkAlpha,
    required this.lightAlpha,
    required this.density,
    required this.minRadius,
    required this.maxRadius,
    required this.seedSalt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintNoise(
      canvas,
      size,
      darkColor: darkColor,
      lightColor: lightColor,
      darkAlpha: darkAlpha,
      lightAlpha: lightAlpha,
      density: density,
      minRadius: minRadius,
      maxRadius: maxRadius,
      seedSalt: seedSalt,
    );
  }

  /// 绘制稳定的纸张噪点，避免重绘时纹理跳动
  static void paintNoise(
    Canvas canvas,
    Size size, {
    required Color darkColor,
    required Color lightColor,
    required double darkAlpha,
    required double lightAlpha,
    required double density,
    required double minRadius,
    required double maxRadius,
    required int seedSalt,
  }) {
    final Random random = Random(_buildSeed(size, salt: seedSalt));
    final Paint darkPaint = Paint()..color = darkColor.withValues(alpha: darkAlpha);
    final Paint lightPaint = Paint()..color = lightColor.withValues(alpha: lightAlpha);
    final int dotCount = max(120, (size.width * size.height / density).floor());

    for (int i = 0; i < dotCount; i++) {
      final Offset offset = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final double radius = minRadius + random.nextDouble() * max(0, maxRadius - minRadius);
      canvas.drawCircle(offset, radius, random.nextBool() ? darkPaint : lightPaint);
    }
  }

  /// 根据尺寸生成稳定种子
  static int _buildSeed(Size size, {required int salt}) {
    return size.width.floor() * 31 + size.height.floor() * 17 + salt;
  }

  @override
  bool shouldRepaint(covariant BoardPaperNoisePainter oldDelegate) {
    return oldDelegate.darkColor != darkColor ||
        oldDelegate.lightColor != lightColor ||
        oldDelegate.darkAlpha != darkAlpha ||
        oldDelegate.lightAlpha != lightAlpha ||
        oldDelegate.density != density ||
        oldDelegate.minRadius != minRadius ||
        oldDelegate.maxRadius != maxRadius ||
        oldDelegate.seedSalt != seedSalt;
  }
}
