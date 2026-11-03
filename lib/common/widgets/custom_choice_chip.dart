import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 自定义选择芯片组件
///
/// 提供与系统 ChoiceChip 相似的功能，但增加了鼠标悬停效果
/// 支持自定义选中颜色、未选中颜色、文本样式等
class CustomChoiceChip extends StatefulWidget {
  /// 标签文本
  final String label;

  /// 是否选中
  final bool selected;

  /// 选中状态回调
  final Function(bool) onSelected;

  /// 选中时的背景颜色
  final Color selectedColor;

  /// 未选中时的背景颜色
  final Color backgroundColor;

  /// 鼠标悬停时的背景颜色
  final Color hoverColor;

  /// 选中时的文本颜色
  final Color selectedTextColor;

  /// 未选中时的文本颜色
  final Color unselectedTextColor;

  /// 文本字体大小
  final double fontSize;

  /// 边框圆角
  final double borderRadius;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 构造函数
  const CustomChoiceChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor = const Color(0xFF2196F3), // 默认蓝色
    this.backgroundColor = const Color(0xFFEEEEEE), // 默认浅灰色
    this.hoverColor = const Color(0xFF1976D2), // 默认深蓝色
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black87,
    this.fontSize = 14.0,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  }) : super(key: key);

  @override
  _CustomChoiceChipState createState() => _CustomChoiceChipState();
}

class _CustomChoiceChipState extends State<CustomChoiceChip> with SafeSetStateMixin {
  /// 是否悬停
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // 确定当前背景色
    final backgroundColor = _determineBackgroundColor();

    // 确定当前文本色
    final textColor = widget.selected ? widget.selectedTextColor : widget.unselectedTextColor;

    return MouseRegion(
      onEnter: (_) {
        if (widget.selected) {
          return;
        }
        safeSetState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        safeSetState(() {
          _isHovering = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onSelected(!widget.selected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius.ww),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontSize: widget.fontSize.wMin,
              fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// 根据当前状态确定背景色
  Color _determineBackgroundColor() {
    if (widget.selected) {
      return widget.selectedColor;
    } else {
      return _isHovering ? widget.hoverColor : widget.backgroundColor;
    }
  }
}
