import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../utils/RandomUtils.dart';
import 'MeteoriteCompleteListener.dart';

class Meteorite {

  Meteorite({
    required this.smallestWidth,
    required this.starSize,
    required this.listener,
    required this.random,
    required this.color,
    required double startX,
    required double startY,
    this.strokeWidth = 4.0,
    this.maxTrailLength = 180,
    this.speed = 2.0,  // 新增速度参数
  }){
    // 使用传入的速度参数，而不是基于starSize计算
    _factor = speed * (doubleInRange(random, 0.8, 1.2)); // 添加少量随机变化
    _x = startX;
    _y = startY;
    _trailLength = doubleInRange(random, 20, maxTrailLength);
    debugPrint('METEORITE SPEED: $speed, FACTOR: $_factor');

    _trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth  // 使用可配置的宽度
      ..color = color
      ..style = PaintingStyle.fill;

    _paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth  // 使用可配置的宽度
      ..color = color
      ..style = PaintingStyle.fill;
  }

  final double strokeWidth;
  final double maxTrailLength;
  final double speed;  // 新增属性
  final Random random;
  final int smallestWidth;
  final MeteoriteCompleteListener listener;
  final double starSize;
  final Color color;

  double _x = 0;
  double _y = 0;

  late Paint _trailPaint;
  late Paint _paint;

  late double _trailLength;
  late double _factor;

  bool _finished = false;

  void updateFrame(double viewWidth, double viewHeight){

    if(_finished){
      return;
    }

    // go left
    _x -= _factor;

    // go down
    _y += _factor;

    _trailPaint.shader = ui.Gradient.linear(
      Offset(_x, _y),
      Offset(_x + _trailLength, _y - _trailLength),
      <Color>[color, color.withOpacity(0.0)]
    );

    if (_x < (viewWidth * -0.5)) {
      listener.onMeteoriteComplete();
      _finished = true;
    }

  }


  void draw(Canvas canvas){

    canvas.drawCircle(Offset(_x, _y), starSize, _paint);

    canvas.drawLine(
      Offset(_x, _y),
      Offset(_x + _trailLength, _y - _trailLength),
      _trailPaint
    );

  }

}