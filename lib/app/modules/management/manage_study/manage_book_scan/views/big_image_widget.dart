import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageBigImageManager {
  static Future<void>? show(
      {required BuildContext context, required WordImageEntity entity, final Function()? onTap}) {
    return Get.dialog<void>(
      GestureDetector(
        // 添加按钮点击区域扩展
        behavior: HitTestBehavior.opaque,
        onTap: OptimizeUtils.noneThrottle(() {
          Get.back();
          onTap?.call();
        }, 200),
        child: BigImageWidget(
          entity: entity,
          onTap: onTap,
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      return value;
    });
  }
}

class BigImageWidget extends StatelessWidget {
  final WordImageEntity entity;
  final Function()? onTap;

  const BigImageWidget({super.key, required this.entity, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
          alignment: const Alignment(0, 0),
          color: const Color(0xff040712).withValues(alpha: 0.8),
          child: _buildImageWidget()),
    );
  }

  Widget _buildImageWidget() {
    if (entity.isUrl) {
      return CachedImageWidget(entity.url ?? '',
          // 保证图片按比例填充但不溢出
          fit: BoxFit.contain,
          height: double.infinity,
          borderRadius: BorderRadius.circular(4.wMin),
          errorWidget: buildImage(
            Assets.customCoursePlaceholder,
            width: 146.ww,
            height: 205.wh,
          ));
    }
    return buildFileImage(
      entity.url ?? "",
      filterQuality: FilterQuality.medium,
      // 保证图片按比例填充但不溢出
      fit: BoxFit.contain,
      height: double.infinity,
      errorBuilder: ((
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return buildImage(
          Assets.customCoursePlaceholder,
          width: 146.ww,
          height: 205.wh,
        );
      }),
    );
  }
}
