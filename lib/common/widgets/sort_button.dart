import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../values/star_colors.dart';

/// 排序按钮组件
///
/// 用于列表页面的排序功能，支持鼠标悬停效果和排序方向指示
class SortButton extends StatefulWidget {
  /// 按钮文本
  final String text;

  /// 是否激活状态
  final bool isActive;

  /// 是否升序
  final bool isAsc;

  /// 点击回调
  final VoidCallback onTap;

  /// 按钮宽度
  final double? width;

  /// 按钮高度
  final double? height;

  /// 激活状态下的背景颜色
  final Color? activeBackgroundColor;

  /// 非激活状态下的背景颜色
  final Color? inactiveBackgroundColor;

  /// 边框颜色，默认为空（无边框）
  final Color? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 圆角半径
  final double? borderRadius;

  /// 文本样式
  final TextStyle? textStyle;

  /// 图标颜色，默认为Colors.white
  final Color iconColor;

  const SortButton({
    Key? key,
    required this.text,
    required this.isActive,
    required this.isAsc,
    required this.onTap,
    this.width,
    this.height,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  State<SortButton> createState() => _SortButtonState();
}

class _SortButtonState extends State<SortButton> with SafeSetStateMixin {
  /// 是否鼠标悬停
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // 激活状态下的背景颜色，优先使用自定义颜色
    final activeColor = widget.activeBackgroundColor ?? color_155DFC;

    // 非激活状态下的背景颜色，优先使用自定义颜色
    final inactiveColor = widget.inactiveBackgroundColor ?? color_364153;

    // 根据状态确定按钮颜色
    Color buttonColor =
        widget.isActive ? activeColor : (_isHovering ? Colors.white.withValues(alpha: 0.3) : inactiveColor);

    // 圆角半径，优先使用自定义圆角
    final radius = widget.borderRadius ?? 8.ww;

    // 边框，如果指定了边框颜色则创建边框
    final border = widget.borderColor != null
        ? Border.all(
            color: widget.borderColor!,
            width: widget.borderWidth ?? 1.wMin,
          )
        : null;

    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovering = true),
      onExit: (_) => safeSetState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width,
          height: widget.height ?? 40.wh,
          padding: EdgeInsets.symmetric(horizontal: 12.ww),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: widget.textStyle ??
                    TextStyle(
                      color: Colors.white,
                      fontSize: 14.wMin,
                      fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.w400,
                    ),
              ),
              SizedBox(width: 4.ww),
              // 根据按钮状态和排序方向显示不同的SVG图标
              SvgPicture.asset(
                widget.isActive
                    ? (widget.isAsc ? Assets.imageModerationSortUp : Assets.imageModerationSortDown)
                    : Assets.imageModerationSortDefault,
                width: 14.wMin,
                height: 14.wMin,
                colorFilter: ColorFilter.mode(widget.isActive ? widget.iconColor : Colors.white, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
