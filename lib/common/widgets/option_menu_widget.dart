import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 选项菜单管理器
/// 用于统一管理和显示弹出菜单
class OptionMenuManager {
  /// 显示附着式菜单
  /// 参数:
  /// [context] - 目标组件的BuildContext
  /// [items] - 菜单项列表
  /// [preferDirection] - 偏好的显示方向，默认为底部中心
  /// [backgroundColor] - 菜单背景颜色
  /// [borderRadius] - 菜单圆角
  /// [verticalOffset] - 垂直方向偏移量调整
  /// [horizontalOffset] - 水平方向偏移量调整
  static void showMenu({
    required BuildContext context,
    required List<OptionMenuItem> items,
    PreferDirection preferDirection = PreferDirection.bottomCenter,
    Color? backgroundColor,
    double? borderRadius,
    double verticalOffset = 5.0,
    double horizontalOffset = 0.0,
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
        return OptionMenuWidget(
          items: items,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          onCancel: cancelFunc,
        );
      },
    );
  }

  /// 根据GlobalKey显示菜单
  /// 参数:
  /// [context] - 应用上下文
  /// [key] - 目标组件的GlobalKey
  /// [items] - 菜单项列表
  /// [preferDirection] - 偏好的显示方向，默认为底部左对齐
  /// [backgroundColor] - 菜单背景颜色
  /// [borderRadius] - 菜单圆角
  /// [additionalOffset] - 附加偏移量
  static void showAtKey({
    required BuildContext context,
    required GlobalKey key,
    required List<OptionMenuItem> items,
    PreferDirection preferDirection = PreferDirection.bottomLeft,
    Color? backgroundColor = const Color(0xff46494C), 
    double? borderRadius,
    Offset? additionalOffset,
  }) {
    if (key.currentContext == null) return;

    // 获取目标相对于屏幕的位置
    final BuildContext keyContext = key.currentContext!;

    // 使用基本方法显示菜单
    showMenu(
      context: keyContext,
      items: items,
      preferDirection: preferDirection,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      // 根据additionalOffset调整偏移
      verticalOffset: additionalOffset?.dy ?? 5.0,
      horizontalOffset: additionalOffset?.dx ?? 0.0,
    );
  }
}

/// 通用的选项菜单组件
/// 可用于各种需要显示弹出菜单的场景
class OptionMenuWidget extends StatefulWidget {
  /// 菜单选项列表
  final List<OptionMenuItem> items;

  /// 菜单背景颜色
  final Color? backgroundColor;

  /// 菜单圆角半径
  final double? borderRadius;

  /// 菜单关闭回调
  final VoidCallback? onCancel;

  const OptionMenuWidget({
    super.key,
    required this.items,
    this.backgroundColor,
    this.borderRadius,
    this.onCancel,
  });

  @override
  State<OptionMenuWidget> createState() => _OptionMenuWidgetState();
}

class _OptionMenuWidgetState extends State<OptionMenuWidget> with SafeSetStateMixin {
  // 跟踪当前鼠标悬停的菜单项索引
  int hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.wMin),
            color: widget.backgroundColor ?? const Color(0xff19213D).withValues(alpha: 0.5),
            border: Border.all(color: const Color.fromRGBO(68, 75, 95, 0.8), width: 0.5.wMin)),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(widget.items.length, (index) => _buildMenuItem(widget.items[index], index)),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(OptionMenuItem item, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        safeSetState(() {
          hoverIndex = index;
        });
      },
      onExit: (event) {
        safeSetState(() {
          hoverIndex = -1;
        });
      },
      child: TapScaleWidget(
        onTap: () {
          // 关闭菜单
          widget.onCancel?.call();
          // 执行菜单项回调
          item.onTap?.call();
        },
        sclae: 1,
        child: Container(
          height: item.height,
          width: 150.wMin,
          padding: EdgeInsets.all(10.wMin),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: hoverIndex == index ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          ),
          child: Text(
            item.title,
            style: item.textStyle ??
                TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEFF5),
                ),
          ),
        ),
      ),
    );
  }
}

/// 菜单选项项
class OptionMenuItem {
  /// 选项文本
  final String title;

  /// 选项图标
  final Widget? icon;

  /// 点击回调
  final VoidCallback? onTap;

  /// 文本样式
  final TextStyle? textStyle;

  /// 选项高度
  final double? height;

  /// 创建选项菜单项
  /// [title] 选项文本
  /// [icon] 选项图标（可选）
  /// [onTap] 点击回调
  /// [textStyle] 文本样式
  /// [height] 选项高度
  const OptionMenuItem({
    required this.title,
    this.icon,
    this.onTap,
    this.textStyle,
    this.height,
  });
}
