import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/values/tag_type.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 扫描词类型菜单管理器
/// 用于统一管理和显示扫描词类型弹出菜单
class ScanWordTypeMenuManager {
  /// 显示附着式菜单
  /// 参数:
  /// [context] - 目标组件的BuildContext
  /// [onSelected] - 选择回调函数
  /// [onSelectedIndex] - 选择索引回调函数
  /// [types] - 可选的类型列表，默认为所有ScanWordType
  /// [preferDirection] - 偏好的显示方向，默认为底部中心
  /// [backgroundColor] - 菜单背景颜色
  /// [borderRadius] - 菜单圆角
  /// [verticalOffset] - 垂直方向偏移量调整
  /// [horizontalOffset] - 水平方向偏移量调整
  static void showMenu({
    required BuildContext context,
    Function(ScanWordType, int)? onSelected,
    List<ScanWordType>? types,
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
        return ScanWordTypeMenuWidget(
          types: types ?? ScanWordType.values,
          onSelected: onSelected != null
              ? (type, index) {
                  cancelFunc();
                  onSelected(type, index);
                }
              : null,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          onCancel: cancelFunc,
        );
      },
    );
  }
}

/// 扫描词类型菜单组件
/// 显示指定的ScanWordType选项的菜单
class ScanWordTypeMenuWidget extends StatefulWidget {
  /// 可选的类型列表
  final List<ScanWordType> types;

  /// 选择回调函数
  final Function(ScanWordType, int)? onSelected;

  /// 菜单背景颜色
  final Color? backgroundColor;

  /// 菜单圆角半径
  final double? borderRadius;

  /// 菜单关闭回调
  final VoidCallback? onCancel;

  const ScanWordTypeMenuWidget({
    super.key,
    this.types = const [],
    this.onSelected,
    this.backgroundColor,
    this.borderRadius,
    this.onCancel,
  });

  @override
  State<ScanWordTypeMenuWidget> createState() => _ScanWordTypeMenuWidgetState();
}

class _ScanWordTypeMenuWidgetState extends State<ScanWordTypeMenuWidget> with SafeSetStateMixin {
  // 跟踪当前鼠标悬停的菜单项索引
  int hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    // 如果没有传入types，则使用所有ScanWordType值
    final typesList = widget.types.isEmpty ? ScanWordType.values : widget.types;

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
              children: List.generate(
                typesList.length,
                (index) => _buildMenuItem(typesList[index], index),
              ),
            ),
          )),
    );
  }

  Widget _buildMenuItem(ScanWordType type, int index) {
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

          // 执行选择回调
          if (widget.onSelected != null) {
            widget.onSelected!(type, index);
          }
        },
        child: Container(
          height: 40.wh,
          width: (160).ww,
          padding: EdgeInsets.all(10.wMin),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.wMin),
            color: hoverIndex == index ? Colors.white.withValues(alpha: 0.05) : Color(0xff2F364C),
          ),
          child: Row(
            children: [
              Container(
                width: 12.ww,
                height: 12.wh,
                decoration: BoxDecoration(
                  color: type.textColor,
                  borderRadius: BorderRadius.circular(6.wMin),
                ),
              ),
              SizedBox(width: 8.ww),
              Text(
                type.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.wMin,
                  color: const Color(0xffEBEFF5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
