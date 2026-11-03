import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../values/star_colors.dart';

/// 释义选项组件
class GlossItemWidget extends StatefulWidget {
  /// 释义数据
  final GlossItem gloss;

  /// 项目索引
  final int index;

  /// 是否选中
  final bool isSelected;

  // 是否需要底边距
  final bool needMargin;

  /// 选中项回调
  final Function(int index, GlossItem gloss) onSelected;

  const GlossItemWidget(
      {Key? key,
      required this.gloss,
      required this.index,
      required this.isSelected,
      required this.onSelected,
      this.needMargin = false})
      : super(key: key);

  @override
  State<GlossItemWidget> createState() => _GlossItemWidgetState();
}

class _GlossItemWidgetState extends State<GlossItemWidget> with SafeSetStateMixin {
  /// 鼠标悬停状态
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final identifier = widget.gloss.difficulty ?? '';
    // 从释义项中获取未审核数量（stars为0的图片数量）
    final pendingCount = widget.gloss.pendingCount;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => safeSetState(() => _isHovering = true),
      onExit: (_) => safeSetState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => widget.onSelected(widget.index, widget.gloss),
        child: Container(
          height: 90.wh,
          padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 8.wh),
          // 真实的盒子高度需要加margin
          margin: widget.needMargin ? EdgeInsets.only(bottom: 8.wh) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.isSelected ? color_155DFC : (_isHovering ? AppTheme.cBgActive : Colors.transparent),
            borderRadius: BorderRadius.circular(8.ww),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 标识符（如A1）
                  if (identifier.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.ww, vertical: 4.wh),
                      decoration: BoxDecoration(
                        color: color_2B7FFF,
                        borderRadius: BorderRadius.circular(4.ww),
                      ),
                      child: Text(
                        identifier,
                        style:
                            TextStyle(fontSize: 12.wMin, fontWeight: FontWeight.w400, color: Colors.white, height: 1.0),
                      ),
                    ),
                  if (identifier.isNotEmpty) SizedBox(width: 8.ww),
                  // 释义文本
                  Expanded(
                    child: // 中文释义
                        Text(
                      widget.gloss.definition ?? '',
                      style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: widget.isSelected ? AppTheme.cTextPrimary : color_D1D5DC,
                          height: 1.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.wh),
              Text(
                widget.gloss.semantic ?? '',
                style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w400, color: color_99A1AF, height: 1.0),
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // 未审核数量标签
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 2.wh),
                  decoration: BoxDecoration(
                    color: color_FB2C36,
                    borderRadius: BorderRadius.circular(10.ww),
                  ),
                  child: Text(
                    '未审核: $pendingCount',
                    style: TextStyle(fontSize: 14.wMin, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
