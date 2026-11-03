import 'package:flutter/material.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 图片审核操作按钮组
class ImageModerationActionButtons extends StatefulWidget {
  final ImageModerationType imageModerationType;
  final bool isBatchMode;
  final bool canBatchReview;
  final VoidCallback? onStartReview;
  final VoidCallback onEnterBatchMode;
  final VoidCallback onExitBatchMode;
  final VoidCallback? onAbandonReview;

  const ImageModerationActionButtons({
    Key? key,
    required this.imageModerationType,
    required this.isBatchMode,
    this.canBatchReview = false,
    this.onStartReview,
    required this.onEnterBatchMode,
    required this.onExitBatchMode,
    this.onAbandonReview,
  }) : super(key: key);

  @override
  State<ImageModerationActionButtons> createState() => _ImageModerationActionButtonsState();
}

class _ImageModerationActionButtonsState extends State<ImageModerationActionButtons> with SafeSetStateMixin {
  // 存储各个按钮的悬停状态
  final Map<String, bool> _hoverStates = {};

  @override
  Widget build(BuildContext context) {
    // 批量审核模式下显示按钮
    if (widget.isBatchMode) {
      // 管理员模式下只显示退出批量按钮
      if (widget.imageModerationType == ImageModerationType.review) {
        return _buildButton(
          id: "exit_batch",
          text: "退出批量",
          backgroundColor: color_FF6900,
          onTap: widget.onExitBatchMode,
        );
      }

      // 普通用户模式显示两个按钮：退出批量、放弃审核
      return Row(
        children: [
          _buildButton(
            id: "exit_batch",
            text: "退出批量",
            backgroundColor: color_FF6900,
            onTap: widget.onExitBatchMode,
          ),
          SizedBox(width: 12.ww),
          _buildButton(
            id: "abandon_review",
            text: "放弃审核",
            backgroundColor: color_E7000B,
            onTap: widget.onAbandonReview,
          ),
        ],
      );
    }

    // 非normal状态（管理员模式）始终显示批量审核按钮
    if (widget.imageModerationType == ImageModerationType.review) {
      return _buildButton(
        id: "admin_batch_review",
        text: "批量审核",
        backgroundColor: color_155DFC,
        onTap: widget.onEnterBatchMode,
      );
    }

    // normal状态下，根据 canBatchReview 决定是否显示批量审核按钮
    List<Widget> buttons = [];

    // 只有当 canBatchReview 为 true 时才显示批量审核按钮
    if (widget.canBatchReview) {
      buttons.add(
        _buildButton(
          id: "batch_review",
          text: "批量审核",
          backgroundColor: color_155DFC,
          onTap: widget.onEnterBatchMode,
        ),
      );
    }

    // 添加放弃审核按钮
    if (buttons.isNotEmpty) {
      buttons.add(SizedBox(width: 12.ww));
    }
    buttons.add(
      _buildButton(
        id: "abandon_review",
        text: "放弃审核",
        backgroundColor: color_E7000B,
        onTap: widget.onAbandonReview,
      ),
    );

    // 添加开始审核按钮
    buttons.add(SizedBox(width: 12.ww));
    buttons.add(
      _buildButton(
        id: "start_review",
        text: "开始审核",
        backgroundColor: color_155DFC,
        onTap: widget.onStartReview,
      ),
    );

    return Row(children: buttons);
  }

  /// 构建普通按钮
  Widget _buildButton({
    required String id,
    required String text,
    required Color backgroundColor,
    required VoidCallback? onTap,
  }) {
    // 确保在Map中初始化悬停状态
    _hoverStates[id] ??= false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _updateHoverState(id, true),
      onExit: (_) => _updateHoverState(id, false),
      child: TapScaleWidget(
        onTap: onTap,
        child: Container(
          width: 88.ww,
          height: 68.wh,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hoverStates[id]! ? backgroundColor.withValues(alpha: 0.8) : backgroundColor,
            borderRadius: BorderRadius.circular(8.wMin),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 更新悬停状态
  void _updateHoverState(String id, bool isHovering) {
    if (_hoverStates[id] != isHovering) {
      safeSetState(() {
        _hoverStates[id] = isHovering;
      });
    }
  }
}
