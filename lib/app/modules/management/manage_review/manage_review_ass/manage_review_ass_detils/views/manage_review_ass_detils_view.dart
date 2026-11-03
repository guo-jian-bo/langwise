import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_review_ass_detils_binding.dart';
import '../controllers/manage_review_ass_detils_controller.dart';

class ManageReviewAssDetilsView extends GetView<ManageReviewAssDetilsController> {
  final String tagText;
  const ManageReviewAssDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_ASS_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewAssDetilsView(tagText: tag),
      binding: ManageReviewAssDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_ASS_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Container(),
      bottomNavigationBar: _buildBottomWidget(),
    );
  }



  Widget _buildBottomWidget(){
    return Container(
      padding: EdgeInsets.only(
        left: 40.wMin,
        right: 40.wMin,
        top: 16.wMin,
        bottom: 24.wMin,
      ),
      child: Obx((){
        return Row(
          children: [
      
            SelectableText(
              "任务UID：${controller.assData.value.taskId??''}",
              style: TextStyle(
                fontSize: 14.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 8.wMin),
            Container(width: 1.wMin, height: 20.wMin, color: AppTheme.cBorderPrimary.color),
            SizedBox(width: 8.wMin),
            SelectableText(
              DateFormatUtil.formatStrtoStr(controller.assData.value.started, newPattern: "yyyy-MM-dd HH:mm"),
              style: TextStyle(
                fontSize: 14.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
      
            const Spacer(),
      
            ButtonWidget(
              text: "放弃任务",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cFeedbackErrorBackground.color,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              fontColor: AppTheme.cFeedbackErrorText.color,
              sclae: 1.05,
              onTap: () {
                
              },
            ),

            Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "重新生成字幕",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceInfo.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.05,
                onTap: () {
                  // controller.toReviewAss(data);
                },
              ),
            ),
      
            Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "审核通过并生成翻译",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceSuccess.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  // controller.toReviewAss(data);
                },
              ),
            ),
      
          ],
        );
      }),
    );
  }

}
