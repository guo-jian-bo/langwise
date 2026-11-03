import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';

/// 拍照按钮组件
///
/// 一个美观的圆形拍照按钮，带有点击动画效果
/// 支持自定义大小和点击回调
class TakePhotoButton extends StatelessWidget {
  /// 创建拍照按钮组件
  ///
  /// [onTap] 点击回调函数
  /// [size] 按钮大小，默认80像素
  /// [borderColor] 边框颜色，默认蓝色
  /// [backgroundColor] 背景颜色，默认黑色
  /// [foregroundColor] 前景颜色，默认白色
  /// [padding] 边框与内容间的内边距
  /// [enableHapticFeedback] 是否启用震动反馈，默认启用
  const TakePhotoButton({
    super.key,
    required this.onTap,
    this.size = 98.0,
    this.borderColor = const Color(0xFF00A1D6),
    this.backgroundColor = Colors.black,
    this.foregroundColor = const Color(0xFFF2F4F9),
    this.padding = 0,
    this.borderWidth = 1.0,
    this.enableHapticFeedback = true,
  });

  /// 点击回调函数
  final VoidCallback onTap;

  /// 按钮大小
  final double size;

  /// 边框颜色
  final Color borderColor;

  /// 背景颜色
  final Color backgroundColor;

  /// 前景颜色
  final Color foregroundColor;

  /// 内边距
  final double padding;

  /// 边框宽度
  final double borderWidth;

  /// 是否启用震动反馈
  final bool enableHapticFeedback;

  @override
  Widget build(BuildContext context) {
    // 创建拍照按钮
    return TapScaleWidget(
      onTap: () {
        if (enableHapticFeedback) {
          HapticFeedback.mediumImpact(); // 触发中等强度的震动
        }
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}
