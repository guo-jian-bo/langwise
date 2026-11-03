import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:bot_toast/bot_toast.dart';

/// 显示按钮上方的下拉菜单
///
/// 用法示例:
/// ```dart
/// ButtonDropdownMenu.show<String>(
///   context: context,
///   options: ['Option 1', 'Option 2', 'Option 3'],
///   labelBuilder: (option) => option,
///   selectedIndex: 0,
///   onSelected: (index, option) {
///     print('Selected: $option at index $index');
///   },
///   anchorKey: buttonKey,
/// );
/// ```
void showButtonDropdownMenu<T>({
  required BuildContext context,
  required List<T> options,
  required String Function(T option) labelBuilder,
  required int selectedIndex,
  required Function(int index, T option) onSelected,
  required GlobalKey anchorKey,
  double? width,
  double? height,
  double? maxHeight,
  Color backgroundColor = const Color(0xFF1D2939),
  Color borderColor = const Color(0xFF4A5565),
  double borderRadius = 8.0,
  double itemHeight = 40.0,
  Color hoverColor = const Color(0xFF155DFC),
  Color selectedColor = Colors.transparent,
  Color textColor = Colors.white,
  Color selectedTextColor = Colors.white,
}) {
  // 获取按钮位置和尺寸
  final RenderBox? renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final size = renderBox.size;
  final Offset globalPosition = renderBox.localToGlobal(Offset.zero);

  // 计算弹框宽度
  final dropdownWidth = width ?? size.width;

  // 计算弹框位置
  final double left = globalPosition.dx;
  final double top = globalPosition.dy - size.height * 0.3;

  // 创建两个Overlay入口
  OverlayEntry? backdropEntry;
  OverlayEntry? menuEntry;

  // 关闭菜单的函数
  void closeMenu() {
    backdropEntry?.remove();
    menuEntry?.remove();
  }

  // 处理选择项目
  void handleSelect(int index, T option) {
    onSelected(index, option);
    closeMenu();
  }

  // 安全检查并添加入口到Overlay
  try {
    final overlay = Overlay.of(context);
    if (overlay.mounted) {
      // 创建背景遮罩层
      backdropEntry = OverlayEntry(
        builder: (context) {
          return Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: closeMenu,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          );
        },
      );

      // 创建菜单层
      menuEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: ButtonDropdownMenu<T>(
                options: options,
                labelBuilder: labelBuilder,
                selectedIndex: selectedIndex,
                onSelected: handleSelect,
                anchorKey: anchorKey,
                width: dropdownWidth,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                borderRadius: borderRadius,
                itemHeight: itemHeight,
                hoverColor: hoverColor,
                selectedColor: selectedColor,
                textColor: textColor,
                selectedTextColor: selectedTextColor,
              ),
            ),
          );
        },
      );

      // 先插入背景层，再插入菜单层，确保菜单在上层
      overlay.insert(backdropEntry);
      overlay.insert(menuEntry);
    }
  } catch (e) {
    debugPrint('Error inserting overlay entries: $e');
  }
}

/// 按钮上方的下拉菜单组件
///
/// 该组件用于在按钮上方显示一个下拉菜单，支持选项选中、鼠标悬停效果等功能。
/// 通常不直接使用该组件，而是通过 [showButtonDropdownMenu] 函数显示。
class ButtonDropdownMenu<T> extends StatefulWidget {
  /// 选项列表
  final List<T> options;

  /// 选项文本构建器
  final String Function(T option) labelBuilder;

  /// 当前选中的索引
  final int selectedIndex;

  /// 选项选择回调
  final Function(int index, T option) onSelected;

  /// 弹框位置
  final GlobalKey? anchorKey;

  /// 弹框宽度
  final double? width;

  /// 弹框高度
  final double? height;

  /// 弹框最大高度
  final double? maxHeight;

  /// 弹框背景色
  final Color backgroundColor;

  /// 弹框边框颜色
  final Color borderColor;

  /// 弹框圆角
  final double borderRadius;

  /// 选项高度
  final double itemHeight;

  /// 选项悬停颜色
  final Color hoverColor;

  /// 选项选中颜色
  final Color selectedColor;

  /// 选项文本颜色
  final Color textColor;

  /// 选项选中文本颜色
  final Color selectedTextColor;

  /// 取消回调
  final Function? onCancel;

  const ButtonDropdownMenu({
    Key? key,
    required this.options,
    required this.labelBuilder,
    required this.selectedIndex,
    required this.onSelected,
    this.anchorKey,
    this.width,
    this.height,
    this.maxHeight,
    this.backgroundColor = const Color(0xFF1D2939),
    this.borderColor = const Color(0xFF4A5565),
    this.borderRadius = 8.0,
    this.itemHeight = 40.0,
    this.hoverColor = const Color(0xFF155DFC),
    this.selectedColor = Colors.transparent,
    this.textColor = Colors.white,
    this.selectedTextColor = Colors.white,
    this.onCancel,
  }) : super(key: key);

  /// 显示按钮上方的下拉菜单
  static void show<T>({
    required BuildContext context,
    required List<T> options,
    required String Function(T option) labelBuilder,
    required int selectedIndex,
    required Function(int index, T option) onSelected,
    required GlobalKey anchorKey,
    double? width,
    double? height,
    double? maxHeight,
    Color backgroundColor = const Color(0xFF1D2939),
    Color borderColor = const Color(0xFF4A5565),
    double borderRadius = 8.0,
    double itemHeight = 40.0,
    Color hoverColor = const Color(0xFF155DFC),
    Color selectedColor = Colors.transparent,
    Color textColor = Colors.white,
    Color selectedTextColor = Colors.white,
  }) {
    showButtonDropdownMenu<T>(
      context: context,
      options: options,
      labelBuilder: labelBuilder,
      selectedIndex: selectedIndex,
      onSelected: onSelected,
      anchorKey: anchorKey,
      width: width,
      height: height,
      maxHeight: maxHeight,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      itemHeight: itemHeight,
      hoverColor: hoverColor,
      selectedColor: selectedColor,
      textColor: textColor,
      selectedTextColor: selectedTextColor,
    );
  }

  /// 使用BotToast在任意位置显示下拉菜单
  ///
  /// 参数:
  /// [context] - 目标组件的BuildContext
  /// [options] - 选项列表
  /// [labelBuilder] - 选项文本构建器
  /// [selectedIndex] - 当前选中的索引
  /// [onSelected] - 选择回调函数
  /// [preferDirection] - 偏好的显示方向，默认为底部中心
  /// [backgroundColor] - 菜单背景颜色
  /// [borderColor] - 菜单边框颜色
  /// [borderRadius] - 菜单圆角
  /// [verticalOffset] - 垂直方向偏移量调整
  /// [horizontalOffset] - 水平方向偏移量调整
  /// [width] - 菜单宽度
  static void showAtPosition<T>({
    required BuildContext context,
    required List<T> options,
    required String Function(T option) labelBuilder,
    required int selectedIndex,
    required Function(int index, T option) onSelected,
    PreferDirection preferDirection = PreferDirection.bottomCenter,
    Color backgroundColor = const Color(0xFF1D2939),
    Color borderColor = const Color(0xFF4A5565),
    double borderRadius = 8.0,
    double verticalOffset = 5.0,
    double horizontalOffset = 0.0,
    double? width,
    double? height,
    double? maxHeight,
    double itemHeight = 40.0,
    Color hoverColor = const Color(0xFF155DFC),
    Color selectedColor = Colors.transparent,
    Color textColor = Colors.white,
    Color selectedTextColor = Colors.white,
  }) {
    // 使用BotToast显示附着式菜单
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: preferDirection,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
      allowClick: false,
      // 确保只有一个菜单显示
      onlyOne: true,
      attachedBuilder: (cancelFunc) {
        return ButtonDropdownMenu<T>(
          options: options,
          labelBuilder: labelBuilder,
          selectedIndex: selectedIndex,
          onSelected: (index, option) {
            cancelFunc();
            onSelected(index, option);
          },
          width: width,
          height: height,
          maxHeight: maxHeight,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderRadius: borderRadius,
          itemHeight: itemHeight,
          hoverColor: hoverColor,
          selectedColor: selectedColor,
          textColor: textColor,
          selectedTextColor: selectedTextColor,
          onCancel: cancelFunc,
        );
      },
    );
  }

  /// 根据GlobalKey显示菜单
  ///
  /// 参数:
  /// [context] - 应用上下文
  /// [key] - 目标组件的GlobalKey
  /// [options] - 选项列表
  /// [labelBuilder] - 选项文本构建器
  /// [selectedIndex] - 当前选中的索引
  /// [onSelected] - 选择回调函数
  /// [preferDirection] - 偏好的显示方向，默认为底部左对齐
  /// [backgroundColor] - 菜单背景颜色
  /// [borderColor] - 菜单边框颜色
  /// [borderRadius] - 菜单圆角
  /// [additionalOffset] - 附加偏移量
  static void showAtKey<T>({
    required BuildContext context,
    required GlobalKey key,
    required List<T> options,
    required String Function(T option) labelBuilder,
    required int selectedIndex,
    required Function(int index, T option) onSelected,
    PreferDirection preferDirection = PreferDirection.bottomLeft,
    Color backgroundColor = const Color(0xFF1D2939),
    Color borderColor = const Color(0xFF4A5565),
    double borderRadius = 8.0,
    Offset? additionalOffset,
    double? width,
    double? height,
    double? maxHeight,
    double itemHeight = 40.0,
    Color hoverColor = const Color(0xFF155DFC),
    Color selectedColor = Colors.transparent,
    Color textColor = Colors.white,
    Color selectedTextColor = Colors.white,
  }) {
    if (key.currentContext == null) return;

    // 获取目标相对于屏幕的位置
    final BuildContext keyContext = key.currentContext!;

    // 使用基本方法显示菜单
    showAtPosition<T>(
      context: keyContext,
      options: options,
      labelBuilder: labelBuilder,
      selectedIndex: selectedIndex,
      onSelected: onSelected,
      preferDirection: preferDirection,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      // 根据additionalOffset调整偏移
      verticalOffset: additionalOffset?.dy ?? 5.0,
      horizontalOffset: additionalOffset?.dx ?? 0.0,
      width: width,
      height: height,
      maxHeight: maxHeight,
      itemHeight: itemHeight,
      hoverColor: hoverColor,
      selectedColor: selectedColor,
      textColor: textColor,
      selectedTextColor: selectedTextColor,
    );
  }

  @override
  State<ButtonDropdownMenu<T>> createState() => _ButtonDropdownMenuState<T>();
}

class _ButtonDropdownMenuState<T> extends State<ButtonDropdownMenu<T>> with SafeSetStateMixin {
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius.ww),
        border: Border.all(
          color: widget.borderColor,
          width: 1.wMin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.options.length, (index) {
            final option = widget.options[index];
            final isSelected = index == widget.selectedIndex;
            final isHovered = index == _hoverIndex;
            return MouseRegion(
              onEnter: (_) => safeSetState(() => _hoverIndex = index),
              onExit: (_) => safeSetState(() => _hoverIndex = null),
              child: GestureDetector(
                onTap: () => widget.onSelected(index, option),
                child: Container(
                  height: widget.itemHeight.wh,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isHovered ? widget.hoverColor : (isSelected ? widget.selectedColor : Colors.transparent),
                    borderRadius: BorderRadius.circular(4.ww),
                  ),
                  padding: EdgeInsets.only(left: 2.ww),
                  margin: EdgeInsets.symmetric(horizontal: 4.ww, vertical: 2.wh),
                  child: Row(
                    children: [
                      // 对勾占位区域，保持布局稳定
                      SizedBox(
                        width: 16.ww,
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: widget.selectedTextColor,
                                size: 16.ww,
                              )
                            : null,
                      ),
                      Gaps.getWidth(2.ww),
                      Expanded(
                        child: Text(
                          widget.labelBuilder(option),
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: isSelected || isHovered ? widget.selectedTextColor : widget.textColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
