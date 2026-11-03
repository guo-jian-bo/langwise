import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 书籍页面项组件
///
/// 展示单个书籍页面，包含页码、图片和操作按钮
class PageItemWidget extends StatelessWidget {
  /// 页面数据模型
  final PageImage pageImage;

  /// 页面索引
  final int index;

  /// 删除回调
  final Function(int)? onDelete;

  /// 构造函数
  const PageItemWidget({
    Key? key,
    required this.pageImage,
    required this.index,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 505.ww,
      padding: EdgeInsets.all(24.ww),
      margin: EdgeInsets.only(right: 32.ww),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(23.wMin),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                height: 64.wh,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.wMin),
                ),
                child: Text(
                  '第 ${index + 1} 页',
                  style: TextStyle(
                    color: const Color(0xffF9F9FA),
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: TapScaleWidget(
                  onTap: OptimizeUtils.noneThrottle(() {
                    onDelete?.call(index);
                  }, 200),
                  child: Container(
                    width: 40.wh,
                    height: 40.wh,
                    margin: EdgeInsets.only(right: 6.ww),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: buildImage(Assets.customCourseTrash),
                  ),
                ),
              ),
            ],
          ),

          Gaps.getHeight(14.wh),
          // 页面图片
          Expanded(
            child: _buildImageWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (pageImage.isNetImageUrl) {
      return CachedImageWidget(pageImage.imageUrl ?? '', // 保证图片按比例填充但不溢出
          fit: BoxFit.contain,
          // width: 146.ww,
          // height: 205.wh,
          borderRadius: BorderRadius.circular(6.wMin),
          errorWidget: buildImage(
            Assets.customCoursePlaceholder,
            // width: 146.ww,
            // height: 205.wh,
          ));
    }

    // 如果文件不存在，直接显示占位图
    if (!pageImage.isUrlExists) {
      return buildImage(
        Assets.customCoursePlaceholder,
        fit: BoxFit.contain,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6.wMin),
      child: buildFileImage(
        pageImage.imageUrl ?? "",
        filterQuality: FilterQuality.medium,
        // 保证图片按比例填充但不溢出
        fit: BoxFit.contain,
        // width: 146.ww,
        // height: 205.wh,
        errorBuilder: ((
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return buildImage(
            Assets.customCoursePlaceholder,
            // width: 146.ww,
            // height: 205.wh,
          );
        }),
      ),
    );
  }
}
