import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:bot_toast/bot_toast.dart';

import '../values/values.dart';

class KnowledgeItemWidget extends StatefulWidget {
  final int index;
  final Knowledge knowledge;
  final bool showDelIcon;
  final double? width;
  final double? height;
  final Function(int, Knowledge)? onTap;
  final Function(int, Knowledge)? onDeleteTap;

  const KnowledgeItemWidget(
      {super.key,
      required this.index,
      required this.knowledge,
      this.showDelIcon = false,
      this.width,
      this.height,
      this.onTap,
      this.onDeleteTap});

  @override
  State<KnowledgeItemWidget> createState() => _KnowledgeItemWidgetState();
}

class _KnowledgeItemWidgetState extends State<KnowledgeItemWidget> {
  final GlobalKey _contentKey = GlobalKey();
  CancelFunc? _cancelTooltip;
  bool _isHovering = false;

  /// 显示内容浮层
  void _showContentTooltip() {
    if (!_isHovering || _cancelTooltip != null) return;

    _cancelTooltip = BotToast.showAttachedWidget(
      targetContext: _contentKey.currentContext!,
      preferDirection: PreferDirection.topCenter,
      attachedBuilder: (cancel) => Container(
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            color: color_1E2939,
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.knowledge.newContent,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffF2F4F9),
                  letterSpacing: 0.08,
                  height: 1,
                ),
              ),
              SizedBox(height: 10.wMin),
              Text(
                widget.knowledge.chineseGlossTitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xffD8DDE8),
                  letterSpacing: 0.072,
                  height: 1,
                ),
              ),
            ],
          )),
    );
  }

  /// 隐藏内容浮层
  void _hideContentTooltip() {
    _cancelTooltip?.call();
    _cancelTooltip = null;
  }

  @override
  void dispose() {
    _hideContentTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        widget.onTap?.call(widget.index, widget.knowledge);
      }, 100),
      sclae: 1.05,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      color: Colors.white.withValues(alpha: 0.1),
                      child: CachedImageWidget(widget.knowledge.imageUrl ?? '',
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: buildLoadingWidget(),
                          errorWidget: buildImage(Assets.managerImageNotFound,
                              width: double.infinity, height: double.infinity, fit: BoxFit.contain)),
                    ),
                    Positioned(
                      left: 8.wMin,
                      top: 8.wMin,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 难度等级组件
                          StatusTagDifficultyWidget(
                            difficulty: widget.knowledge.difficulty,
                            language: widget.knowledge.language,
                          ),
                          // 如果有难度值，显示在难度等级下面；如果没有难度值，显示在难度等级位置
                          if (widget.knowledge.difficulty != null) ...[
                            Gaps.getHeight(6.wMin),
                            Container(
                              width: 100.wMin,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 5.wMin, bottom: 5.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: const Color(0xff2388FF),
                              ),
                              child: Text(
                                "${widget.knowledge.styleCount ?? 0} 图片风格",
                                style: TextStyle(
                                  fontSize: 13.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xffF2F4F9),
                                  letterSpacing: 0.08,
                                  height: 1,
                                ),
                              ),
                            ),
                            Gaps.getHeight(6.wMin),
                            Container(
                              width: 100.wMin,
                              padding: EdgeInsets.only(top: 5.wMin, bottom: 5.wMin),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: color_00C950,
                              ),
                              child: Text(
                                "${widget.knowledge.availableImageCount ?? 0}  可用图片",
                                style: TextStyle(
                                  fontSize: 13.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xffF2F4F9),
                                  letterSpacing: 0.08,
                                  height: 1,
                                ),
                              ),
                            ),
                          ] else ...[
                            // 如果没有难度值，将标签放在难度等级的位置
                            Gaps.getHeight(6.wMin),
                            Container(
                              width: 100.wMin,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 5.wMin, bottom: 5.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: const Color(0xff2388FF),
                              ),
                              child: Text(
                                "${widget.knowledge.styleCount ?? 0} 图片风格",
                                style: TextStyle(
                                  fontSize: 13.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xffF2F4F9),
                                  letterSpacing: 0.08,
                                  height: 1,
                                ),
                              ),
                            ),
                            Gaps.getHeight(6.wMin),
                            Container(
                              width: 100.wMin,
                              padding: EdgeInsets.only(top: 5.wMin, bottom: 5.wMin),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.wMin),
                                color: color_00C950,
                              ),
                              child: Text(
                                "${widget.knowledge.availableImageCount ?? 0}  可用图片",
                                style: TextStyle(
                                  fontSize: 13.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xffF2F4F9),
                                  letterSpacing: 0.08,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.showDelIcon)
                      Positioned(
                        right: 5.wMin,
                        top: 5.wMin,
                        child: GestureDetector(
                          key: widget.knowledge.deleteButtonKey,
                          onTap: () {
                            widget.onDeleteTap?.call(widget.index, widget.knowledge);
                          },
                          child: Container(
                            width: 18.wMin,
                            height: 18.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.wMin),
                              color: const Color(0xff19213D),
                            ),
                            child: buildImage(Assets.managerClose, width: 18.wMax, height: 18.wMax),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 8.wMin,
                      bottom: 8.wMin,
                      child: Container(
                        width: 24.wMin,
                        height: 24.wMin,
                        padding: EdgeInsets.all(5.wMin),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff08AFE6),
                        ),
                        child: SvgPicture.asset("assets/svg/public/icon_speaker.svg"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.wMin),
            MouseRegion(
              key: _contentKey,
              onEnter: (_) {
                _isHovering = true;
                _showContentTooltip();
              },
              onExit: (_) {
                _isHovering = false;
                _hideContentTooltip();
              },
              child: Text(
                widget.knowledge.newContent,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffF2F4F9),
                  letterSpacing: 0.08,
                  height: 1,
                ),
              ),
            ),
            SizedBox(height: 2.wMin),
            Text(
              widget.knowledge.chineseGlossTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: const Color(0xffD8DDE8),
                letterSpacing: 0.072,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
