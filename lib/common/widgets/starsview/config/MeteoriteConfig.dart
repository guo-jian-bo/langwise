import 'package:flutter/material.dart';

class MeteoriteConfig {

  const MeteoriteConfig({
    this.enabled = true,
    this.minMeteoriteSize = .5,
    this.maxMeteoriteSize = 3,
    this.colors = const <Color>[Colors.white],
    this.minMeteoriteSpeed = 1.0,
    this.maxMeteoriteSpeed = 4.0,
    this.initialDelay = 1000,  // 新增：初始延迟（毫秒）
    this.intervalDelay = 500   // 新增：流星间隔延迟（帧数）
  });

  final bool enabled;
  final double minMeteoriteSize;
  final double maxMeteoriteSize;
  final List<Color> colors;
  final double minMeteoriteSpeed;
  final double maxMeteoriteSpeed;
  final int initialDelay;    // 页面创建后多久开始第一个流星（毫秒）
  final int intervalDelay;   // 流星之间的间隔（帧数）
}