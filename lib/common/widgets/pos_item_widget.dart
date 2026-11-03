import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 词性选项组件
class PosItemWidget extends StatefulWidget {
  /// 词性组数据
  final PosGroup posGroup;

  /// 项目索引
  final int index;

  /// 选中项回调
  final Function(int index, PosGroup posGroup) onSelected;

  /// 是否选中
  final bool isSelected;

  // 是否需要底边距
  final bool needMargin;

  /// 未审核的图片数量
  final int unreviewedCount;

  const PosItemWidget(
      {Key? key,
      required this.posGroup,
      required this.index,
      required this.onSelected,
      required this.isSelected,
      this.needMargin = false,
      this.unreviewedCount = 0})
      : super(key: key);

  @override
  State<PosItemWidget> createState() => _PosItemWidgetState();
}

class _PosItemWidgetState extends State<PosItemWidget> with SafeSetStateMixin {
  /// 鼠标悬停状态
  bool _isHovering = false;

  /// 设置悬停状态
  void _setHoverState(bool isHovering) {
    if (_isHovering != isHovering) {
      safeSetState(() {
        _isHovering = isHovering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHoverState(true),
      onExit: (_) => _setHoverState(false),
      child: GestureDetector(
        onTap: () => widget.onSelected(widget.index, widget.posGroup),
        child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 12.ww),
            height: 37.wh,
            // 真实的盒子高度需要加margin
            margin: widget.needMargin ? EdgeInsets.only(bottom: 8.wh) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: widget.isSelected ? color_155DFC : (_isHovering ? AppTheme.cBgActive : Colors.transparent),
              borderRadius: BorderRadius.circular(8.ww),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.posGroup.title ?? "",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: widget.isSelected ? AppTheme.cTextPrimary : color_D1D5DC,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 只有当有未审核图片时才显示数量
                if (widget.unreviewedCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.ww, vertical: 2.wh),
                    margin: EdgeInsets.only(left: 8.ww),
                    decoration: BoxDecoration(
                      color: color_FB2C36,
                      borderRadius: BorderRadius.circular(10.ww),
                    ),
                    child: Text(
                      "未审核: ${widget.unreviewedCount}",
                      style: TextStyle(
                        fontSize: 12.wMin,
                        fontWeight: FontWeight.w500,
                        color: widget.isSelected ? Colors.white : Colors.white,
                      ),
                    ),
                  ),
              ],
            )),
      ),
    );
  }
}
