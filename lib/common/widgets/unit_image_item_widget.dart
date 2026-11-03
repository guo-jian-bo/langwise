import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../values/values.dart';

/// 单元图片项组件
///
/// 用于显示单个图片项，包含图片、选择框和信息标签
class UnitImageItemWidget extends StatelessWidget {
  /// 图片数据
  final ImageItem image;

  /// 图片选择回调
  final Function(ImageItem image) onImageSelect;

  /// 图片点击回调（用于预览）
  final Function(ImageItem image, int index)? onImageTap;

  /// 图片在列表中的索引
  final int index;

  const UnitImageItemWidget({
    super.key,
    required this.image,
    required this.onImageSelect,
    required this.index,
    this.onImageTap,
  });

  /// 处理整个视图的点击事件
  void _handleImageTap() {
    onImageTap?.call(image, index);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = image.isSelected;
    return GestureDetector(
       onTap: _handleImageTap,
      child: Stack(
        children: [
        // 图片容器
        AspectRatio(
          aspectRatio: 1,
          child: CachedImageWidget(
            image.imageUrl ?? '',
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(8.wMin),
            placeholder: buildLoadingWidget(),
            errorWidget: buildImage(
              Assets.managerImageNotFound,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // 选择框
        Positioned(
          top: 8.ww,
          left: 8.ww,
          child: GestureDetector(
            // 阻止事件冒泡到父视图
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onImageSelect(image);
            },
            child: Container(
              width: 26.ww,
              height: 32.wh,
              padding: EdgeInsets.only(left: 6.ww, top: 2.wh, right: 6.ww, bottom: 2.wh),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4.wMin),
              ),
              child: isSelected
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
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 地区和风格
                Expanded(
                  child: Text(
                    "${image.localeTitle ?? ''} ${image.styleTitle ?? ''}".trim(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.ww),
                // 星星评分
                StarRatingWidget(
                  litStars: image.imageScore ?? 0,
                  starSize: 10.0,
                  litStarColor: color_FDC700,
                  unlitStarColor: color_D1D5DC,
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
