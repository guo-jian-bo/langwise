import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 知识点项目组件
///
/// 用于展示单个知识点的卡片组件，包含ID、状态、内容预览和审核信息
class KnowledgePointItemWidget extends StatefulWidget {
  /// 知识点数据
  final KnowledgePoint point;

  /// 点击事件回调
  final Function(KnowledgePoint)? onTap;

  /// 构造函数
  const KnowledgePointItemWidget({
    Key? key,
    required this.point,
    this.onTap,
  }) : super(key: key);

  @override
  State<KnowledgePointItemWidget> createState() => _KnowledgePointItemWidgetState();
}

class _KnowledgePointItemWidgetState extends State<KnowledgePointItemWidget> with SafeSetStateMixin {
  /// 是否悬停
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // 根据悬停状态设置背景色
    final backgroundColor = _isHovering ? Colors.white.withValues(alpha: 0.2) : color_1E2939;

    return MouseRegion(
      onEnter: (_) => _updateHoverState(true),
      onExit: (_) => _updateHoverState(false),
      child: GestureDetector(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.point) : null,
        child: Container(
          key: widget.point.globalKey,
          padding: EdgeInsets.only(left: 16.ww, right: 16.ww, top: 16.wh, bottom: 16.wh),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 知识点ID和状态
              _buildStatusTag(widget.point.statusTitle ?? '', widget.point.statusColor),
              // 知识点内容
              Text(
                widget.point.content ?? '',
                style: TextStyle(color: Colors.white, fontSize: 18.wMin, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.point.typeTitle ?? '',
                style: TextStyle(color: color_99A1AF, fontSize: 12.wMin, fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 审核日期和图片数量
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '审核日期: ${widget.point.newUpdate}',
                    style: TextStyle(color: color_99A1AF, fontSize: 12.wMin, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    '${widget.point.reviewedImageCount ?? 0}/${widget.point.imageCount ?? 0} 张图片',
                    style: TextStyle(color: color_51A2FF, fontSize: 12.wMin, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 更新悬停状态
  void _updateHoverState(bool isHovering) {
    if (_isHovering != isHovering) {
      safeSetState(() {
        _isHovering = isHovering;
      });
    }
  }

  /// 构建状态标签
  Widget _buildStatusTag(String statusTitle, Color statusColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 4.wh),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4.ww),
      ),
      child: Text(
        statusTitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.wMin,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
