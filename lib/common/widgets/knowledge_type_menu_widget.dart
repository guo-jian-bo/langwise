import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:langwise/common/values/tag_type.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 知识类型菜单组件
class KnowledgeTypeMenuWidget extends StatefulWidget {
  /// 可选的类型列表
  final List<KnowledgeType> types;

  /// 选择回调函数
  final Function(KnowledgeType, int)? onSelected;

  /// 菜单背景颜色
  final Color? backgroundColor;

  /// 菜单圆角半径
  final double? borderRadius;

  /// 菜单关闭回调
  final VoidCallback? onCancel;

  const KnowledgeTypeMenuWidget({
    super.key,
    this.types = const [],
    this.onSelected,
    this.backgroundColor,
    this.borderRadius,
    this.onCancel,
  });

  @override
  State<KnowledgeTypeMenuWidget> createState() => _KnowledgeTypeMenuWidgetState();
}

class _KnowledgeTypeMenuWidgetState extends State<KnowledgeTypeMenuWidget> with SafeSetStateMixin {
  // 跟踪当前鼠标悬停的菜单项索引
  int hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    // 如果没有传入types，则使用所有ScanWordType值
    final typesList = widget.types.isEmpty ? KnowledgeType.values : widget.types;

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

  Widget _buildMenuItem(KnowledgeType type, int index) {
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
          width: (160 - 28).ww,
          padding: EdgeInsets.all(10.wMin),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.wMin),
            color: hoverIndex == index ? Colors.white.withValues(alpha: 0.05) : Color(0xff2F364C),
          ),
          child: Text(
            type.title,
            style: TextStyle(
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

/// 知识类型菜单管理器
class KnowledgeTypeMenuManager {
  /// 显示附着式菜单
  /// 参数:
  /// [context] - 目标组件的BuildContext
  /// [onSelected] - 选择回调函数
  /// [types] - 可选的类型列表，默认为所有KnowledgeType
  /// [preferDirection] - 偏好的显示方向，默认为底部中心
  /// [backgroundColor] - 菜单背景颜色
  /// [borderRadius] - 菜单圆角
  /// [verticalOffset] - 垂直方向偏移量调整
  /// [horizontalOffset] - 水平方向偏移量调整
  static void showMenu({
    required BuildContext context,
    Function(KnowledgeType, int)? onSelected,
    List<KnowledgeType>? types,
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
        return KnowledgeTypeMenuWidget(
          types: types ?? KnowledgeType.values,
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

  /// 根据GlobalKey显示菜单
  /// 参数:
  /// [context] - 应用上下文
  /// [key] - 目标组件的GlobalKey
  /// [onSelected] - 选择回调函数
  /// [types] - 可选的类型列表，默认为所有KnowledgeType
  /// [preferDirection] - 偏好的显示方向，默认为底部左对齐
  /// [backgroundColor] - 菜单背景颜色
  /// [borderRadius] - 菜单圆角
  /// [additionalOffset] - 附加偏移量
  static void showAtKey({
    required BuildContext context,
    required GlobalKey key,

    /// 选择回调函数
    final Function(KnowledgeType, int)? onSelected,
    List<KnowledgeType>? types,
    PreferDirection preferDirection = PreferDirection.bottomLeft,
    Color? backgroundColor,
    double? borderRadius,
    Offset? additionalOffset,
  }) {
    if (key.currentContext == null) return;

    // 获取目标相对于屏幕的位置
    final BuildContext keyContext = key.currentContext!;

    // 使用基本方法显示菜单
    showMenu(
      context: keyContext,
      onSelected: onSelected,
      types: types,
      preferDirection: preferDirection,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      // 根据additionalOffset调整偏移
      verticalOffset: additionalOffset?.dy ?? 5.0,
      horizontalOffset: additionalOffset?.dx ?? 0.0,
    );
  }
}
