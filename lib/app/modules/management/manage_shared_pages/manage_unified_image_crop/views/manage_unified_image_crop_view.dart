import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../bindings/manage_unified_image_crop_binding.dart';
import '../controllers/manage_unified_image_crop_controller.dart';
import 'manage_unified_image_crop_canvas_widget.dart';
import 'manage_unified_image_crop_setting_widget.dart';
import 'manage_unified_image_crop_title_widget.dart';

class ManageUnifiedImageCropView extends GetView<ManageUnifiedImageCropController> {
  final String tagText;
  const ManageUnifiedImageCropView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_UNIFIED_IMAGE_CROP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUnifiedImageCropView(tagText: tag),
      binding: ManageUnifiedImageCropBinding(tag: tag),
      routeName: Routes.MANAGE_UNIFIED_IMAGE_CROP,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            ManageUnifiedImageCropTitleWidget(controller: controller),

            SizedBox(height: 24.wMin),

            Expanded(
              child: Row(
                spacing: 24.wMin,
                children: [
                  Expanded(
                    child: ManageUnifiedImageCropCanvasWidget(controller: controller),
                  ),
                  SizedBox(
                    width: 500.wMin,
                    child: ManageUnifiedImageCropSettingWidget(controller: controller),
                  ),
                ],
              ),
            ),
        
          ],
        ),
      ),
    );
  }
}
