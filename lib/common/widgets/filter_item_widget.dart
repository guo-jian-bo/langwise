// lib/common/widgets/filter_item_widget.dart
import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../values/values.dart';

/// 快速筛选选项组件
class FilterItemWidget extends StatefulWidget {
  /// 筛选标签
  final String label;

  /// 项目索引
  final int index;

  /// 数量
  final int count;

  /// 选中项回调
  final Function(int index) onSelected;

  /// 是否选中
  final bool isSelected;

  const FilterItemWidget({
    Key? key,
    required this.label,
    required this.index,
    required this.count,
    required this.onSelected,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<FilterItemWidget> createState() => _FilterItemWidgetState();
}

class _FilterItemWidgetState extends State<FilterItemWidget> with SafeSetStateMixin {
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
        onTap: () => widget.onSelected(widget.index),
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 8.wh),
            height: 37.wh,
            // 真实的盒子高度需要加margin
            margin: EdgeInsets.only(bottom: 8.wh),
            decoration: BoxDecoration(
              color: widget.isSelected ? color_155DFC : (_isHovering ? AppTheme.cBgActive : Colors.transparent),
              borderRadius: BorderRadius.circular(8.ww),
            ),
            child: Text(
              widget.label + "(${widget.count})",
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: widget.isSelected ? AppTheme.cTextPrimary : color_D1D5DC,
              ),
            )),
      ),
    );
  }
}
