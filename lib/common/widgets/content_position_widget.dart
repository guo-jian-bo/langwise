import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 内容位置选项组件
class ContentPositionWidget extends StatefulWidget {
  /// 内容位置数据
  final ContentPosition contentPosition;

  /// 项目索引
  final int index;

  /// 选中项回调
  final Function(int index, ContentPosition contentPosition) onSelected;

  /// 是否选中
  final bool isSelected;

  /// 是否需要底边距
  final bool needMargin;

  /// 未审核的图片数量
  final int unreviewedCount;

  /// 构造函数
  ///
  /// [contentPosition] 内容位置数据
  /// [index] 项目索引
  /// [onSelected] 选中项回调
  /// [isSelected] 是否选中
  /// [needMargin] 是否需要底边距，默认为false
  /// [unreviewedCount] 未审核的图片数量，默认为0
  const ContentPositionWidget({
    Key? key,
    required this.contentPosition,
    required this.index,
    required this.onSelected,
    required this.isSelected,
    this.needMargin = false,
    this.unreviewedCount = 0,
  }) : super(key: key);

  @override
  State<ContentPositionWidget> createState() => _ContentPositionWidgetState();
}

class _ContentPositionWidgetState extends State<ContentPositionWidget> with SafeSetStateMixin {
  /// 鼠标悬停状态
  bool _isHovering = false;

  /// 设置悬停状态
  ///
  /// [isHovering] 是否悬停
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
        onTap: () => widget.onSelected(widget.index, widget.contentPosition),
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
                  widget.contentPosition.title ?? "未命名内容",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: widget.isSelected ? AppTheme.cTextPrimary : color_D1D5DC,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 显示已审核图片数量（评分大于4的图片）
              if (reviewedHighScoreCount > 0)
                Container(
                  width: 25.wMin,
                  height: 25.wMin,
                  margin: EdgeInsets.only(left: 8.ww),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color_2B7FFF,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$reviewedHighScoreCount",
                    style: TextStyle(
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
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
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 计算已审核图片数量（imageScore > 3）
  ///
  /// 返回内容位置中评分大于4的图片数量
  int get reviewedHighScoreCount {
    if (widget.contentPosition.images == null) return 0;
    return widget.contentPosition.images!.where((image) => image.imageScore != null && image.imageScore! > 3).length;
  }
}
