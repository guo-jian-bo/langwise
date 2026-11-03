import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../bindings/manage_unified_image_create_binding.dart';
import '../controllers/manage_unified_image_create_controller.dart';
import 'manage_unified_image_create_mode_widget.dart';
import 'manage_unified_image_create_reference_widget.dart';
import 'manage_unified_image_create_setting_widget.dart';
import 'manage_unified_image_create_title_widget.dart';

class ManageUnifiedImageCreateView extends GetView<ManageUnifiedImageCreateController> {
  final String tagText;
  const ManageUnifiedImageCreateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_UNIFIED_IMAGE_CREATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUnifiedImageCreateView(tagText: tag),
      binding: ManageUnifiedImageCreateBinding(tag: tag),
      routeName: Routes.MANAGE_UNIFIED_IMAGE_CREATE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: _buildBodyWidget(),
    );
  }

  Widget _buildBodyWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          ManageUnifiedImageCreateTitleWidget(controller: controller),

          SizedBox(height: 24.wMin),

          Expanded(
            child: Row(
              spacing: 24.wMin,
              children: [
                Expanded(
                  child: Column(
                    spacing: 24.wMin,
                    children: [
                      Expanded(child: ManageUnifiedImageCreateModeWidget(controller: controller)),
                      Expanded(child: ManageUnifiedImageCreateReferenceWidget(controller: controller)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 610.wMin,
                  child: ManageUnifiedImageCreateSettingWidget(controller: controller),
                ),
              ],
            ),
          ),
      
        ],
      ),
    );
  }




}
