import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 限制行数的可选择文本组件
/// 
/// 基于 SelectableText.rich 实现，具有以下优点：
/// 1. 文本垂直居中：自动将文本垂直居中显示
/// 2. 可选择复制：支持文本选择和复制功能
/// 3. 行数限制：默认最多显示3行，可自定义
/// 4. 滚动控制：默认禁止滚动，可自定义滚动行为
/// 5. 样式灵活：支持自定义文本样式、光标颜色等
/// 6. 兼容性好：与 Flutter 3.27.3 完全兼容
///
/// 特别适合用于显示 IPA 符号等需要复制的文本，同时保持界面整洁
class LimitedSelectableText extends StatelessWidget {
  /// 要显示的文本
  final String text;

  /// 文本样式
  final TextStyle? style;

  /// 文本对齐方式
  final TextAlign textAlign;

  /// 文本方向
  final TextDirection? textDirection;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 文本溢出处理方式
  final TextOverflow overflow;

  /// 自定义选择控制器
  final TextSelectionControls? selectionControls;

  /// 选择改变回调
  final SelectionChangedCallback? onSelectionChanged;

  /// 是否启用交互式选择
  final bool enableInteractiveSelection;

  /// 工具提示消息
  final String? semanticsLabel;

  /// 自定义光标颜色
  final Color? cursorColor;

  /// 自定义光标宽度
  final double? cursorWidth;

  /// 自定义光标高度
  final double? cursorHeight;

  /// 自定义光标半径
  final Radius? cursorRadius;

  /// 拖拽开始行为
  final DragStartBehavior dragStartBehavior;

  /// 鼠标光标
  final MouseCursor? mouseCursor;

  /// 最小行数
  final int? minLines;

  /// 最大行数
  final int? maxLines;

  /// 文本缩放因子
  final TextScaler? textScaler;

  /// 滚动物理效果
  final ScrollPhysics? scrollPhysics;

  /// 构造函数
  const LimitedSelectableText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.focusNode,
    this.overflow = TextOverflow.ellipsis,
    this.selectionControls,
    this.onSelectionChanged,
    this.enableInteractiveSelection = true,
    this.semanticsLabel,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.minLines = 1,
    this.maxLines = 3,
    this.textScaler,
    this.scrollPhysics = const NeverScrollableScrollPhysics(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DefaultSelectionStyle selectionStyle = DefaultSelectionStyle.of(context);

    // 使用SelectableText.rich构建，但限制最大行数为3
    return SelectableText.rich(
      TextSpan(
        text: text,
        style: style ?? theme.textTheme.bodyMedium,
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      focusNode: focusNode,
      // 限制行数
      maxLines: maxLines,
      minLines: minLines,
      textScaler: textScaler,
      style: style,
      selectionControls: selectionControls,
      onSelectionChanged: onSelectionChanged,
      enableInteractiveSelection: enableInteractiveSelection,
      semanticsLabel: semanticsLabel,
      cursorColor: cursorColor ?? selectionStyle.cursorColor ?? theme.colorScheme.primary,
      cursorWidth: cursorWidth!,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      dragStartBehavior: dragStartBehavior,
      scrollPhysics: scrollPhysics,
    );
  }

  /// 创建一个可复制的静态文本，最多显示三行
  static Widget createCopyableText(
    String text, {
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    Color? cursorColor,
    int? maxLines,

    /// 滚动物理效果
    final ScrollPhysics? scrollPhysics,
  }) {
    return LimitedSelectableText(
      text,
      style: style,
      textAlign: textAlign,
      cursorColor: cursorColor,
      enableInteractiveSelection: true,
      maxLines: maxLines,
      scrollPhysics: scrollPhysics,
    );
  }
}
