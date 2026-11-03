import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_storyboard_workbench_binding.dart';
import '../controllers/manage_storyboard_workbench_controller.dart';
import 'manage_storyboard_workbench_image_widget.dart';
import 'manage_storyboard_workbench_prompt_widget.dart';
import 'manage_storyboard_workbench_result_widget.dart';
import 'manage_storyboard_workbench_title_widget.dart';

class ManageStoryboardWorkbenchView extends GetView<ManageStoryboardWorkbenchController> {
  final String tagText;
  const ManageStoryboardWorkbenchView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_STORYBOARD_WORKBENCH}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageStoryboardWorkbenchView(tagText: tag),
      binding: ManageStoryboardWorkbenchBinding(tag: tag),
      routeName: Routes.MANAGE_STORYBOARD_WORKBENCH,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: controller.getDetilsData,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            ManageStoryboardWorkbenchTitleWidget(controller: controller),
                
            SizedBox(height: 24.wMin),
                
            Row(
              spacing: 24.wMin,
              children: [
                Expanded(
                  child: ManageStoryboardWorkbenchPromptWidget(controller: controller),
                ),
                Expanded(
                  child: ManageStoryboardWorkbenchImageWidget(controller: controller),
                ),
              ],
            ),

            SizedBox(height: 24.wMin),
                
            ManageStoryboardWorkbenchResultWidget(controller: controller),
        
          ],
        ),
      ),
    );
  }





}
