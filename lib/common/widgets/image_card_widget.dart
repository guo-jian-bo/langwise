import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../values/values.dart';

/// 图片卡片组件
class ImageCardWidget extends StatefulWidget {
  /// 图片数据
  final ImageItem image;

  /// 点击回调
  final Function(ImageItem image) onTap;

  /// 是否处于批量模式
  final bool isBatchMode;

  /// 审核图片文本（悬停时显示）
  final String? reviewText;

  const ImageCardWidget({
    Key? key,
    required this.image,
    required this.onTap,
    this.isBatchMode = false,
    this.reviewText,
  }) : super(key: key);

  @override
  State<ImageCardWidget> createState() => _ImageCardWidgetState();
}

class _ImageCardWidgetState extends State<ImageCardWidget> with AutomaticKeepAliveClientMixin, SafeSetStateMixin {
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
    super.build(context);
    // 边框颜色基于星级评分
    final borderColor = widget.image.borderColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHoverState(true),
      onExit: (_) => _setHoverState(false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.image),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: 5.wMin,
            ),
            borderRadius: BorderRadius.circular(8.wMin),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.wMin),
            child: Stack(
              children: [
                // 图片 - 悬停时放大，使用Hero动画
                Positioned.fill(
                  child: Hero(
                    // 使用与ImageReviewDialog相同的tag格式，确保动画连贯性
                    tag: 'image_${widget.image.imageId}',
                    // 使用Material包裹，确保动画效果更平滑
                    child: AnimatedScale(
                      // 批量模式下也添加鼠标悬停放大效果
                      scale: _isHovering ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: CachedImageWidget(
                        widget.image.imageUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: buildLoadingWidget(),
                        errorWidget: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40.ww,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 批量模式下显示选中状态
                if (widget.isBatchMode)
                  Positioned(
                    top: 8.wh,
                    right: 8.ww,
                    child: Container(
                      width: 26.ww,
                      height: 32.wh,
                      padding: EdgeInsets.only(left: 6.ww, top: 2.wh, right: 6.ww, bottom: 2.wh),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4.wMin),
                      ),
                      child: widget.image.isSelected
                          ? SvgPicture.asset(
                              Assets.imageModerationSelected,
                              width: 18.ww,
                              height: 20.wh,
                            )
                          : SvgPicture.asset(
                              Assets.imageModerationWhite,
                              width: 18.ww,
                              height: 20.wh,
                            ),
                    ),
                  ),

                // 悬停时显示审核标签
                if (_isHovering && !widget.isBatchMode)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 6.wh),
                        decoration: BoxDecoration(
                          color: color_155DFC,
                          borderRadius: BorderRadius.circular(8.ww),
                        ),
                        child: Text(
                          widget.reviewText ?? '审核图片',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 底部浮层
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 8.wh),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 地区
                        Text(
                          "${widget.image.localeTitle ?? ''} ${widget.image.styleTitle ?? ''}",
                          style: TextStyle(
                            color: AppTheme.cTextPrimary,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4.wh),
                        // 星星评分 - 使用封装组件
                        StarRatingWidget(
                          litStars: widget.image.imageScore ?? 0,
                          starSize: 14.0,
                          litStarColor: color_FDC700,
                          unlitStarColor: color_D1D5DC,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
