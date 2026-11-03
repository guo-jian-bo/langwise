import 'package:flutter/animation.dart';
import 'dart:math' as math;

abstract final class CustomCurves {

  static const Curve flipError = _FlipErrorCurve._();
  
}


class _FlipErrorCurve extends Curve {
  const _FlipErrorCurve._();

  // 可调节参数
  static const double _fastPartPercentage = 0.3; // 前面快速部分的百分比
  static const double _speedFactor = 2.0;       // 前面部分的加速系数，越大越快
  static const double _oscillationFrequency = 30.0; // 抖动频率
  static const double _oscillationAmplitude = 0.04; // 抖动幅度
  static const double _oscillationPeakPoint = 0.8;  // 抖动强度峰值位置(0-1)

  @override
  double transformInternal(double t) {
    return _bounce(t);
  }

  double _bounce(double t) {
    // 前30%加速
    if (t <= _fastPartPercentage) {
      // 使用加速系数，让前面更快
      double fastPartValue = t * _speedFactor;
      return fastPartValue;
    } 
    // 后70%持续上升并抖动
    else {
      // 将t映射到0-1范围，用于后70%部分
      double adjustedT = (t - _fastPartPercentage) / (1.0 - _fastPartPercentage);
      
      // 前面快速部分结束时的值
      double fastPartEndValue = _fastPartPercentage * _speedFactor;
      
      // 基础上升曲线 - 从fastPartEndValue上升到1.0
      double remainingValue = 1.0 - fastPartEndValue;
      double baseValue = fastPartEndValue + (adjustedT * remainingValue);
      
      // 添加抖动效果 - 使用正弦函数
      double frequency = _oscillationFrequency;
      double amplitude = _oscillationAmplitude;
      
      // 抖动幅度变化 - 先增强后减弱
      double dampingFactor;
      if (adjustedT < _oscillationPeakPoint) {
        // 前半段抖动逐渐增强
        dampingFactor = adjustedT / _oscillationPeakPoint;
      } else {
        // 后半段抖动逐渐减弱
        dampingFactor = (1.0 - adjustedT) / (1.0 - _oscillationPeakPoint);
      }
      
      // 叠加抖动效果
      double oscillation = amplitude * dampingFactor * math.sin(frequency * adjustedT * math.pi);
      
      return baseValue + oscillation;
    }
  }
}