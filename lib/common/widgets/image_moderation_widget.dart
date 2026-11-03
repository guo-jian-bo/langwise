import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ImageModerationWidget extends StatefulWidget {
  final KnowledgePoint item;
  final int index;
  final Function(int, KnowledgePoint) onTap;

  const ImageModerationWidget({super.key, required this.item, required this.index, required this.onTap});

  @override
  State<ImageModerationWidget> createState() => _ImageModerationWidgetState();
}

class _ImageModerationWidgetState extends State<ImageModerationWidget> with SafeSetStateMixin {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovering = true),
      onExit: (_) => safeSetState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          widget.onTap.call(widget.index, widget.item);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(12.ww),
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary,
            borderRadius: BorderRadius.circular(8.ww),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.ww),
            color: _isHovering ? Colors.white.withOpacity(0.2) : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 状态和审核人
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 4.wh),
                  decoration: BoxDecoration(
                    color: widget.item.statusColor,
                    borderRadius: BorderRadius.circular(4.ww),
                  ),
                  child: Text(
                    widget.item.statusTitle ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Gaps.getHeight(4.wh),

              // 标题
              Text(
                widget.item.content ?? '',
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 更新时间
                  Text(
                    '更新: ${widget.item.newUpdate}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.wMin,
                    ),
                  ),
                  Gaps.getWidth(12.ww),
                  Text(
                    widget.item.nickName ?? '',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.wMin,
                    ),
                  ),
                  const Spacer(),
                  // 类型
                  Text(
                    widget.item.knowledgeType.title,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.wMin,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
